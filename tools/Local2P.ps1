param(
    # Kit:   every window (host and joining players) runs from the kit's game copy, with the mods in the kit's mods folder.
    # Usual: your usual Slay the Spire 2 (Steam, launch option --fastmp) hosts; the kit's windows join it,
    #        loading the same mods your usual game has enabled.
    # CopyMods: copy the mods your usual game has enabled into the kit's mods folder, then stop.
    [ValidateSet('Kit', 'Usual', 'CopyMods')][string]$Mode = 'Kit',
    [string]$GameDir = '',
    [int]$Count = 0,
    [string]$Resolution = '1280x720'
)

$ErrorActionPreference = 'Stop'
$kit = Split-Path -Parent $PSScriptRoot
$kitMods = (New-Item -ItemType Directory -Force (Join-Path $kit 'mods')).FullName
$ja = (Get-Culture).Name -like 'ja*'
function Say([string]$Japanese, [string]$English) { Write-Host ($(if ($ja) { $Japanese } else { $English })) }
function Fail([string]$Japanese, [string]$English) { Say $Japanese $English; exit 1 }

# ---- Steam, the game and its Workshop folder (any Steam library) ----
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

# ---- Your usual game's settings: language and enabled mods ----
$settingsFile = Get-ChildItem (Join-Path $env:APPDATA 'SlayTheSpire2\steam') -Recurse -Filter 'settings.save' -ErrorAction SilentlyContinue |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
$enabled = $null
$language = $(if ($ja) { 'jpn' } else { 'eng' })
if ($settingsFile) {
    $settings = Get-Content -Raw $settingsFile.FullName | ConvertFrom-Json
    if ($settings.language) { $language = $settings.language }
    $enabled = @($settings.mod_settings.mod_list | Where-Object { $_.is_enabled } | ForEach-Object { $_.id })
}

# A mod is a folder with a manifest (.json with an "id") next to its .dll or .pck.
function Find-Mods([string[]]$Roots, [bool]$OnlyEnabled) {
    $found = @()
    foreach ($dir in $Roots) {
        if (!(Test-Path $dir)) { continue }
        foreach ($json in Get-ChildItem $dir -Recurse -Filter '*.json' -ErrorAction SilentlyContinue) {
            if ($json.Name -match 'config|settings|log') { continue }
            if ($json.Directory.GetFiles('*.dll').Count -eq 0 -and $json.Directory.GetFiles('*.pck').Count -eq 0) { continue }
            $id = try { (Get-Content -Raw $json.FullName | ConvertFrom-Json).id } catch { $null }
            if (!$id) { continue }
            if ($OnlyEnabled -and $enabled -ne $null -and $id -notin $enabled) { continue }
            if ($found.Id -contains $id) { continue }
            $found += [pscustomobject]@{ Id = $id; Dir = $json.Directory }
        }
    }
    return $found
}
$usualMods = { Find-Mods @($workshop, (Join-Path $GameDir 'mods')) $true }

if ($Mode -eq 'CopyMods') {
    $mods = & $usualMods
    foreach ($m in $mods) {
        $target = Join-Path $kitMods $m.Dir.Name
        if (Test-Path $target) { Remove-Item $target -Recurse -Force }
        Copy-Item $m.Dir.FullName $target -Recurse -Force
    }
    Say ("キットの mods フォルダにコピーしました: " + ($mods.Id -join ', ')) ("Copied into the kit's mods folder: " + ($mods.Id -join ', '))
    exit 0
}

