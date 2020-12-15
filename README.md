# Start/Stop Failover Test

These scripts are designed to allow you to start and stop a Failover Test on an existing VPG and can be used with windows scheduler to automate this process if desired.  Please note that using the script to stop a Failover Test doesn't allow you to select success or failure, or add notes at the end of a Failover Test.

## Legal Disclaimer

This script is an example script and is not supported under any Zerto support program or service. The author and Zerto further disclaim all implied warranties including, without limitation, any implied warranties of merchantability or of fitness for a particular purpose.

In no event shall Zerto, its authors or anyone else involved in the creation, production or delivery of the scripts be liable for any damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, loss of business information, or other pecuniary loss) arising out of the use of or the inability to use the sample scripts or documentation, even if the author or Zerto has been advised of the possibility of such damages. The entire risk arising out of the use or performance of the sample scripts and documentation remains with you.

## Getting Started

There are two scripts. Use DR-TestStart.ps1 to initiate the Failover Test, and DR-TestStop.ps1 to stop the Failover Test.

Set the variables below including the VPG name you would like bring up in a Failover Test.

## Prerequisites

### Environment Requirements

- PowerShell 5.0+

### In-Script Variables

- ZVM IP / Port
- ZVM User / Password
- VPG Name

## Running the Script

Once the necessary requirements have been completed select an appropriate host to run the script from. To run the script type the following from the directory the script is located in:

.\DR-TestStart.ps1 or .\DR-TestStop.ps1
