param([switch]$OutPutToGridView,[parameter(Mandatory=$true)][string[]]$Usernames)

$Metadata = @{
	Title = "Report ActiveDirectory User Groups"
	Filename = "Report-ActiveDirectoryUserGroups.ps1"
	Description = ""
	Tags = "powershell, activedirectory, report"
	Project = ""
	Author = "Janik von Rotz"
	AuthorEMail = "contact@janikvonrotz.ch"
	CreateDate = "2013-03-27"
	LastEditDate = "2013-03-28"
	Version = "1.0.1"
	License = @'
This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivs 3.0 Unported License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/3.0/ or
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}

<#
#--------------------------------------------------#
# Example
#--------------------------------------------------#
 
.\Report-ActiveDirectoryUserGroups.ps1 -OutPutToGridView -Usernames "User1", "User2"

$Report = .\Report-ActiveDirectoryUserGroups.ps1 -Usernames "User1", "User2"

#>

if($Host.Version.Major -gt 2){
    throw "Only compatible with Powershell version 2 and less"
}else{

	#--------------------------------------------------#
	# Includes
	#--------------------------------------------------#
	Import-Module Quest.ActiveRoles.ArsPowerShellSnapIn

	#--------------------------------------------------#
	# Main
	#--------------------------------------------------#
	$ADUserGroupReport = @()
	
	function New-ADReportItem {
		param(
			$Name,
			$DN,
			$SamAccountName,
			$GroupName
		)
		New-Object PSObject -Property @{
			Name = $Name
			DN = $DN
			SamAccountName = $SamAccountName
			GroupName =$GroupName
		}
	}
	
	foreach($Username in $Usernames){
	
		$ADusers = Get-QADUser vonrotz -Properties Name,DN,SamAccountName,MemberOf | Select-Object Name,DN,SamAccountName,MemberOf
		foreach($ADUser in $ADusers){
			foreach($ADUserGroups in $ADUser.Memberof){ 
			
				$GroupName = $(Get-QADGroup $ADUserGroups).Name
				Write-Host $GroupName  -BackgroundColor Yellow -ForegroundColor Black

				$ADUserGroupReport += New-ADReportItem -Name $ADUser.Name -DN $ADUser.DN -SamAccountName $ADUser.SamAccountName -GroupName $GroupName
					   
				foreach($ADGroup in (Get-QADGroup -ContainsIndirectMember $ADUserGroups | Select-Object Name)){
				
					Write-Host ($ADGroup.Name)  -BackgroundColor Yellow -ForegroundColor Black
					$ADUserGroupReport += New-ADReportItem -Name $ADUser.Name -DN $ADUser.DN -SamAccountName $ADUser.SamAccountName -GroupName $ADGroup.Name
				}  
			} 
		}
	}

	if($OutPutToGridView -eq $true){
		$ADUserGroupReport | Out-GridView
		Write-Host "`nFinished" -BackgroundColor Green -ForegroundColor Black
		Read-Host "`nPress Enter to exit"
	}else{
		return $ADUserGroupReport
	}
	
}