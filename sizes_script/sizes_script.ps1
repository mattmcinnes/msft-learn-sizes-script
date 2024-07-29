# INITIAL VARIABLES:

## Script version:
$scriptVersion = "Beta 1.4.1"

## Test mode
$testMode = $false

## Demo mode
$demoMode = $false

## Script mode
$scriptModeTitle = ""

## Repo name (change after the great divide)
$repoName = "azure-docs-pr"

## Default azure-docs-pr path (adjust this path as necessary)
$defaultGitDir = "C:\Users\$env:USERNAME\GitHub\$repoName"

## Important directories for the script
$originalDirectory = Get-Location
$archiveDirectory = "$originalDirectory\archive"
$tempDirectory = "$originalDirectory\temp"
$templateDirectory = "$originalDirectory\templates"
$inputDirectory = "$originalDirectory\INPUT"
$examplesDirectory = "$originalDirectory\examples"
$outputDirectory = "$originalDirectory\OUTPUT"
$batchDirectory = "$originalDirectory\BATCH"

## Today's Date
$todayDate = Get-Date -Format "MM-dd-yyyy"

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

function TestMode {
    Write-Host "`nTesting mode is enabled. Selecting defaults`n"
    $inputLetter = "a"
    $inputNumber = "1"
    $seriesValid = $true
}

# PRE-RUN OPS AND CLEANUP
## Delete all data in the temp directory
Get-ChildItem -Path $tempDirectory -Recurse | Remove-Item -Force
## Create an info file in the temp directory
New-Item -Path $tempDirectory -Name ".temp" -ItemType "file" -Force | Out-Null
## Create an info file in the INPUT directory
New-Item -Path $inputDirectory -Name ".temp" -ItemType "file" -Force | Out-Null
## Create an info file in the archive directory
New-Item -Path $archiveDirectory -Name ".temp" -ItemType "file" -Force | Out-Null
## Create an info file in the BATCH directory
New-Item -Path $batchDirectory -Name ".temp" -ItemType "file" -Force | Out-Null


# WELCOME MESSAGE
$spaceCount = 17 - $scriptVersion.Length
$spaces = " " * $spaceCount
$scriptVersionExt = $scriptVersion  + $spaces
function IntroBlock {
Write-Host "+----------------------------------------------------------------------+" -ForegroundColor Yellow
Write-Host "|" -NoNewline -ForegroundColor Yellow; Write-Host "               Welcome to the Azure Sizes docs script!                " -NoNewline; Write-Host "|" -ForegroundColor Yellow
Write-Host "|" -NoNewline -ForegroundColor Yellow; Write-Host "   Written to help you easily create, update, or retire sizes docs.   " -NoNewline; Write-Host "|" -ForegroundColor Yellow
Write-Host "|" -NoNewline -ForegroundColor Yellow; Write-Host "                                                                      " -NoNewline; Write-Host "|" -ForegroundColor Yellow
Write-Host "|" -NoNewline -ForegroundColor Yellow; Write-Host "                   - Created by @mattmcinnes                          " -NoNewline -ForegroundColor DarkGray; Write-Host "|" -ForegroundColor Yellow
Write-Host "|" -NoNewline -ForegroundColor Yellow; Write-Host "                   - Script version $scriptVersionExt                 " -NoNewline -ForegroundColor DarkGray; Write-Host "|" -ForegroundColor Yellow
Write-Host "+----------------------------------------------------------------------+" -ForegroundColor Yellow
}

Clear-Host #Clear the screen
IntroBlock #Display the welcome message


# WHAT OPERATION IS THE SCRIPT RUNNING
Write-Host "`nSELECT ACTION`n" -BackgroundColor Blue
Write-Host "What do you plan on doing with this script?`n"
Write-Host "    a. Create a new size series" -ForegroundColor Yellow
Write-Host "    b. Update an existing size series" -NoNewLine -ForegroundColor DarkGray; Write-Host "(not yet fully implemented)" -ForegroundColor DarkGray
Write-Host "    c. Retire an existing size series" -NoNewLine -ForegroundColor DarkGray; Write-Host "(not yet fully implemented)" -ForegroundColor DarkGray
Write-Host "    d. Data cleanup from previous operations"
while ($true) {
    $inputLetter = Read-Host "`nEnter the letter of the action you'd like to perform (e.g., 'a' for 'Create a new size series')`n"
    if ($inputLetter -match '^[a-d]$') {
        break
    } else {
        Write-Host "Invalid input. Please enter a letter from 'a' to 'd'`n" -ForegroundColor Red
    }
}
if ($inputLetter -eq "a") {
    $scriptOperation = "create"
} elseif ($inputLetter -eq "b") {
    $scriptOperation = "update"
} elseif ($inputLetter -eq "c") {
    $scriptOperation = "retire"
} elseif ($inputLetter -eq "d") {
    $scriptOperation = "cleanup"
}
$scriptOpIng = $scriptOperation.Substring(0, $scriptOperation.Length - 1) + "ing"
if ($scriptOperation -eq "cleanup") {
    Write-Host "`nYou're running the script in cleanup mode." -ForegroundColor Magenta
} else {
    Write-Host "`nYou're $scriptOpIng a size series." -ForegroundColor Magenta
}


Read-Host "`nPress Enter to continue`n"
Clear-Host


## CLEANUP OPERATION
if ($scriptOperation -eq "cleanup") {
    Write-Host "CLEANUP OPERATION" -BackgroundColor Red -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "This operation will remove all files in the 'OUTPUT', 'INPUT', and 'BATCH' directories.`n" -ForegroundColor Red
    Write-Host "WARNING: This operation cannot be undone. Please ensure you have backed up any important data before continuing.`n" -ForegroundColor Red
    Write-Host "NOTE: This operation will not remove any files in the 'archive' directory.`n" -ForegroundColor Yellow
    while ($true) {
        $userResponse = Read-Host "Type 'e' to erase the .\OUTPUT, .\INPUT, and .\BATCH directories and continue`n"
        if ($userResponse -eq "e") {
            break
        } else {
            Write-Host "Invalid input. Please type 'e' to erase the .\OUTPUT and .\INPUT directories and continue`n" -ForegroundColor Red
        }
    }
    Get-ChildItem -Path $outputDirectory -Recurse | Remove-Item -Force -Recurse
    Get-ChildItem -Path $inputDirectory -Recurse | Remove-Item -Force -Recurse
    Get-ChildItem -Path $batchDirectory -Recurse | Remove-Item -Force -Recurse
    Write-Host "`nErasing old files."
    Write-Host "`nThe script will now reset" -NoNewline; DelayDots
    .\sizes_script.ps1
}

# SINGLE RUN OR BATCH MODE
Clear-Host
$showMessage = $false
$invalidInput = $false
$batchMode = $false
$validContinue = $false
$validSelect = $null
$readOnlyMode = $false


$filesInBatch = Get-ChildItem -Path $batchDirectory -File
if ($filesInBatch.Count -gt 0) {
    $filesinBatchDir = $true
    $showMessage = $true
    $showMessageContent = "It looks like there is a batch operation in progress from a previous run. Select Batch run to continue this operation."
}

while ($true) {
    Write-Host "BATCH MODE TOGGLE" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "Are you running this script as a part of a batch operation (i.e. multiple sizes in one PR), a single series run, or a read-only run?`n"
    if ($validSelect -eq "a") { Write-Host "   [a. Single run]" -ForegroundColor Green } else { Write-Host "    a. Single run" }
    Write-Host "        - This script will run once and create files for a single series." -ForegroundColor DarkGray
    Write-Host "        - Markdown files will be stored in the 'OUTPUT' directory" -ForegroundColor DarkGray
    Write-Host " "
    if ($validSelect -eq "b") { Write-Host "   [b. Batch run]" -ForegroundColor Green } else { Write-Host "    b. Batch run" }
    Write-Host "        - You can run this script multiple times to create a single PR with multiple sizes affected." -ForegroundColor DarkGray
    Write-Host "        - Markdown files are moved to a newly created 'BATCH' after script completion." -ForegroundColor DarkGray
    Write-Host "        - " -ForegroundColor DarkGray -NoNewline ; Write-Host "NOTE:" -BackgroundColor DarkYellow -NoNewline ; Write-Host " The 'OUTPUT' folder will only contain per-run files." -ForegroundColor DarkGray
    Write-Host "        - " -ForegroundColor DarkGray -NoNewline ; Write-Host "WARNING:" -BackgroundColor Red -NoNewline ; Write-Host " Do not mix size types in batch mode (1 compute-optimized size + 2 general-purpose sizes)." -ForegroundColor DarkGray
    Write-Host " "
    if ($validSelect -eq "c") { Write-Host "   [c. Read-only run]" -ForegroundColor Green } else { Write-Host "    c. Read-only run" }
    Write-Host "        - Read-only mode clears out the script's OUTPUT folder for future runs." -ForegroundColor DarkGray
    Write-Host "        - " -ForegroundColor DarkGray -NoNewline ; Write-Host "WARNING:" -BackgroundColor Red -NoNewline ; Write-Host " No data will be saved after the script is finished." -ForegroundColor DarkGray


    if ($invalidInput -eq $true) { Write-Host "`nERROR: Invalid input.`n" -ForegroundColor Red }
    if ($showMessage -eq $true -and $invalidInput -eq $false) { Write-Host "`n$showMessageContent`n" -ForegroundColor Magenta }
    if ($showMessage -eq $false -and $invalidInput -eq $false) { Write-Host "`n`n" }

    Write-Host "Enter a letter 'a - 'c' to select the script operation and move files accordingly.`n"

    $userResponse = Read-Host
    if ($userResponse -eq "a") {
        $showMessageContent = "Script is in single-run mode. Press Enter to continue"
        $batchMode = $false ; $readOnlyMode = $false
        $showMessage = $true ; $validContinue = $true ; $invalidInput = $false
        $validSelect = "a"
        Clear-Host
    } elseif ($userResponse -eq "b") {
        $showMessageContent = "Script is in batch mode. Press Enter to continue"
        $batchMode = $true ; $readOnlyMode = $false
        $showMessage = $true ; $validContinue = $true ; $invalidInput = $false
        $validSelect = "b"
        Clear-Host
    } elseif ($userResponse -eq "c") {
        $showMessageContent = "Script is in read-only mode. Press Enter to continue"
        $batchMode = $false ; $readOnlyMode = $true
        $showMessage = $true
        $validContinue = $true
        $validSelect = "c"
        Clear-Host
    } elseif ($userResponse -eq "" -and $validContinue -eq $true) {
        Write-Host "`nContinuing...:"
        Clear-Host
        break
    } else {
        Clear-Host
        $invalidInput = $true
    }
}

# ALIAS ENTRY

## Microsoft Alias
$validInput = $true
$showMessage = $false
$validContinue = $false
while ($true) {
    Clear-Host
    Write-Host "ALIAS ENTRY" -BackgroundColor Blue -NoNewline; Write-Host " - MS Alias" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "What is your Microsoft Alias (for ms.author).`n"
    Write-Host "NOTE: You will enter your GitHub alias in the next step." -ForegroundColor DarkYellow
    if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
    if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
    if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n" }
    if ($validContinue -eq $false) { $userResponse = Read-Host "Enter your Microsoft alias`n"
    } else { $userResponse = Read-Host "Press Enter to continue or enter a different alias`n" }
    if ($userResponse -ne "") {
        $validInput = $true
        $validContinue = $true
        $showMessage = $true
        $msftAlias = $userResponse
        $messageText = "Hello $msftAlias!"
    } elseif ($userResponse -eq "" -and $validContinue -eq $true) {
        break
    } elseif ($testMode -eq $true) {
        $validInput = $true
        $showMessage = $false
        Write-Host "Test mode is enabled. Setting defaults..."
        Read-Host "`nPress Enter to continue`n"
        break
    } else { 
        $validInput = $false
        $showMessage = $false
        $errorMessage = "Invalid input. Please enter your alias."
    }
}

## GitHub Alias
$validInput = $true
$showMessage = $false
$validContinue = $false
while ($true) {
    Clear-Host
    Write-Host "ALIAS ENTRY" -BackgroundColor Blue -NoNewline; Write-Host " - GitHub Alias" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "What is your GitHub Alias (for author and topic notifications)`n"
    Write-Host "NOTE: If your GitHub alias is the same as your Microsoft alias, entering 's' will reuse the previous value." -ForegroundColor DarkYellow
    if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
    if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
    if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n" }
    if ($validContinue -eq $false) { $userResponse = Read-Host "Enter your GitHub alias`n"
    } else { $userResponse = Read-Host "Press Enter to continue or enter a different alias`n" }
    if ($userResponse -ne "" -and $userResponse -ne "s") {
        $validInput = $true
        $validContinue = $true
        $showMessage = $true
        $gitAlias = $userResponse
        $messageText = "Hello $gitAlias!"
    } elseif ($userResponse -eq "" -and $validContinue -eq $true) {
        break
    } elseif ($userResponse -eq "s") {
        $validInput = $true
        $showMessage = $true
        $validContinue = $true
        $gitAlias = $msftAlias
        $messageText = "Hello again, $gitAlias!"
    } elseif ($testMode -eq $true) {
        $validInput = $true
        $showMessage = $false
        Write-Host "Test mode is enabled. Setting defaults..."
        Read-Host "`nPress Enter to continue`n"
        break
    } else { 
        $validInput = $false
        $showMessage = $false
        $errorMessage = "Invalid input. Please enter your alias."
    }
}



