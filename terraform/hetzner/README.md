# Nextcloud Talk Backend Mini-Infrastructure for Hetzner

The mini infrastructure will consist of a single VM and two elastic IPs (IPv4 and IPv6 subnet).

## How to bring up and update

```
export TF_VAR_hcloud_token="<insert your Hetzner token>"
export TF_VAR_frontend_domain="ncbackend.my.domain"
export TF_VAR_letsencrypt_mail="mail@my.domain"
export TF_VAR_nc_endpoint="my.nextcloud.servers.domain" //comma-separate if you have multiple ones
export TF_VAR_nc_sharedsecret="<your Nextcloud shared secret>" //the same as in the Nextcloud settings under "Talk"
export TF_VAR_turn_sharedsecret="<your TURN server shared secret>" //the same as in the Nextcloud settings under "Talk"

terraform init
terraform apply
```

The Terraform script will output your IPv4/6 addresses after successful deployment. Create a DNS A and AAAA record with your frontend domain `TF_VAR_frontend_domain` pointing to your Floating IPv4 and IPv6 addresses.

Because these DNS records might not be set up at the beginning, the first deployment might not run, because Let's Encrypt + Certbot cannot generate certificates. In this case, just log via SSH in and restart the services with `cd /opt/app; docker-compose down; docker-compose up -d` as soon as you have validated that your DNS records are now active.

## How to destroy

```
terraform destroy
```

Please beware that the destoy command also brings down your elastic IPs. If you want to bring them up again they might be different than before, so you may have to also set new DNS records.
