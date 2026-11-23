param(
    [string]$GameDir = '',
    [int]$Count = 0,
    [string]$Resolution = '1280x720'
)

# DEV_CUSTOM local multiplayer kit: your usual Slay the Spire 2 (started from Steam with the launch option --fastmp)
# hosts, and 1-3 extra game windows started here join it as the other players. The extra windows run from a copy
# of the game inside this folder, with their own saves, and load the same mods your usual game has enabled.
$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$ja = (Get-Culture).Name -like 'ja*'
function Say([string]$Japanese, [string]$English) { Write-Host ($(if ($ja) { $Japanese } else { $English })) }
function Fail([string]$Japanese, [string]$English) { Say $Japanese $English; exit 1 }

# 1. Find Steam and the game (any Steam library folder).
$steam = (Get-ItemProperty 'HKCU:\Software\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
if (!$steam) { Fail 'Steamが見つかりません。' 'Steam was not found.' }
$steam = $steam -replace '/', '\'
$libraries = @($steam)
$vdf = Join-Path $steam 'steamapps\libraryfolders.vdf'
if (Test-Path $vdf) {
    foreach ($m in [regex]::Matches((Get-Content -Raw $vdf), '"path"\s+"([^"]+)"')) { $libraries += $m.Groups[1].Value -replace '\\\\', '\' }
}
$library = $null
if (!$GameDir) {
    foreach ($lib in $libraries | Select-Object -Unique) {
        $candidate = Join-Path $lib 'steamapps\common\Slay the Spire 2'
        if (Test-Path (Join-Path $candidate 'SlayTheSpire2.exe')) { $GameDir = $candidate; $library = $lib; break }
    }
}
if (!$GameDir -or !(Test-Path (Join-Path $GameDir 'SlayTheSpire2.exe'))) {
    Fail 'Slay the Spire 2 が見つかりません。Steamでインストールしてください。' 'Slay the Spire 2 was not found. Install it with Steam.'
}
if (!$library) { $library = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $GameDir)) }
$workshop = Join-Path $library 'steamapps\workshop\content\2868840'
Say "ゲーム: $GameDir" "Game: $GameDir"

