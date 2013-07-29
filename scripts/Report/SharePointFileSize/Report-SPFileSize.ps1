$SPWebs = Get-SPWebs

$SPListItemReport = @()

foreach($SPWeb in $SPWebs){
    
     Write-Progress -Activity "Checking website" -status $SPWeb.title -percentComplete ([int]([array]::IndexOf($SPWebs, $SPWeb)/$SPWebs.Count*100))
    
    [Uri]$SPWebUrl = $SPWeb.Url

    $SPLists = Get-SPLists -Identity $SPWebUrl.OriginalString -OnlyDocumentLibraries
    
    foreach($SPList in $SPLists){
    
        $SPListUrl = $SPWebUrl.Scheme + "://" + $SPWebUrl.Host + $SPlist.DefaultViewUrl -replace "/([^/]*)\.(aspx)",""
    
        $SPListitems = Get-SPListItems -Identity $SPList.ParentWeb.Url -ListName $SPList.title -OnlyFiles
        
        foreach($SPListitem in $SPListItems){
        
            $SPListItemReport += New-SPListItemSize -Website $SPWeb.title -WebsiteUrl $SPWeb.Url -List $SPList.title -ListUrl $SPListUrl -Item $SPListitem.Name -ItemUrl $SPListitem.Url -Size $SPListitem.file.length
        
        }    
    }    
}

$SPListItemReport |  Export-Csv "ReportData.csv" -Delimiter ";" -Encoding "UTF8"