# DATA WARNING AND RESET
Clear-Host 
if ($batchMode -eq $false) {
    Write-Host "DATA RESET" -BackgroundColor Red -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "WARNING:"`
    "ALL FILES IN THE SCRIPT 'OUTPUT' and 'INPUT' DIRECTORY WILL BE REMOVED!"`
    "`nIf you've used this script previously there might be important data in these directories."`
    "`nPlease move all data to a safe location or ensure it can be erased before continuing." -ForegroundColor Red

    Write-Host "
    Output Directory: 
        - Path: $outputDirectory
        - Operation: All data deleted

    Input Directory: 
        - Path: $inputDirectory
        - Operation: Data moved to 'archive' directory
    " -ForegroundColor Yellow

    if ($demoMode -eq $true) {
        Write-Host "`nNOTE: Demo mode is enabled but the script will still erase the INPUT directory and create new files.`n" -ForegroundColor DarkYellow
    }
    while ($true) {
        if ($testMode -eq $true) {
            $userResponse = "e"
        } else {
            $userResponse = Read-Host "`nType 'e' to erase the .\OUTPUT directory and continue`n"
        }
        if ($userResponse -eq "e") {
            break
        } else {
            Write-Host "Invalid input. Please type 'e' to erase the .\OUTPUT directory and continue`n"
        }
    }
    Get-ChildItem -Path $outputDirectory -Recurse | Remove-Item -Force
    Get-ChildItem -Path $inputDirectory -Recurse | Move-Item -Destination $archiveDirectory -Force
    Write-Host "`nErasing old files" -NoNewline
    DelayDots
    Clear-Host
} else {
    Write-Host "DATA MIGRATION" -BackgroundColor DarkYellow -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "WARNING:"`
    "ALL FILES IN THE SCRIPT 'OUTPUT' and 'INPUT' DIRECTORY WILL BE MOVED!"`
    "`nIf you've used this script previously for non-batch operations there might be data in these directories you do not want in the batch."`
    "`nPlease move all non-batch data to a safe location or manually erase it before continuing." -ForegroundColor Yellow

    Write-Host "
    Output Directory: 
        - Path: $outputDirectory
        - Operation: All data moved to 'BATCH' directory

    Input Directory: 
        - Path: $inputDirectory
        - Operation: Data moved to 'archive' directory
    " -ForegroundColor DarkGray
    Read-Host "`nClose the script to cancel. Press Enter to continue.`n"

    $fileCount = 0
    $outputFiles = Get-ChildItem -Path $outputDirectory -Recurse
    foreach ($file in $outputFiles) {
        $file | Move-Item -Destination $batchDirectory -Force
        $fileCount++
    }
    Write-Host "`n$fileCount files moved from OUTPUT to BATCH directory" -ForegroundColor Green

    $fileCount = 0
    $inputFiles = Get-ChildItem -Path $inputDirectory -Recurse
    foreach ($file in $inputFiles) {
        $file | Move-Item -Destination $archiveDirectory -Force
        $fileCount++
    }
    Write-Host "`n$fileCount files moved from INPUT to archive directory" -ForegroundColor Green

    Read-Host "`nOperations complete. Press Enter to continue.`n"
    Clear-Host
}

