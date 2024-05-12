# Cloudflare Terraform Auto Import
This script is a wrapper for importing large numbers of Cloudflare zones and/or resources using the cf-terraforming command line tool provided by Cloudflare.  Using a comma separated list of zone ids and zone names, and a list of desired terraform resources, the cf-terraform-autoimport.ps1 script will automatically take care of all the steps to setup your Terraform Cloudflare configuration.  The script will:
1. Download from your account the current configuration of your desired resources.
2. Build the terraform configuration files.
3. Collect the necessary import commands, write them to file and then...
4. Init your directory and Create your tfstate file.
5. Repeat 1-4 on your entire list of zones creating a set of resources in separate directories for each zone.  

# Required Setup
1. terraform 
2. cf-terraforming script [cf-terraforming(github)](https://github.com/cloudflare/cf-terraforming).
3. resources.txt - a list of terraform resources from the [cloudflare/cloudflare](https://registry.terraform.io/providers/cloudflare/cloudflare/latest) provider (example provided).
4. zone_list.txt - a comma separated list of zone ids and zone names (example provided).
5. providers.tf - should only need the cloudflare providers unless you want to customize this further.
6. $Env:CLOUDFLARE_API_TOKEN environment variable.  

# Instructions for use
1. Customize the zone_list.txt and resources.txt to your desired zones and resources.
2. Add your $Env:CLOUDFLARE_API_TOKEN environment variable.
3. Run terraform init in the directory your running this from. 
4. Run cf-terraforming-autoimport.ps1 in powershell.    

# Possible Roadmap
1. Add switches to only run the file generation portion of the script.
2. Add switches to only run the import portion (terraform init and tfstate creation).
3. API KEY Support
4. Python version?