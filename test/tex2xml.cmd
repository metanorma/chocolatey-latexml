set StrawberryBin=C:\Strawberry\perl\site\bin
set PATH=%StrawberryBin%;C:\Strawberry\c\bin;C:\Strawberry\perl\bin;%PATH%

call %StrawberryBin%\latexml --dest=%APPVEYOR_BUILD_FOLDER%\basic-test.xml %APPVEYOR_BUILD_FOLDER%\test\basic.tex
call %StrawberryBin%\latexml --dest=%APPVEYOR_BUILD_FOLDER%\color-test.xml %APPVEYOR_BUILD_FOLDER%\test\color.tex
call %StrawberryBin%\latexml --dest=%APPVEYOR_BUILD_FOLDER%\ntheorem-test.xml %APPVEYOR_BUILD_FOLDER%\test\ntheorem.tex
