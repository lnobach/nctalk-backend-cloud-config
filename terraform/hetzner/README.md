# Nextcloud Talk Backend Mini-Infrastructure for Hetzner

The mini infrastructure will consist of a single VM with v4 and v6 primary addresses and rDNS entries.

## How to bring up and update

```
export TF_VAR_hcloud_token="<insert your Hetzner token>"
export TF_VAR_backend_domain="ncbackend.my.domain"
export TF_VAR_letsencrypt_mail="mail@my.domain"
export TF_VAR_nc_endpoint="my.nextcloud.servers.domain" //comma-separate if you have multiple ones
export TF_VAR_nc_sharedsecret="<your Nextcloud shared secret>" //the same as in the Nextcloud settings under "Talk"
export TF_VAR_turn_sharedsecret="<your TURN server shared secret>" //the same as in the Nextcloud settings under "Talk"

terraform init
terraform apply
```

The Terraform script will output your IPv4/6 addresses after successful deployment.
Currently the Terraform provider does not support setting DNS records, so create a DNS A and AAAA record with your spreed backend's domain `TF_VAR_backend_domain` pointing to your primary IPv4 and IPv6 addresses.

Because the records might not be set up at the beginning, the first deployment might not run, because Let's Encrypt + Certbot cannot generate certificates. In this case, just log via SSH in and restart the services with `cd /opt/app; docker-compose down; docker-compose up -d` as soon as you have validated that your DNS records are now active.

## How to destroy

When destroying the server, you can now preserve your primary IP addresses (at a small monthly fee)
to be able to spin up the server at a later time with the same addresses (then you can also keep your
DNS records the same).
If you want to preserve them this, just destroy the server itself:

```
terraform destroy -target=hcloud_server.vb
```

With a later `terraform apply`, the server will claim the same primary IP addresses again.

If you want to lose your IP addresses, then hit:

```
terraform destroy
```

If you want to now bring the infrastructure up again, the IP addresses might be different, so you may have to also update the DNS records.
