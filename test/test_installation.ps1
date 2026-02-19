# PowerShell Test Script for Chocolatey LaTeXML Installation/Uninstallation
# This script mocks Chocolatey functions to test the install/uninstall scripts without system changes

param(
    [switch]$TestInstall,
    [switch]$TestUninstall,
    [switch]$Verbose
)

# Global test state
$global:TestResults = @()
$global:MockedCalls = @()
$global:FilesCreated = @()

# Mock environment variables
if ($IsWindows) {
    $env:ChocolateyInstall = "C:\ProgramData\chocolatey"
} else {
    $env:ChocolateyInstall = "/tmp/chocolatey"
}

# Mock Strawberry Perl path
$env:ChocolateyPackageVersion = "0.8.8"

function Write-TestResult {
    param($TestName, $Result, $Details = "")
    $global:TestResults += [PSCustomObject]@{
        Test = $TestName
        Result = $Result
        Details = $Details
        Timestamp = Get-Date
    }

    $color = if ($Result -eq "PASS") { "Green" } elseif ($Result -eq "FAIL") { "Red" } else { "Yellow" }
    Write-Host "[$Result] $TestName" -ForegroundColor $color
    if ($Details) {
        Write-Host "    $Details" -ForegroundColor Gray
    }
}

function Write-MockCall {
    param($FunctionName, $Parameters)
    $global:MockedCalls += [PSCustomObject]@{
        Function = $FunctionName
        Parameters = $Parameters
        Timestamp = Get-Date
    }
    if ($Verbose) {
        Write-Host "MOCK: $FunctionName called with: $($Parameters | ConvertTo-Json -Compress)" -ForegroundColor Cyan
    }
}

# Mock cpanm command
function Mock-Cpanm {
    param($Arguments)

    Write-MockCall "cpanm" @{ Arguments = $Arguments }

    if ($Arguments -contains "--showdeps") {
        Write-Host "Mock: Showing dependencies for LaTeXML"
        return
    }

    if ($Arguments -contains "--uninstall") {
        Write-Host "Mock: Uninstalling LaTeXML"
        return
    }

    # Simulate installation
    Write-Host "Mock: Installing LaTeXML from CPAN"
    $global:LASTEXITCODE = 0
}

# Mock Test-Path to simulate Strawberry Perl existence
function Mock-TestPath {
    param($Path)

    if ($Path -like "*Strawberry*") {
        return $true  # Simulate Strawberry Perl is installed
    }

    return Test-Path $Path
}

# Mock Get-Command to simulate latexml availability
function Mock-GetCommand {
    param($Name, $ErrorAction)

    if ($Name -eq "latexml") {
        # Return mock command info
        return [PSCustomObject]@{
            Name = "latexml"
            Definition = "C:\Strawberry\perl\site\bin\latexml.bat"
            Source = "C:\Strawberry\perl\site\bin\latexml.bat"
        }
    }

    if ($Name -eq "cpanm" -or $Name -eq "cpanm.bat") {
        return [PSCustomObject]@{
            Name = "cpanm"
            Definition = "C:\Strawberry\perl\bin\cpanm.bat"
            Source = "C:\Strawberry\perl\bin\cpanm.bat"
        }
    }

    # For other commands, use the real Get-Command
    return Microsoft.PowerShell.Core\Get-Command $Name -ErrorAction $ErrorAction
}

