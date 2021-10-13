using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

# Interact with query parameters or the body of the request.

$TenantFilter = $Request.Query.TenantFilter
    $selectstring = "id,createdDateTime,displayName,description,mail,mailEnabled,mailNickname,resourceProvisioningOptions,securityEnabled,visibility,organizationId,onPremisesSamAccountName,membershipRule,grouptypes"

if($Request.Query.GroupID){ 
$groupid = $Request.query.groupid
$selectstring = "id,createdDateTime,displayName,description,mail,mailEnabled,mailNickname,resourceProvisioningOptions,securityEnabled,visibility,organizationId,onPremisesSamAccountName,membershipRule"
}
if($Request.Query.members){ 
    $members = "members"
    $selectstring = "id,createdDateTime,displayName,description,hideFromOutlookClients,hideFromAddressLists,mail,mailEnabled,mailNickname,resourceProvisioningOptions,securityEnabled,visibility,organizationId,onPremisesSamAccountName,membershipRule"
}


        $GraphRequest = New-GraphGetRequest -asApp $true -uri "https://graph.microsoft.com/beta/groups/$($GroupID)/$($members)?`$top=999&select=$selectstring" -tenantid $TenantFilter | select-object *,@{ Name = 'primDomain'; Expression = { $_.mail -split "@" | Select-Object -last 1 } }


# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = @($GraphRequest)
    })