# IS LOCAL GIT DIRECTORY DEFAULT?
$gitDirInput = "C:\Users\$env:USERNAME\GitHub\$repoName"
Write-Host "LOCAL REPO CLONE LOCATION" -BackgroundColor Blue -NoNewline; Write-Host "" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
Write-Host "Here you'll define the location of your local Git directory for the $repoName repository.`n"
Write-Host "NOTE: If you're just exploring the script and don't want to run any Git operations, type 'd' for demo mode.`n" -ForegroundColor DarkYellow
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
    } elseif ($userResponse -eq "z") {
        $dirReal = $true
        Write-Host "`n-=WELCOME TO TESTING MODE!=-`n" -ForegroundColor Green -NoNewLine; Write-Host "The script will continue without creating a new branch or creating files. `nThis is purely for testing"
        $testMode = $true
        $scriptModeTitle = " (TESTING MODE)" 
        break
    } elseif ($userResponse -eq "d") {
        $dirReal = $true
        Write-Host "`n-=WELCOME TO DEMO MODE!=-`n" -ForegroundColor Green -NoNewLine; Write-Host "The script will continue without checks or Git operations. `nIt will still create files, but it will not require that they're edited, nor will it commit them to a branch."
        $demoMode = $true
        $scriptModeTitle = " (DEMO MODE)"
        $gitDir = $originalDirectory
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
Clear-Host




# DEFINE SIZE SERIES TYPE
$showMessage = $false
while ($true) {
    Write-Host "SIZE TYPE" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "What type (category) is your size series?`n"
    Write-Host "    a. General-purpose" -ForegroundColor Yellow
    Write-Host "    b. Compute-optimized" -ForegroundColor Yellow
    Write-Host "    c. Memory-optimized" -ForegroundColor Yellow
    Write-Host "    d. Storage-optimized" -ForegroundColor Yellow
    Write-Host "    e. GPU-accelerated" -ForegroundColor Yellow
    Write-Host "    f. FPGA-accelerated" -ForegroundColor Yellow
    Write-Host "    g. High-performance-compute" -ForegroundColor Yellow
    Write-Host "    h. Other" -ForegroundColor Yellow
    if ($showMessage -eq $true) {
        Write-Host "`nERROR: Invalid input. Please enter a letter from 'a' to 'h'`n" -ForegroundColor Red
    } else {
        Write-Host "`n `n" -ForegroundColor DarkGray
    }
    if ($testMode -eq $true) {
        TestMode
        break
    } else {
        $inputLetter = Read-Host "Enter the letter of the correct category (e.g., 'a' for 'General-purpose' type)`n"
    }
    if ($inputLetter -match '^[a-h]$') {
        break
    } else {
        $showMessage = $true
        Clear-Host
    }
}

if ($inputLetter -eq "a") {
    $seriesType = "general-purpose"
    $seriesTypeFancy = "General purpose"
    $seriesTypeShort = "gen"
} elseif ($inputLetter -eq "b") {
    $seriesType = "compute-optimized"
    $seriesTypeFancy = "Compute optimized"
    $seriesTypeShort = "comp"
} elseif ($inputLetter -eq "c") {
    $seriesType = "memory-optimized"
    $seriesTypeFancy = "Memory optimized"
    $seriesTypeShort = "mem"
} elseif ($inputLetter -eq "d") {
    $seriesType = "storage-optimized"
    $seriesTypeFancy = "Storage optimized"
    $seriesTypeShort = "stor"
} elseif ($inputLetter -eq "e") {
    $seriesType = "gpu-accelerated"
    $seriesTypeFancy = "GPU accelerated"
    $seriesTypeShort = "gpu"
} elseif ($inputLetter -eq "f") {
    $seriesType = "fpga-accelerated"
    $seriesTypeFancy = "FPGA accelerated"
    $seriesTypeShort = "fpga"
} elseif ($inputLetter -eq "g") {
    $seriesType = "high-performance-compute"
    $seriesTypeFancy = "High Performance Compute (HPC)"
    $seriesTypeShort = "hpc"
} elseif ($inputLetter -eq "h") {
    $seriesType = "other"
    Write-Host "`nUNSUPPORTED OPERATION: Please contact a content developer to add a new category.`n" -ForegroundColor Red
    return
}
## Now that we know the type, define the full size path
if ($demoMode -eq $false) {
    $sizesTypeDirectory = $gitDir + "\articles\virtual-machines\sizes\$seriesType"
} else {
    $sizesTypeDirectory = "${originalDirectory}\demo"
}
## Let the user know the type they've selected
Write-Host "`nYou're $scriptOpIng a $seriesTypeFancy type series." -ForegroundColor Magenta
Read-Host "`nPress Enter to continue`n"
Clear-Host






# DEFINE SERIES FAMILY
$showMessage = $false
while ($true) {
    Write-Host "SIZE FAMILY" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "What family or sub-family does this series belong to?`n"

    $files = Get-ChildItem -Path $sizesTypeDirectory -Filter '*-family.md*'

    # Iterate over each file and assign a letter
    $counter = 0
    foreach ($file in $files) {
        # Output the file name and its assigned letter
        $counter++
        $familyFileTrunk = $file.Name -replace "-family\.md", " family"
        $familyFileTrunk = $familyFileTrunk.Substring(0, 2).ToUpper() + $familyFileTrunk.Substring(2)
        Write-Host "    $counter. ${familyFileTrunk}" -ForegroundColor Yellow
    }
    $maxValidReadEntries = $counter
    $counter++
    Write-Host "    $counter. Other (not listed)" -ForegroundColor Yellow

    if ($showMessage -eq $true) {
        Write-Host $messageText -ForegroundColor Red
    } else {
        Write-Host "`n `n" -ForegroundColor DarkGray
    }

    if ($testMode -eq $true) {
        TestMode
        $inputNumber = "1"
    } else {
        $inputNumber = Read-Host "Enter the number of the correct family or subfamily (e.g., '1' for 'A family')`n"
    }
    if ($inputNumber -match "^[1-$maxValidReadEntries]$") {
        break
    } elseif ($inputNumber -eq $counter) {
        $messageText = "`nUNSUPPORTED OPERATION: Please contact a content developer to add a family.`n"
        $showMessage = $true
        Clear-Host
    } else {
        $messageText = "`nERROR: Invalid input. Please enter a number from 1 to $counter or 'done'.`n"
        $showMessage = $true
        Clear-Host
    }
}

## Set the family name based on number selection
$selectedFile = $files[$inputNumber - 1].Name
$seriesFamily = $selectedFile -replace "-family.md", "" 
$seriesFamilyUpper = $seriesFamily.ToUpper()
Write-Host "`nYou're $scriptOpIng a '$seriesFamilyUpper' family, $seriesTypeFancy series." -ForegroundColor Magenta
Read-Host "`nPress Enter to continue`n"
Clear-Host







# DEFINE THE SIZE SERIES NAME LOOP
$validFileSelect = $false
while ($validFileSelect -eq $false) {

    # Check if $seriesInput starts with $seriesFamily, case-insensitively
    Write-Host "SIZE SERIES NAME" -NoNewline -BackgroundColor Blue; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "What is the full name of the size series you're working on? `n(Make sure to include the family/subfamily name you selected. In this case: '${seriesFamilyUpper}')`n"
    if ($testMode -eq $true) {
        TestMode
        $seriesInput = "AxTESTING"
    } else {
        $seriesInput = Read-Host "Enter the size series name (e.g., '${seriesFamilyUpper}v2', 'Fsv2', 'M')`n"
        $seriesValid = $false
    }
    while ($seriesValid -eq $false) {
        if ($seriesInput.StartsWith($seriesFamily, [StringComparison]::InvariantCultureIgnoreCase)) {
            Write-Host "`n$seriesInput is in the $seriesFamilyUpper family.`n" -ForegroundColor Green
            $seriesValid = $true
        } else {
            $seriesInput = Read-Host "`nERROR: $seriesInput does not start with '$seriesFamilyUpper'.`nPlease enter a valid name or restart the script if '$seriesFamilyUpper family' is incorrect.`n"
        }
    }
    # Check if the input ends with '-series'
    if ($seriesInput.EndsWith("-series")) {
        # If the input already ends with '-series', do something specific
        $seriesSelected = $seriesInput
        $seriesBaseName = $seriesSelected -replace "-series", ""
    } else {
        # If the input does not end with '-series', add '-series' to the end
        $seriesBaseName = $seriesInput
        $seriesSelected = $seriesInput + "-series"
    }
    # Define the file name for the series selected
    $seriesFileName = $seriesSelected.ToLower() + ".md"
    $seriesNameLower = $seriesSelected.ToLower()
    $seriesBaseNameLower = $seriesBaseName.ToLower()

    Write-Host "`nYou're now working on: $seriesSelected" -ForegroundColor Magenta
    Write-Host "  type: $seriesTypeFancy`n" -ForegroundColor DarkGray
    Read-Host "`nPress Enter to continue`n"





    # See if the file exists before continuing. This is dependant on the script operation mode.
    $foundFiles = Get-ChildItem -Path $sizesTypeDirectory -Filter $seriesFileName -File -ErrorAction SilentlyContinue

    # Check if any files were found
    if ($foundFiles) {
        foreach ($file in $foundFiles) {
            Write-Host "File found: $($file.Name)"
            if ($scriptOperation -eq "create") {
                Write-Host "`nERROR: The $seriesFileName file already exists. Please choose a different series name or update the existing series...`n" -ForegroundColor Red
                $validFileSelect = $false
            } elseif ($scriptOperation -eq "update") {
                Write-Host "The file exists and will be updated."
                $validFileSelect = $true
            } elseif ($scriptOperation -eq "retire") {
                Write-Host "The file exists and will be retired."
                $validFileSelect = $true
            }
        }
    } else {
        Write-Debug "`nNo files named '$seriesFileName' found in $sizesTypeDirectory."
        if ($scriptOperation -eq "create") {
            $validFileSelect = $true
        } else {
            Write-Host "`nERROR: No file named '$seriesFileName' found. Please choose a different series name or create a new series...`n" -ForegroundColor Red
            $validFileSelect = $false
        }
    }     
}




if ($scriptOperation -eq "create") {
    # CREATE OPERATIONS

    ## Copy series file and create final path variable
    $seriesFileFinalPath = "${sizesTypeDirectory}\${seriesFileName}"
    $seriesFileTempPath = "$originalDirectory\temp\${seriesFileName}"
    $seriesFileTempLocalPath = ".\temp\${seriesFileName}"
    $seriesFileOutputPath = "$outputDirectory\${seriesFileName}"
    Copy-Item -Path "$templateDirectory\temp-series.md" -Destination "${seriesFileTempPath}"

    ## Copy specs file and create final path variable
    $seriesSpecsFinalPath = "${sizesTypeDirectory}\includes\${seriesNameLower}-specs.md"
    $seriesSpecsTempPath = "$originalDirectory\temp\${seriesNameLower}-specs.md"
    $seriesSpecsTempLocalPath = ".\temp\${seriesNameLower}-specs.md"
    $seriesSpecsOutputPath = "$outputDirectory\includes\${seriesNameLower}-specs.md"
    Copy-Item -Path "$templateDirectory\temp-specs.md" -Destination "${seriesSpecsTempPath}"

    ## Copy summary file and create final path variable
    $seriesSummaryFinalPath = "${sizesTypeDirectory}\includes\${seriesNameLower}-summary.md"
    $seriesSummaryTempPath = "$originalDirectory\temp\${seriesNameLower}-summary.md"
    $seriesSummaryTempLocalPath = ".\temp\${seriesNameLower}-summary.md"
    $seriesSummaryOutputPath = "$outputDirectory\includes\${seriesNameLower}-summary.md"
    Copy-Item -Path "$templateDirectory\temp-summary.md" -Destination "${seriesSummaryTempPath}"

    ## Copy hardware csv file and create new and template path variable
    $hardwareCSVTempPath = "${originalDirectory}\temp\${seriesNameLower}-hardware.csv"
    $hardwareCSVTemplatePath = "${templateDirectory}\temp-hardware.csv"
    Copy-Item -Path "$templateDirectory\temp-hardware.csv" -Destination "${hardwareCSVTempPath}"

    ## Copy Sizes Names List CSV file
    $sizesNamesListINPUTPath = "$inputDirectory\INPUT-sizes-name-list_${seriesNameLower}.csv"
    $sizesNamesListINPUTLocalPath = ".\INPUT\INPUT-sizes-name-list_${seriesNameLower}.csv"
    if ($testMode -eq $true) {
        Copy-Item -Path "$examplesDirectory\example-sizes-name-list.csv" -Destination "${sizesNamesListINPUTLocalPath}"
    } else {
        Copy-Item -Path "$templateDirectory\temp-sizes-name-list.csv" -Destination "${sizesNamesListINPUTLocalPath}"
    }
    Clear-Host









    $hardwareDirectory = "${originalDirectory}\hardware"
    $hardwareCSV = Import-Csv -Path $hardwareCSVTempPath

    # DEFINE HARDWARE INFO
    $hwPartType = ""
    $hwPresent = ""
    $hwArch = ""
    $hwOem = ""
    $hwBrand = ""
    $hwFamily = ""
    $hwModel = ""
    $hwCodename = ""
    $hwLink = ""


    # Part in Series?
    $hwHasPartMEM = $false; if ($testMode -eq $true) { $hwHasPartMEM = $true }
    $hwHasPartNIC = $false; if ($testMode -eq $true) { $hwHasPartNIC = $true }
    $hwHasPartGPU = $false; if ($testMode -eq $true) { $hwHasPartGPU = $true }
    $hwHasPartNPU = $false; if ($testMode -eq $true) { $hwHasPartNPU = $false }
    $hwHasPartFPGA = $false; if ($testMode -eq $true) { $hwHasPartFPGA = $false }



    $validInput = $true
    $showMessage = $false
    while ($true) {
        Clear-Host
        Write-Host "CUSTOM HARDWARE PRESENCE" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "What hardware types are present on the series' host?`n"
        Write-Host "NOTE: It's unlikely (and often impossible) for a size to contain all of the options listed below.`n" -ForegroundColor DarkYellow
        Write-Host "WARNING: Double check the presence of Local (Temp) storage on your size! You can't add or remove this later.`n" -ForegroundColor Red
        Write-Host "A 'standard host' has:`n  - A detailed CPU (entered later)`n  - Unspecified memory specs (aside from capacity)`n  - A Mellanox (now Nvidia) ConnectX NIC.`n"
        Write-Host "Disabling a hardware type will populate it with: `n  - Default values for required components`n  - No values for those that don't normally exist.`n"
        Write-Host "  Hardware component status:" -ForegroundColor DarkGray
        Write-Host "    1. Local Storage (Temp Disks)           " -NoNewLine; if ($hwHasPartTMPDSK -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[None]" -ForegroundColor Red }
        Write-Host "    2. Custom Memory (RAM)                  " -NoNewLine; if ($hwHasPartMEM -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[Default]" -ForegroundColor Yellow }
        Write-Host "    3. Custom Network Interface Card (NIC)  " -NoNewLine; if ($hwHasPartNIC -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[Default]" -ForegroundColor Yellow }
        Write-Host "    4. Graphics Processing Unit (GPU)       " -NoNewLine; if ($hwHasPartGPU -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[None]" -ForegroundColor Red }
        Write-Host "    5. Neural/AI Processing Unit (NPU)      " -NoNewLine; if ($hwHasPartNPU -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[None]" -ForegroundColor Red }
        Write-Host "    6. Field-Programmable Gate Array (FPGA) " -NoNewLine; if ($hwHasPartFPGA -eq $true) { Write-Host "[Present]" -ForegroundColor Green } else { Write-Host "[None]" -ForegroundColor Red }
        
        if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
        if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
        if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n" }
        $userResponse = Read-Host "State the presence of a specific custom component by entering the number of a listed hardware type`nEnter 'done' to continue with the above hardware presence values`n"

        if ($userResponse -eq "1") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartTMPDSK -eq $true) { $hwHasPartTMPDSK = $false ; $localStoragePresent = $false ; $messageText = "Local Storage no longer present"} else { $hwHasPartTMPDSK = $true ; $localStoragePresent = $true ; $messageText = "Local Storage now present" }
        } elseif ($userResponse -eq "2") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartMEM -eq $true) { $hwHasPartMEM = $false ; $messageText = "Custom Memory no longer present"} else { $hwHasPartMEM = $true ; $messageText = "Custom Memory now present" }
        } elseif ($userResponse -eq "3") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartNIC -eq $true) { $hwHasPartNIC = $false ; $messageText = "Custom NIC no longer present" } else { $hwHasPartNIC = $true ; $messageText = "Custom NIC now present" }
        } elseif ($userResponse -eq "4") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartGPU -eq $true) { $hwHasPartGPU = $false ; $messageText = "GPU no longer present"} else { $hwHasPartGPU = $true ; $messageText = "GPU now present" }
            if ($hwHasPartGPU -eq $false -and $hwHasPartNPU -eq $false -and $hwHasPartFPGA -eq $false) {$acceleratorPresent = $false} else {$acceleratorPresent = $true}
            if ($hwHasPartGPU -eq $true -and ($hwHasPartNPU -eq $true -or $hwHasPartFPGA -eq $true)) { 
                $errorMessage = "Only one accelerator type can be present at a time. Please disable the other accelerator types before enabling this one.`nIf this size does have multiple accelerators, please contact the content dev team to add this functionality."
                $hwHasPartGPU = $false
                $validInput = $false
                $showMessage = $false
            }
        } elseif ($userResponse -eq "5") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartNPU -eq $true) { $hwHasPartNPU = $false ; $messageText = "NPU no longer present"} else { $hwHasPartNPU = $true ; $messageText = "NPU now present"}
            if ($hwHasPartGPU -eq $false -and $hwHasPartNPU -eq $false -and $hwHasPartFPGA -eq $false) {$acceleratorPresent = $false} else {$acceleratorPresent = $true}
            if ($hwHasPartNPU -eq $true -and ($hwHasPartGPU -eq $true -or $hwHasPartFPGA -eq $true)) { 
                $errorMessage = "Only one accelerator type can be present at a time. Please disable the other accelerator types before enabling this one.`nIf this size does have multiple accelerators, please contact the content dev team to add this functionality."
                $hwHasPartNPU = $false
                $validInput = $false
                $showMessage = $false
            }
        } elseif ($userResponse -eq "6") {
            $validInput = $true
            $showMessage = $true
            if ($hwHasPartFPGA -eq $true) { $hwHasPartFPGA = $false ; $messageText = "FPGA no longer present"} else { $hwHasPartFPGA = $true ; $messageText = "FPGA now present"}
            if ($hwHasPartGPU -eq $false -and $hwHasPartNPU -eq $false -and $hwHasPartFPGA -eq $false) {$acceleratorPresent = $false} else {$acceleratorPresent = $true}
            if ($hwHasPartFPGA -eq $true -and ($hwHasPartNPU -eq $true -or $hwHasPartGPU -eq $true)) { 
                $errorMessage = "Only one accelerator type can be present at a time. Please disable the other accelerator types before enabling this one.`nIf this size does have multiple accelerators, please contact the content dev team to add this functionality."
                $hwHasPartFPGA = $false
                $validInput = $false
                $showMessage = $false
            }
        } elseif ($userResponse -eq "done") {
            $validInput = $true
            $showMessage = $false
            break
        } else {
            if ($testMode -eq $true) {
                $validInput = $true
                $showMessage = $false
                Write-Host "Test mode is enabled. Setting all to present and accelerator to GPU..."
                Read-Host "`nPress Enter to continue`n"
                break
            } else { 
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Invalid input. Please enter a number from 1 to 6."
            }
        }
    }

    # DEFINE THE PROCESSOR CPU INFO
    ## CPU COUNT
    $hwCpuModelCount = $null; if ($testMode -eq $true) { $hwCpuModelCount = "1" }
    $validInput = $true
    $showMessage = $false
    $validContinue = $false
    $hwCpuModelIteration = 1
    while ($true) {
        Clear-Host
        Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - CPU Count" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "How many different CPU models are represented in this series' host? A single series could use either one of multiple generations of a CPU.`n"
        Write-Host "NOTE: Most series only utilize one CPU model.`n" -ForegroundColor DarkYellow
        if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
        if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
        if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n" }
        if ($validContinue -eq $false) { $userResponse = Read-Host "Enter the number of CPUs present on the host`n"
        } else { $userResponse = Read-Host "Press Enter to continue or enter a different number to select another CPU count`n" }
        if ($userResponse -match "^[1-9]$") {
            $validInput = $true
            $validContinue = $true
            $showMessage = $true
            $hwCpuModelCount = $userResponse
            $messageText = "CPU count set to $hwCpuModelCount"
        } elseif ($userResponse -eq "" -and $validContinue -eq $true) {
            break
        } elseif ($testMode -eq $true) {
            $validInput = $true
            $showMessage = $false
            Write-Host "Test mode is enabled. Setting defaults..."
            Read-Host "`nPress Enter to continue`n"
            break
        } else { 
            $validInput = $false
            $showMessage = $false
            $errorMessage = "Invalid input. Please enter a number from 1 to 9."
        }
    }

    $processorSKU = ""
    while ($hwCpuModelIteration -le $hwCpuModelCount) {
        # CPU ARCHITECTURE
        $hwArch = $null; if ($testMode -eq $true) { $hwArch = "x86-64" }
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        $hardwareTypes = Get-ChildItem -Path "${hardwareDirectory}\CPU" -Directory
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline
            if ($hwCpuModelCount -gt 1 ) { Write-Host " - CPU Architecture" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            } else { Write-Host " - CPU Architecture (Iteration ${hwCpuModelIteration})" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green }
            if ($hwCpuModelCount -gt 1) { Write-Host "What architecture is CPU #${hwCpuModelCount}?`n" } else { Write-Host "What architecture is the host CPU?`n" }
            Write-Host "NOTE: The most common CPU architecture on Azure is" -NoNewline -ForegroundColor DarkYellow; Write-Host " x86-64.`n" -ForegroundColor Yellow
            Write-Host "  CPU Architectures:" -ForegroundColor DarkGray
            while ($true) {
                $counter = 0
                foreach ($dir in $hardwareTypes) {
                    # Output the file name and its assigned letter
                    $counter++
                    if ($dir.Name -eq $hwArch) { Write-Host "   [ $counter. $($dir.Name) ]" -ForegroundColor Green } elseif ($dir.Name -eq "x86-64" -and $dir.Name -ne $hwArch) { Write-Host "     $counter. $($dir.Name)" -ForegroundColor Yellow } else { Write-Host "     $counter. $($dir.Name)" }
                }
                $maxValidReadEntries = $counter
                $counter++
                Write-Host "     $counter. Other"
                break
            }
            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }
            ### Input Message ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Select the CPU architecture from the list above`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different number to select another architecture`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please select a CPU architecture."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -eq "$counter") {
                $validInput = $false
                $showMessage = $false
                $hwArch = $null
                $errorMessage = "Please contact the content dev team to add a new CPU architecture."
            } elseif ($userResponse -match "^[1-$maxValidReadEntries]$") {
                $validInput = $true
                $showMessage = $true
                $hwArch = $hardwareTypes[$userResponse - 1].Name
                $messageText = "CPU architecture set to $hwArch"
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $false
                    Write-Host = "Test mode is enabled. Setting defaults..."
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "Invalid input. Please enter a number from 1 to $counter."
                }
            }
        }

        #CPU OEM
        $hwOem = $null; if ($testMode -eq $true) { $hwOem = "Intel" }
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        $hardwareTypes = Get-ChildItem -Path "${hardwareDirectory}\CPU\${hwArch}" -Directory
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - CPU OEM" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the OEM (manufacturer) of the CPU?`n"
            Write-Host "  ${hwArch} CPU OEMs:" -ForegroundColor DarkGray
            while ($true) {
                $counter = 0
                foreach ($dir in $hardwareTypes) {
                    # Output the file name and its assigned letter
                    $counter++
                    if ($dir.Name -eq $hwOem) { Write-Host "   [ $counter. $($dir.Name) ]" -ForegroundColor Green } else { Write-Host "     $counter. $($dir.Name)" }
                }
                $maxValidReadEntries = $counter
                $counter++
                Write-Host "     $counter. Other"
                break
            }
            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }
            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Select the CPU OEM from the list above`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different number to select another OEM`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please select a CPU OEM."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -eq "$counter") {
                $validInput = $false
                $showMessage = $false
                $hwOem = $null
                $errorMessage = "Please contact the content dev team to add a new CPU OEM."
            } elseif ($userResponse -match "^[1-$maxValidReadEntries]$") {
                $validInput = $true
                $showMessage = $true
                $hwOem = $hardwareTypes[$userResponse - 1].Name
                $messageText = "CPU OEM set to $hwOem"
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $false
                    Write-Host = "Test mode is enabled. Setting defaults..."
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "Invalid input. Please enter a number from 1 to $counter."
                }
            }
        }


        #CPU BRAND
        $hwBrand = $null; if ($testMode -eq $true) { $hwBrand = "Xeon" }
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        $hardwareTypes = Get-ChildItem -Path "${hardwareDirectory}\CPU\${hwArch}\${hwOem}"
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - CPU Brand" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the brand (first part of the name) of the CPU?`n"
            Write-Host "  ${hwOem} ${hwArch} CPU Names:" -ForegroundColor DarkGray
            while ($true) {
                $counter = 0
                foreach ($file in $hardwareTypes) {
                    # Output the file name and its assigned letter
                    $counter++
                    if ($file.Name -eq $hwBrand) { Write-Host "   [ $counter. $($file.Name) ]" -ForegroundColor Green } else { Write-Host "     $counter. $($file.Name)" }
                }
                $maxValidReadEntries = $counter
                $counter++
                Write-Host "     $counter. Other"
                break
            }
            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }
            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Select the CPU brand from the list above`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different number to select another brand`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please select a CPU brand."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -eq "$counter") {
                $validInput = $false
                $showMessage = $false
                $hwBrand = $null
                $errorMessage = "Please contact the content dev team to add a new CPU brand."
            } elseif ($userResponse -match "^[1-$maxValidReadEntries]$") {
                $validInput = $true
                $showMessage = $true
                $hwBrand = $hardwareTypes[$userResponse - 1].Name
                $messageText = "CPU brand set to $hwBrand"
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $false
                    Write-Host = "Test mode is enabled. Setting defaults..."
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "Invalid input. Please enter a number from 1 to $counter."
                }
            }
        }



        # ASK ABOUT THE CPU MODEL
        $hwModel = $null; if ($testMode -eq $true) { $hwModel = "8088 v512" }
        $hwModelCopy = "<model>"
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - CPU Model Info" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the rest of the CPU's model name/number (rest of the name after ${hwBrand})`n"
            Write-Host "NOTE: If the series uses Intel Xeon CPUs, the CPU might be a 'Xeon E5-2699 v4' or an 'Xeon Platinum 8380H'.`nYou would enter 'E5-2699 v4' and 'Platinum 8380H' respectively`n" -ForegroundColor DarkYellow
            Write-Host "  Full CPU name:" -ForegroundColor DarkGray
            if ($hwModel -ne $null) { Write-Host "    ${hwOem} ${hwBrand} ${hwModelCopy}" -ForegroundColor Green } else { Write-Host "    ${hwOem} ${hwBrand} <model>" }

            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "${hwOem} ${hwBrand} "
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different model`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please enter a CPU model."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -match "${hwBrand}" -or $userResponse -match "${hwOem}") {
                $validInput = $false
                $errorMessage = "Do not enter the CPU oem or brand. Just enter the specific CPU model name."
            } else {
                if ($testMode -eq $true) {
                    Write-Host "Script is in Test mode. Setting defaults..." -ForegroundColor Green 
                    $validInput = $true
                    $showMessage = $false
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $true
                    $showMessage = $true
                    $hwModel = $userResponse
                    $messageText = "CPU model set to ${hwModel}"    
                    $hwModelCopy = $hwModel
                    $retryCount++
                }
            }
        }

        #FINAL INFO FOR WRITING
        if ($hwCpuModelIteration -eq 1) {
            $processorSKU = "${hwOem} ${hwBrand} ${hwModelCopy} [${hwArch}]"
        } else { 
            $processorSKU = "${processorSKU} <br>${hwOem} ${hwBrand} ${hwModelCopy} [${hwArch}]" }
        $cpuOem = $hwOem
        $cpuBrand = $hwBrand
        $cpuModel = $hwModel
        $cpuArch = $hwArch
        $hwCpuModelIteration++
    }

    <#
    # Memory Info
    if ($hwHasPartMEM -eq $true) {
        $hwModel = $null
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - Custom Memory Info" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What are the specs of your hardware's custom memory configuration?`n"
            Write-Host "NOTE: If the series uses Intel Xeon CPUs, the CPU might be a 'Xeon E5-2699 v4' or an 'Xeon Platinum 8380H'.`nYou would enter 'E5-2699 v4' and 'Platinum 8380H' respectively`n" -ForegroundColor DarkYellow
            Write-Host "  Full CPU name:" -ForegroundColor DarkGray
            Write-Host "    ${hwOem} ${hwBrand} ${hwModelCopy}:"

            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "${hwOem} ${hwBrand} "
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different model`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please enter a CPU model."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -match "${hwBrand}" -or $userResponse -match "${hwOem}") {
                $validInput = $false
                $errorMessage = "Do not enter the CPU oem or brand. Just enter the specific CPU model name."
            } else {
                if ($testMode -eq $true) {
                    Write-Host "Script is in Test mode. Continuing..." -ForegroundColor Green 
                    $validInput = $true
                    $showMessage = $false
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $true
                    $showMessage = $true
                    $hwModel = $userResponse
                    $messageText = "CPU model set to ${hwModel}"    
                    $hwModelCopy = $hwModel
                    $retryCount++
                }
            }
        }
    }


    #>

    # ACCELERATORS
    if ($acceleratorPresent -eq $true) {
        #ACCELERATOR TYPE
        if ($hwHasPartGPU -eq $true) {
            $hwType = "GPU"
        } elseif ($hwHasPartNPU -eq $true) {
            $hwType = "NPU"
        } elseif ($hwHasPartFPGA -eq $true) {
            $hwType = "FPGA"
        } else {
            $hwType = $null
        }

        #ACCELERATOR OEM
        $hwOem = $null; if ($testMode -eq $true) { $hwOem = "Nvidia" }
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        $hardwareTypes = Get-ChildItem -Path "${hardwareDirectory}\accelerators\${hwType}" -Directory
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - ${hwType} OEM" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "Because you enabled an accelerator, you now will define the ${hwType}'s specs.`n"
            Write-Host "NOTE: If you didn't intend to enable an accelerator, please restart the script.`n" -ForegroundColor DarkYellow
            Write-Host "What is the OEM (manufacturer) of the ${hwType}?`n"
            Write-Host "  ${hwType} OEMs:" -ForegroundColor DarkGray
            while ($true) {
                $counter = 0
                foreach ($dir in $hardwareTypes) {
                    # Output the file name and its assigned letter
                    $counter++
                    if ($dir.Name -eq $hwOem) { Write-Host "   [ $counter. $($dir.Name) ]" -ForegroundColor Green } else { Write-Host "     $counter. $($dir.Name)" }
                }
                $maxValidReadEntries = $counter
                $counter++
                Write-Host "     $counter. Other"
                break
            }
            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }
            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Select the ${hwType} OEM from the list above`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different number to select another OEM`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please select a ${hwType} OEM."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -eq "$counter") {
                $validInput = $false
                $showMessage = $false
                $hwOem = $null
                $errorMessage = "Please contact the content dev team to add a new ${hwType} OEM."
            } elseif ($userResponse -match "^[1-$maxValidReadEntries]$") {
                $validInput = $true
                $showMessage = $true
                $hwOem = $hardwareTypes[$userResponse - 1].Name
                $messageText = "${hwType} OEM set to $hwOem"
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $false
                    Write-Host = "Test mode is enabled. Setting defaults..."
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "Invalid input. Please enter a number from 1 to $counter."
                }
            }
        }


        #ACCELERATOR BRAND
        $hwBrand = $null; if ($testMode -eq $true) { $hwBrand = "Xeon" }
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        $hardwareTypes = Get-ChildItem -Path "${hardwareDirectory}\accelerators\${hwType}\${hwOem}"
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - ${hwType} Brand" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the brand (first part of the name) of the ${hwType}?`n"
            Write-Host "NOTE: Some products (like certain modern Nvidia GPUs) have no explicit brand, but they do list how they are connected to the server.`nFor example, Nvidia has PCIe and HGX GPUs.`n" -ForegroundColor DarkYellow
            Write-Host "  ${hwOem} ${hwType} brands:" -ForegroundColor DarkGray
            while ($true) {
                $counter = 0
                foreach ($file in $hardwareTypes) {
                    # Output the file name and its assigned letter
                    $counter++
                    if ($file.Name -eq $hwBrand) { Write-Host "   [ $counter. $($file.Name) ]" -ForegroundColor Green } else { Write-Host "     $counter. $($file.Name)" }
                }
                $maxValidReadEntries = $counter
                $counter++
                Write-Host "     $counter. Other"
                break
            }
            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }
            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Select the ${hwType} brand from the list above`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different number to select another brand`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please select a ${hwType} brand."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -eq "$counter") {
                $validInput = $false
                $showMessage = $false
                $hwBrand = $null
                $errorMessage = "Please contact the content dev team to add a new ${hwType} brand."
            } elseif ($userResponse -match "^[1-$maxValidReadEntries]$") {
                $validInput = $true
                $showMessage = $true
                $hwBrand = $hardwareTypes[$userResponse - 1].Name
                $messageText = "${hwType} brand set to $hwBrand"
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $false
                    Write-Host = "Test mode is enabled. Setting defaults..."
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "Invalid input. Please enter a number from 1 to $counter."
                }
            }
        }



        # ASK ABOUT THE ACCELERATOR MODEL
        $hwModel = $null; if ($testMode -eq $true) { $hwModel = "P100" }
        $hwModelCopy = "<model>"
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - ${hwType} Model Info" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the rest of the ${hwType}'s model name/number (rest of the name after ${hwBrand})`n"
            Write-Host "NOTE: If the series uses Nvidia RTX ${hwType}s, the ${hwType} might be an 'H100 40GB PCIe' or an 'RTX 4000 Ada-generation'.`nYou would enter 'H100' and '4000 Ada-generation' respectively`nIf the model name contains the memory (i.e. A100 80GB) do not include it in the model name. That info is input later.`n" -ForegroundColor DarkYellow
            Write-Host "  Full ${accType} name:" -ForegroundColor DarkGray
            if ($hwModel -ne $null) { Write-Host "    ${hwOem} ${hwBrand} ${hwModelCopy}" -ForegroundColor Green } else { Write-Host "    ${hwOem} ${hwBrand} <model>" }

            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "${hwOem} ${hwBrand} "
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different model`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please enter a ${hwType} model."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -match "${hwBrand}" -or $userResponse -match "${hwOem}") {
                $validInput = $false
                $errorMessage = "Do not enter the ${hwType} oem or brand. Just enter the specific ${hwType} model name."
            } else {
                if ($testMode -eq $true) {
                    Write-Host "Script is in Test mode. Setting defaults..." -ForegroundColor Green 
                    $validInput = $true
                    $showMessage = $false
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $true
                    $showMessage = $true
                    $hwModel = $userResponse
                    $messageText = "${hwType} model set to ${hwModel}"    
                    $hwModelCopy = $hwModel
                    $retryCount++
                }
            }
        }



        # ASK ABOUT THE ACCELERATOR MEMORY BUFFER
        $hwMemBuffer = $null; if ($testMode -eq $true) { $hwMemBuffer = "80" }
        $hwMemBufferCopy = "<memory>"
        $validInput = $true
        $showMessage = $false
        $retryCount = 0
        while ($true) {
            Clear-Host
            Write-Host "DEFINE HARDWARE" -BackgroundColor Blue -NoNewline; Write-Host " - ${hwType} Memory Buffer Info" -ForegroundColor Blue -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
            Write-Host "What is the rest of the ${hwBrand} ${hwModel} ${hwType}'s memory buffer size (if applicable)`n"
            Write-Host "NOTES:`n- Enter the amount of memory in GB, but do not include the 'G' or 'GB' ('80GB' would be '80').`n- If the ${hwType} has memory in the MB, represent it as a decimal (250MB = .25GB).`nIf the ${hwType} shares system memory, put in the maximum amount it can address.`n- If the device has no memory/frame buffer, enter '0'.`n- Only enter the max amount of memory on a single device, not per host.`n" -ForegroundColor DarkYellow
            Write-Host "  ${hwType} Memory:" -ForegroundColor DarkGray
            if ($hwMemBuffer -ne $null) { Write-Host "    ${hwOem} ${hwBrand} ${hwModel} ${hwMemBuffer}GB" -ForegroundColor Green } else { Write-Host "    ${hwOem} ${hwBrand} ${hwModel} <memory>" }

            if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
            if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
            if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

            ### Input Portion ###
            if ($retryCount -eq 0) {
                $userResponse = Read-Host "Memory Buffer Size for ${hwOem} ${hwBrand} ${hwModel}`n"
                $showMessage = $true
            } else {
                $userResponse = Read-Host "Press Enter to continue or enter a different memory amount`n"
                $showMessage = $true
            }
            ### Actual Input
            if ($userResponse -eq "" -and $retryCount -eq 0) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please enter the ${hwType}'s memory buffer."
            } elseif ($userResponse -eq "" -and $retryCount -gt 0 -and $validInput -eq $true) {
                break
            } elseif ($userResponse -match "${hwBrand}" -or $userResponse -match "${hwOem}") {
                $validInput = $false
                $errorMessage = "Do not enter the ${hwType} oem or brand. Just enter the specific ${hwType} memory amount."
            } elseif ($userResponse -match "[a-zA-Z]") {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "Please enter a number for the memory buffer size. Do not include letters or special characters."
            } elseif ($userResponse -eq "0") {
                $validInput = $true
                $showMessage = $true
                $hwMemBuffer = ""
                $messageText = "${hwType} memory buffer set to none"    
                $hwMemBufferCopy = $hwMemBuffer
                $retryCount++
            } else {
                if ($testMode -eq $true) {
                    Write-Host "Script is in Test mode. Setting defaults..." -ForegroundColor Green 
                    $validInput = $true
                    $showMessage = $false
                    Read-Host "`nPress Enter to continue`n"
                    break
                } else { 
                    $validInput = $true
                    $showMessage = $true
                    $hwMemBuffer = $userResponse
                    $messageText = "${hwType} memory buffer set to ${hwMemBuffer} GB"    
                    $hwMemBufferCopy = $hwMemBuffer
                    $retryCount++
                }
            }
        }

        #FINAL INFO FOR WRITING
        if ($hwMemBuffer -eq "") {
            $acceleratorSKU = "${hwOem} ${hwBrand} ${hwModel} ${hwType}"
        } else {
            $acceleratorSKU = "${hwOem} ${hwBrand} ${hwModel} ${hwType} (${hwMemBuffer}GB)"
        }
        $accType = $hwType
        $accOem = $hwOem
        $accBrand = $hwBrand
        $accModel = $hwModel
        $accMemory = $hwMemBuffer
    }


    # SIZE NAME INPUT
    $showMessage = $false
    while ($true) {
        Clear-Host
        Write-Host "INDIVIDUAL SIZE NAMES" -BackgroundColor Blue -NoNewline
        Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "Now we'll enter the data for the $seriesBaseName series' individual size names.`n"

        Write-Host "  INSTRUCTIONS:" -ForegroundColor DarkGray
        Write-Host "    - Fill out the file with relevant data using a text editor (default for this script is Notepad)."
        Write-Host "    - Replace the '<example#>' text with each size name, and add more lines when needed."
        Write-Host "    - Don't add spaces, commas, or other special characters to the size names."
        Write-Host "    - Size names should follow the <Qualifier>_<Type><Specs>_v<Version> format (e.g., Standard_D8_v3)."
        Write-Host "    - Save the file when you're done! Otherwise you'll end up with errors..."

        if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
        if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
        if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

        Write-Host "Type 'n' to open the file in Notepad.exe"
        Write-Host "Type 'x' to open the file in Excel.exe"
        Write-Host "Type 'f' to open the containing folder in explorer.exe"
        Write-Host "Type 'e' to view an example"
        Write-Host "Type 'done' when you've finished entering data in the file to continue"

        if ($testMode -eq $true) {
            Read-Host "`nTest Mode Enabled, press Enter to continue`n"
            $userResponse = "done"
        } else {
            $userResponse = Read-Host
        }
        
        if ($userResponse -eq "f") {
            Start-Process "explorer.exe" -ArgumentList "$inputDirectory"
            Write-Host "`nOpening explorer.exe" -NoNewline
            DelayDots
        } elseif ($userResponse -eq "n") {
            Start-Process "notepad.exe" -ArgumentList $sizesNamesListINPUTPath
            Write-Host "`nOpening notepad.exe" -NoNewline
            DelayDots
        } elseif ($userResponse -eq "x") {
            Start-Process "excel.exe" -ArgumentList "`"$sizesNamesListINPUTPath`""
            Write-Host "`nOpening excel.exe" -NoNewline
            DelayDots
        } elseif ($userResponse -eq "e") {
            $csvData = Import-Csv -Path "$examplesDirectory\example-sizes-name-list.csv"
            Write-Host "`nHere's an example of the file content:`n" -ForegroundColor Magenta
            Write-Host "  Size-Name" -ForegroundColor DarkGray
            foreach ($row in $csvData) {
                Write-Host "  " -NoNewline
                Write-Host $row."Size-Name"
            }
            Read-Host "`nPress Enter to continue`n"
        } elseif ($userResponse -eq "done") {
            $sizesNamesListTemplatePath = "$templateDirectory\temp-sizes-name-list.csv"
            $sizesNamesListTemplateContent = Get-Content -Path $sizesNamesListTemplatePath -Raw
            $sizesNamesListNewContent = Get-Content -Path $sizesNamesListINPUTPath -Raw
            $csvData = Import-Csv -Path $sizesNamesListINPUTPath
            if ($sizesNamesListNewContent -eq $sizesNamesListTemplateContent) {
                if ($testMode -eq $true) {
                    $validInput = $true
                    $showMessage = $true
                    $messageText = "The file looks the same, but you're in testing mode. The script will now continue"
                    break
                } else {
                    $validInput = $false
                    $showMessage = $false
                    $errorMessage = "The file looks the same, did you not edit the default values and/or forget to save?"
                }
            } elseif ('Size-Name' -notin $csvData[0].PSObject.Properties.Name) {
                $validInput = $false
                $showMessage = $false
                $errorMessage = "The required column 'Size-Name' does not exist in the CSV data. Did you remove or edit the header line?"
            } else {
                $validInput = $true
                $showMessage = $false
                $messageText = "The file has been edited and saved successfully!"
                break
            }
        } else {
            $validInput = $false
            $showMessage = $false
            $errorMessage = "Invalid input. Please type 'n', 'x', 'f', 'e', or 'done'."
        }
    }

    ## REVIEW SIZE NAMES
    $showMessage = $false
    while ($true) {
        $csvData = Import-Csv -Path $sizesNamesListINPUTPath
        Clear-Host
        Write-Host "INDIVIDUAL SIZE NAMES" -BackgroundColor Blue -NoNewline; Write-Host " - REVIEW" -ForegroundColor Blue -NoNewline;
        Write-Host "${scriptModeTitle}`n" -ForegroundColor Green

        Write-Host "The file has been edited! Here are the series names you've entered:`n"
        Write-Host "  Size-Name" -ForegroundColor DarkGray
        foreach ($row in $csvData) {
            Write-Host "    - " -NoNewline
            Write-Host $row."Size-Name"
        }
        Write-Host "`nRemember to " -NoNewLine; Write-Host "close your editor!"-ForegroundColor Red
        Write-Host "NOTE: If you continue while the file is still open, you will encounter errors and the script will fail!`n" -ForegroundColor DarkYellow
        Write-Host "If there's an issue with these series names, press 'n' to open the file in notepad and make edits.`nIf these series names look good, press Enter to continue.'`n:" -NoNewline
        if ($testMode -eq $true) {
            Read-Host "`nTest Mode Enabled, press Enter to continue`n"
            $userResponse = ""
            break
        } else {
            $userResponse = Read-Host
            if ($userResponse -eq "") {
                break
            } elseif ($userResponse -eq "n") {
                $validInput = $true
                $showMessage = $false
                Write-Host "`nOpening notepad.exe" -NoNewline
                Start-Process "notepad.exe" -ArgumentList $sizesNamesListINPUTPath
                DelayDots
            } else {
                $validInput = $false
                $showMessage = false
                $errorMessage = "Invalid input. Please enter 'n' or 'done'." 
            }
        }
    }
    

    # Combine the CSVs (Name Input and Category Templates), Write the combined files to INPUT and TEMP directories
    $sizesListCsvPath = $sizesNamesListINPUTPath
    $count = 0
    while ($true) {
        if ($count -eq 0) {
            # CPU Memory
            $templateCsvPath = "$templateDirectory\temp-specs-cpu-memory.csv"
            $mergedCsvINPUTPath = "$inputDirectory\INPUT-cpu-memory-specs_${seriesNameLower}.csv"
            $mergedCsvTEMPPath = "$tempDirectory\edited-specs-cpu-memory.csv"
        } elseif ($count -eq 1) {
            # Storage Local
            if ($localStoragePresent -eq $true) {
                $templateCsvPath = "$templateDirectory\temp-specs-storage-local.csv"
                $mergedCsvINPUTPath = "$inputDirectory\INPUT-storage-local-specs_${seriesNameLower}.csv"
                $mergedCsvTEMPPath = "$tempDirectory\edited-specs-storage-local.csv"
            }
        } elseif ($count -eq 2) {
            # Storage Remote
            $templateCsvPath = "$templateDirectory\temp-specs-storage-remote.csv"
            $mergedCsvINPUTPath = "$inputDirectory\INPUT-storage-remote-specs_${seriesNameLower}.csv"
            $mergedCsvTEMPPath = "$tempDirectory\edited-specs-storage-remote.csv"
        } elseif ($count -eq 3) {
            # Network
            $templateCsvPath = "$templateDirectory\temp-specs-network.csv"
            $mergedCsvINPUTPath = "$inputDirectory\INPUT-network-specs_${seriesNameLower}.csv"
            $mergedCsvTEMPPath = "$tempDirectory\edited-specs-network.csv"
        } elseif ($count -eq 4) {
            # Accelerators
            if ($acceleratorPresent -eq $true) {
                $templateCsvPath = "$templateDirectory\temp-specs-accelerators.csv"
                $mergedCsvINPUTPath = "$inputDirectory\INPUT-accelerators-specs_${seriesNameLower}.csv"
                $mergedCsvTEMPPath = "$tempDirectory\edited-specs-accelerators.csv"
            } else {
                break
            }
        } else {
            break
        }

        # Import the first CSV file into a variable
        $csvSizesNameData = Import-Csv -Path $sizesListCsvPath

        # Import only the header row of the second CSV
        $csvTemplateData = Get-Content -Path $templateCsvPath -TotalCount 1

        # Create a new object with headers from $csvTemplateData
        $headers = $csvTemplateData -split "," | ForEach-Object { $_.Trim() }
        $combinedData = @()

        # Combine each row from $csvSizesNameData with the headers from $csvTemplateData
        foreach ($row in $csvSizesNameData) {
            $newRow = New-Object -TypeName PSObject
            foreach ($header in $headers) {
                if ($csvSizesNameData[0].PSObject.Properties.Name -contains $header) {
                    $newRow | Add-Member -MemberType NoteProperty -Name $header -Value $row.$header
                } else {
                    $newRow | Add-Member -MemberType NoteProperty -Name $header -Value $null
                }
            }
            $combinedData += $newRow
        }
        # Export the combined data to a new CSV file
        $combinedData | Export-Csv -Path $mergedCsvINPUTPath -NoTypeInformation
        $combinedData | Export-Csv -Path $mergedCsvTEMPPath -NoTypeInformation
        # Output the path to the merged CSV file
        Write-Output "Merged CSV created at: $mergedCsvPath"

        $count++
    }
    
    ## Now that we're done with the sizes names INPUT, move it to the temp directory (in case we need it again).
    $tempStorSizesNameList = "${originalDirectory}\temp\sizes-name-list_${seriesNameLower}.csv"
    Move-Item -Path $sizesNamesListINPUTPath -Destination $tempStorSizesNameList



    
    # SET GLOBAL PATHS
    ## Specs Cpu-Memory CSV file
    $global:specsCpuMemoryINPUTPath = "$inputDirectory\INPUT-cpu-memory-specs_${seriesNameLower}.csv"
    $global:specsCpuMemoryINPUTLocalPath = ".\INPUT\INPUT-cpu-memory-specs_${seriesNameLower}.csv"
    $global:specsCpuMemoryOriginalTemplatePath = "$templateDirectory\temp-specs-cpu-memory.csv"
    $global:specsCpuMemoryEditedTemplatePath = "$tempDirectory\edited-specs-cpu-memory.csv"


    ## Specs Storage Local CSV file
    $global:specsStorageLocalINPUTPath = "$inputDirectory\INPUT-storage-local-specs_${seriesNameLower}.csv"
    $global:specsStorageLocalINPUTLocalPath = ".\INPUT\INPUT-storage-local-specs_${seriesNameLower}.csv"
    $global:specsStorageLocalOriginalTemplatePath = "$templateDirectory\temp-specs-storage-local.csv"
    $global:specsStorageLocalEditedTemplatePath = "$tempDirectory\edited-specs-storage-local.csv"


    ## Specs Storage Remote CSV file
    $global:specsStorageRemoteINPUTPath = "$inputDirectory\INPUT-storage-remote-specs_${seriesNameLower}.csv"
    $global:specsStorageRemoteINPUTLocalPath = ".\INPUT\INPUT-storage-remote-specs_${seriesNameLower}.csv"
    $global:specsStorageRemoteOriginalTemplatePath = "$templateDirectory\temp-specs-storage-remote.csv"
    $global:specsStorageRemoteEditedTemplatePath = "$tempDirectory\edited-specs-storage-remote.csv"


    ## Specs Network CSV file
    $global:specsNetworkINPUTPath = "$inputDirectory\INPUT-network-specs_${seriesNameLower}.csv"
    $global:specsNetworkINPUTLocalPath = ".\INPUT\INPUT-network-specs_${seriesNameLower}.csv"
    $global:specsNetworkOriginalTemplatePath = "$templateDirectory\temp-specs-network.csv"
    $global:specsNetworkEditedTemplatePath = "$tempDirectory\edited-specs-network.csv"


    ## Specs Accelerators CSV file
    $global:specsAcceleratorsINPUTPath = "$inputDirectory\INPUT-accelerators-specs_${seriesNameLower}.csv"
    $global:specsAcceleratorsINPUTLocalPath = ".\INPUT\INPUT-accelerators-specs_${seriesNameLower}.csv"
    $global:specsAcceleratorsOriginalTemplatePath = "$templateDirectory\temp-specs-accelerators.csv"
    $global:specsAcceleratorsEditedTemplatePath = "$tempDirectory\edited-specs-accelerators.csv"







    # WRITE THE DATA

    ##Set initial file status
    $global:currentFileStatus = "(not edited)"
    $global:fileStatusNoOpens = "(not edited)"
    $global:fileStatusNoEdits = "(not edited)"
    $global:fileStatusOpenNoEdits = "(opened, not edited)"
    $global:fileStatusEdited = "(edited)"

    $global:fileStatus1 = "(not edited)"
    $global:openedFile1 = $false

    $global:fileStatus2 = "(not edited)"
    $global:openedFile2 = $false
    
    $global:fileStatus3 = "(not edited)"
    $global:openedFile3 = $false

    $global:fileStatus4 = "(not edited)"
    $global:openedFile4 = $false

    $global:fileStatus5 = "(not edited)"
    $global:openedFile5 = $false

    $global:fileStatusF = "(not opened)"
    $global:currentTemplate = "NULL"
    $global:currentTemplateContent = "NULL"
    $global:currentINPUT = "NULL"
    $global:currentINPUTContent = "NULL"

    ## Create some functions (for better readability)
    function RenderDataInputStatus {
        Write-Host "SPECIFICATIONS INPUT" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "Now we'll enter the data for the ${seriesBaseName} series' specs.`n"
        Write-Host "Fill out the following INPUT .csv files (comma-deliniated) with relevant data using Excel or a text editor:`n"
        Write-Host "  1. CPU and Memory specs   " -NoNewLine; if ($global:fileStatus1 -eq $global:fileStatusEdited) { Write-Host "$global:fileStatus1" -ForegroundColor Green } else { Write-Host "$global:fileStatus1" -ForegroundColor Yellow }
        Write-Host "    $specsCpuMemoryINPUTLocalPath `n" -ForegroundColor DarkGray
        if ($localStoragePresent -eq $true) {
            Write-Host "  2. Local Storage specs    " -NoNewLine; if ($global:fileStatus2 -eq $global:fileStatusEdited) { Write-Host "$global:fileStatus2" -ForegroundColor Green } else { Write-Host "$global:fileStatus2" -ForegroundColor Yellow }
            Write-Host "    $specsStorageLocalINPUTLocalPath `n" -ForegroundColor DarkGray
        } else {
            Write-Host "  2. Local Storage specs    " -NoNewLine; Write-Host "(ignored)" -ForegroundColor DarkGreen;
            Write-Host "    No INPUT file present as feature is disabled. `n " -ForegroundColor DarkGray
            $global:fileStatus2 = $global:fileStatusEdited
        }
        Write-Host "  3. Remote Storage specs   " -NoNewLine; if ($global:fileStatus3 -eq $global:fileStatusEdited) { Write-Host "$global:fileStatus3" -ForegroundColor Green } else { Write-Host "$global:fileStatus3" -ForegroundColor Yellow }
        Write-Host "    $specsStorageRemoteINPUTLocalPath `n" -ForegroundColor DarkGray
        Write-Host "  4. Network specs          " -NoNewLine; if ($global:fileStatus4 -eq $global:fileStatusEdited) { Write-Host "$global:fileStatus4" -ForegroundColor Green } else { Write-Host "$global:fileStatus4" -ForegroundColor Yellow }
        Write-Host "    $specsNetworkINPUTLocalPath `n" -ForegroundColor DarkGray
        if ($acceleratorPresent -eq $true) {
            Write-Host "  5. Accelerator specs      " -NoNewline; if ($global:fileStatus5 -eq $global:fileStatusEdited) { Write-Host "$global:fileStatus5" -ForegroundColor Green } else { Write-Host "$global:fileStatus5" -ForegroundColor Yellow }
            Write-Host "    $specsAcceleratorsINPUTLocalPath `n" -ForegroundColor DarkGray
            Write-Host "`nNOTE (Accelerators): The 'Accelerator-Memory-GB section is based on the total memory buffer available to the VM, not the memory per hardware device.`nFor example, if you have 3x 4GB GPUs, you would have 12GB of memory buffer available to the VM." -ForegroundColor DarkYellow
        } else {
            Write-Host "  5. Accelerator specs      " -NoNewline; Write-Host "(ignored)" -ForegroundColor DarkGreen
            Write-Host "    No INPUT file present as feature is disabled. `n " -ForegroundColor DarkGray
            $global:fileStatus5 = $global:fileStatusEdited
        }
        Write-Host "`nNOTE: If there is no data for a specific value, leave the cell empty.`nFilling the cells with a '-' or '0' will render incorrectly" -ForegroundColor DarkYellow
    }


    

    function CompareAllContent {
        $global:currentFileStatus = $global:fileStatus1
        $currentTemplateContent = Get-Content -Path $global:specsCpuMemoryEditedTemplatePath -Raw
        $currentINPUTContent = Get-Content -Path $global:specsCpuMemoryINPUTPath -Raw
        if ($currentINPUTContent -ne $currentTemplateContent) {
            $global:currentFileStatus = $global:fileStatusEdited
        } elseif ($global:openedFile1 -eq $true) {
            $global:currentFileStatus = $global:fileStatusOpenNoEdits
        } else {
            $global:currentFileStatus = $global:fileStatusNoOpens
        }
        $global:fileStatus1 = $global:currentFileStatus

        if ($localStoragePresent -eq $true) {
            $global:currentFileStatus = $global:fileStatus2
            $currentTemplateContent = Get-Content -Path $global:specsStorageLocalEditedTemplatePath -Raw
            $currentINPUTContent = Get-Content -Path $global:specsStorageLocalINPUTPath -Raw
            if ($currentINPUTContent -ne $currentTemplateContent) {
                $global:currentFileStatus = $global:fileStatusEdited
            } elseif ($global:openedFile2 -eq $true) {
                $global:currentFileStatus = $global:fileStatusOpenNoEdits
            } else {
                $global:currentFileStatus = $global:fileStatusNoOpens
            }
            $global:fileStatus2 = $global:currentFileStatus
        }

        $global:currentFileStatus = $global:fileStatus3
        $currentTemplateContent = Get-Content -Path $global:specsStorageRemoteEditedTemplatePath -Raw
        $currentINPUTContent = Get-Content -Path $global:specsStorageRemoteINPUTPath -Raw
        if ($currentINPUTContent -ne $currentTemplateContent) {
            $global:currentFileStatus = $global:fileStatusEdited
        } elseif ($global:openedFile3 -eq $true) {
            $global:currentFileStatus = $global:fileStatusOpenNoEdits
        } else {
            $global:currentFileStatus = $global:fileStatusNoOpens
        }
        $global:fileStatus3 = $global:currentFileStatus


        $global:currentFileStatus = $global:fileStatus4
        $currentTemplateContent = Get-Content -Path $global:specsNetworkEditedTemplatePath -Raw
        $currentINPUTContent = Get-Content -Path $global:specsNetworkINPUTPath -Raw
        if ($currentINPUTContent -ne $currentTemplateContent) {
            $global:currentFileStatus = $global:fileStatusEdited
        } elseif ($global:openedFile4 -eq $true) {
            $global:currentFileStatus = $global:fileStatusOpenNoEdits
        } else {
            $global:currentFileStatus = $global:fileStatusNoOpens
        }
        $global:fileStatus4 = $global:currentFileStatus

        if ($acceleratorPresent -eq $true) {
            $global:currentFileStatus = $global:fileStatus5
            $currentTemplateContent = Get-Content -Path $global:specsAcceleratorsEditedTemplatePath -Raw
            $currentINPUTContent = Get-Content -Path $global:specsAcceleratorsINPUTPath -Raw
            if ($currentINPUTContent -ne $currentTemplateContent) {
                $global:currentFileStatus = $global:fileStatusEdited
            } elseif ($global:openedFile5 -eq $true) {
                $global:currentFileStatus = $global:fileStatusOpenNoEdits
            } else {
                $global:currentFileStatus = $global:fileStatusNoOpens
            }
            $global:fileStatus5 = $global:currentFileStatus
        }
    }
    

    ## Input Loop
    $validInput = $true
    $showMessage = $false
    Clear-Host
    RenderDataInputStatus
    while ($true) {
        if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
        if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
        if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

        Write-Host "Enter numbers '1 - 5' to open the corresponding file in Excel `nEnter 'f' to open the INPUT directory in Explorer `nEnter 'e' to view an example `nEnter 'r' to refresh the edit status `nEnter 'done' when you've finished entering data in all files to continue`n:" -NoNewline
        if ($testMode -eq $true) {
            Read-Host "`nTest Mode Enabled, press Enter to continue`n"
            $userResponse = "done"
        } else {
            $userResponse = Read-Host
        }
        if ($userResponse -eq "1") {
            Start-Process "excel.exe" -ArgumentList "`"$specsCpuMemoryINPUTPath`""
            $global:currentTemplate = $specsCpuMemoryEditedTemplatePath
            $global:currentINPUT = $specsCpuMemoryINPUTPath
            Write-Host "`nOpening excel.exe" -NoNewline
            $global:openedFile1 = $true
            DelayDots
            Read-Host "`nPress Enter to continue...`n"
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "2") {
            if ($localStoragePresent -eq $true) {
                Start-Process "excel.exe" -ArgumentList "`"$specsStorageLocalINPUTPath`""
                $global:currentTemplate = $specsStorageLocalEditedTemplatePath
                $global:currentINPUT = $specsStorageLocalINPUTPath
                Write-Host "`nOpening excel.exe" -NoNewline
                $global:openedFile2 = $true
                DelayDots
                Read-Host "`nPress Enter to continue...`n"
                CompareAllContent
                Clear-Host
                RenderDataInputStatus
            } else {
                $validInput = $false
                $errorMessage = "Local Storage is not present in this series. Please select another option."
                Clear-Host
                RenderDataInputStatus
            }
        } elseif ($userResponse -eq "3") {
            Start-Process "excel.exe" -ArgumentList "`"$specsStorageRemoteINPUTPath`""
            $global:currentTemplate = $specsStorageRemoteEditedTemplatePath
            $global:currentINPUT = $specsStorageRemoteINPUTPath
            Write-Host "`nOpening excel.exe" -NoNewline
            $global:openedFile3 = $true
            DelayDots
            Read-Host "`nPress Enter to continue...`n"
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "4") {
            Start-Process "excel.exe" -ArgumentList "`"$specsNetworkINPUTPath`""
            $global:currentTemplate = $specsNetworkEditedTemplatePath
            $global:currentINPUT = $specsNetworkINPUTPath
            Write-Host "`nOpening excel.exe" -NoNewline
            $global:openedFile4 = $true
            DelayDots
            Read-Host "`nPress Enter to continue...`n"
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "5") {
            if ($acceleratorPresent -eq $true) {
                Start-Process "excel.exe" -ArgumentList "`"$specsAcceleratorsINPUTPath`""
                $global:currentTemplate = $specsAcceleratorsEditedTemplatePath
                $global:currentINPUT = $specsAcceleratorsINPUTPath
                Write-Host "`nOpening excel.exe" -NoNewline
                $global:openedFile5 = $true
                DelayDots
                Read-Host "`nPress Enter to continue...`n"
                CompareAllContent
                Clear-Host
                RenderDataInputStatus
            } else {
            $validInput = $false
            $errorMessage = "Accelerators are not present in this series. Please select another option."
            Clear-Host
            RenderDataInputStatus
            }
        } elseif ($userResponse -eq "f") {
            Start-Process "explorer.exe" -ArgumentList "$inputDirectory"
            $validInput = $true
            Write-Host "`nOpening explorer.exe" -NoNewline
            DelayDots
            Read-Host "`nPress Enter to continue...`n"
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "r") {
            Write-Host "`nRefreshing status" -NoNewline
            DelayDots
            $validInput = $true
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "e") {
            Write-Host "`nWould you like to view the example in this window or in Excel?`nType 'x' for Excel or press Enter to view in-window."
            $validInput = $true
            $userResponse = Read-Host
            if ($userResponse -eq "x") {
                Start-Process "excel.exe" -ArgumentList "`"$examplesDirectory\example-specs-cpu-memory.csv`""
                Write-Host "`nOpening excel.exe" -NoNewline
                DelayDots
            } else {
                $csvData = Import-Csv -Path "$examplesDirectory\example-specs-cpu-memory.csv"
                Write-Host "`nHere's an example of the file content (in this case, the CPU & Memory file):`n" -ForegroundColor Magenta
                $longSizeNameLength = ($csvData | ForEach-Object { $_."Size-Name".Length } | Measure-Object -Maximum).Maximum
                $spacesSizeName = " " * ($longSizeNameLength - 9)
                $longCpuLength = ($csvData | ForEach-Object { $_."vCPUs".Length } | Measure-Object -Maximum).Maximum
                #$spacesCpu = " " * ($longCpuLength - 5)
                $spacesCpu = ""
                $longMemoryLength = ($csvData | ForEach-Object { $_."Memory-GB".Length } | Measure-Object -Maximum).Maximum
                #$spacesMemory = " " * ($longMemoryLength - 9)
                $spacesMemory = ""
                Write-Host "|  Size-Name${spacesSizeName} | vCPUs${spacesCpu} | Memory-GB${spacesMemory} |"
                foreach ($row in $csvData) {
                    $spacesSizeName = " " * ($longSizeNameLength - $row."Size-Name".Length)
                    $spacesCpu = " " * ($longCpuLength - $row."vCPUs".Length)
                    $spacesMemory = " " * ($longMemoryLength - $row."Memory-GB".Length)
                    Write-Host "|  $($row."Size-Name")${spacesSizeName} |  $($row."vCPUs")${spacesCPU}   |  $($row."Memory-GB")${spacesMemory}      |"
                }
            }
            Read-Host "`nPress Enter to continue`n"
            CompareAllContent
            Clear-Host
            RenderDataInputStatus
        } elseif ($userResponse -eq "done") {
            CompareAllContent
            if ($acceleratorPresent -eq $false) {
                $global:fileStatus4 = $global:fileStatusEdited
            }
            if ($global:fileStatus1 -ne $global:fileStatusEdited -or $global:fileStatus2 -ne $global:fileStatusEdited -or $global:fileStatus3 -ne $global:fileStatusEdited -or $global:fileStatus4 -ne $global:fileStatusEdited) {
                $validInput = $false
                $errorMessage = "You haven't edited all the files.`nMake sure to open all files and enter the necessary data before continuing."
                if ($testMode -eq $true) {
                    Write-Host "`nTesting mode is enabled. The script will continue despite the warning." -NoNewline
                    Clear-Host
                    break
                }
                CompareAllContent
                Clear-Host
                RenderDataInputStatus
            } else {
                Write-Host "`nAll files have been edited!" -ForegroundColor Green
                Write-Host "`nWARNING: Make sure to close all editors before continuing. `nIf you continue while the files are still open, you will encounter errors and the script will fail!" -ForegroundColor Red
                Read-Host "`nAfter ensuring all editor windows are closed, press Enter to continue`n"
                Clear-Host
                break
            }
        } else {
            Clear-Host
            RenderDataInputStatus
            $validInput = $false
            $errorMessage = "Invalid input. Please enter 1 - 5, 'e', 'r', or type 'done'."
        }
    }

    # SUMMARY TIME
    $summaryExamplePath = "$examplesDirectory\example-summary.txt"
    New-Item -Path "$inputDirectory\INPUT-summary.txt" -ItemType File
    $summaryINPUTPath = "$inputDirectory\INPUT-summary.txt"

    $showMessage = $false
    $validInput = $true
    while ($true) {
        Clear-Host
        Write-Host "SUMMARY INPUT" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "Now we'll enter the data for the ${seriesBaseName} series' summary.`n"
        Write-Host "Fill out the " -NoNewLine; Write-Host "INPUT-summary_${seriesBaseName}-series.txt" -NoNewLine -ForegroundColor Yellow; Write-Host " file with the size series' summary.`n"
        Write-Host "NOTE: Make sure the summary is a single paragraph of plain text."

        if ($validInput -eq $false) { Write-Host "`nERROR: ${errorMessage}`n" -ForegroundColor Red }
        if ($showMessage -eq $true) { Write-Host "`n${messageText}`n" -ForegroundColor Magenta }
        if ($showMessage -ne $true -and $validInput -ne $false) { Write-Host "`n`n" }

        Write-Host "Enter 'n' to open the file in Notepad.exe.`nEnter 'f' to open the directory in Explorer.exe.`nEnter 'e' to view an example.`nEnter 'done' when you've finished entering data in the file to continue."

        if ($testMode -eq $true) {
            Read-Host "`nTest Mode Enabled, press Enter to continue`n"
            break
        } else {
            $userResponse = Read-Host
        }

        if ($userResponse -eq "n") {
            Start-Process "notepad.exe" -ArgumentList "$summaryINPUTPath"
            Write-Host "`nOpening notepad.exe" -NoNewline
            DelayDots
        } elseif ($userResponse -eq "f") {
            Start-Process "explorer.exe" -ArgumentList "$inputDirectory"
            Write-Host "`nOpening explorer.exe" -NoNewline
            DelayDots
        } elseif ($userResponse -eq "e") {
            Write-Host "`nWould you like to view the example in this window or in Notepad?`nType 'n' for Notepad or press Enter to view in-window."
            $userResponse = Read-Host
            if ($userResponse -eq "n") {
                Start-Process "notepad.exe" -ArgumentList "`"$examplesDirectory\example-summary.txt`""
                Write-Host "`nOpening notepad.exe" -NoNewline
                DelayDots
            } else {
                $csvData = Import-Csv -Path "$examplesDirectory\example-specs-cpu-memory.csv"
                Write-Host "`nHere's an example of a summary file:`n" -ForegroundColor Magenta
                $summaryExampleContent = Get-Content -Path $summaryExamplePath -Raw
                Write-Host $summaryExampleContent
                Read-Host "`nPress Enter to continue`n"
            }
        } elseif ($userResponse -eq "done") {
            $summaryNewContent = Get-Content -Path $summaryINPUTPath -Raw
            $summaryNoData = Get-Content -Path "$templateDirectory\emptyfile.txt" -Raw
            if ($summaryNewContent -eq $summaryNoData) {
                if ($testMode -eq $true) {
                    Write-Host "`nThe file looks empty, but you're in testing mode. The script will now continue`n"
                    break
                } else {
                    $validInput = $false
                    $errorMessage = "The file looks empty, did you not edit the file and/or forget to save?"
                }
            } else {
                break
            }
        } else {
            $validInput = $false
            $errorMessage = "Invalid input. Please type 'n', 'f', 'e', or 'done'."
        }
    }



    # SUMMARY REVIEW
    $showMessage = $false
    $validInput = $true
    while ($true) {
        Clear-Host
        Write-Host "SUMMARY INPUT" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
        Write-Host "The file has been edited! Here's the content you've entered:`n"
        Write-Host "  ${seriesSelected} Summary:" -ForegroundColor DarkGray
        Write-Host "    $summaryNewContent"
        Write-Host "`n`nRemember to " -NoNewLine; Write-Host "close your editor!"-ForegroundColor Red
        Write-Host "NOTE: If you continue while the file is still open, you will encounter errors and the script will fail!`n" -ForegroundColor DarkYellow
        Write-Host "If this content looks good, press 'Enter' to continue."
        if ($testMode -eq $true) {
            Read-Host "`nTest Mode Enabled, press Enter to continue`n"
            $userResponse = ""
        } else {
            $userResponse = Read-Host
        }

        if ($userResponse -eq "") {
            break
        }
    }


} elseif ($scriptOperation -eq "update") {
    # UPDATE OPERATIONS
    Write-Host "ERROR: Sorry, this script is not yet built to update files...`nPlease restart the script and select a different operation." -ForegroundColor Red
    return
} elseif ($scriptOperation -eq "retire") {
    # RETIRE OPERATIONS
    Write-Host "ERROR: Sorry, this script is not yet built to retire files...`nPlease restart the script and select a different operation." -ForegroundColor Red
    return
} else {
    Write-Host "ERROR: Something went wrong... Please restart the script." -ForegroundColor Red
    return
}






