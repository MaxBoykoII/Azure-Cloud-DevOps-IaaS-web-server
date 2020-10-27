# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction
This project includes a Packer template and a Terraform template for deploying a customizable, scalable web server in Azure. The infrastructure as code specified in this project includes in the following main components:

- A policy to ensure that the indexed resources are tagged
- A packer template for deploying an Ubuntu VM image, which is configured to a host a simple web page
- A resource group
- A virtual network
- A subnet
- A public ip address, which can be used to view the web page
- A configured load balancer
- Virtual machines attached to an availability set, allowing for scalability
- A network security group

In addition, the location, the prefix used for naming and tagging resources, the VM count, the VM username and password, and the image used for creating the VMs are all configurable.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Getting Started

#### Creating a Service Principal for Terraform

1. Navigate to Azure Active Directory in the Azure Portal

2. Navigate to "App Registrations"

3. Click "New Registration"

4. Create a single tenant service principal with no redirect URI named "Terraform"

5. Navigate to the "Subscriptions" service

6. In your primary subscription, navigate to "Access control (IAM)"

7. Click Add > Add role assignment

8. Give the "Contributor" role to your "Terraform" application

9. Click Save

10. Select the "Terraform" application

11. Navigate to "Certificates & Secrets"

12. Add a new client secret

13. Configure the environment variables needed by Terraform and Packer 

    ```sh
    export ARM_CLIENT_SECRET=<your client secret>
    export ARM_CLIENT_ID=<your client id>
    export ARM_SUBSCRIPTION_ID=<your arm subscription id>
    export ARM_TENANT_ID=<your arm tenant id>
    ```

    Note that your client secret, client id, and tenant id come from your "Terraform" application. Your subscription id comes directly from your subscription.

#### Deploying a Tagging Policy

1. Login with the cli 

   ```az login```

2. Create a policy definition

   ``` az policy definition create --name "tagging-policy" --display-name "Require tags for indexed resources" --mode Indexed --rules "policy.json" ```

3. Create a policy assignment

   ``` az policy assignment create --policy "tagging-policy" --name "tagging-policy"```

#### Deploying the Packer Template

1. Create a resource group for the packer image

   ``` az group create --name iass-web-packer-resources --location westus```

2. Build the packer template

   ```packer build server.json```

   Note that you can customize the variables specified in the packer template. For instance,

   ```packer build -var 'image_name=<your image name>' server.json```

3. Review the deployed image

   ```az image list```

#### Deploying the Server Infrastructure

1. Initialize terraform

   ```terraform init```

2. Create a plan

   ```terraform plan -out solution.plan```

3. Execute the plan

   ```terraform apply```

#### Viewing the Server

1. In the azure portal, click on all resources and locate the public ip resource. 
2. Copy the public ip address and paste into a web browser. You should a simple web page with the text "Great Bulls of America"

#### Removing the Server Infrastructure

1. Tear down the infrastructure deployed by terraform

   ```terraform destroy```

### Customization

Both the packer template and the terraform template support customization. To configurate the packer template, for example, you can can overwrite any of the user variables:

```
packer build \
	-var 'resource_group_name=<your resource group name>' \
	-var 'image_name=<your image name>' \
	-var 'vm_tag=<your vm tag>' \
	-var 'location=<your location' \
    server.json
```

You can similarly customize the terraform template by overwriting the defaults in variables.tf. For instance,

```
terraform plan \
	-var 'prefix=<your prefix>' \
	-var 'location=<your location>' \
	-var 'vm_count=<your vm count>' \
	-var 'vm_username=<your vm username>' \
	-var 'vm_password=<your vm password>' \
	-var 'environment=<your environment tag>' \
	-var 'image_name=<your image name>' \
	-var 'image_rg_name=<your image resource group name>' \
	-out solution.plan
```

