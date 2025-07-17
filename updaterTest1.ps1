# --- Config ---
$Python    = "C:\Users\player\AppData\Local\Programs\Python\Python312\python.exe"
$Pip       = "C:\Users\player\AppData\Local\Programs\Python\Python312\Scripts\pip.exe"
$EICDir    = "D:\EIC"
$LogDir    = Join-Path $EICDir 'Logs'
$LogFile   = Join-Path $LogDir ("NightlyUpdater_{0:yyyy-MM}.log" -f (Get-Date))

$PipArgs       = @('install','https://svs.gsfc.nasa.gov/prepub/abg/eic-hyperwall-media/dist/eic_update-current.tar.gz')
$ConsumerArgs  = @('-m','eic_update.consumer')
$PythonScripts = "C:\Users\player\AppData\Local\Programs\Python\Python312\Scripts"

# --- Helpers ---
function Write-Log {
    param([string]$Message,[string]$Level='INFO')
    $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$stamp [$Level] $Message" | Tee-Object -FilePath $LogFile -Append
}

# make sure log folder exists
if (-not (Test-Path $LogDir)) { New-Item $LogDir -ItemType Directory | Out-Null }

Write-Log "PATH = $($env:Path -split ';' -join '; ')"

# --- Main ---
if (-not (Test-Path $EICDir)) {
    Write-Log "EIC root '$EICDir' not found." 'ERROR'
    exit 1
}

try {
    Write-Log 'Starting EIC Update Consumer.'

    Set-Location $PythonScripts
    Write-Log "Changed directory to '$PythonScripts'."

    & $Pip @PipArgs 2>&1 | Tee-Object -Variable pipOut
    $pipExit = $LASTEXITCODE
    if ($pipExit) {
        Write-Log "pip exited with $pipExit" 'ERROR'
        Write-Log "pip output:`n$($pipOut -join "`n")" 'ERROR'
        exit $pipExit
    }
    Write-Log 'Updater installation succeeded.'

    & $Python @ConsumerArgs 2>&1 | Tee-Object -Variable conOut
    $conExit = $LASTEXITCODE
    if ($conExit) {
        Write-Log "consumer exited with $conExit" 'ERROR'
        Write-Log "consumer output:`n$($conOut -join "`n")" 'ERROR'
        exit $conExit
    }
    Write-Log 'Consumer completed successfully.'
}
catch {
    Write-Log "PowerShell error: $($_.Exception.Message)" 'ERROR'
    exit 1
}

Write-Log 'Finished EIC Update Consumer.'
