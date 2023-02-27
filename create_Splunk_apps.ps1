function Create-DeploymentServerApp {
    param ( 
        [Parameter(Mandatory = $true)] [string] $deploymentServerIPAddress,
        [Parameter(Mandatory = $true)] [string] $siteName
        )
 
        $forwarderfolderName = $writeFilePath + $siteName + "_deployer_settings"
        New-Item -Path $forwarderfolderName -ItemType Directory
    
        $forwarderLocalName = $forwarderfolderName + "\local"
        New-Item -Path $forwarderLocalName -ItemType Directory
        
        $deployerMetaName = $forwarderfolderName + "\meta"
        New-Item -Path $deployerMetaName -ItemType Directory


        $localFile =  $forwarderLocalName + "\app.conf"
        New-Item $localFile
        Set-Content -Path $localFile "[install]"
        add-Content -Path $localFile "state = enabled"
        add-Content -Path $localFile ""
        Add-Content -path $localFile "[package]"
        Add-Content -path $localFile "check_for_updates = false"
        add-Content -Path $localFile ""
        Add-Content -path $localFile "[ui]"
        Add-Content -path $localFile "is_visible = false"
        Add-Content -path $localFile "is_manageable = false"
    
        $deploymentFile =  $forwarderLocalName + "\deploymentclient.conf"
        New-Item $deploymentFile
        Set-Content -Path deploymentFile "[deployment-client]"
        add-Content -Path $deploymentFile "phoneHomeIntervalInSecs = 600"
        add-Content -Path $deploymentFile ""
        add-Content -Path $deploymentFile "[target-broker:deploymentServer]"
        $tempDeploymentServerIP = "targetUri = " + $deploymentServerIPAddress
        add-Content -Path $deploymentFile $tempDeploymentServerIP
    
        $metadataFile =  $deployerMetaName + "\local.meta"
        New-Item $metadataFile
        Set-Content -Path $metadataFile "[]"
        add-Content -Path $metadataFile "access = read : [ * ], write : [ admin ]"
        add-Content -Path $metadataFile "export = system" 
        
}
function Create-ForwardingApp{
    param ( 
        
        [Parameter(Mandatory = $true)] [string] $siteName
        )
         $indexerListString

        $needsComma = $false
        foreach($tempString in $indexerIPs){
    
            if($needsComma -eq $false){
                $indexerListString += $tempString
                $needsComma = $true
            }
            else {
                $indexerListString += "," + $tempString
            }
        }

 
        $deployerfolderName = $writeFilePath + $siteName + "_forwarding_settings"
        New-Item -Path $deployerfolderName -ItemType Directory
    
        $deployerLocalName = $deployerfolderName + "\local"
        New-Item -Path $deployerLocalName -ItemType Directory
        
        $deployerMetaName = $deployerfolderName + "\meta"
        New-Item -Path $deployerMetaName -ItemType Directory
        
        
        $localFile =  $deployerLocalName + "\app.conf"
        New-Item $localFile
        Set-Content -Path $localFile "[install]"
        add-Content -Path $localFile "state = enabled"
        add-Content -Path $localFile ""
        Add-Content -path $localFile "[package]"
        Add-Content -path $localFile "check_for_updates = false"
        add-Content -Path $localFile ""
        Add-Content -path $localFile "[ui]"
        Add-Content -path $localFile "is_visible = false"
        Add-Content -path $localFile "is_manageable = false"
    
        $deploymentFile =  $deployerLocalName + "\limits.conf"
        New-Item $deploymentFile
        Set-Content -Path deploymentFile "[thruput]"
        add-Content -Path $deploymentFile "maxKBps = 0"
        
        $outputFile =  $deployerLocalName + "\outputs.conf"
        New-Item $outputFile
        Set-Content -Path $outputFile "[tcpout]"
        add-Content -Path $outputFile "defaultGroup = primary_indexers"
        Add-Content -Path $outputFile ""
        add-Content -Path $outputFile "[tcpout:primary_indexers]"
        add-Content -Path $outputFile $indexerListString

    
        
        $metadataFile =  $deployerMetaName + "\local.meta"
        New-Item $metadataFile
        Set-Content -Path $metadataFile "[]"
        add-Content -Path $metadataFile "access = read : [ * ], write : [ admin ]"
        add-Content -Path $metadataFile "export = system" 
    
    
}
function Create-IndexVolumeSettings{
    param ( 
           [Parameter(Mandatory = $true)] [string] $siteName
        )
        
    #indexer Volume settings
    $volumefolderName = $writeFilePath + $siteName + "_indexer_volume_indexes"
    New-Item -Path $volumefolderName -ItemType Directory

    $volumeLocalName = $volumefolderName + "\local"
    New-Item -Path $volumeLocalName -ItemType Directory
    
    $volumeMetaName = $volumefolderName + "\meta"
    New-Item -Path $volumeMetaName -ItemType Directory

    $localFile =  $volumeLocalName + "\app.conf"
    New-Item $localFile
    Set-Content -Path $localFile "[install]"
    add-Content -Path $localFile "state = enabled"
    add-Content -Path $localFile ""
    Add-Content -path $localFile "[package]"
    Add-Content -path $localFile "check_for_updates = false"
    add-Content -Path $localFile ""
    Add-Content -path $localFile "[ui]"
    Add-Content -path $localFile "is_visible = false"
    Add-Content -path $localFile "is_manageable = false"

    $indexPartitionFile =  $volumeLocalName + "\indexes.conf"
    New-Item $indexPartitionFile
    Set-Content -Path $indexPartitionFile "[volume:primary]"
    add-Content -Path $indexPartitionFile "path = /path/to/index/storage/partition"
    add-Content -Path $indexPartitionFile "maxVolumeDataSizeMB = 5000000"   
    add-Content -Path $indexPartitionFile ""
    add-Content -Path $indexPartitionFile "[volume:_splunk_summaries]"
    add-Content -Path $indexPartitionFile "path = /path/to/index/storage/partition"
    add-Content -Path $indexPartitionFile "maxVolumeDataSizeMB = 100000"

    $metadataFile =  $volumeMetaName + "\local.meta"
    New-Item $metadataFile
    Set-Content -Path $metadataFile "[]"
    add-Content -Path $metadataFile "access = read : [ * ], write : [ admin ]"
    add-Content -Path $metadataFile "export = system" 

}
function Create-Indexes{
    param ( 
        [Parameter(Mandatory = $true)] [string] $siteName
     )
    #Set up individual Indexes

$indexerVolumeName = $writeFilePath + $siteName + "_indexes"
New-Item -Path $indexerVolumeName -ItemType Directory

    $indexerLocalName = $indexerVolumeName + "\local"
    New-Item -Path $indexerLocalName -ItemType Directory
    
    $indexerMetaName = $indexerVolumeName + "\meta"
    New-Item -Path $indexerMetaName -ItemType Directory

$localFile =  $indexerLocalName + "\app.conf"
New-Item $localFile
Set-Content -Path $localFile "[install]"
add-Content -Path $localFile "state = enabled"
add-Content -Path $localFile ""
Add-Content -path $localFile "[package]"
Add-Content -path $localFile "check_for_updates = false"
add-Content -Path $localFile ""
Add-Content -path $localFile "[ui]"
Add-Content -path $localFile "is_visible = false"
Add-Content -path $localFile "is_manageable = false"

$indexPartitionFile =  $indexerLocalName + "\indexes.conf"
New-Item $indexPartitionFile
Set-Content -Path $indexPartitionFile "[default]"
add-Content -Path $indexPartitionFile "homePath.maxDataSizeMB = 300000"
add-Content -Path $indexPartitionFile "coldPath.maxDataSizeMB = 200000"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[main]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/defaultdb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/defaultdb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/defaultdb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[history]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/historydb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/historyb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/historydb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[summary]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/summarydb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/summarydb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/summarydb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[_internal]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/_internaldb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/_internaldb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/_internaldb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[_introspection]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/_introspectiondb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/_introspectiondb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/_introspectiondb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[_telemetry]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/_telemetrydb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/_telemetrydb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/_telemetrydb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[_audit]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/_auditdb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/_auditdb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/_auditdb/thaweddb"
add-Content -Path $indexPartitionFile ""
add-Content -Path $indexPartitionFile "[_thefishbucket]"
add-Content -Path $indexPartitionFile "homePath   = volume:primary/_thefishbucketdb/db"
add-Content -Path $indexPartitionFile "coldPath   = volume:primary/_thefishbucketdb/colddb"
add-Content -Path $indexPartitionFile "thawedPath = $SPLUNK_DB/_thefishbucketdb/thaweddb"


$metadataFile =  $indexerMetaName + "\local.meta"
New-Item $metadataFile
Set-Content -Path $metadataFile "[]"
add-Content -Path $metadataFile "access = read : [ * ], write : [ admin ]"
add-Content -Path $metadataFile "export = system" 
}

