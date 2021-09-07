function New-PodeAnvilApp {
    <#
    .SYNOPSIS
    Generate Pode/Pode.Web Desktop App.

    .DESCRIPTION
    Generate an electron app that utilizes Pode and Pode.Web as its backend.

    .PARAMETER Path
    The path to the .ps1 file you want to base the app on.

    .PARAMETER Name
    The name of the electron app.

    .PARAMETER OutputPath
    The output path for electron application.

    .PARAMETER Port
    The port pode web interface will listen to (important if running multiple instances for pode web or multiple PodeAnvil application)

    #>

    param(
        [Parameter(Mandatory)]$Path,
        [Parameter(Mandatory)]$Name,
        [Parameter()]$OutputPath,
        [Parameter()][ValidateSet("pwsh", "powershell")]$PowerShellExecutable,
        [Parameter()][ValidateRange(10000 , 65535)][int]$Port = 19876,
        [Switch]$Force
    )

    BEGIN {
        $ModulePath = (Get-Item $PSScriptRoot).parent

        if ($IsLinux -or $IsMacOS) {
            $PowerShellExecutable = 'pwsh'
        }
        else {
            if ($null -eq $PowerShellExecutable) {
                $PowerShellExecutable = 'powershell'
            }
        }

        #check if index.js exists
        $IndexJsPath = (Join-Path -Path $ModulePath.FullName -ChildPath "index.js")
        if (Test-Path -Path $IndexJsPath -ErrorAction Stop) {

        }

        #check if webserver.json exists and read its content
        $WebServerConfigPath = (Join-Path -Path $ModulePath.FullName -ChildPath "webserver.json")
        if (Test-Path -Path $WebServerConfigPath -ErrorAction Stop) {
            Write-Verbose "Reading WebServerConfig from $WebServerConfigPath"
            $WebServerConfig = Get-Content -Path $WebServerConfigPath -ErrorAction Stop | ConvertFrom-Json -ErrorAction Stop
        }

        if (Test-Path -Path $Path) {
            $ps1file = Get-Item -Path $Path
            if ($ps1file.Name -notlike '*.ps1') {
                throw "Please specify a ps1 file in `$Path ($Path)"
            }
        }
        else {
            throw
        }

        $Npx = Get-Command npx
        if ($null -eq $Npx) {
            throw "NodeJS is required to run New-PodeAnvilApp you can download it here: https://nodejs.org"
        }

        $Git = Get-Command git
        if ($null -eq $Git) {
            throw "Git is required to run New-PodeAnvilApp."
        }

        if ($null -eq $OutputPath) {
            $OutputPath = $PWD
            Write-Verbose "No output path specified. Using: $OutputPath"
        }
        else {
            $OutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
            Write-Verbose "Output path resolved to: $OutputPath"
        }

        if (Test-Path (Join-Path $OutputPath $Name)) {
            Write-Verbose "Output path exists. Removing it."
            Remove-Item (Join-Path $OutputPath $Name) -Force -Recurse
        }

        if (-not (Test-Path $OutputPath)) {
            Write-Verbose "Output path does not exist. Creating new output path."
            New-Item -Path $OutputPath -ItemType Directory | Out-Null
        }
    }

    PROCESS {
        Push-Location $OutputPath

        Write-Verbose "Installing: create-electron-app@latest"
        npm install create-electron-app #--global

        Write-Verbose "Creating electron app: $Name"
        npx create-electron-app $Name

        Pop-Location

        $ElectronSourceDir = [IO.Path]::Combine($OutputPath, $Name, 'src')
        Write-Verbose "ElectronSourceDir: $ElectronSourceDir"

        Write-Verbose "Copy Pode PS1 File $ps1file"
        Copy-Item -Path $ps1file -Destination $((Join-Path -Path $ElectronSourceDir -ChildPath $ps1file.Name))

        #copy Index.js file to the Electron Source Directory
        Copy-Item -Path $IndexJsPath -Destination $((Join-Path -Path $ElectronSourceDir -ChildPath "index.js")) -Force

        Copy-PodeModules -Destination $ElectronSourceDir

        #Modify Web Server Config
        $WebServerConfig.powershell_exec = $PowerShellExecutable
        $WebServerConfig.port = $Port
        $WebServerConfig.pode_script_filename = $ps1file.Name

        #Create Web Server Config JSON file
        $WebServerConfig | ConvertTo-Json | Set-Content -Path "$ElectronSourceDir\webserver.json" -Force

        Write-Verbose "Building electron app with forge"
        npm install @electron-forge/cli

        Set-Location (Join-Path -Path $OutputPath -ChildPath $Name)
        electron-forge make
    }

    END {

    }
}