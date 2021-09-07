function Copy-PodeModules {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]$Destination
    )

    $InstalledModules = Get-InstalledModule -Name Pode, Pode.Web

    foreach ($Module in $InstalledModules) {
        $ModuleDirectory = $Module.InstalledLocation
        $DestinationModulePath = $(Join-Path -Path $Destination -ChildPath (Join-Path -Path $Module.Name -ChildPath $Module.Version.ToString()))

        Write-Verbose "Copying Module: $($Module.Name) -- From: $ModuleDirectory To: $DestinationModulePath "
        Copy-Item -Path $ModuleDirectory -Destination  $DestinationModulePath -Recurse -Force
    }
}