# CONTENT REVIEW - PAGE 1
Clear-Host
$csvData = Import-Csv -Path $tempStorSizesNameList
Write-Host "CONTENT REVIEW" -BackgroundColor Blue -NoNewline; Write-Host " - Page 1" -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
Write-Host "Let's go through the current setup for the $seriesSelected series.`nHere's the information we have:`n"
Write-Host "  Size family and file data:" -ForegroundColor DarkGray
Write-Host "    - Type: $seriesTypeFancy"
Write-Host "    - Family: $seriesFamilyUpper"
Write-Host "    - Series: $seriesSelected"
Write-Host "    - File: $seriesFileName"
Write-Host "`n  Sizes Names List:" -ForegroundColor DarkGray
foreach ($row in $csvData) {
    Write-Host "    - " -NoNewline
    Write-Host $row."Size-Name"
}
Read-Host "`nIf there's an issue in any of this content, restart the script.`nIf everything looks good, press Enter to continue.`n"
Clear-Host

function CsvFirstandLastImport {
    $csvData = Import-Csv -Path $global:csvPath
    # Check if the CSV data is not empty
    if ($csvData.Count -gt 0) {
        # Store the first row value of the vCPUs column
        $global:firstRowData = $csvData[0].$global:csvColumn

        # Store the last row value of the vCPUs column
        $global:lastRowData = $csvData[$csvData.Count - 1].$global:csvColumn

        # If the first and last row values are the same, only display one of them. If they're both empty, display "N/A", otherwise display the range with a ' - ' separator.
        if ($global:firstRowData -eq $global:lastRowData) {
            $global:dataRange = "$global:firstRowData"
        } elseif ($global:firstRowData -ne $global:lastRowData) {
            $global:dataRange = "$global:firstRowData - $global:lastRowData"
        } else {
           $global:dataRange = "N/A"
        }
    }
}

