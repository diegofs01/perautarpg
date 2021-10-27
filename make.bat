cls

setlocal enabledelayedexpansion

if not exist "obj" (
 	mkdir obj
)

for /f %%f in ('dir /s/b *.asm') do ..\rgbds\rgbasm.exe -L -o .\obj\%%~nf.o %%f

for /f %%f in ('dir /b obj\*.o') do set objectList=!objectList! %%f

cd obj

..\..\rgbds\rgblink.exe -o ..\perautarpg.gbc -n ..\perautarpg.sym -m perautarpg.map !objectList!

cd ..

..\rgbds\rgbfix.exe -v -p 0xFF perautarpg.gbc
..\bgb\bgb64.exe perautarpg.gbc

