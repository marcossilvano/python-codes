# Get-ExecutionPolicy
# Set-ExecutionPolicy Unrestricted (powershell in Admin mode)

$source = "."
$destination = ".\_JELOS\images"

New-Item -ItemType Directory -Force -Path $destination
Copy-Item $source\* $destination -Exclude @("_MUOS","_JELOS") -Recurse

Get-ChildItem -File -Recurse | Rename-Item -NewName {$_.Basename + '-image' + $_.Extension}