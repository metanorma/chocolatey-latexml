$Strawberry = "C:\Strawberry"
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"

# We need --notest here because:
# Difference at line 1 for ****
#       got : 'kpsewhich: warning: running with administrator privileges'
#  expected : 'No obvious problems'
& cpanm --notest --verbose LaTeXML@$Env:ChocolateyPackageVersion

Get-Command latexml | Select-Object -ExpandProperty Definition