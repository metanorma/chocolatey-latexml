$SuccessExitCode = $Args[0]
$FailedExitCode = $Args[1]
$ResultExitCode = $SuccessExitCode

if ((Test-Path .\basic-test.xml) -and (Test-Path .\color-test.xml) -and (Test-Path .\ntheorem-test.xml)) { 
  $found = Select-String -Path ".\*-test.xml" -Pattern "ERROR"
  if ($found) { 
    $ResultExitCode=$FailedExitCode 
  }
} else {
  $ResultExitCode=$FailedExitCode 
}

exit $ResultExitCode