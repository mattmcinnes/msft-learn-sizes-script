# Initial question
Write-Host "Do you want to edit a single file or all files in a directory?"
Write-Host "    1. Single file"
Write-Host "    2. All files in a directory"
$choice = Read-Host

if ($choice -eq "1") {
    # Prompt the user for a file path
    Write-Host "Enter the file path to make edits"
    $filePath = Read-Host
    $filePath = $filePath.Trim('"')
    # Read the file name from the file path
    $fileName = Split-Path -Path $filePath -Leaf
    $files = @([pscustomobject]@{ FullName = $filePath; Name = $fileName })
} elseif ($choice -eq "2") {
    # Prompt the user for a directory
    Write-Host "Enter the directory path to process files"
    $directoryPath = Read-Host
    $directoryPath = $directoryPath.Trim('"')
    # Get all files in the directory (excluding sub-directories)
    $files = Get-ChildItem -Path $directoryPath -File
} else {
    Write-Host "Invalid choice. Please enter 1 or 2."
    exit
}

foreach ($file in $files) {
    $filePath = $file.FullName
    $fileName = $file.Name

    Write-Host "Processing file: $fileName"

    $content = Get-Content -Path $filePath -Raw

    # Replace potential incorrect headers
    $content = ($content -replace 'Uncached Storage', 'Uncached Disk') `
        -replace 'Storage Speed', 'Disk Speed' `
        -replace 'Storage IOPS', 'Disk IOPS' `

    # Local Disk Replacements
    $content = ($content -replace 'Temp Disk Random Read \(RR\)<sup>1</sup> Speed \(MBps\)', 'Temp Disk Random Read (RR)<sup>1</sup> Throughput (MB/s)') `
        -replace 'Temp Disk Random Write \(RW\)<sup>1</sup> Speed \(MBps\)', 'Temp Disk Random Write (RW)<sup>1</sup> Throughput (MB/s)'


    # Remote Disk Replacements
    $content = ($content -replace 'Uncached Disk IOPS', 'Uncached Premium SSD Disk IOPS') `
        -replace 'Uncached Disk Speed \(MBps\)', 'Uncached Premium SSD Throughput (MB/s)' `
        -replace 'Uncached Disk Burst<sup>1</sup> IOPS', 'Uncached Premium SSD Burst<sup>1</sup> IOPS' `
        -replace 'Uncached Disk Burst<sup>1</sup> Speed \(MBps\)', 'Uncached Premium SSD Burst<sup>1</sup> Throughput (MB/s)' `
        -replace 'Uncached Special<sup>2</sup> Disk IOPS', 'Uncached Ultra Disk and Premium SSD v2 IOPS' `
        -replace 'Uncached Special<sup>2</sup> Disk Speed \(MBps\)', 'Uncached Ultra Disk and Premium SSD v2 Throughput (MB/s)' `
        -replace 'Uncached Burst<sup>1</sup> Special<sup>2</sup> Disk IOPS', 'Uncached Burst<sup>1</sup> Ultra Disk and Premium SSD v2 IOPS' `
        -replace 'Uncached Burst<sup>1</sup> Special Disk IOPS', 'Uncached Burst<sup>1</sup> Ultra Disk and Premium SSD v2 IOPS' `
        -replace 'Uncached Burst<sup>1</sup> Special<sup>2</sup> Disk Speed \(MBps\)', 'Uncached Burst<sup>1</sup> Ultra Disk and Premium SSD v2 Disk Throughput (MB/s)' `
        -replace 'Uncached Burst<sup>1</sup> Special Disk Speed \(MBps\)', 'Uncached Burst<sup>1</sup> Ultra Disk and Premium SSD v2 Disk Throughput (MB/s)' `
        -replace '- <sup>2</sup>Special Storage refers to either \[Ultra Disk\]\(../../../virtual-machines/disks-enable-ultra-ssd.md\) or \[Premium SSD v2\]\(../../../virtual-machines/disks-deploy-premium-v2.md\) storage.', ''

    # Network Replacements
    $content = ($content -replace 'Max Bandwidth \(Mbps\)', 'Max Network Bandwidth (Mb/s)')


    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $content -Force
}

Read-Host -Prompt "Press Enter to exit"