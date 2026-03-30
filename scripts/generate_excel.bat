@echo off
setlocal

set SCRIPT_DIR=%~dp0
pushd "%SCRIPT_DIR%.." >nul

call dart run tool\generate_excel.dart
if errorlevel 1 (
  echo Fallo al generar el Excel.
  popd >nul
  exit /b 1
)

echo Excel generado correctamente en assets/data/virtual_football_data.xlsx
popd >nul
endlocal