# CONTENT REVIEW - PAGE 2
Clear-Host
Write-Host "CONTENT REVIEW" -BackgroundColor Blue -NoNewline; Write-Host " - Page 2" -NoNewLine; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
Write-Host "Let's go through the tables for the $seriesSelected series.`nHere's the information we have:`n"
#CPU and Memory
Write-Host "  CPU and Memory:" -ForegroundColor DarkGray
if ($hwCpuModelCount -eq 1) { 
    Write-Host "    $processorSKU CPU" 
} else { 
    $processorSKUPretty = $processorSKU -replace "<br>", ", "
    Write-Host "    $processorSKUPretty CPUs" 
}
$global:csvPath = $specsCpuMemoryInputPath; $global:csvColumn = "vCPUs"; CsvFirstandLastImport
Write-Host "     - vCPUs (vCores): $dataRange"; $specAggCPUCores = $dataRange
$global:csvPath = $specsCpuMemoryInputPath; $global:csvColumn = "Memory-GB"; CsvFirstandLastImport
Write-Host "     - Memory (GB)   : $dataRange"; $specAggMemory = $dataRange
#Storage Local
if ($localStoragePresent -eq $true) {
    Write-Host "  Local Storage:" -ForegroundColor DarkGray
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-Count"; CsvFirstandLastImport
    Write-Host "     - Max Temp Storage (Qty.)             : $dataRange"; $specAggLocalDiskCount = $dataRange
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-Size-GB"; CsvFirstandLastImport
    Write-Host "     - Temp Storage Size (GiB)             : $dataRange"; $specAggLocalDiskSize = $dataRange
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-RR-IOPS"; CsvFirstandLastImport
    Write-Host "     - Temp Random Read Storage IOPS          : $dataRange"; $specAggLocalDiskRRIOPS = $dataRange
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-RR-MBps"; CsvFirstandLastImport
    Write-Host "     - Temp Random Read Storage Speed (MBps)  : $dataRange"; $specAggLocalDiskRRSpeed = $dataRange
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-RW-IOPS"; CsvFirstandLastImport
    Write-Host "     - Temp Random Write Storage IOPS         : $dataRange"; $specAggLocalDiskRWIOPS = $dataRange
    $global:csvPath = $specsStorageLocalInputPath; $global:csvColumn = "Local-Disk-RW-MBps"; CsvFirstandLastImport
    Write-Host "     - Temp Random Write Storage Speed (MBps) : $dataRange"; $specAggLocalDiskRWSpeed = $dataRange
} else {
    Write-Host "  Local Storage:" -ForegroundColor DarkGray
    Write-Host "    No local storage present in this series."
}
#Storage Remote
Write-Host "  Remote Storage:" -ForegroundColor DarkGray
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Disk-Count"; CsvFirstandLastImport
Write-Host "     - Max Remote Storage (Qty.)                   : $dataRange"; $specAggRemoteDiskCount = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Disk-IOPS"; CsvFirstandLastImport
Write-Host "     - Uncached Storage IOPS                       : $dataRange"; $specAggRemoteDiskIOPS = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Disk-MBps"; CsvFirstandLastImport
Write-Host "     - Uncached Storage Speed (MBps)               : $dataRange"; $specAggRemoteDiskSpeed = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Disk-Burst-IOPS"; CsvFirstandLastImport
Write-Host "     - Uncached Storage Burst IOPS                 : $dataRange"; $specAggRemoteDiskBurstSpeed = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Disk-Burst-MBps"; CsvFirstandLastImport
Write-Host "     - Uncached Storage Burst Speed (MBps)         : $dataRange"; $specAggRemoteDiskSize = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Special-Disk-IOPS"; CsvFirstandLastImport
Write-Host "     - Uncached Special Storage IOPS               : $dataRange"; $specAggRemoteDiskIOPS = $dataRange
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Special-Disk-MBps"; CsvFirstandLastImport
Write-Host "     - Uncached Special Storage Speed (MBps)       : $dataRange"
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Special-Disk-Burst-IOPS"; CsvFirstandLastImport
Write-Host "     - Uncached Burst Special Storage IOPS         : $dataRange"
$global:csvPath = $specsStorageRemoteInputPath; $global:csvColumn = "Remote-Special-Disk-Burst-MBps"; CsvFirstandLastImport
Write-Host "     - Uncached Burst Special Storage Speed (MBps) : $dataRange"
#Network
Write-Host "  Network:" -ForegroundColor DarkGray
$global:csvPath = $specsNetworkInputPath; $global:csvColumn = "NIC-count"; CsvFirstandLastImport
Write-Host "     - Max NICs (Qty.)     : $dataRange"; $specAggNetNicCount = $dataRange
$global:csvPath = $specsNetworkInputPath; $global:csvColumn = "Bandwidth-Mbps"; CsvFirstandLastImport
Write-Host "     - Max Bandwidth (Mbps): $dataRange"; $specAggNetBandwidth = $dataRange
#Accelerators
if ($acceleratorPresent -eq $true) {
    Write-Host "  Accelerators:" -ForegroundColor DarkGray
    Write-Host "    $acceleratorSKU"
    $global:csvPath = $specsAcceleratorsInputPath; $global:csvColumn = "Accelerator-Count"; CsvFirstandLastImport
    Write-Host "     - Accelerators (Qty.)    : $dataRange"; $specAggAccelCount = $dataRange
    $global:csvPath = $specsAcceleratorsInputPath; $global:csvColumn = "Accelerator-Memory-GB"; CsvFirstandLastImport
    Write-Host "     - Accelerator Memory (GB): $dataRange"; $specAggAccelMemory = $dataRange
} else {
    Write-Host "  Accelerators:" -ForegroundColor DarkGray
    Write-Host "    - No accelerators present in this series."
}

