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
(New-Object System.Net.WebClient).DownloadFile("https://raw.githubusercontent.com/ahmadzahoory/az300template/master/az-300-website-migration.zip", (Get-Location).Path + "\az-300-website-migration.zip")

$zipfile = $shell_app.Namespace((Get-Location).Path + "\az-300-website-migration.zip")
$destination = $shell_app.Namespace((Get-Location).Path)
$destination.copyHere($zipfile.items())

# Create the web app in IIS
New-WebApplication -Name netapp -PhysicalPath c:\inetpub\wwwroot\vm-website -Site "Default Web Site" -force
# Initialize the disk
Get-Disk | Where partitionstyle -eq 'raw' | Initialize-Disk -PartitionStyle MBR -PassThru | New-Partition -AssignDriveLetter -UseMaximumSize | Format-Volume -FileSystem NTFS -NewFileSystemLabel "DataDisk01" -Confirm:$false

# Format data disk
Get-Disk | Where partitionstyle -eq 'raw' 
Initialize-Disk -Number 2 -PartitionStyle MBR -PassThru 
New-Partition -DiskNumber 2 -DriveLetter F -UseMaximumSize 
Format-Volume -DriveLetter F -FileSystem NTFS -NewFileSystemLabel "DataDisk02" -Confirm:$false

# Download website02 code from Github
Invoke-WebRequest https://raw.githubusercontent.com/ahmadzahoory/az300template/master/az-300-website-migration-02.zip -OutFile f:\website02\az-300-website-migration-02.zip

# Unzip .zip file
Expand-Archive f:\website02\az-300-website-migration-02.zip -DestinationPath f:\website02

# Create an 2nd IIS site and it associated Application Pool. 
$SiteFolderPath = "f:\website02"         # Website Folder
$SiteAppPool = "webserver02"             # Application Pool Name
$SiteName = "webserver02"                # IIS Site Name

New-Item $SiteFolderPath -type Directory
New-Item IIS:\AppPools\$SiteAppPool
New-Item IIS:\Sites\$SiteName -physicalPath $SiteFolderPath -bindings @{protocol="http";bindingInformation=":8080:"}
Set-ItemProperty IIS:\Sites\$SiteName -name applicationPool -value $SiteAppPool

# Open ICMP port
New-NetFirewallRule -DisplayName "Allow Inbound Port 8080" -Direction inbound -LocalPort 8080 -Protocol TCP -Action Allow
