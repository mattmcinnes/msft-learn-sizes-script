$repoName = "msft-learn-sizes-script"
$defaultGitDir = "C:\Users\$env:USERNAME\GitHub\$repoName"

## Function to delay and show dots
function DelayDots {
    Start-Sleep -Milliseconds  500
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds  500
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds  500
    Write-Host "." -NoNewline
    Start-Sleep -Milliseconds  500
    Write-Host " "
}

# Define the path to your local repository
$gitDirInput = "C:\Users\$env:USERNAME\GitHub\$repoName"
Write-Host "LOCAL REPO CLONE LOCATION" -BackgroundColor Blue -NoNewline; Write-Host "" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
Write-Host "Here you'll define the location of your local Git directory for the $repoName repository.`n"
$userResponse = Read-Host "Is your '$repoName' local directory located at the default location ($defaultGitDir)?`n(y/n)"
$dirReal = $false
$gitDir = $defaultGitDir
while ($true) {
    if ($userResponse -eq "y") {
        # Double check that the directory exists...
        while ($dirReal -eq $false) {
            if (Test-Path -Path $gitDir) {
                Write-Host "`nDefault Directory found!" -ForegroundColor Green
                $dirReal = $true
                break
            } else {
                Write-Host "The directory does not exist... Please ensure you have a local copy of $repoName and enter the correct path"
                $gitDir = Read-Host "Please enter the full path to your Git directory`n:"
            }
        }
        break
    } elseif ($userResponse -eq "n"){
        # If no, ask the user if its in one of the options, or ask the user to enter the path to their Git directory, then check if it exists in case of typos
        Clear-Host
        $showMessage = $false
        while ($true) {
            Write-Host "LOCAL REPO CLONE LOCATION" -BackgroundColor Blue -NoNewline; Write-Host " - Alternate Location" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "`nCommon options:`n"
            $commonDirsList = "C:\GitHub\$repoName", "C:\Users\$env:USERNAME\Documents\GitHub\$repoName", "C:\Users\$env:USERNAME\GitHub\$repoName", "D:\GitHub\$repoName"
            $commonDirCount = $commonDirsList.Count
            for ($i = 0; $i -lt $commonDirCount; $i++) {
                Write-Host "    $($i + 1). $($commonDirsList[$i])" -ForegroundColor Yellow
            }
            if ($showMessage -eq $true) {
                Write-Host $messageText -ForegroundColor Red
            } else {
                Write-Host "`n" -ForegroundColor DarkGray
            }
            $gitDirInput = Read-Host "`nSelect from the list of common options (enter '1' through '$commonDirCount') or enter the full path to your Git directory:`n"
            if ($gitDirInput -ge 1 -and $gitDirInput -le $commonDirCount) {
                $gitDir = $commonDirsList[$gitDirInput - 1]
                if (Test-Path -Path $gitDir) {
                    Write-Host "`nDirectory found!" -ForegroundColor Green
                    break
                } else {
                    $messageText = "`nERROR: The directory does not exist. Try another default or enter the full path to your Git directory."
                    $showMessage = $true
                    Clear-Host
                }
            } elseif ($girDirInput.Length -gt 2) {
                $gitDir = $gitDirInput
                if (Test-Path -Path $gitDir) {
                    Write-Host "Directory found!" -ForegroundColor Green
                    break
                } else {
                    $messageText = "`nERROR: The directory does not exist. Double-check the path and try again."
                    $showMessage = $true
                    Clear-Host
                }
            } else {
                $messageText = "`nERROR: Invalid input. Please enter a number from '1' to '$commonDirCount' or enter the full path to your Git directory."
                $showMessage = $true
                Clear-Host
            }
        }
        break
    } else {
        Write-Host "Invalid input. Please enter 'y' or 'n'" -ForegroundColor Red
        $userResponse = Read-Host
    }
}
Write-Host "`nThe directory is set to: $gitDir" -ForegroundColor Magenta
Read-Host "`nPress Enter to continue`n"


# Navigate to the repository directory
Set-Location -Path $gitDir

# Execute the git pull command and capture the output
$gitOutput = git pull origin main 2>&1

# Check the output for specific messages
if ($gitOutput -match "Already up to date.") {
	Write-Output "`nThe repository is already up to date."
} elseif ($gitOutput -match "Updating") {
	Write-Output $gitOutput
} else {
	Write-Output "`nAn error occurred during git pull: $gitOutput"
}
# Output a message indicating the pull is complete
Write-Host "`nScript complete! Closing this script" -NoNewLine
DelayDots
Exit