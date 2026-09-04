# Dokolab Homelab

## Introduction
This repo contains my configuration of my homelab.

This is a project I do in my spare time to learn and have fun. I have recently graduated college with a Bachelor's degree in Computer Science from Cal State LA. My specialty is Cloud Engineering and Kubernetes. My homelab is a place where I can learn and practice with industry standards in my own home.

## Cluster Architecture
I use [Talos Linux](https://www.talos.dev/) for each of my nodes. I have a lot of experience in [NixOS](https://nixos.org/), however setting up a complex kubernetes cluster with NixOS instances is cumbersome and Talos offers lightweight, minimal, and provides production grade security right out of the box. Currently I have a 6 node setup with 3 master nodes and 3 worker nodes.

### Cilium ownership

Cilium `1.20.1` is bootstrapped from the Talos control-plane machine configuration as an inline manifest. Talos owns the kernel-facing and cluster-critical configuration:

```yaml
# Talos machine configuration
machine:
  features:
    kubePrism:
      enabled: true
      port: 7445

cluster:
  network:
    cni:
      name: none
  proxy:
    disabled: true
  inlineManifests:
    - name: cilium
      contents: <Helm-rendered Cilium 1.20.1 core manifest>

---
# Cilium Helm values rendered into the Talos inline manifest
agent: true
operator:
  enabled: true
envoy:
  enabled: true
gatewayAPI:
  enabled: true
  enableAlpn: true
  enableAppProtocol: true
ipam:
  mode: kubernetes
kubeProxyReplacement: true
k8sServiceHost: localhost
k8sServicePort: 7445
cgroup:
  autoMount:
    enabled: false
  hostRoot: /sys/fs/cgroup
securityContext:
  capabilities:
    ciliumAgent:
      - CHOWN
      - KILL
      - NET_ADMIN
      - NET_RAW
      - IPC_LOCK
      - SYS_ADMIN
      - SYS_RESOURCE
      - DAC_OVERRIDE
      - FOWNER
      - SETGID
      - SETUID
    cleanCiliumState:
      - NET_ADMIN
      - SYS_ADMIN
      - SYS_RESOURCE
hubble:
  enabled: true
  relay:
    enabled: true
  ui:
    enabled: true
    service:
      annotations:
        omni-kube-service-exposer.sidero.dev/port: "50080"
        omni-kube-service-exposer.sidero.dev/label: Hubble
l2announcements:
  enabled: true
  leaseDuration: 3s
  leaseRenewDeadline: 1s
  leaseRetryPeriod: 500ms
k8sClientRateLimit:
  qps: 15
  burst: 20
socketLB:
  hostNamespaceOnly: true
```

Flux does not install or configure the Cilium runtime. It owns only the Cilium policies and custom resources stored under `infrastructure/configs/cilium`.
Talos therefore owns the complete Cilium installation, including Hubble Relay/UI, Envoy, the agent, operator, CRDs, shared ConfigMap, RBAC, and TLS Secrets. Flux must not contain a Cilium `HelmRelease` or manage those core resources. Cilium policies applied by Flux are consumed automatically by the Talos-managed Cilium agents.

### Private Gateway API endpoints

Flux configures two Cilium Gateways:

- `apps` uses `192.168.4.200` for `*.home.dokocloud.net` application traffic.
- `telemetry` uses `192.168.4.201` for metrics-only OTLP traffic at `otel.home.dokocloud.net` on ports `4317` and `4318`, plus Carbon plaintext metrics on TCP port `2003`.

Reserve both addresses outside the DHCP pool. On the Technitium DNS server at `192.168.4.51`, create a wildcard record for `*.home.dokocloud.net` pointing to `192.168.4.200`, then create the more-specific `otel.home.dokocloud.net` record pointing to `192.168.4.201`. Clients must trust the root CA used by the `internal-ca-issuer` ClusterIssuer.

LAN clients reach these names by using `192.168.4.51` as their resolver. Tailscale clients resolve through MagicDNS instead, so `home.dokocloud.net` also needs a split-DNS nameserver entry pointing at `192.168.4.51` in the Tailscale admin console.

Each Gateway grants namespace access through its own boolean label, so a namespace can attach routes to both:

| Label | Grants routes on |
| --- | --- |
| `homelab/gateway-apps: "true"` | `apps` (HTTPS `443`) |
| `homelab/gateway-telemetry: "true"` | `telemetry` (OTLP `4317`/`4318`, Carbon `2003`) |

`monitoring` carries both, because Grafana is published on the `apps` Gateway while the OTLP and Carbon receivers stay on `telemetry`.

Hostnames currently routed on the `apps` Gateway:

| Hostname | Namespace | Backend |
| --- | --- | --- |
| `immich.home.dokocloud.net` | `immich` | `immich-server:2283` |
| `actualbudget.home.dokocloud.net`, `actual.home.dokocloud.net` | `actualbudget` | `actualbudget:5006` |
| `homepage.home.dokocloud.net` | `homepage` | `homepage:3000` |
| `grafana.home.dokocloud.net` | `monitoring` | `grafana:80` |

Keep the existing Tailscale exposure during initial rollout. Remove it only after the Gateway resources are programmed, both DNS answers resolve correctly, the wildcard certificate is ready, each application passes an HTTPS request, and the OTLP and Carbon metrics transports have been tested.

## Hardware
The cluster is hosted on bare metal across four Dell Wyse 5070 thin clients:
- CPU: Intel Pentium Silver J5005
- RAM: 8 or 16 GB DDR4 (Worker | Master)
- Storage: 128 GB SATA
- Network: 2.5 GbE NIC




## Installed Apps & Tools
### Infrastructure
Everything needed to run the cluster
<table>
    <tr>
        <th>Logo</th>
        <th>Name</th> <th>Description</th>
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
        <td><img width="32" src="https://external-secrets.io/latest/pictures/eso-round-logo.svg"></td>
        <td><a href="https://external-secrets.io/latest/">External Secrets Operator</a></td>
        <td>Used to sync my secrets from AWS Secret Manager to my cluster.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/svg/flux-cd.svg"></td>
        <td><a href="https://fluxcd.io/">Flux CD</a></td>
        <td>My GitOps solution of choice. Better than Argo.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/grafana.svg"></td>
        <td><a href="https://grafana.com/">Grafana</a></td>
        <td>The open observability platform for building custom dashboards for my cluster.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://cdn.jsdelivr.net/gh/walkxcode/dashboard-icons/svg/prometheus.svg"></td>
        <td><a href="https://prometheus.io/">Prometheus</a></td>
        <td>An open-source monitoring solution for collecting metrices across my cluster.</td>
    </tr>
    <tr>
        <td><img width="32" src="https://grafana.com/static/assets/img/logos/grafana-tempo.svg"></td>
        <td><a href="https://github.com/grafana/tempo">Tempo</a></td>
        <td>An open-source monitoring solution for collecting and tracking traces in my cluster</td>
    </tr>
    <tr>
        <td><img width="32" src="https://www.svgrepo.com/show/414732/democracy-esteem-regard.svg"></td>
        <td><a href="https://github.com/democratic-csi/democratic-csi">Democratic CSI Driver</a></td>
        <td>Used to provision Persistent Volumes directly on my TrueNAS.
    </tr>
    <tr>
        <td><img width="32" src="https://docs.renovatebot.com/assets/images/logo.png"></td>
        <td><a href="https://github.com/renovatebot/renovate">Renovate</a></td>
        <td>Used to update dependencies in the cluster automaticlly.
    </tr>
    </td>
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
        <td><img width="32" src="https://avatars.githubusercontent.com/u/37879538?s=48&v=4"></td>
        <td><a href="https://actualbudget.org/">Actual</a></td>
        <td>Self-hosted personal finance app with bank integration functionality.</td>
    </tr>
</table>

### Next Steps
Currently this cluster only really has the foundations laid with the infrastructure basically done. I currently plan to add more apps or anything else I get inspired to do.
