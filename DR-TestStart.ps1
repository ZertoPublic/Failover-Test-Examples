<#
.SYNOPSIS
This script is designed to initiate a Failover Test on an existing VPG.

.DESCRIPTION
This script can be used to schedule a Failover Test, or remotely exectute a Failover Test without accessing the Zerto GUI.  The script will default to the most recent checkpoint.

.EXAMPLE
Examples of script execution

.VERSION
Applicable versions of Zerto Products script has been tested on. Unless specified, all scripts in repository will be 6.5u3 and later. If you have tested the script on multiple
versions of the Zerto product, specify them here. If this script is for a specific version or previous version of a Zerto product, note that here and specify that version
in the script filename. If possible, note the changes required for that specific version.

.LEGAL
Legal Disclaimer:

----------------------
This script is an example script and is not supported under any Zerto support program or service.
The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without
limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability
to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or
performance of the sample scripts and documentation remains with you.
----------------------
#>

################################################
# Configure the variables below
################################################
$LogDataDir = <YOUR LOGGING DIRECTORY HERE>
$ZertoServer = <IP ADDRESS OF YOUR ZERTO ZVM SERVER HERE>
$ZertoPort = "9669"
$ZertoUser = <USERNAME TO AUTHENTICATE TO ZERTO HERE>
$ZertoPassword = <PASSWORD HERE>
$VPGName = <VPG NAME HERE>
################################################
# Setting log directory for engine and current month
################################################
$CurrentMonth = Get-Date -Format MM.yy
$CurrentTime = Get-Date -Format hh.mm.ss
$CurrentLogDataDir = $LogDataDir + $CurrentMonth
$CurrentLogDataFile = $LogDataDir + $CurrentMonth + "\FOT-Log-" + $CurrentTime + ".txt"
# Testing path exists to engine logging, if not creating it
$ExportDataDirTestPath = Test-Path $CurrentLogDataDir
if ($ExportDataDirTestPath -eq $False) {
    New-Item -ItemType Directory -Force -Path $CurrentLogDataDir
}
Start-Transcript -Path $CurrentLogDataFile -NoClobber

################################################
# Setting Cert Policy - required for successful auth with the Zerto API
################################################
Add-Type @"
 using System.Net;
 using System.Security.Cryptography.X509Certificates;
 public class TrustAllCertsPolicy : ICertificatePolicy {
 public bool CheckValidationResult(
 ServicePoint srvPoint, X509Certificate certificate,
 WebRequest request, int certificateProblem) {
 return true;
 }
 }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

################################################
# Building Zerto API string and invoking API
################################################
$baseURL = "https://" + $ZertoServer + ":" + $ZertoPort + "/v1/"
# Authenticating with Zerto APIs
$xZertoSessionURL = $baseURL + "session/add"
$authInfo = ("{0}:{1}" -f $ZertoUser, $ZertoPassword)
$authInfo = [System.Text.Encoding]::UTF8.GetBytes($authInfo)
$authInfo = [System.Convert]::ToBase64String($authInfo)
$headers = @{Authorization = ("Basic {0}" -f $authInfo) }
$sessionBody = '{"AuthenticationMethod": "1"}'
$TypeJSON = "application/JSON"
$xZertoSessionResponse = Invoke-WebRequest -Uri $xZertoSessionURL -Headers $headers -Method POST -Body $sessionBody -ContentType $TypeJSON
# Extracting x-zerto-session from the response, and adding it to the actual API
$xZertoSession = $xZertoSessionResponse.headers.get_item("x-zerto-session")
$zertoSessionHeader = @{"x-zerto-session" = $xZertoSession; "Accept" = $TypeJSON }

################################################
# Getting the VPG Identifier for the FOT
################################################
$VPGSURL = $BaseURL + "vpgs"
$VPGsCMD = Invoke-RestMethod -Uri $VPGSURL -TimeoutSec 100 -Headers $zertoSessionHeader -ContentType $TypeJSON
$VPGIdentifier = $VPGsCMD | where-object { $_.VpgName -eq $VPGName } | select-object VpgIdentifier -ExpandProperty VpgIdentifier

################################################
# Starting the FOT
################################################
$VPGSFOTURL = $BaseURL + "vpgs/" + $VPGIdentifier + "/FailoverTest"
$VPGsFOTCMD = Invoke-RestMethod -Method Post -Uri $VPGSFOTURL -TimeoutSec 100 -Headers $zertoSessionHeader -ContentType $TypeJSON

################################################
# Stopping logging
################################################
Stop-Transcript
