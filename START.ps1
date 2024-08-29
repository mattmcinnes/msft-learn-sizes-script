# Import variables from the main sizes_script file
. ./bin/version.ps1


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

. ./bin/update.ps1
Clear-Host
IntroBlock
. ./bin/sizes_script.ps1