function Get-IndexerIpInfo{
    param ( 
        [Parameter(Mandatory = $true)] [string] $siteName
     )
    [int]$indexerCount = Read-Host "How many indexers will your environment be using?"

    for ($x = 1; $x -le $indexerCount; $x++){
        $tempString = "What is the IP Address of indexer " + $x + " and its port (example 10.0.0.1:9997)?"
        $tempInput = Read-Host $tempString
        $indexerIPs.Add($tempInput)
    }

   
}

function Create-LicensingApp{
     param ( 
        [Parameter(Mandatory = $true)] [string] $licenseServerIPAddress,
        [Parameter(Mandatory = $true)] [string] $siteName
        )
    #Licensing App settings
    $forwarderfolderName = $writeFilePath + $siteName + "_licensing"
    New-Item -Path $forwarderfolderName -ItemType Directory

    $forwarderLocalName = $forwarderfolderName + "\local"
    New-Item -Path $forwarderLocalName -ItemType Directory
    
    $deployerMetaName = $forwarderfolderName + "\meta"
    New-Item -Path $deployerMetaName -ItemType Directory


    $localFile =  $forwarderLocalName + "\app.conf"
    New-Item $localFile
    Set-Content -Path $localFile "[install]"
    add-Content -Path $localFile "state = enabled"
    add-Content -Path $localFile ""
    Add-Content -path $localFile "[package]"
    Add-Content -path $localFile "check_for_updates = false"
    add-Content -Path $localFile ""
    Add-Content -path $localFile "[ui]"
    Add-Content -path $localFile "is_visible = false"
    Add-Content -path $localFile "is_manageable = false"

    $indexPartitionFile =  $forwarderLocalName + "\server.conf"
    New-Item $indexPartitionFile
    Set-Content -Path $indexPartitionFile "[license]"
    $tempLicenseServerIP = "master_uri = https://" + $licenseServerIPAddress 
    add-Content -Path $indexPartitionFile $tempLicenseServerIP
  
    $metadataFile =  $deployerMetaName + "\local.meta"
    New-Item $metadataFile
    Set-Content -Path $metadataFile "[]"
    add-Content -Path $metadataFile "access = read : [ * ], write : [ admin ]"
    add-Content -Path $metadataFile "export = system" 
}

