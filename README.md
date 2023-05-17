# Using Terraform to create ARO cluster

The use of Terraform to manage the lifecycle of cloud resources is an extremely common pattern, and has led to a number of customer questions around "How can I manage ARO with Terraform?"

This repo contains a working example of how to use Terraform to provision a ARO cluster.

## Prerequisites

Using the code in the repo will require having the following tools installed:

- Azure and Red Hat Accounts
- The Terraform CLI
- The AZURE CLI
- Azure Red Hat OpenShift pull secret. [Download the pull secret file from the Red Hat OpenShift Cluster Manager web site](https://cloud.redhat.com/openshift/install/azure/aro-provisioned).

Additionally, Terraform repos often have a local variables file (`terraform.tfvars`) that is **not** committed to the repo because it will often have creds or API keys in it. For this repo, it's quite simple:

```hcl
cat << EOF > terraform.auto.tfvars
resource_prefix="sazed"
domain = "sazed"
location="eastus"
resource_group_name="sazed-aro-rg"
pull_secret="pull-secret.txt"


aro_cluster_aad_sp_client_id="xxx-xxx-xxx-xxx"
aro_cluster_aad_sp_client_secret="xxx-xxx-xxx-xxx"
aro_cluster_aad_sp_object_id="xxx-xxx-xxx-xxx"
aro_rp_aad_sp_object_id="xxx-xxx-xxx-xxx"
```

## Getting Started

1. Clone this repo down

   ```bash
   git clone git@github.com:sohaibazed/aro-terraform.git
   cd aro-terraform
   ```

1. Initialize Terraform

   ```bash
   terraform init
   ```

### Public ARO Cluster

1. Check for any variables in `vars.tf` that you want to change such as the cluster name.

1. Plan the Terraform configuration

   ```bash
   terraform plan -out aro.plan
   ```

1. Apply the Terraform plan

   ```bash
   terraform apply aro.plan
   ```
