$JamfUriBase="https://your.jamfserver.com"
$JamfUriBaseComputers="/JSSResource/computers"
$JamfUriBaseComputerId="/JSSResource/computers/id"
$UriToken="/api/v1/auth/token"

$UriComputers = $JamfUriBase + $JamfUriBaseComputers
$UriComputerId = $JamfUriBase + $JamfUriBaseComputerId
$JamfUriToken = $JamfUriBase + $UriToken

$ComputerSerialNUmber="The_serial_number_of_a_computer_in_your_jamfserver"

$Message = "## Start execution of JAMF tests ##"
Write-Host "`n$Message" -ForegroundColor Cyan

# Get Jamf API user credentials
$JamfCred = Get-Credential -UserName YOURAPIUSER

## Get Jamf token
function getjamfAuth()
{
    
    $call = Invoke-RestMethod -Method Post -Uri $JamfUriToken -Authentication Basic -Credential $JamfCred
    return $call

}

## Get computerlist from jamf
$jamftoken = getjamfAuth
$jamftoken = $jamftoken.token
$headers = @{
    Authorization = "Bearer $jamftoken"
    Accept = "application/json"
}
Write-Host "UriComputers: $UriComputers"
$JamfComputersJSON = Invoke-RestMethod -Method Get -Uri $UriComputers -Headers $headers -ContentType "application/json;charset=UTF-8"

## List with computerId ComputerName
Write-Host $JamfComputersJSON.psobject.properties.value

## List with names (Serialnumbers)
Write-Host $JamfComputersJSON.psobject.properties.value.name

## List with computer Id's
Write-Host $JamfComputersJSON.psobject.properties.value.id

Write-Host $JamfComputersJSON.computers.where{ $_.name -eq $ComputerSerialNUmber}.id
$JamfComputerId = $JamfComputersJSON.computers.where{ $_.name -eq $ComputerSerialNUmber}.id

############# TODO: Check if the old token is still valid before geting a new token
## Get token
$jamftoken = getjamfAuth
$jamftoken = $jamftoken.token

$headers = @{
  Authorization = "Bearer $jamftoken"
   Accept = "application/json"
}

$JamfComputer = Invoke-RestMethod -Uri $UriComputerId/$JamfComputerId  -Headers $headers -ContentType "application/json;charset=UTF-8"

$JamfComputerUser = $JamfComputer.psobject.properties.value.general.mdm_capable_users

## Last date of report
$Assetjamf_date = $JamfComputer.psobject.properties.value.general.report_date
Write-Host "Last date of report:" $Assetjamf_date

## Mdm Capable User
$Assetjamf_user = $JamfComputerUser.psobject.properties.value
Write-Host "Mdm Capable user:"  $Assetjamf_user

#Write-Host $AssetjamfOSversion
$AssetjamfOSversion = $JamfComputer.psobject.properties.value.hardware.os_version
Write-Host "OS Version:" $AssetjamfOSversion

## User real name
Write-Host $JamfComputer.psobject.properties.value.groups_accounts.local_accounts.where{ $_.name -eq $JamfComputerUser.psobject.properties.Value}.realname 
$JamfComputerUserRealName = $JamfComputer.psobject.properties.value.groups_accounts.local_accounts.where{ $_.name -eq $JamfComputerUser.psobject.properties.Value}.realname 
Write-Host $JamfComputerUserRealName
