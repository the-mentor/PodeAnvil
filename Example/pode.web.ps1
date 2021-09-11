############## START HEADER - DO NOT CHANGE THIS SECTION ##############
#This Line enables the app to run on computers that do not have Pode and Pode.Web Installed
$Env:PSModulePath = $Env:PSModulePath + ";$PSScriptRoot"

Import-Module -Name Pode.Web

$WebServerConfig = Get-Content -Path "$PSScriptRoot\webserver.json" | ConvertFrom-Json



Start-PodeServer -DisableTermination {
    Add-PodeEndpoint -Address $($WebServerConfig.address) -Port $($WebServerConfig.port) -Protocol $($WebServerConfig.protocol)
############## END HEADER- DO NOT CHANGE THIS SECTION ##############

    # e use of the pode.web templates
    Use-PodeWebTemplates -Title 'PodeAnvil Demo App' -Theme Light

    Set-PodeWebHomePage -NoTitle -Layouts @(
        New-PodeWebHero -Title 'Welcome to PodeAnvil Demo App' -Message 'This is the home page' -Content @(
            New-PodeWebText -Value 'Here is some text!' -InParagraph -Alignment Center
        )

        $chartData = {
            $count = 1
            if ($WebEvent.Data.FirstLoad -eq '1') {
                $count = 4
            }

            return (1..$count | ForEach-Object {
                    @{
                        Key    = $_
                        Values = @(
                            @{
                                Key   = 'Example1'
                                Value = (Get-Random -Maximum 10)
                            },
                            @{
                                Key   = 'Example2'
                                Value = (Get-Random -Maximum 10)
                            }
                        )
                    }
                })
        }

        $processData = {
            Get-Process |
            Sort-Object -Property CPU -Descending |
            Select-Object -First 10 |
            ConvertTo-PodeWebChartData -LabelProperty ProcessName -DatasetProperty CPU, Handles
        }

        New-PodeWebGrid -Cells @(
            New-PodeWebCell -Content @(
                New-PodeWebChart -Name 'Line Example 1' -NoAuth -Type Line -ScriptBlock $chartData -Append -TimeLabels -MaxItems 15 -AutoRefresh -AsCard
            )
            New-PodeWebCell -Content @(
                New-PodeWebChart -Name 'Top Processes' -NoAuth -Type Bar -ScriptBlock $processData -AutoRefresh -RefreshInterval 10 -AsCard
            )
            New-PodeWebCell -Content @(
                New-PodeWebCounterChart -Counter '\Processor(_Total)\% Processor Time' -MinY 0 -MaxY 100 -NoAuth -AsCard
            )
        )


    )

    # add the page
    Add-PodeWebPage -Name 'Buttons' -Icon Activity -Layouts @(
        New-PodeWebCard -Name "This is a cool card" -Content @(
            New-PodeWebText -Value "this is some text"

            New-PodeWebButton -Name 'Click Me' -DataValue 'Random' -ScriptBlock {
                #Show-PodeWebToast -Message "This came from a button, with a data value of '$($WebEvent.Data['Value'])'!"
                Show-PodeWebNotification -Title 'Hi!' -Body 'Hello, there!' -Icon home
            }

            New-PodeWebButton -Name 'Repository' -Icon 'github' -Url 'https://github.com/Badgerati/Pode.Web'
        )

        New-PodeWebCard -Content @(
            New-PodeWebCodeEditor -Name 'Editor' -Language 'powershell'
        )
    )

    Add-PodeWebPage -Name 'Process' -Icon 'Settings' -ScriptBlock {
        New-PodeWebContainer -Content @(
            New-PodeWebTable -Name 'Process' -DataColumn Name -Sort -Filter -ScriptBlock {
                $data = Get-Process
                $filter = $WebEvent.Data.Filter

                if (![string]::IsNullOrWhiteSpace($filter)) {
                    $filter = "*$($filter)*"
                    #$data = @($data | Where-Object { ($_.psobject.properties.value -match $filter).length -gt 0 })
                    $data = Get-Process $filter
                }

                foreach ($p in $data) {
                    [ordered]@{
                        ProcessName    = $p.ProcessName
                        ID      = $p.id
                        Actions = @(
                            New-PodeWebButton -Name 'Stop' -Icon 'Stop-Circle' -IconOnly -ScriptBlock {
                                Stop-Process -Name $WebEvent.Data.Value -Force | Out-Null
                                Show-PodeWebToast -Message "$($WebEvent.Data.Value) stopped"
                                Sync-PodeWebTable -Id $ElementData.Parent.ID
                            }
                        )
                    }
                }
            }
        )
    }

############## START FOOTER - DO NOT CHANGE THIS SECTION ##############
}
############## END FOOTER DO NOT CHANGE THIS SECTION ##############