$writeFilePath 
if ($IsWindows){
   
    $someString = get-location 
    $writeFilePath = $somestring.path + "\splunkApps\"

}
else{
    $someString = get-location 
    $writeFilePath = $somestring.path + "/splunkApps/"
}

$indexerIPs = New-Object -TypeName 'System.Collections.ArrayList'; 
$indexerListString = ""


$sName = Read-Host "What will the name of the Splunk Environment be named?"
Get-IndexerIpInfo -siteName $siteName

$deployServer = Read-Host "Will you be using a deployment server? (y/n)"
if ($deployServer -eq "y"){
    $deploymentServerIP = Read-Host "What is the deployment server's address and port?  (example 10.5.5.1:8089)"
    Create-DeploymentServerApp -siteName $sName  -deploymentServerIPAddress $deploymentServerIP
}

$licenseServer = Read-Host "Will you be setting up a license server? (y/n)"
if($licenseServer -eq "y"){
    $licenseServerIP = Read-Host "What is the Licensing Server IP address and port (example 10.6.6.1:8089)"
    Create-LicensingApp -siteName $sName -licenseServerIPAddress $licenseServerIP
}

$forwardingApp = Read-Host "Will you be forwarding data to another location? (y/n) This does not need Indexer IPs bc it will use the IPs you supplied for Indexers above"
if($forwardingApp -eq "y"){
    Create-ForwardingApp -siteName $sName 
}

Create-IndexVolumeSettings -siteName $sName
Create-Indexes -siteName $sName


Write-Host "Wrote your apps to " + $writeFilePath

