# Dokolab Homelab

## Introduction
This repo contains my configuration of my homelab.

This is a project I do in my spare time to learn and have fun. I have recently graduated college with a Bachelor's in Computer Science from CSU Los Angeles. My specialty is Cloud Engineering and Kubernetes. My homelab is a place where I can learn and practice with industry standards in my own home.

## Cluster Architecture
I use [Talos Linux](https://www.talos.dev/) for each of my nodes. I have a lot of experience in [NixOS](https://nixos.org/), however setting up a complex kubernetes cluster with NixOS instances is cumbersome and Talos offers lightweight, minimal, and provides production grade security right out of the box. Currently I have a 6 node setup with 3 master nodes and 3 worker nodes.

## Hardware
Currently I use a custom built home server (Ryzen 9 3900x, 64 GB of DDR4 RAM, 64GB SSD for boot, 30TB HDD array for storage) running [Incus](https://linuxcontainers.org/incus/) as a VM Hypervisor running 7 VM instances (6 + 1 TrueNAS).




## Installed Apps & Tools
### Infrastructure
Everything needed to run the cluster
<table>
    <tr>
        <th>Logo</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/cert-manager.svg"></td>
        <td><a href="https://cert-manager.io/">Cert Manager</a></td>
        <td>X.509 certificate management for Kubernetes.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/cilium.svg"></td>
        <td><a href="https://cilium.io/">Cilium</a></td>
        <td>My CNI flavor. eBPF-based Networking, Observability, Security</td>
    </tr>
    <tr>
        <td><img width="32" src="https://is1-ssl.mzstatic.com/image/thumb/Purple221/v4/cd/61/dc/cd61dce4-ab78-64b0-95cc-14bd9dc3b11f/AppIcon-0-0-85-220-0-0-4-0-2x-0-0-0.png/1200x630bb.png"></td>
        <td><a href="https://developers.cloudflare.com/cloudflare-one/">Tailscale</a></td>
        <td>Used to expose public services (without using Public IPs) on my mesh VPN network.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/postgresql.svg"></td>
        <td><a href="https://cloudnative-pg.io/">CloudNativePG</a></td>
        <td>Database operator for running PostgreSQL clusters.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://marketplace-assets.digitalocean.com/logos/hashicorpvault.svg"></td>
        <td><a href="https://www.hashicorp.com/en/products/vault">Vault</a></td>
        <td>Used as a local key/value secret store.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://www.svgrepo.com/download/477066/lock.svg"></td>
        <td><a href="https://external-secrets.io/latest/">External Secrets Operator</a></td>
        <td>Used to sync my secrets from my Vault to my cluster.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/flux-cd.svg"></td>
        <td><a href="https://fluxcd.io/">Flux CD</a></td>
        <td>My GitOps solution of choice. Better than Argo.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/grafana.svg"></td>
        <td><a href="https://grafana.com/">Grafana</a></td>
        <td>The open observability platform.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/prometheus.svg"></td>
        <td><a href="https://prometheus.io/">Prometheus</a></td>
        <td>An open-source monitoring system with a dimensional data model, flexible query language, efficient time series database and modern alerting approach.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://www.svgrepo.com/show/414732/democracy-esteem-regard.svg"></td>
        <td><a href="https://github.com/democratic-csi/democratic-csi">Democratic CSI Driver</a></td>
        <td>Used to provision Persistent Volumes directly on my TrueNAS.</td>
    </tr>
        <tr>
        <td><img width="32" src="https://avatars.githubusercontent.com/u/17888862?s=48&v=4"></td>
        <td><a href="https://github.com/intel/intel-device-plugins-for-kubernetes">Intel Device Plugins</a></td>
        <td>Used to expose my Arc A310 GPU to the cluster.</td>
    </tr>
</table>

### Apps
User Applications
<table>
    <tr>
        <th>Logo</th>
        <th>Name</th>
        <th>Description</th>
    </tr>
    <tr>
        <td><img width="32" src="https://play-lh.googleusercontent.com/nJsRIdtaot1-FKH3kiRem4kjqUU1-_0hd_64qZH0BgtzUecYfWLCDfpk2nNVul8hOrw"></td>
        <td><a href="https://immich.app/">Immich</a></td>
        <td>Self-hosted photo and video management service.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://dashboard.snapcraft.io/site_media/appmedia/2022/01/jellyfin.png"></td>
        <td><a href="https://jellyfin.org/">Jellyfin</a></td>
        <td>Self-hosted steaming service for my backed up media.</td>
    </tr>
</table>

### Next Steps
Currently this cluster only really has the foundations laid with the infrastructure basically done. I currently plan to add more apps or anything else I get inspired to do.
