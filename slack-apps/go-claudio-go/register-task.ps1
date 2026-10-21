# Registers a Windows scheduled task that runs go-claudio-go's app.py inside
# WSL at logon. Normally called by install.sh.
#
# Usage: .\register-task.ps1 -Distro Ubuntu -App /path/to/app.py
#        .\register-task.ps1 -Remove
param(
    [string]$Distro = "Ubuntu",
    [string]$App,
    [switch]$Remove
)

$ErrorActionPreference = "Stop"
$TaskName = "GoClaudioGo"

if ($Remove) {
    if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
        Stop-ScheduledTask -TaskName $TaskName
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        Write-Host "Removed scheduled task $TaskName"
    }
    exit
}

if (-not $App) {
    throw "-App is required: the Linux path of app.py"
}

# Load the variables install.sh saved, then run the app with output in a log
$LogDir = '~/.local/state/go-claudio-go'
$Command = "set -a; source ~/.config/go-claudio-go/env; set +a; " +
    "export PATH=~/.local/bin:`$PATH PYTHONUNBUFFERED=1; mkdir -p $LogDir; " +
    "exec $App >> $LogDir/app.log 2>&1"

# conhost --headless runs wsl.exe without opening a console window
$action = New-ScheduledTaskAction -Execute "conhost.exe" `
    -Argument "--headless wsl.exe -d $Distro --exec bash -c `"$Command`""
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $env:USERNAME
# Re-run every 5 minutes; IgnoreNew skips it while the app is still running,
# so this only restarts the app after it exits
$trigger.Repetition = (New-ScheduledTaskTrigger -Once -At (Get-Date) `
    -RepetitionInterval (New-TimeSpan -Minutes 5)).Repetition
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive
# No time limit (the default kills the task after 3 days) and run on battery
$settings = New-ScheduledTaskSettingsSet `
    -ExecutionTimeLimit ([TimeSpan]::Zero) `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -MultipleInstances IgnoreNew

Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $trigger `
    -Principal $principal -Settings $settings -Force | Out-Null
Stop-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
Start-ScheduledTask -TaskName $TaskName
Write-Host "Registered and started scheduled task $TaskName"
