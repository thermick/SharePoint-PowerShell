############################################################################################################################################
# This script allows to remove Web Parts from the Web Parts Gallery. 
# Required parameters:
#   ->$sSiteCollectionUrl: Site Collection Url.
############################################################################################################################################
If ((Get-PSSnapIn -Name Microsoft.SharePoint.PowerShell -ErrorAction SilentlyContinue) -eq $null ) 
{ Add-PSSnapIn -Name Microsoft.SharePoint.PowerShell }

#Hacemos un buen uso de PowerShell par ano penalizar el rendimiento
$host.Runspace.ThreadOptions = "ReuseThread"
$sSiteCollectionUrl="http://<Site_Collection_Url>"

#Function that delete Web Parts from the Web Parts catalogue
function RemoveWebPartsFromCatalogue
{
    param ($sSiteCollection)  
    try
    {    
        $spSiteCollection = Get-SPWeb -Identity $sSiteCollection        
        $wpCatlog =[Microsoft.SharePoint.SPListTemplateType]::WebPartCatalog
        $spList = $spSiteCollection.GetCatalog([Microsoft.SharePoint.SPListTemplateType]::WebPartCatalog)        
        $wpID = New-Object System.Collections.ObjectModel.Collection[System.Int32]
        
        #Getting Web Parts to be deleted
        foreach ($spItem in $spList.Items)
        {            
            if($spItem.DisplayName.Contains("<YourSearchCriteria>"))
            {   
                #$spItem.DisplayName
                $wpID.Add($spItem.ID) 
            }
        }
        
        #Deleting the Web Parts
        foreach($wp in $wpID)
        {              
            $wpItem = $spList.GetItemById($wp)
            write-Host -f blue "Deleting Web Part with ID $wpID"
            $wpItem.Delete()
        }
        $spList.Update()
        $spSiteCollection.Dispose()    
    }
    catch [System.Exception]
    {
        write-host -f red $_.Exception.ToString()
    }
}

Start-SPAssignment –Global
RemoveWebPartsFromCatalogue -sSiteCollection $sSiteCollectionUrl
Stop-SPAssignment –Global
Remove-PSSnapin Microsoft.SharePoint.PowerShell