Read-Host "`nIf there's an issue in any of this content, go back and edit the files in the INPUT directory.`nIf everything looks good, press 'Enter' to continue.`n"
Clear-Host




# CREATE THE FINAL FILES
Clear-Host
$createArticleStatus = ""
$doCreateArticle = $true
$createSummaryStatus = ""
$doCreateSummary = $true
$createSpecsStatus = ""
$doCreateSpecs = $true
$invalidInput = $false
while ($true) {
    Write-Host "FINAL FILE CREATION" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
    Write-Host "Now that we have all the necessary data, we'll create the final files for the $seriesSelected series.`n"
    Write-Host "  Files being created:" -ForegroundColor DarkGray
    Write-Host "    - " -NoNewLine; Write-Host "${createArticleStatus}" -ForegroundColor Red -NoNewLine; Write-Host "Size series article: ${seriesBaseNameLower}-series.md"
    Write-Host "    - " -NoNewLine; Write-Host "${createSummaryStatus}" -ForegroundColor Red -NoNewLine; Write-Host "Summary include: ${seriesBaseNameLower}-series-summary.md"
    Write-Host "    - " -NoNewline; Write-Host "${createSpecsStatus}" -ForegroundColor Red -NoNewLine; Write-Host "Specs include: ${seriesBaseNameLower}-series-specs"

    if ($invalidInput -eq $true) { Write-Host "`nERROR: Invalid input.`n" -ForegroundColor Red }
    if ($showMessage -eq $true) { Write-Host "`n$showMessageContent`n" -ForegroundColor Magenta }
    if ($showMessage -eq $false -and $invalidInput -eq $false) { Write-Host "`n`n" }

    Write-Host "Enter a number '1' - '3' to disable a file's creation.`nEnter 'done' to continue creating all enabled files.`n"

    $userResponse = Read-Host
    if ($userResponse -eq "1") {
        if ($doCreateArticle -eq $true) {
            $createArticleStatus = "[Disabled] "
            $doCreateArticle = $false
            $showMessageContent = "`nSize series article creation has been disabled."
        } elseif ($doCreateArticle -eq $false) {
            $createArticleStatus = ""
            $doCreateArticle = $true
            $showMessageContent = "`nSize series article creation has been re-enabled."
        }
        Clear-Host
    } elseif ($userResponse -eq "2") {
        if ($doCreateSummary -eq $true) {
            $createSummaryStatus = "[Disabled] "
            $doCreateSummary = $false
            $showMessageContent = "`nSize summary include creation has been disabled."
        } elseif ($doCreateSummary -eq $false) {
            $createSummaryStatus = ""
            $doCreateSummary = $true
            $showMessageContent = "`nSize summary include creation has been re-enabled."
        }
        Clear-Host
    } elseif ($userResponse -eq "3") {
        if ($doCreateSpecs -eq $true) {
            $createSpecsStatus = "[Disabled] "
            $doCreateSpecs = $false
            $showMessageContent = "`nSize specs include creation has been disabled."
        } elseif ($doCreateSpecs -eq $false) {
            $createSpecsStatus = ""
            $doCreateSpecs = $true
            $showMessageContent = "`nSize specs include creation has been re-enabled."
        }
        Clear-Host
    } elseif ($userResponse -eq "done") {
        Write-Host "`nCreating files:"
        break
    } else {
        Clear-Host
        $invalidInput = $true
    }
}

