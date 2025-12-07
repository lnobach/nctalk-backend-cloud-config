# nctalk-backend-cloud-config

If you have a private Nextcloud server with a weak link (e.g. at home or in an office branch) and want to use Nextcloud Talk with
its default backend, the line might be exhausted by the traffic and your video/audio will start to stutter.
Nextcloud Talk provides a high-performance backend to manage conferencing sessions, which has been 
[open-sourced](https://github.com/nextcloud/spreed/issues/3106).
Thus, it might be beneficial to *outsource* your video conferencing sessions to a dedicated cloud server with a strong link,
maintaining full control over your server, and keeping your other Nextcloud services hosted by your own.

This framework automatically spins up a Nextcloud Talk High-Performance Backend instance for personal / small office use in 
a couple of minutes. You need a cloud provider supporting user data (cloud-config) input on VM creation.

This setup is not yet optimized for horizontal scaling for large installations, but might be in the future by using load
balancers and extending the Terraform configuration accordingly.

This setup is targeted to be up to date on creation, but does not maintain automatic lifecycling of the NC Talk backend and 
dependencies (including security patches) once it is up.
Consider recreating the instance regularly to keep it up to date, which is easy, because it is automated.

## Microservice inventory

The following services are automatically spun up via docker-compose:

- **spreedbackend**: Spreed signaling backend as provided by [strukturag](https://github.com/strukturag/nextcloud-spreed-signaling).
- **janus**: WebRTC gateway used by spreedbackend. WebRTC port range (20000-20100/udp) exposed to public.
- **nginx**: Reverse proxy for spreedbackend. HTTP(S) exposed to public.
- **nats**: NATS streaming server because required by spreedbackend.
- **coturn** TURN relay. Ports 3478,5349 (TCP/UDP) and 49160-49200 (UDP) exposed to public.

To increase security and trust in the container images provided, all of them are GitHub Actions builds 
from GitHub code:

- [ghcr.io/lnobach/nextcloud-spreed-signaling](https://github.com/lnobach/misc-docker-ci/pkgs/container/nextcloud-spreed-signaling), based on [strukturag/nextcloud-spreed-signaling](https://github.com/strukturag/nextcloud-spreed-signaling),
- [ghcr.io/lnobach/janus-gateway](https://github.com/lnobach/misc-docker-ci/pkgs/container/janus-gateway), based on [lnobach/misc-docker-ci/janus-gateway/Dockerfile](https://github.com/lnobach/misc-docker-ci/blob/master/janus-gateway/Dockerfile).
- [ghcr.io/lnobach/coturn](https://github.com/lnobach/misc-docker-ci/pkgs/container/coturn), based on [lnobach/misc-docker-ci/coturn/Dockerfile](https://github.com/lnobach/misc-docker-ci/blob/master/coturn/Dockerfile).

## Open issues

- Certificate checking for WebRTC DTLS encryption is currently **disabled**, because the certificates validity checking does not 
correctly work. Note that this [is a general issue of WebRTC DTLS](https://github.com/meetecho/janus-gateway/blob/5ec8568709c483ae89b1aa77e127d14c3b59428c/conf/janus.jcfg.sample.in#L162) and is probably OK for now, but be aware of it. 


## How to set up - the Terraform way (recommended)

There are Terraform implementations available.
See `terraform/<provider>/README.md` for details.

- [hetzner - Hetzner Cloud](./terraform/hetzner)

With Terraform, you can set up your infrastructure with just a few variables and commands. This is probably the easiest and most error-free way.

## How to set up - the UI way (not recommended)

- Copy `vars.bash.example` to `vars.bash` and adapt the variables explained there.
- Run `./make.sh` to generate `cloud-config.yaml`.
- Create a new VM with a Rocky Linux 10 image and supply the content of `cloud-config.yaml` as user data.
**SSH public key authentication will be enforced.**
- Set a DNS A and optionally AAAA record to point to the IP address(es) of your VM.
- Wait a couple of minutes.
- Under the settings in your Nextcloud instance, open the *Talk* tabs, enter the URL `https://<domainname>/standalone-signaling` and 
enter your secret key.
- Enjoy your Nextcloud Talk backend via Web using your DNS name.

## How to tell Nextcloud to use your new backend

- Under *Settings*, go to the *Talk* section.
- Create a new STUN server `<domainname>:5349`. You can optionally delete the others.
- Create a new TURN server `<domainname>:5349` and enter your TURN shared secret as previously chosen in the variables (variable `turn_sharedsecret`).
- Enter the data of the signaling server:
  - `https://<domainname>/standalone-signaling`
  - Enable checking of the SSL certificate
  - Enter the shared secret (variable `nc_sharedsecret`).

If you keep the variables for setting up the backend infrastructure, you don't need to repeat this
for every attempt to set up the backend.

## Troubleshooting and Insights

- You can log in via SSH to your box (root) and follow the cloud-init output during setup with
`tail -f /var/log/cloud-init-output.log`.
- If something beyond cloud-init is not working, try to check the log output of docker-compose first with
`ssh -t root@<ip> "cd /opt/app; docker compose logs --tail=100 -f`.

