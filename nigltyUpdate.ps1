
# --- Configuration Variables ---
# Python command
$PythonCommand = "C:\Users\player\AppData\Local\Programs\Python\Python312\python.exe"

# pip command
$PipCommand = "C:\Users\player\AppData\Local\Programs\Python\Python312\Scripts\pip.exe"

# EIC root directory
$EIC_Dir = "D:\EIC"

# EIC log file path
$Timestamp = Get-Date -Format "yyyy-MM"
$LogFilePath = $EIC_Dir +   "\Logs\NightlyUpdater_" + $Timestamp + ".log"

# Directory containing EIC local script and related modules
$ScriptDirectory = $EIC_Dir + "\Scripts" 

# Directory containing Python scripts and related modules
$PythonScriptsDir = "C:\Users\player\AppData\Local\Programs\Python\Python312\Scripts"

# Define arguments for installing latest updater
$PipArgs = @("install", "https://svs.gsfc.nasa.gov/prepub/abg/eic-hyperwall-media/dist/eic_update-current.tar.gz")

# Define arguments for running consumer task
$ConsumerArgs = @("-m", "eic_update.consumer")



# --- Function to log messages ---
function Write-Log {
    param (
        [string]$Message,
        [string]$Level = "INFO" # INFO, WARN, ERROR
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "$Timestamp [$Level] $Message"
    Add-Content -Path $LogFilePath -Value $LogEntry
    Write-Host $LogEntry # Outputs to console for immediate feedback
}

$CurrPath = $env:path -split ';'
Write-Log -Message $CurrPath
Write-Host $CurrPath






# Check if the EIC root directory exists
if ((Test-Path $EIC_Dir)) {

  # --- Script Execution ---
  Write-Log -Message "Starting EIC Update Consumer script."

  try {
    # Check if the Python executable exists
    #if (-not (Test-Path $PythonExecutable)) {
    #    Write-Log -Message "Error: Python executable not found at '$PythonExecutable'." -Level "ERROR"
    #    exit 1 # Exit with error code
    #}

    # Check if the script directory exists
    if (-not (Test-Path $ScriptDirectory)) {
      Write-Log -Message "Error: Script directory not found at '$ScriptDirectory'." -Level "ERROR"
        exit 1 # Exit with error code
    }


    # Change to the Python Scripts directory
    Set-Location -Path $PythonScriptsDir -ErrorAction Stop | Write-Log -Message "Changed directory to '$PythonScriptsDir'."

    # Install latest updater
    $Result = & $PipCommand @PipArgs 2>&1

    # Check for updater installation errors
    if ($LASTEXITCODE -ne 0) {
        Write-Log -Message "Updater installation exited with error code: $LASTEXITCODE" -Level "ERROR"
        Write-Log -Message "Updater installation output/error: $Result" -Level "ERROR"
    } else {
      Write-Log -Message "Updater installation completed successfully."
      if ($Result) {
        Write-Log -Message "Updater installation Output: $Result"
      }
    }

    # Invoke the consumer
    $Result = & $PythonCommand @ConsumerArgs 2>&1

    # Check for consumer task output or errors
    if ($LASTEXITCODE -ne 0) {
        Write-Log -Message "Consumer task exited with error code: $LASTEXITCODE" -Level "ERROR"
        Write-Log -Message "Consumer task Output/Error: $Result" -Level "ERROR"
    } else {
      Write-Log -Message "Consumer task completed successfully."
      if ($Result) {
        Write-Log -Message "Consumer task Output: $Result"
      }
    }

} catch {
  # Catch any PowerShell-specific errors during execution
  Write-Log -Message "PowerShell error occurred: $($_.Exception.Message)" -Level "ERROR"
  Write-Log -Message "Error details: $($_.Exception | Format-List -Force | Out-String)" -Level "ERROR"
  exit 1 # Exit with error code
}

}

Write-Log -Message "Finished EIC Update Consumer script execution."
