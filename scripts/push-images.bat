@echo off
setlocal

cd /d C:\repo\image_share

powershell -ExecutionPolicy Bypass -File .\scripts\build-manifest.ps1
if errorlevel 1 (
    echo manifest generation failed.
    exit /b 1
)

git add manifest.json images
git commit -m "Update images and manifest"
if errorlevel 1 (
    echo git commit failed. Maybe no changes.
    exit /b 0
)

git push origin main
if errorlevel 1 (
    echo git push failed.
    exit /b 1
)

echo Done.
exit /b 0