# 2. The mods your usual game has enabled (Workshop subscriptions and the game's mods folder).
$settingsFile = Get-ChildItem (Join-Path $env:APPDATA 'SlayTheSpire2\steam') -Recurse -Filter 'settings.save' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
$enabled = $null
$language = 'eng'
if ($settingsFile) {
    $settings = Get-Content -Raw $settingsFile.FullName | ConvertFrom-Json
    if ($settings.language) { $language = $settings.language }
    $enabled = @($settings.mod_settings.mod_list | Where-Object { $_.is_enabled } | ForEach-Object { $_.id })
}
$manifests = @()
foreach ($dir in @($workshop, (Join-Path $GameDir 'mods'))) {
    if (!(Test-Path $dir)) { continue }
    foreach ($json in Get-ChildItem $dir -Recurse -Filter '*.json' -ErrorAction SilentlyContinue) {
        if ($json.Name -match 'config|settings|log') { continue }
        $id = try { (Get-Content -Raw $json.FullName | ConvertFrom-Json).id } catch { $null }
        if (!$id -or ($json.Directory.GetFiles('*.dll').Count -eq 0 -and $json.Directory.GetFiles('*.pck').Count -eq 0)) { continue }
        if ($enabled -ne $null -and $id -notin $enabled) { continue }
        $manifests += [pscustomobject]@{ Id = $id; Dir = $json.Directory }
    }
}
if (!($manifests | Where-Object Id -eq 'devcustom')) {
    Fail 'DEV_CUSTOM が見つからないか無効です。Workshopでサブスクライブして、ゲームのMOD設定で有効にしてください。' `
        'DEV_CUSTOM was not found or is disabled. Subscribe on the Workshop and enable it in the game''s mod settings.'
}

# 3. How many extra windows.
Say 'いつものSTS2（Steamの起動オプションに --fastmp）がホストになり、ここで起動するゲームが参加者になります。' `
    'Your usual STS2 (Steam launch option --fastmp) is the host; the games started here join it.'
while ($Count -lt 1 -or $Count -gt 3) {
    $answer = Read-Host $(if ($ja) { '追加で起動するゲームの数（参加プレイヤー人数）[1-3]' } else { 'How many extra game windows (joining players) [1-3]' })
    if (-not [int]::TryParse($answer, [ref]$Count)) { $Count = 0 }
}

# 4. The game copy (made once, about 3 GB; remade after a game update).
$game = (New-Item -ItemType Directory -Force (Join-Path $kit 'game-copy')).FullName
$live = Get-Content -Raw -LiteralPath (Join-Path $GameDir 'release_info.json')
$copyInfo = Join-Path $game 'release_info.json'
if ((Test-Path $copyInfo) -and ((Get-Content -Raw $copyInfo) -ne $live)) {
    Say 'ゲームが更新されたので、コピーを作り直します…' 'The game was updated: refreshing the copy...'
    Remove-Item (Join-Path $game 'data_sts2_windows_x86_64') -Recurse -Force
}
if (!(Test-Path (Join-Path $game 'data_sts2_windows_x86_64\sts2.dll'))) {
    Say 'ゲームをコピーしています（初回のみ・約3GB）…' 'Copying the game (first time only, about 3 GB)...'
    Get-ChildItem -LiteralPath $GameDir -File | Copy-Item -Destination $game -Force
    Copy-Item -LiteralPath (Join-Path $GameDir 'data_sts2_windows_x86_64') -Destination $game -Recurse -Force
}
$mods = New-Item -ItemType Directory -Force (Join-Path $game 'mods')
foreach ($old in Get-ChildItem $mods.FullName -Directory) { Remove-Item $old.FullName -Recurse -Force }
foreach ($m in $manifests) {
    $target = Join-Path $mods.FullName $m.Dir.Name
    if (!(Test-Path $target)) { Copy-Item $m.Dir.FullName $target -Recurse -Force }
}
Say ('MOD: ' + (($manifests.Id | Select-Object -Unique) -join ', ')) ('Mods: ' + (($manifests.Id | Select-Object -Unique) -join ', '))

# 5. Start the joining players, each with its own settings and saves inside the copy.
function Write-Utf8([string]$Path, [string]$Text) { [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false)) }
Write-Utf8 (Join-Path $game 'override.cfg') "[application]`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"DevCustomLocal2P`"`n`n[sentry]`nconfig/dsn=`"`"`n"
$appData = $env:APPDATA
try {
    for ($i = 1; $i -le $Count; $i++) {
        $clientId = 1000 + $i
        $env:APPDATA = (New-Item -ItemType Directory -Force (Join-Path $game "player$($i + 1)")).FullName
        foreach ($profile in @('1', "$clientId")) {
            $dir = New-Item -ItemType Directory -Force (Join-Path $env:APPDATA "DevCustomLocal2P\default\$profile")
            $file = Join-Path $dir.FullName 'settings.save'
            if (!(Test-Path $file)) {
                Write-Utf8 $file ('{"schema_version":8,"language":"' + $language + '","skip_intro_logo":true,"seen_ea_disclaimer":true,"fullscreen":false,"mod_settings":{"mods_enabled":true}}')
            }
        }
        Start-Process -FilePath (Join-Path $game 'SlayTheSpire2.exe') -WorkingDirectory $game `
            -ArgumentList @('--force-steam=off', '--fastmp', '--resolution', $Resolution, "--clientId=$clientId") | Out-Null
        Say "プレイヤー$($i + 1) のゲームを起動しました。" "Started the window for player $($i + 1)."
        Start-Sleep -Seconds 3
    }
}
finally { $env:APPDATA = $appData }
Write-Host ''
Say 'いつものSTS2: DEV_CUSTOM → ONLINE → ホスト → モード → キャラ選択' 'Usual STS2: DEV_CUSTOM -> ONLINE -> Host -> mode -> character'
Say '追加のゲーム: DEV_CUSTOM → ONLINE → 参加（このPCのホストに自動でつながります）' 'Extra windows: DEV_CUSTOM -> ONLINE -> Join (connects to this PC''s host by itself)'
