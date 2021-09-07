############## START - DO NOT CHANGE THIS SECTION ##############
#This Line enables the app to run on computers that do not have Pode and Pode.Web Installed
$Env:PSModulePath = $Env:PSModulePath + ";$PSScriptRoot"

Import-Module -Name Pode.Web

$WebServerConfig = Get-Content -Path "$PSScriptRoot\webserver.json" | ConvertFrom-Json

############## END - DO NOT CHANGE THIS SECTION ##############

Start-PodeServer -DisableTermination {
    Add-PodeEndpoint -Address $($WebServerConfig.address) -Port $($WebServerConfig.port) -Protocol $($WebServerConfig.protocol)

	# set the use of the pode.web templates
    Use-PodeWebTemplates -Title 'PodeAnvile - Electron Test' -Theme Light

    # add the page
    Add-PodeWebPage -Name Page1 -Icon Activity -Layouts @(
        New-PodeWebCard -Name "This is a cool card" -Content @(
            New-PodeWebText -Value "this is some text"
        )
    )
}