$mods = if ($Mode -eq 'Kit') { Find-Mods @($kitMods) $false } else { & $usualMods }
if (!($mods | Where-Object Id -eq 'devcustom')) {
    if ($Mode -eq 'Kit') {
        Fail 'キットの mods フォルダに DEV_CUSTOM がありません。README の「MODを入れる」を見てください。' `
            'DEV_CUSTOM is not in the kit''s mods folder. See "Adding mods" in the README.'
    }
    Fail 'DEV_CUSTOM が見つからないか無効です。Workshopでサブスクライブして、ゲームのMOD設定で有効にしてください。' `
        'DEV_CUSTOM was not found or is disabled. Subscribe on the Workshop and enable it in the game''s mod settings.'
}

# ---- How many windows ----
$min = $(if ($Mode -eq 'Kit') { 2 } else { 1 })
$max = $(if ($Mode -eq 'Kit') { 4 } else { 3 })
while ($Count -lt $min -or $Count -gt $max) {
    $prompt = if ($Mode -eq 'Kit') {
        $(if ($ja) { "起動するゲームの数（プレイヤー人数）[2-4]" } else { "How many game windows (players) [2-4]" })
    } else {
        $(if ($ja) { "追加で起動するゲームの数（参加プレイヤー人数）[1-3]" } else { "How many extra game windows (joining players) [1-3]" })
    }
    $answer = Read-Host $prompt
    if (-not [int]::TryParse($answer, [ref]$Count)) { $Count = 0 }
}

# ---- The game copy (made once, about 3 GB; remade after a game update) ----
$game = (New-Item -ItemType Directory -Force (Join-Path $kit 'game-copy')).FullName
$live = Get-Content -Raw -LiteralPath (Join-Path $GameDir 'release_info.json')
$copyInfo = Join-Path $game 'release_info.json'
if ((Test-Path $copyInfo) -and ((Get-Content -Raw $copyInfo) -ne $live)) {
    Say 'ゲームが更新されたので、コピーを作り直します…' 'The game was updated: refreshing the copy...'
    Remove-Item (Join-Path $game 'data_sts2_windows_x86_64') -Recurse -Force
}
if (!(Test-Path (Join-Path $game 'data_sts2_windows_x86_64\sts2.dll'))) {
    Say 'ゲームをコピーしています（初回のみ・約3GB・数分かかります）…' 'Copying the game (first time only, about 3 GB, a few minutes)...'
    Get-ChildItem -LiteralPath $GameDir -File | Copy-Item -Destination $game -Force
    Copy-Item -LiteralPath (Join-Path $GameDir 'data_sts2_windows_x86_64') -Destination $game -Recurse -Force
}
$copyMods = New-Item -ItemType Directory -Force (Join-Path $game 'mods')
foreach ($old in Get-ChildItem $copyMods.FullName -Directory) { Remove-Item $old.FullName -Recurse -Force }
foreach ($m in $mods) {
    $target = Join-Path $copyMods.FullName $m.Dir.Name
    if (!(Test-Path $target)) { Copy-Item $m.Dir.FullName $target -Recurse -Force }
}
Say ('MOD: ' + ($mods.Id -join ', ')) ('Mods: ' + ($mods.Id -join ', '))

# ---- Start the windows, each with its own settings and saves inside the copy ----
function Write-Utf8([string]$Path, [string]$Text) { [IO.File]::WriteAllText($Path, $Text, [Text.UTF8Encoding]::new($false)) }
Write-Utf8 (Join-Path $game 'override.cfg') "[application]`nconfig/use_custom_user_dir=true`nconfig/custom_user_dir_name=`"DevCustomLocal2P`"`n`n[sentry]`nconfig/dsn=`"`"`n"
# Kit mode: window 1 hosts (player id 1), the rest join as 1001, 1002, 1003. Usual mode: every window joins.
$players = @()
if ($Mode -eq 'Kit') {
    $players += [pscustomobject]@{ Name = 'player1'; Id = 1; Host = $true }
    for ($i = 1; $i -lt $Count; $i++) { $players += [pscustomobject]@{ Name = "player$($i + 1)"; Id = 1000 + $i; Host = $false } }
} else {
    for ($i = 1; $i -le $Count; $i++) { $players += [pscustomobject]@{ Name = "player$($i + 1)"; Id = 1000 + $i; Host = $false } }
}
$appData = $env:APPDATA
try {
    foreach ($p in $players) {
        $env:APPDATA = (New-Item -ItemType Directory -Force (Join-Path $game $p.Name)).FullName
        foreach ($profile in @('1', "$($p.Id)") | Select-Object -Unique) {
            $dir = New-Item -ItemType Directory -Force (Join-Path $env:APPDATA "DevCustomLocal2P\default\$profile")
            $file = Join-Path $dir.FullName 'settings.save'
            if (!(Test-Path $file)) {
                Write-Utf8 $file ('{"schema_version":8,"language":"' + $language + '","skip_intro_logo":true,"seen_ea_disclaimer":true,"fullscreen":false,"mod_settings":{"mods_enabled":true}}')
            }
        }
        $gameArgs = @('--force-steam=off', '--fastmp', '--resolution', $Resolution)
        if (!$p.Host) { $gameArgs += "--clientId=$($p.Id)" }
        Start-Process -FilePath (Join-Path $game 'SlayTheSpire2.exe') -WorkingDirectory $game -ArgumentList $gameArgs | Out-Null
        if ($p.Host) { Say 'ホスト役のゲームを起動しました。' 'Started the host window.' }
        else { Say "参加者のゲーム（$($p.Name)）を起動しました。" "Started a joining window ($($p.Name))." }
        Start-Sleep -Seconds 3
    }
}
finally { $env:APPDATA = $appData }
Write-Host ''
if ($Mode -eq 'Kit') {
    Say '最初に開いたゲーム: DEV_CUSTOM → ONLINE → ホスト → モード → キャラ選択' 'First window: DEV_CUSTOM -> ONLINE -> Host -> mode -> character'
} else {
    Say 'いつものSTS2: DEV_CUSTOM → ONLINE → ホスト → モード → キャラ選択' 'Usual STS2: DEV_CUSTOM -> ONLINE -> Host -> mode -> character'
}
Say 'ほかのゲーム: DEV_CUSTOM → ONLINE → 参加（このPCのホストに自動でつながります）' 'Other windows: DEV_CUSTOM -> ONLINE -> Join (connects to this PC''s host by itself)'
