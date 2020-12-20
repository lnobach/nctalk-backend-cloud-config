# nctalk-backend-cloud-config

If you have a private Nextcloud server with a weak link (e.g. at home or in an office branch) and want to use Nextcloud Talk with
its default backend, the line might be exhausted by the traffic and your video/audio will start to stutter.
Nextcloud Talk provides a high-performance backend to manage conferencing sessions, which has been 
recently [open-sourced](https://github.com/nextcloud/spreed/issues/3106).
Thus, it might be beneficial to *outsource* your video conferencing sessions to a dedicated cloud server with a strong link,
maintaining full control over your server, and keeping your other Nextcloud services hosted by your own.

This framework automatically spins up a Nextcloud Talk High-Performance Backend instance for personal / small office use in 
a couple of minutes. You need a cloud provider supporting user data (cloud-config) input on VM creation.

This setup is not optimized for horizontal scaling for large installations. Consider using Kubernetes in this case.

This setup is targeted to be up to date on creation, but does not maintain automatic lifecycling of the NC Talk backend and 
dependencies (including security patches) once it is up.
Consider recreating the instance regularly to keep it up to date, which is easy, because it is automated :)

## Microservice inventory

The following services are automatically spun up via docker-compose:

- **spreedbackend**: Spreed signaling backend as provided by [strukturag](https://github.com/strukturag/nextcloud-spreed-signaling).
- **janus**: WebRTC gateway used by spreedbackend. WebRTC port range (20000-20100/udp) exposed to public.
- **nginx**: Reverse proxy for spreedbackend. HTTP(S) exposed to public.
- **nats**: NATS streaming server because required by spreedbackend.
- **coturn** TURN relay. Ports 3478,5349 (TCP/UDP) and 49160-49200 (UDP) exposed to public.

To increase security and trust in the container images provided by me (`lnobach`), all of them are Docker Hub autobuilds 
from GitHub code:

- [lnobach/nginx-certbot](https://hub.docker.com/r/lnobach/nginx-certbot), based on a fork of https://github.com/staticfloat/docker-nginx-certbot
- [lnobach/nextcloud-spreed-signaling](https://hub.docker.com/r/lnobach/nextcloud-spreed-signaling), based on a fork of https://github.com/strukturag/nextcloud-spreed-signaling
- [lnobach/janus-gateway](https://hub.docker.com/r/lnobach/janus-gateway), based on https://github.com/lnobach/janus-docker-builder

## Current shortcomings

- Certificate checking for WebRTC DTLS encryption is currently **disabled**, because the certificates validity checking does not 
correctly work. Note that this [is a general issue of WebRTC DTLS](https://github.com/meetecho/janus-gateway/blob/5ec8568709c483ae89b1aa77e127d14c3b59428c/conf/janus.jcfg.sample.in#L162) and is probably OK for now, but be aware of it. 
- A small fraction of processes still run as root in Docker, which must be improved from a security point of view.

## How to set up - the UI way

- Copy `vars.bash.example` to `vars.bash` and adapt the variables explained there.
- Run `./make.sh` to generate `cloud-config.yaml`.
- Create a new Elastic IP (v4 and v6).
- Let a DNS A and AAAA record point to the Elastic IP.
- Create a new VM with a CentOS 8 image and supply the content of `cloud-config.yaml` as user data. 
**SSH public key authentication will be enforced.**
- Assign the Elastic IP to your VM.
- Wait a couple of minutes.
- Under the settings in your Nextcloud instance, open the *Talk* tabs, enter the URL `https://<domainname>/standalone-signaling` and 
enter your secret key.
- Enjoy your Nextcloud Talk backend via Web using your DNS name :)

## How to set up - the Terraform way

There are Terraform implementations available.
See `terraform/<provider>/README.md` for details.

- [hetzner - Hetzner Cloud](./terraform/hetzner)

## How to tell Nextcloud to use your new backend

- Under *Settings*, go to the *Talk* section.
- Create a new STUN server `<domainname>:5349`. You can optionally delete the others.
- Create a new TURN server `<domainname>:5349` and enter your TURN shared secret as previously chosen in the variables (variable `turn_sharedsecret`).
- Enter the data of the signaling server:
  - `https://<domainname>/standalone-signaling`
  - Enable checking of the SSL certificate
  - Enter the shared secret (variable `nc_sharedsecret`).

## Troubleshooting and Insights

- You can log in via SSH to your box (root) and follow the cloud-init output during setup with
`tail -f /var/log/messages | grep cloud-init`.
- If something beyond cloud-init is not working, try to check the log output of docker-compose first with
`ssh -t root@<ip> "cd /opt/app; docker-compose logs --tail=100 -f`.
- It is recommended to have an Elastic IP in place to keep the public address if instances are
recreated. If you don't want to use it, remove the `/opt/app/tools/set_elastic_address` execution
from your cloud-config.
