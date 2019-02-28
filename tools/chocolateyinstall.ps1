$Strawberry = "C:\Strawberry"

# We need to install 'miktex' manually to make sure that it's installed for 'Strawberry Perl'
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"
if (!(Test-Path -Path "$Env:ChocolateyInstall\lib\miktex")) {
   & cinst -y miktex
}

& cpanm --v LaTeXML

Get-Command latexml | Select-Object -ExpandProperty Definition