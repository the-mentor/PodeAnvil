function Install-PodeAnvilNpmPackages {
    Param(
        [switch]$Global
    )

    Write-Verbose "Installing: create-electron-app@latest"
    if ($Global) {
        npm install create-electron-app --global
    }
    else {
        npm install create-electron-app
    }


    Write-Verbose "Building electron app with forge"
    if ($Global) {
        npm install @electron-forge/cli --global
    }
    else {
        npm install @electron-forge/cli
    }


}