function Set-PodeAnvilPackageConfig {
    param (
        [Parameter(Mandatory)]$PackageConfigPath,
        $AppFriendlyName,
        $AppDescription,
        [version]$AppVersion,
        $IconUrl,
        $SetupIcon,
        $LoadingGif,
        [bool]$NoMSI
    )

    $PackageConfig = Get-Content -Path $PackageConfigPath -Raw | ConvertFrom-Json
    $SquirrelConfig = $PackageConfig.config.forge.makers | Where-Object {$_.Name -match 'squirrel'} | Select-Object -ExpandProperty config

    #Set App Friendly Name
    if ($AppFriendlyName) {
        $PackageConfig.productName = $AppFriendlyName
    }

    #Set App Friendly Name
    if ($AppVersion) {
        $PackageConfig.version = $AppVersion.ToString()
    }

    #Set App Description
    if ($AppDescription) {
        $PackageConfig.description = $AppDescription
    }

    foreach ($parameter in ($PSBoundParameters.Keys.Where({$_ -match 'IconUrl|SetupIcon|LoadingGif|NoMSI'}))) {
        Write-Verbose "Setting SquirrelConfig $($parameter): $($PSBoundParameters[$parameter])"
        $Name = $parameter -replace '^\w', $parameter.Substring(0, 1).ToLower()
        Write-Verbose $Name
        $SquirrelConfig | Add-Member -MemberType NoteProperty -Name $Name -Value $PSBoundParameters[$parameter]
    }

    $PackageConfigPath = $PackageConfigPath -replace '.org','' #used for debugging

    $PackageConfig | ConvertTo-Json -Depth 99 | Out-File -FilePath $PackageConfigPath -Encoding utf8 -Force

    $PackageConfig
    $SquirrelConfig
}

<#
$packageConfig = [IO.Path]::Combine($OutputPath, $Name, 'package.json')
        $squirrelSplat = @{'ConfigPath' = $packageConfig}
        if ($IconUrl) {$squirrelSplat['IconUrl'] = $IconUrl}
        if ($SetupIcon) {
            $iconPath = (Get-ChildItem -Path $src -Filter (Split-Path $SetupIcon -Leaf) -Recurse)[0].FullName
            $squirrelSplat['SetupIcon'] = $iconPath
        }
        if ($LoadingGif) {
            $gifPath = (Get-ChildItem -Path $src -Filter (Split-Path $LoadingGif -Leaf) -Recurse)[0].FullName
            $squirrelSplat['LoadingGif'] = $gifPath
        }

function Set-SquirrelConfig {
    param(
        [Parameter(Mandatory)]
        $ConfigPath,
        $IconUrl,
        $SetupIcon,
        $LoadingGif
    )

    $content = Get-Content -Path $ConfigPath -Raw | ConvertFrom-Json
    $squirrelConfig = $Content.Config.Forge.Makers.Where({$_.Name -like '*squirrel'}).Config
    $keys = $PSBoundParameters.Keys.Where({$_ -ne 'ConfigPath'})

    foreach ($parameter in $keys) {
        Write-Verbose ('Setting SquirrelConfig {0}: {1}' -f $parameter, $PSBoundParameters[$parameter])
        $name = $parameter -replace '^\w', $parameter.Substring(0, 1).ToLower()
        $squirrelConfig | Add-Member -MemberType NoteProperty -Name $name -Value $PSBoundParameters[$parameter]
    }

    $Content | ConvertTo-Json -Depth 10 | Out-File -FilePath $ConfigPath -Force -Encoding utf8
}

#>