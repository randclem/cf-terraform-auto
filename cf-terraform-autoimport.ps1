###
#   Cloudflare Terraform Auto Importer
#   Requirements: 
#       terraform.exe
#       cf-terraforming.exe script
#       providers.tf (configured with your required providers)
#       resources.txt (lists of terraform resources to pull into state)
#       zone_list.txt (list of zones in a comma separated list of zone_id,zone_name)
#       Necessary environment variables for your cloudflare API token
###

$zones = Get-Content -Path ".\zone_list.txt"
$resources = Get-Content -Path ".\resources.txt"
#$CF_EMAIL = $Env:CLOUDFLARE_EMAIL
$CF_TOKEN = $Env:CLOUDFLARE_API_TOKEN
$provider = "providers.tf"

if (-not ($CF_TOKEN)) { 
    Write-Host "No token set.  Please set environment variable: CLOUDFLARE_API_TOKEN"
    exit 
}

foreach ($zone in $zones)
{
    $zone_id = ($zone -split ',')[0].trim()
    $zone_name = ($zone -split ',')[1].trim()
    $dir_name = "./"+$zone_name+"/"
    $output_import_file = $dir_name+$zone_name + ".txt"

    if ( -not (Test-Path -Path $zone_name) ) {
        New-Item -Path ".\" -Name $zone_name -ItemType "directory"
    }

    if ( -not (Test-Path -Path $zone_name+"\"+$provider) ){
        Copy-Item $provider -Destination $zone_name
    }

    # Generate the resource.tf and import command files
    foreach ($resource in $resources) 
    {
        $output_file = $dir_name + $zone_name + "_" + $resource + ".tf"
        cf-terraforming generate --token $CF_TOKEN -z $zone_id --resource-type $resource > $output_file
        cf-terraforming import --resource-type $resource --token $CF_TOKEN --zone $zone_id >> $output_import_file
        Write-Host $output_file
        Write-Host $output_import_file
    }

    # Create array of import file commands
    $import_list = Get-Content -Path $output_import_file

    # Enter the directory for this zone
    Set-Location -Path $dir_name
    
    # Convert all files to UTF8 encoding - otherwise import will fail.
    Get-ChildItem . |
    ForEach-Object {
        $content = Get-Content $_
        $content | Set-Content -Encoding utf8 $_
    }
    
    # Terraform Init the project directory
    & terraform init

    # Run all import commands to create tfstate file
    foreach($import in $import_list)
    {
        $import_split = $import -split ' '
        & $import_split[0] $import_split[1] $import_split[2] $import_split[3]
    }

    Set-Location ../
}