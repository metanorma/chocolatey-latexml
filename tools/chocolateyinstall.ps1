$Strawberry = "C:\Strawberry"
$env:Path = "$Strawberry\c\bin;$Strawberry\perl\site\bin;$Strawberry\perl\bin;$Env:Path"

& cpanm git://github.com/brucemiller/LaTeXML.git@9a0e7dc5

Get-Command latexml | Select-Object -ExpandProperty Definition
