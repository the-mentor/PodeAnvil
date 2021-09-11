function Confirm-PodeAnvilDependencies {

    try {Get-InstalledModule -Name Pode -ErrorAction Stop | Out-Null} catch {throw "Pode Module is missing please install it using: Install-Module -Name Pode"}
    try {Get-InstalledModule -Name Pode.Web -ErrorAction Stop | Out-Null} catch {throw "Pode Module is missing please install it using: Install-Module -Name Pode.Web"}

    $Npm = Get-Command npm
    if ($null -eq $Npm) {
        throw "NodeJS is required to run New-PodeAnvilApp you can download it here: https://nodejs.org"
    }

    $Npx = Get-Command npx
    if ($null -eq $Npx) {
        throw "NodeJS is required to run New-PodeAnvilApp you can download it here: https://nodejs.org"
    }

    $Git = Get-Command git
    if ($null -eq $Git) {
        throw "Git is required to run New-PodeAnvilApp."
    }

}