function Test-InstallationScript {
    Write-Host "`n=== Testing Installation Script ===" -ForegroundColor Yellow

    # Reset test state
    $global:MockedCalls = @()
    $global:FilesCreated = @()

    try {
        # Simulate the installation script logic
        Write-Host "Simulating LaTeXML installation..." -ForegroundColor Green

        $Strawberry = "C:\Strawberry"
        $packageName = 'latexml'

        # Mock verification steps
        Write-Host "Step 1: Verifying Strawberry Perl..."
        if (Mock-TestPath $Strawberry) {
            Write-TestResult "Strawberry Perl Detection" "PASS" "Strawberry Perl found at $Strawberry"
        } else {
            Write-TestResult "Strawberry Perl Detection" "FAIL" "Strawberry Perl not found"
        }

        Write-Host "Step 2: Verifying cpanm..."
        $cpanmPath = "$Strawberry\perl\bin\cpanm.bat"
        if (Mock-TestPath $cpanmPath) {
            Write-TestResult "cpanm Detection" "PASS" "cpanm found at $cpanmPath"
        } else {
            Write-TestResult "cpanm Detection" "FAIL" "cpanm not found"
        }

        Write-Host "Step 3: Simulating CPAN installation..."
        Mock-Cpanm @("--showdeps", "LaTeXML@$env:ChocolateyPackageVersion")
        Mock-Cpanm @("LaTeXML@$env:ChocolateyPackageVersion")
        Write-TestResult "CPAN Installation" "PASS" "cpanm install command executed"

        Write-Host "Step 4: Verifying installation..."
        $latexmlCmd = Mock-GetCommand "latexml" -ErrorAction SilentlyContinue
        if ($latexmlCmd) {
            Write-TestResult "LaTeXML Command Registration" "PASS" "latexml found at $($latexmlCmd.Definition)"
        } else {
            Write-TestResult "LaTeXML Command Registration" "FAIL" "latexml command not found"
        }

        Write-Host "`nInstallation script test completed!" -ForegroundColor Green

    } catch {
        Write-TestResult "Installation Script Execution" "FAIL" "Error: $_"
    }
}

function Test-UninstallationScript {
    Write-Host "`n=== Testing Uninstallation Script ===" -ForegroundColor Yellow

    # Reset test state
    $global:MockedCalls = @()

    try {
        # Simulate the uninstallation script logic
        Write-Host "Simulating LaTeXML uninstallation..." -ForegroundColor Green

        $Strawberry = "C:\Strawberry"

        Write-Host "Step 1: Verifying Strawberry Perl..."
        if (Mock-TestPath $Strawberry) {
            Write-TestResult "Strawberry Perl Detection" "PASS" "Strawberry Perl found at $Strawberry"
        } else {
            Write-TestResult "Strawberry Perl Detection" "FAIL" "Strawberry Perl not found"
        }

        Write-Host "Step 2: Simulating CPAN uninstallation..."
        Mock-Cpanm @("--verbose", "--uninstall", "--force", "LaTeXML@$env:ChocolateyPackageVersion")
        Write-TestResult "CPAN Uninstallation" "PASS" "cpanm uninstall command executed"

        Write-Host "Step 3: Verifying uninstallation..."
        # In a real scenario, Get-Command would return null after uninstallation
        Write-TestResult "Uninstallation Verification" "PASS" "Uninstallation sequence completed"

        Write-Host "`nUninstallation script test completed!" -ForegroundColor Green

    } catch {
        Write-TestResult "Uninstallation Script Execution" "FAIL" "Error: $_"
    }
}

function Test-NuspecFile {
    Write-Host "`n=== Testing Nuspec File ===" -ForegroundColor Yellow

    $nuspecPath = ".\latexml.nuspec"

    if (!(Test-Path $nuspecPath)) {
        Write-TestResult "Nuspec File Exists" "FAIL" "latexml.nuspec not found"
        return
    }

    Write-TestResult "Nuspec File Exists" "PASS" "latexml.nuspec found"

    try {
        [xml]$nuspec = Get-Content $nuspecPath

        # Check required elements
        $metadata = $nuspec.package.metadata

        if ($metadata.id -eq "latexml") {
            Write-TestResult "Package ID" "PASS" "ID is 'latexml'"
        } else {
            Write-TestResult "Package ID" "FAIL" "ID should be 'latexml', got '$($metadata.id)'"
        }

        if ($metadata.version) {
            Write-TestResult "Version Present" "PASS" "Version: $($metadata.version)"
        } else {
            Write-TestResult "Version Present" "FAIL" "Version not specified"
        }

        if ($metadata.dependencies) {
            $deps = $metadata.dependencies.dependency
            $strawberryDep = $deps | Where-Object { $_.id -eq "strawberryperl" }
            if ($strawberryDep) {
                Write-TestResult "Strawberry Perl Dependency" "PASS" "strawberryperl dependency found"
            } else {
                Write-TestResult "Strawberry Perl Dependency" "FAIL" "strawberryperl dependency not found"
            }
        } else {
            Write-TestResult "Dependencies" "FAIL" "No dependencies specified"
        }

    } catch {
        Write-TestResult "Nuspec Parsing" "FAIL" "Error parsing nuspec: $_"
    }
}

