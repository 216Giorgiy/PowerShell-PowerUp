<#
$Metadata = @{
    Title = "Get SharePoint Lists"
	Filename = "Get-SPLists.ps1"
	Description = ""
	Tags = ""powershell, sharepoint, function"
	Project = ""
	Author = "Janik von Rotz"
	AuthorContact = "http://janikvonrotz.ch"
	CreateDate = "2013-07-29"
	LastEditDate = "2013-07-29"
	Version = "1.0.0"
	License = @'
This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Switzerland License.
To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/ch/ or 
send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
'@
}
#>

function Get-SPLists{

<#

.SYNOPSIS
    Get all SharePoint lists.

.DESCRIPTION
	Get all SharePoint lists.
    
.PARAMETER Identity
	Url of the SharePoint website containing the lists.
    
.PARAMETER OnlyDocumentLibraries
	Only get document libraries
    
.PARAMETER Recursive
	Requires Identity, includes the every sub list of the specified website.


.EXAMPLE
	PS C:\> Get-SPLists -Identity "http://sharepoint.vbl.ch/Projekte/SitePages/Homepage.aspx" -OnlyDocumentLibraries -Recursive

#>

	param(
		[Parameter(Mandatory=$false)]
		[string]$Identity,
		
		[switch]$OnlyDocumentLibraries,

		[switch]$Recursive
	)
    
    #--------------------------------------------------#
    # modules
    #--------------------------------------------------#
    if ((Get-PSSnapin “Microsoft.SharePoint.PowerShell” -ErrorAction SilentlyContinue) -eq $null) {
        Add-PSSnapin “Microsoft.SharePoint.PowerShell”
    }

    #--------------------------------------------------#
    # main
    #--------------------------------------------------#
    
    # array for the website objects
    $SPLists = @()
    $SPListItems = @()
    
    # check if url has been passed
    if($Identity){
    
        # get url
        [Uri]$SPWebUrl = $Identity.ToString() -replace "/SitePages/Homepage.aspx",""
                
        if($Recursive){
        
            # get all lists from each subweb
            $SPWebs = Get-SPWebs -Identity $SPWebUrl.OriginalString
            $SPWebs | %{
                $SPLists += $_.Lists
            }
                        
        }else{
        
            # only add this website
            $SPWeb = Get-SPWeb -Identity $SPWebUrl.OriginalString
            $SPLists = $SPWeb.lists
        }        
     }else{
    
        # get all lists
        Get-SPWebApplication | Get-SPsite -Limit all | %{
            $_ |  Get-SPWeb -Limit all | %{
                $SPLists += $_.Lists
            }
        }    
    }
    
    # filter lists
    if($OnlyDocumentLibraries){
        $SPLists = $SPLists | where {$_.BaseType -eq "DocumentLibrary"}
    }
       
    # output items
    $SPlists | %{
        $_ | select *
    }
}