param(
    [string]$Root = "C:\repo\image_share",
    [string]$ImageDirName = "images",
    [string]$OutputFileName = "manifest.json"
)

$ErrorActionPreference = "Stop"

$rootPath = Resolve-Path $Root
$imageDir = Join-Path $rootPath $ImageDirName
$outputFile = Join-Path $rootPath $OutputFileName

if (!(Test-Path $imageDir)) {
    throw "Image directory not found: $imageDir"
}

$allowedExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".webp", ".bmp")

$files = @()

$items = Get-ChildItem -Path $imageDir -File | Where-Object {
    $allowedExtensions -contains $_.Extension.ToLower()
} | Sort-Object Name

foreach ($item in $items) {
    $hash = Get-FileHash -Path $item.FullName -Algorithm SHA256

    $files += [PSCustomObject]@{
        name   = $item.Name
        path   = "$ImageDirName/$($item.Name)"
        size   = $item.Length
        sha256 = $hash.Hash.ToLower()
    }
}

$manifest = [PSCustomObject]@{
    version     = 1
    generatedAt = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    files       = $files
}

$json = $manifest | ConvertTo-Json -Depth 10

[System.IO.File]::WriteAllText($outputFile, $json, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "Manifest written to $outputFile"
Write-Host ("File count: {0}" -f $files.Count)