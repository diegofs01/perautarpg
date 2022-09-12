cls

set "RGBDS_DIR=C:\perautarpg\rgbds"
set "EMU_DIR=C:\perautarpg\bgb"
set "BASE_DIR=C:\perautarpg\src"
set "OBJ_DIR=%BASE_DIR%\obj"

setlocal enabledelayedexpansion

if not exist %OBJ_DIR% (
 	mkdir %OBJ_DIR%
)

for /f %%f in ('dir /s/b %BASE_DIR%\*.asm') do %RGBDS_DIR%\rgbasm.exe -i %BASE_DIR% -o %OBJ_DIR%\%%~nf.o %%f

for /f %%f in ('dir /b %OBJ_DIR%\*.o') do set objectList=!objectList! %OBJ_DIR%\%%f

%RGBDS_DIR%\rgblink.exe -m %OBJ_DIR%\perautarpg.map -n %BASE_DIR%\perautarpg.sym -o %BASE_DIR%\perautarpg.gbc !objectList! 

%RGBDS_DIR%\rgbfix.exe -v -p 0xFF %BASE_DIR%\perautarpg.gbc
%EMU_DIR%\bgb64.exe %BASE_DIR%\perautarpg.gbc

