# Set execution policy
Set-ExecutionPolicy Unrestricted -Force
New-Item -ItemType directory -Path 'C:\temp'

# Install IIS and Web Management Tools.
Import-Module ServerManager
install-windowsfeature web-server, web-webserver -IncludeAllSubFeature
install-windowsfeature web-mgmt-tools

#Change physical path of a site
Import-Module WebAdministration
Set-ItemProperty -path "IIS:\Sites\Default Web Site\" -name physicalPath -value "f:\website-code-300-01-01"

#Restart IIS
iisreset /restart