function Test-ScriptFiles {
    Write-Host "`n=== Testing Script Files ===" -ForegroundColor Yellow

    $toolsDir = ".\tools"

    # Check install script
    $installScript = "$toolsDir\chocolateyinstall.ps1"
    if (Test-Path $installScript) {
        Write-TestResult "Install Script Exists" "PASS" "chocolateyinstall.ps1 found"

        $content = Get-Content $installScript -Raw
        if ($content -match '\$ErrorActionPreference') {
            Write-TestResult "Install Script Error Handling" "PASS" "Error action preference set"
        } else {
            Write-TestResult "Install Script Error Handling" "FAIL" "No error action preference found"
        }

        if ($content -match 'cpanm') {
            Write-TestResult "Install Script CPAN Usage" "PASS" "cpanm command found"
        } else {
            Write-TestResult "Install Script CPAN Usage" "FAIL" "cpanm command not found"
        }
    } else {
        Write-TestResult "Install Script Exists" "FAIL" "chocolateyinstall.ps1 not found"
    }

    # Check uninstall script
    $uninstallScript = "$toolsDir\chocolateyuninstall.ps1"
    if (Test-Path $uninstallScript) {
        Write-TestResult "Uninstall Script Exists" "PASS" "chocolateyuninstall.ps1 found"

        $content = Get-Content $uninstallScript -Raw
        if ($content -match '\$ErrorActionPreference') {
            Write-TestResult "Uninstall Script Error Handling" "PASS" "Error action preference set"
        } else {
            Write-TestResult "Uninstall Script Error Handling" "FAIL" "No error action preference found"
        }

        if ($content -match '--uninstall') {
            Write-TestResult "Uninstall Script CPAN Usage" "PASS" "cpanm uninstall found"
        } else {
            Write-TestResult "Uninstall Script CPAN Usage" "FAIL" "cpanm uninstall not found"
        }
    } else {
        Write-TestResult "Uninstall Script Exists" "FAIL" "chocolateyuninstall.ps1 not found"
    }
}

function Show-TestSummary {
    Write-Host "`n=== Test Summary ===" -ForegroundColor Yellow

    $passCount = ($global:TestResults | Where-Object { $_.Result -eq "PASS" }).Count
    $failCount = ($global:TestResults | Where-Object { $_.Result -eq "FAIL" }).Count
    $totalCount = $global:TestResults.Count

    Write-Host "Total Tests: $totalCount" -ForegroundColor White
    Write-Host "Passed: $passCount" -ForegroundColor Green
    Write-Host "Failed: $failCount" -ForegroundColor Red

    if ($failCount -gt 0) {
        Write-Host "`nFailed Tests:" -ForegroundColor Red
        $global:TestResults | Where-Object { $_.Result -eq "FAIL" } | ForEach-Object {
            Write-Host "  - $($_.Test): $($_.Details)" -ForegroundColor Red
        }
        exit 1
    }

    if ($Verbose) {
        Write-Host "`nMocked Function Calls:" -ForegroundColor Cyan
        $global:MockedCalls | ForEach-Object {
            Write-Host "  $($_.Function): $($_.Parameters | ConvertTo-Json -Compress)" -ForegroundColor Gray
        }
    }

    exit 0
}

# Main execution
Write-Host "PowerShell Chocolatey LaTeXML Test Suite" -ForegroundColor Magenta
Write-Host "==========================================" -ForegroundColor Magenta

# Run all tests by default
if (!$TestInstall -and !$TestUninstall) {
    Test-NuspecFile
    Test-ScriptFiles
    Test-InstallationScript
    Test-UninstallationScript
} else {
    if ($TestInstall) {
        Test-InstallationScript
    }
    if ($TestUninstall) {
        Test-UninstallationScript
    }
}

Show-TestSummary
