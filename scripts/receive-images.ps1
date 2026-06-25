param(
    [string]$BaseUrl = "https://fumin1990jk-creator.github.io/image_share",
    [string]$SaveDir = "$env:USERPROFILE\Downloads\incoming",
    [string]$StateFile = "$env:USERPROFILE\Downloads\received_hashes.txt"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path $SaveDir | Out-Null
if (!(Test-Path $StateFile)) {
    New-Item -ItemType File -Force -Path $StateFile | Out-Null
}

$received = @()
if (Test-Path $StateFile) {
    $received = Get-Content $StateFile | Where-Object { $_ -and $_.Trim() -ne "" }
}

$manifestUrl = "$BaseUrl/manifest.json?v=$(Get-Date -Format 'yyyyMMddHHmmss')"
$manifest = Invoke-RestMethod -Uri $manifestUrl -Method Get

foreach ($file in $manifest.files) {
    if ($received -contains $file.sha256) {
        continue
    }

    $fileUrl = "$BaseUrl/$($file.path)"
    $outFile = Join-Path $SaveDir $file.name

    Invoke-WebRequest -Uri $fileUrl -OutFile $outFile -UseBasicParsing

    $downloadedHash = (Get-FileHash -Path $outFile -Algorithm SHA256).Hash.ToLower()
    if ($downloadedHash -ne $file.sha256) {
        Remove-Item $outFile -Force
        throw "Hash mismatch: $($file.name)"
    }

    Add-Content -Path $StateFile -Value $file.sha256
    Write-Host "Downloaded: $($file.name)"
}