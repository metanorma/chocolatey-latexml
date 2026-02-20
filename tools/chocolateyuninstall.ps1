# Uninstall LaTeXML via CPAN
Write-Host "Uninstalling LaTeXML..." -ForegroundColor Green

$ErrorActionPreference = 'Continue'
$Strawberry = "C:\Strawberry"

# Verify Strawberry Perl is available
if (-not (Test-Path $Strawberry)) {
  Write-Warning "Strawberry Perl not found at $Strawberry. LaTeXML may already be uninstalled."
  exit 0
}

# Set up PATH for Strawberry Perl
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"

# Verify cpanm is available
$cpanmPath = "$Strawberry\perl\bin\cpanm.bat"
if (-not (Test-Path $cpanmPath)) {
  Write-Warning "cpanm not found at $cpanmPath. Cannot uninstall LaTeXML via cpanm."
  exit 0
}

Write-Host "Using cpanm from: $cpanmPath" -ForegroundColor Yellow

# Extract CPAN version from Chocolatey version (strip build revision)
# Chocolatey version 0.8.8.1 -> CPAN version 0.8.8
$chocoVersion = $Env:ChocolateyPackageVersion
$cpanVersion = ($chocoVersion -split '\.')[0..2] -join '.'

# Uninstall LaTeXML
Write-Host "Uninstalling LaTeXML version: $cpanVersion" -ForegroundColor Yellow

& $cpanmPath --verbose --uninstall --force "LaTeXML@$cpanVersion" 2>&1 | Out-String | Write-Host

if ($LASTEXITCODE -ne 0) {
  Write-Warning "cpanm uninstall exited with code: $LASTEXITCODE"
}

# Verify uninstallation
Write-Host "Verifying LaTeXML uninstallation..." -ForegroundColor Green

$latexmlPath = Get-Command latexml -ErrorAction SilentlyContinue
if ($latexmlPath) {
  Write-Warning "LaTeXML may still be installed at: $($latexmlPath.Definition)"
  Write-Host "This could be a system Perl installation or PATH caching issue" -ForegroundColor Yellow
} else {
  Write-Host "LaTeXML successfully uninstalled - latexml command not found" -ForegroundColor Green
}

Write-Host "LaTeXML uninstallation completed!" -ForegroundColor Green
