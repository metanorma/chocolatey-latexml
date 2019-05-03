$Strawberry = "C:\Strawberry"
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"

& cpanm LaTeXML@$Env:ChocolateyPackageVersion

Get-Command latexml | Select-Object -ExpandProperty Definition