function TableCSVconvertMD {
    $headers = $global:csvData[0].PSObject.Properties.Name
    $headerRow = "| " + ($headers -join " | ") + " |"
    $separatorRow = "| " + ($headers | ForEach-Object {'--- |'}) -join "|"

    # Initialize the Markdown content with the header
    $global:markdownTableContent = @($headerRow, $separatorRow)

    # Add each row of the CSV to the Markdown table
    foreach ($row in $global:csvData) {
        $rowData = @()
        foreach ($header in $headers) {
            $rowData += $row.$header
        }
        $global:markdownTableContent += "| " + ($rowData -join " | ") + " |"
    }

    # Convert the array to a single string with line breaks
    $global:markdownTableContent = $global:markdownTableContent -join "`n"
}




## DEFINE SOME INFO

$noLocalStorageMessage = "> [!NOTE]
> No local storage present in this series. For similar sizes with local storage, see the [Dpdsv6-series](./dpdsv6-series.md).
>
> For frequently asked questions, see [Azure VM sizes with no local temp disk](../../azure-vms-no-temp-disk.yml)."

$noAcceleratorsMessage = "> [!NOTE]
> No accelerators are present in this series."

$storageLocalResAndDefs = "#### Storage resources
- [Introduction to Azure managed disks](../../../virtual-machines/managed-disks-overview.md)
- [Azure managed disk types](../../../virtual-machines/disks-types.md)
- [Share an Azure managed disk](../../../virtual-machines/disks-shared.md)

#### Table definitions
- <sup>1</sup>Temp disk speed often differs between RR (Random Read) and RW (Random Write) operations. RR operations are typically faster than RW operations. The RW speed is usually slower than the RR speed on series where only the RR speed value is listed.
- Storage capacity is shown in units of GiB or 1024^3 bytes. When you compare disks measured in GB (1000^3 bytes) to disks measured in GiB (1024^3) remember that capacity numbers given in GiB may appear smaller. For example, 1023 GiB = 1098.4 GB.
- Disk throughput is measured in input/output operations per second (IOPS) and MBps where MBps = 10^6 bytes/sec.
- To learn how to get the best storage performance for your VMs, see [Virtual machine and disk performance](../../../virtual-machines/disks-performance.md)."

