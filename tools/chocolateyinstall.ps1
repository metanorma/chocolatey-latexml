# Install LaTeXML via CPAN
Write-Host "Installing LaTeXML..." -ForegroundColor Green

$ErrorActionPreference = 'Continue'
$packageName = 'latexml'
$Strawberry = "C:\Strawberry"

# Verify Strawberry Perl is available
if (-not (Test-Path $Strawberry)) {
  throw "Strawberry Perl not found at $Strawberry. Please ensure strawberryperl is installed."
}

# Set up PATH for Strawberry Perl
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"

# Verify cpanm is available
$cpanmPath = "$Strawberry\perl\bin\cpanm.bat"
if (-not (Test-Path $cpanmPath)) {
  throw "cpanm not found at $cpanmPath. Please ensure Strawberry Perl is properly installed."
}

Write-Host "Using cpanm from: $cpanmPath" -ForegroundColor Yellow

# Extract CPAN version from Chocolatey version (strip build revision)
# Chocolatey version 0.8.8.1 -> CPAN version 0.8.8
$chocoVersion = $Env:ChocolateyPackageVersion
$cpanVersion = ($chocoVersion -split '\.')[0..2] -join '.'
Write-Host "Chocolatey package version: $chocoVersion" -ForegroundColor Yellow
Write-Host "CPAN module version: $cpanVersion" -ForegroundColor Yellow

# Show dependencies being installed
Write-Host "LaTeXML dependencies:" -ForegroundColor Yellow
& $cpanmPath --showdeps "LaTeXML@$cpanVersion" 2>&1 | Out-String | Write-Host

# Install LaTeXML with --notest to skip tests (tests require TeX which may not be available)
Write-Host "Installing LaTeXML version: $cpanVersion" -ForegroundColor Yellow
& $cpanmPath --notest "LaTeXML@$cpanVersion" 2>&1 | Out-String | Write-Host

if ($LASTEXITCODE -ne 0) {
  throw "Failed to install LaTeXML. cpanm exited with code: $LASTEXITCODE"
}

# Verify installation
Write-Host "Verifying LaTeXML installation..." -ForegroundColor Green

$latexmlPath = Get-Command latexml -ErrorAction SilentlyContinue
if ($latexmlPath) {
  Write-Host "LaTeXML installed successfully at: $($latexmlPath.Definition)" -ForegroundColor Green

  # Test latexml command
  try {
    $versionOutput = & latexml --VERSION 2>&1
    Write-Host "LaTeXML version: $versionOutput" -ForegroundColor Green
  } catch {
    Write-Warning "Could not verify LaTeXML version: $_"
  }
} else {
  throw "LaTeXML installation verification failed - latexml command not found in PATH"
}

Write-Host "LaTeXML installation completed successfully!" -ForegroundColor Green
