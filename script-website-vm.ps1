# Set execution policy
Set-ExecutionPolicy Unrestricted -Force
New-Item -ItemType directory -Path 'C:\temp'

# Install IIS and Web Management Tools.
Import-Module ServerManager
install-windowsfeature web-server, web-webserver -IncludeAllSubFeature
install-windowsfeature web-mgmt-tools

# Download the files for our web application.
Set-Location -Path C:\inetpub\wwwroot

$shell_app = new-object -com shell.application
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/ahmadzahoory/az300template/master/vm-website-01.zip", (Get-Location).Path + "\azure-vm-website.zip")

$zipfile = $shell_app.Namespace((Get-Location).Path + "\azure-vm-website.zip")
$destination = $shell_app.Namespace((Get-Location).Path)
$destination.copyHere($zipfile.items())

# Create the web app in IIS
New-WebApplication -Name netapp -PhysicalPath c:\inetpub\wwwroot\vm-website -Site "Default Web Site" -force

# The following code will create an 2nd IIS site and it associated Application Pool. 

$SiteFolderPath = "F:\myWebServer"          # Website Folder
$SiteAppPool = "my2ndwebserver"             # Application Pool Name
$SiteName = "my2ndwebserver"                # IIS Site Name

New-Item $SiteFolderPath -type Directory
New-Item IIS:\AppPools\$SiteAppPool
New-Item IIS:\Sites\$SiteName -physicalPath $SiteFolderPath -bindings @{protocol="http";bindingInformation=":8080:"}
Set-ItemProperty IIS:\Sites\$SiteName -name applicationPool -value $SiteAppPool


# Open Port 8080. 
New-NetFirewallRule -DisplayName "Allow Inbound Port 8080" -Direction inbound -LocalPort 8080 -Protocol TCP -Action Allow