$seriesInPreviewMessage = "> [!NOTE]
> Azure Virtual Machine Series $seriesBaseName are currently in **Preview**. See the [Preview Terms Of Use | Microsoft Azure](https://azure.microsoft.com/support/legal/preview-supplemental-terms/) for legal terms that apply to Azure features that are in beta, preview, or otherwise not yet released into general availability.
"

# ACTUALLY CREATE ENABLED FILES
New-Item -Path "$outputDirectory\includes" -ItemType Directory -ErrorAction SilentlyContinue
if ($doCreateArticle -eq $true) {
    Write-Host "`nCreating size series article: ${seriesBaseNameLower}-series.md"
    # Read from the temp file
    $articleContent = Get-Content -Path "$templateDirectory\temp-series.md" -Raw
    # Replace values in the template
    $articleContent = $articleContent -replace "SERIESNAMEUC", $seriesBaseName
    $articleContent = $articleContent -replace "SERIESNAMELC", $seriesBaseNameLower
    $articleContent = $articleContent -replace "TODAYDATE", $todayDate
    $articleContent = $articleContent -replace "GITHUBALIAS", $githubAlias
    $articleContent = $articleContent -replace "MSFTALIAS", $msftAlias
    $articleContent = $articleContent -replace "LISTFEATURESUPPORT", $featureSupportList
    if ($seriesInPreview -eq $true) { $articleContent = $articleContent -replace "SERIESPREVIEWMSG", $seriesInPreviewMessage } else { $articleContent = $articleContent -replace "SERIESPREVIEWMSG", "" }
    ### Table: CPU Memory
    $global:csvData = Import-Csv -Path "$INPUTDirectory\INPUT-cpu-memory-specs_${seriesBaseNameLower}-series.csv"
    TableCSVconvertMD
    $articleContent = $articleContent -replace "TABLECPUMEMORY", $global:markdownTableContent
    ### Table: Storage Local
    if ($localStoragePresent -eq $true) {
        $global:csvData = Import-Csv -Path "$INPUTDirectory\INPUT-storage-local-specs_${seriesBaseNameLower}-series.csv"
        TableCSVconvertMD
        $articleContent = $articleContent -replace "TABLESTORAGELOCAL", $global:markdownTableContent
        $articleContent = $articleContent -replace "STORLOCALRESANDDEFS", $storageLocalResAndDefs
    } else {
        $articleContent = $articleContent -replace "TABLESTORAGELOCAL", "$noLocalStorageMessage" 
        $articleContent = $articleContent -replace "STORLOCALRESANDDEFS", "" }
    ### Table: Storage Remote
    $global:csvData = Import-Csv -Path "$INPUTDirectory\INPUT-storage-remote-specs_${seriesBaseNameLower}-series.csv"
    TableCSVconvertMD
    $articleContent = $articleContent -replace "TABLESTORAGEREMOTE", $global:markdownTableContent
    ### Table: Network
    $global:csvData = Import-Csv -Path "$INPUTDirectory\INPUT-network-specs_${seriesBaseNameLower}-series.csv"
    TableCSVconvertMD
    $articleContent = $articleContent -replace "TABLENETWORK", $global:markdownTableContent
    ### Table: Accelerators
    if ($acceleratorPresent -eq $true) {
        $global:csvData = Import-Csv -Path "$INPUTDirectory\INPUT-accelerators-specs_${seriesBaseNameLower}-series.csv"
        TableCSVconvertMD
        $articleContent = $articleContent -replace "TABLEACCELERATORS", $global:markdownTableContent
    } else {
        $articleContent = $articleContent -replace "TABLEACCELERATORS", "$noAcceleratorsMessage"
    }
    ### List: Special Features
    $articleContent = $articleContent -replace "SPECIALFEATURES", $global:specialFeatureFormattedData
    ### List: Features Limitations
    $articleContent = $articleContent -replace "FEATURELIMITATIONS", $global:featureLimitationFormattedData


    ### General fixes and definitions
    
    #### CPU and MEMORY Info
    $articleContent = $articleContent -replace "Size-Name", "Size Name"
    $articleContent = $articleContent -replace "vCPUs", "vCPUs (Qty.)"
    $articleContent = $articleContent -replace "Memory-GB", "Memory (GB)"
    
    #### NETWORK (NIC Info)
    $articleContent = $articleContent -replace "NIC-Count", "Max NICs (Qty.)"
    $articleContent = $articleContent -replace "Bandwidth-Mbps", "Max Bandwidth (Mbps)"

    #### STORAGE LOCAL (Disk Info)
    $articleContent = $articleContent -replace "Local-Disk-Count", "Max Temp Storage Disks (Qty.)"
    $articleContent = $articleContent -replace "Local-Disk-Size-GB", "Temp Disk Size (GiB)"
    $articleContent = $articleContent -replace "Local-Disk-RW-IOPS", "Temp Disk Random Write (RW)<sup>1</sup> IOPS"
    $articleContent = $articleContent -replace "Local-Disk-RW-MBps", "Temp Disk Random Write (RW)<sup>1</sup> Speed (MBps)"
    $articleContent = $articleContent -replace "Local-Disk-RR-IOPS", "Temp Disk Random Read (RR)<sup>1</sup> IOPS"
    $articleContent = $articleContent -replace "Local-Disk-RR-MBps", "Temp Disk Random Read (RR)<sup>1</sup> Speed (MBps)"

    #### STORAGE REMOTE (Disk Info)
    $articleContent = $articleContent -replace "Remote-Disk-Count", "Max Remote Storage Disks (Qty.)"
    $articleContent = $articleContent -replace "Remote-Disk-IOPS", "Uncached Disk IOPS"
    $articleContent = $articleContent -replace "Remote-Disk-MBps", "Uncached Disk Speed (MBps)"
    $articleContent = $articleContent -replace "Remote-Disk-Burst-IOPS", "Uncached Disk Burst<sup>1</sup> IOPS"
    $articleContent = $articleContent -replace "Remote-Disk-Burst-MBps", "Uncached Disk Burst<sup>1</sup> Speed (MBps)"
    $articleContent = $articleContent -replace "Remote-Special-Disk-IOPS", "Uncached Special<sup>2</sup> Disk IOPS"
    $articleContent = $articleContent -replace "Remote-Special-Disk-MBps", "Uncached Special<sup>2</sup> Disk Speed (MBps)"
    $articleContent = $articleContent -replace "Remote-Special-Disk-Burst-IOPS", "Uncached Burst<sup>1</sup> Special<sup>2</sup> Disk IOPS"
    $articleContent = $articleContent -replace "Remote-Special-Disk-Burst-MBps", "Uncached Burst<sup>1</sup> Special<sup>2</sup> Disk Speed (MBps)"

    
    #### ACCELERATORS (GPU Info)
    $articleContent = $articleContent -replace "Accelerator-Count", "Accelerators (Qty.)"
    $articleContent = $articleContent -replace "Accelerator-Memory-GB", "Accelerator Memory (GB)"
    
    ## Output new file to the OUTPUT directory
    $articleContent | Set-Content -Path $seriesFileOutputPath
}
if ($doCreateSummary -eq $true) {
    Write-Host "`nCreating size summary include: ${seriesBaseNameLower}-series-summary.md"
    # Create the summary file
    $summaryContent = Get-Content -Path "$templateDirectory\temp-summary.md" -Raw
    $summaryContent = $summaryContent -replace "SERIESNAMEUC", $seriesBaseName
    $summaryContent = $summaryContent -replace "SUMMARYTEXTINPUT", $summaryNewContent
    $summaryContent = $summaryContent -replace "TODAYDATE", $todayDate
    $summaryContent = $summaryContent -replace "GITHUBALIAS", $githubAlias
    $summaryContent = $summaryContent -replace "MSFTALIAS", $msftAlias
    $summaryContent | Set-Content -Path $seriesSummaryOutputPath
}
if ($doCreateSpecs -eq $true) {
    Write-Host "`nCreating size specs include: ${seriesBaseNameLower}-series-specs"
    # Read from the template
    $specsContent = Get-Content -Path "$templateDirectory\temp-specs.md" -Raw
    # Replace values in the template
    $specsContent = $specsContent -replace "SERIESNAMEUC", $seriesBaseName
    $specsContent = $specsContent -replace "SERIESNAMELC", $seriesBaseNameLower
    $specsContent = $specsContent -replace "TODAYDATE", $todayDate
    $specsContent = $specsContent -replace "GITHUBALIAS", $githubAlias
    $specsContent = $specsContent -replace "MSFTALIAS", $msftAlias
    ### Table: Processor
    $specsContent = $specsContent -replace "PROCESSORSKU", $processorSKU
    $specsContent = $specsContent -replace "VCORESQTY", "$specAggCPUCores"
    ### Table: Memory
    $specsContent = $specsContent -replace "MEMORYGB", "$specAggMemory"
    if ($hwHasPartMEM -eq $true) {
        $specsContent = $specsContent -replace "MEMORYDATA", "$specAggMemorySpeed" } else { $specsContent = $specsContent -replace "MEMORYDATA", "" }
    ### Table: Local Storage
    $specsContent = $specsContent -replace "TEMPDISKQTY", "$specAggLocalDiskCount"
    $specsContent = $specsContent -replace "TEMPDISKSIZE", "$specAggLocalDiskSize"
    $specsContent = $specsContent -replace "TEMPDISKIOPS", "$specAggLocalDiskRWIOPS"
    $specsContent = $specsContent -replace "TEMPDISKSPEED", "$specAggLocalDiskRWSpeed"
    ### Table: Remote Storage
    $specsContent = $specsContent -replace "DATADISKSQTY", "$specAggRemoteDiskCount"
    $specsContent = $specsContent -replace "DATADISKIOPS", "$specAggRemoteDiskIOPS"
    $specsContent = $specsContent -replace "DATADISKSPEED", "$specAggRemoteDiskSpeed"
    ### Table: Network
    $specsContent = $specsContent -replace "NICSQTY", "$specAggNetNicCount"
    $specsContent = $specsContent -replace "NETBANDWIDTH", "$specAggNetBandwidth"
    ### Table: Accelerators
    if ($acceleratorPresent -eq $true) {
        $specsContent = $specsContent -replace "ACCELDATA", "ACCELSKU ACCELMEM ACCELVMDATA"
        $specsContent = $specsContent -replace "ACCELSKU", "ACCELSKU ACCELMEM ACCELVMDATA"
        $specsContent = $specsContent -replace "ACCELVMDATA", "<br> ACCELVMMEMMIN - ACCELVMMEMMAX<sup>GiB</sup> per VM"
    } else {
        $specsContent = $specsContent -replace "ACCELDATA", ""
        $specsContent = $specsContent -replace "ACCELQTY", "None"
    }
    ## Output new file to the OUTPUT directory
    $specsContent | Set-Content -Path $seriesSpecsOutputPath

    
}

Write-Host "`nAll files have been created!`n" -ForegroundColor Green
Write-Host "Enter 'f' to open the OUTPUT folder and view the files or Press Enter to continue`n"
$userResponse = Read-Host
if ($userResponse -eq "f") {
    Start-Process "explorer.exe" -ArgumentList "$outputDirectory"
    Write-Host "`nOpening explorer.exe" -NoNewline
    DelayDots
    Read-Host "`nPress Enter to continue`n"
}

if ($batchMode -eq $true) {
    Write-Host "`nBatch mode is enabled. 'OUTPUT' files will now be moved to the 'BATCH' directory.`n" -ForegroundColor Yellow
    $fileCount = 0
    $inputFiles = Get-ChildItem -Path $outputDirectory -Recurse
    foreach ($file in $inputFiles) {
        Move-Item -Path $file.FullName -Destination $batchDirectory -Force
        $fileCount++
    }
    Get-ChildItem -Path "$batchDirectory" -Filter ".temp" -Recurse | Remove-Item -Force
    Write-Host "`n$fileCount files moved from OUTPUT to BATCH directory" -ForegroundColor Green

    Write-Host "`nWould you like to run the script again and $scriptOperation another series for the batch operation?`n" -ForegroundColor Yellow
    $userResponse = Read-Host "Enter 'y' to run again or 'n' to exit"
    if ($userResponse -eq "y") {
        Write-Host "Restarting script for next series" -ForegroundColor Yellow -NoNewline
        DelayDots
        Clear-Host
        .\sizes_script.ps1
    } else {
        Write-Host "`nExiting script...`n" -ForegroundColor Yellow
        exit 0
    }

}




# GIT OPERATIONS (pt.1)
Clear-Host
Write-Host "GIT OPERATIONS" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green
Write-Host "Before continuing, we'll create a new branch for this script to utilize.`nThis will run several git commands, so make sure you don't have any unsaved work in an open branch.`nAny unsaved work will be stashed."
Write-Host "`nWARNING: This requires that you have Git installed locally and you've set up PowerShell to use Git commands. `nIf you haven't done this, close the script and manually upload the files from the OUTPUT directory to a new PR.`n" -ForegroundColor DarkRed -BackgroundColor Yellow
Read-Host "`nPress Enter to run git operations.`n"

## Make sure the user has a valid branch, then check out to it.
Set-Location $gitDir
Write-Host "`nStashing content..."
if ($testMode -eq $true) {
    Write-Host "`nTesting mode is enabled. The script will not stash, checkout, or pull from the main branch."
} elseif ($demoMode -eq $true) {
    Write-Host "`nDemo mode is enabled. The script will not stash, checkout, or pull from the main branch."
} else {
    git stash push -m "Content auto-stashed by sizes script while ${scriptOpIng} the ${seriesSelected}."
    git checkout main
    git pull upstream main
    git push origin main
    git fetch
}

### Define the branch name and make sure there isn't already one with the same name. Dont do this if in testing mode
$branchNameBase = "sizes_${seriesSelected}_script-${scriptOperation}"
$revNum = 0

$branchName = $branchNameBase
$existsInLocal = git branch --list $branchNameBase
$existsInRemote = git branch --list -r | Select-String "origin/$branchNameBase"
# Evaluate existence
while ($existsInLocal -or $existsInRemote) {
    $revNum++
    Write-Host "Branch '$branchName' exists. Selecting alternative name..."
    $branchName = $branchNameBase + ".rev" + $revNum
    $existsInLocal = git branch --list $branchName
    $existsInRemote = git branch --list -r | Select-String "origin/$branchName"
}

if ($testMode -eq $false) {
    ### Run final checkout
    Write-Host "`nThe automated branch name will be: '$branchName'"
    Read-Host "`nPress Enter to create the branch..."
    git checkout -b $branchName
} else {
    Write-Host "`nTesting mode is enabled. The script will not create a new branch or create files."
    Write-Host "`nYour branch WOULD have been called '$branchName' if not in testing mode." -NoNewline
    DelayDots
}


# GIT OPERATIONS (pt.2)
Clear-Host
Write-Host "PUBLISH PULL REQUEST" -BackgroundColor Blue -NoNewline; Write-Host "${scriptModeTitle}`n" -ForegroundColor Green

Write-Host "Now that the files have been created and the branch has been created, we'll push the branch to the repository and create a pull request.`n"

Write-Host "This is currently disabled since the script is on version $scriptVersion. Feature will be enabled in the beta release.`n"

Write-Host "Please manually add the files from the OUTPUT directory to your branch and create a PR via the git CLI...`n"





