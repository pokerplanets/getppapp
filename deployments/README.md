# Infrastructure & Deployment

This directory contains Terraform configurations and documentation for deploying the PokerPlanets landing page to Google Cloud Storage (GCS) behind Cloudflare.

## Architecture

- **Google Cloud Storage**: Hosts the static website content (HTML, CSS, JS).
  - Two buckets: `pokerplanets-ru.com` (Prod) and `test.pokerplanets-ru.com` (Test).
- **Cloudflare**: Provides DNS, CDN, and Security.
  - **Prod**: Proxies traffic from Cloudflare through EdgeNext to GCS.
  - **Test**: Proxies traffic from Cloudflare through EdgeNext to GCS, with a WAF rule restricting access to VPN IP `20.218.138.97`.

## Prerequisites

1.  **GCP Project**: Ensure you have a Google Cloud Project.
2.  **Terraform State Bucket**: Create a GCS bucket named `pokerplanets-terraform-state` (manual step) to store Terraform state.
    ```bash
    gcloud storage buckets create gs://pokerplanets-terraform-state --location=EU
    ```
3.  **Cloudflare**:
    -   Zone ID for `pokerplanets-ru.com`.
    -   API Token with permissions to manage DNS and Filters/Firewall Rules.

## Secrets Setup (GitHub Actions)

Go to your GitHub Repository Settings -> Secrets and Variables -> Actions, and add the following secrets:

| Secret Name | Description |
| :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID. |
| `GCP_SA_KEY` | The Service Account JSON key with permissions to manage GCS and Storage Admin. |
| `CLOUDFLARE_API_TOKEN` | Cloudflare API Token. |
| `CLOUDFLARE_ZONE_ID` | Cloudflare Zone ID for `pokerplanets-ru.com`. |
| `EDGENEXT_ACCESS_KEY` | EdgeNext API Access Key (for Prod). |
| `EDGENEXT_SECRET_KEY` | EdgeNext API Secret Key (for Prod). |

## EdgeNext Configuration (Automated)

For the **Prod** environment, EdgeNext is now fully managed via Terraform using the `edgenext_cdn_domain` resource.
*   **Origin**: Automatically configured to point to `c.storage.googleapis.com` via HTTP (Port 80) with the correct Host header.
*   **CNAME**: The CNAME assigned by EdgeNext is automatically retrieved and used in Cloudflare DNS records.
*   **Redirect**: A Cloudflare Page Rule is configured to redirect `www.pokerplanets-ru.com/*` to `https://pokerplanets-ru.com/$1`.

## SSL/TLS Setting

Since GCS static website hosting via `c.storage.googleapis.com` only supports HTTP for custom domains:
-   In **Cloudflare SSL/TLS** settings, set the encryption mode to **Flexible** (or ensure Cloudflare connects to origin via HTTP).

## Deployment Workflows

### 1. Infrastructure (`.github/workflows/infra.yml`)
-   Triggers on push to `main` affecting `deployments/`.
-   Runs `terraform apply` to update buckets, IAM, and Cloudflare rules.

### 2. Application (`.github/workflows/deploy.yml`)
-   **Test**: Automatically deploys to `gs://test.pokerplanets-ru.com` on every push to `main`.
-   **Prod**: Manually triggered via GitHub Actions UI ("Run workflow") from `main` branch. Select "prod" as the environment to deploy to `gs://pokerplanets-ru.com`.
