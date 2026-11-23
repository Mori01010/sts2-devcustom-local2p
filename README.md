# DEV_CUSTOM ローカルマルチ起動キット / Local Multiplayer Kit

Slay the Spire 2 用MOD **DEV_CUSTOM** の ONLINE モードを、**1台のPCで2〜4つのゲーム画面を開いて** テストするためのキットです。
1つ目の画面がホスト、残りが参加者になり、1人でマルチプレイの動作を確認できます。

> 本キットとMODは一部AIを使用して作成しています。
> English instructions are below.

## 必要なもの
- Steam版 Slay the Spire 2（インストール済みであればOK。キットが場所を自動で探します）
- 空き容量 約3GB（初回に、このフォルダの中へゲームのコピーを作ります。普段のゲームには手を加えません）

## 1. ダウンロードと解凍
1. 右側の **Releases** から `DevCustom-Local2P-Kit-v*.zip` をダウンロード
2. 好きな場所に解凍（例: デスクトップ）

解凍したフォルダの中身:

| ファイル | 役割 |
|---|---|
| `Start-Local2P.bat` | **メイン。** キットだけで2〜4つのゲームを起動します |
| `Copy-MyMods.bat` | いつものゲームで有効にしているMODを、キットの `mods` フォルダにまとめてコピーします |
| `Join-UsualGame.bat` | いつものゲームをホストにして参加する、別の使い方用です（後述） |
| `mods` フォルダ | キットのゲームに読み込ませるMODを入れる場所です |

## 2. MODを入れる
キットで起動するゲームは、**`mods` フォルダに入っているMODだけ** を読み込みます。**DEV_CUSTOM は必須** です。

**かんたんな方法（おすすめ）**
1. いつものゲームで、DEV_CUSTOM とテストしたいMODを Workshop でサブスクライブし、MOD設定で有効にしておく
2. `Copy-MyMods.bat` をダブルクリック → 有効なMODがすべて `mods` フォルダにコピーされます

**手動で入れる方法**
MODのフォルダ（`.dll` や `.pck` と `.json` が入っているフォルダ）を、そのまま `mods` フォルダに入れてください。
- Workshop のMODは `Steamのフォルダ\steamapps\workshop\content\2868840\<アイテムID>\` の中にあります
- 自作MODのビルド結果もそのまま入れられます
- MODを入れ替えたら、ゲームを起動し直すと反映されます

## 3. 起動して遊ぶ
1. `Start-Local2P.bat` をダブルクリックし、起動するゲームの数（2〜4）を入力
   - 初回はゲームのコピーに数分かかります
2. **最初に開いたゲーム**: DEV_CUSTOM → ONLINE → **ホスト** → スタンダード／ブリッツ／カスタム → キャラ選択
3. **ほかのゲーム**: DEV_CUSTOM → ONLINE → **参加**（このPCのホストに自動でつながります）

- 各ゲームのセーブ・設定は `game-copy` フォルダの中に別々に保存され、普段のセーブには影響しません
- ゲームが更新されたら、次に起動したときにコピーを自動で作り直します
- 不要になったら、フォルダごと削除するだけで元どおりです

---

## 別の使い方: いつものゲームと一緒に使う
普段遊んでいるSTS2（Steamから起動）をホストにして、キットのゲームを参加者として追加することもできます。
この場合、キットのゲームは **いつものゲームで有効にしているMOD** をそのまま読み込みます（`mods` フォルダは使いません）。

1. Steamのライブラリで Slay the Spire 2 を右クリック → **プロパティ** → **起動オプション** に `--fastmp` と入力
   （Steamを通さず、このPC上でホストできるようになります。普段遊ぶときは消してください）
2. いつものゲームを起動し、DEV_CUSTOM → ONLINE → **ホスト** → モード → キャラ選択
3. `Join-UsualGame.bat` をダブルクリックし、追加するゲームの数（1〜3）を入力
4. 追加で開いたゲームで DEV_CUSTOM → ONLINE → **参加**

---

## English

Test DEV_CUSTOM's ONLINE mode with **2–4 game windows on one PC**: the first window hosts, the others join.

> This kit and the mod were made partly with AI.

**You need:** Steam's Slay the Spire 2 (the kit finds it by itself) and about 3 GB of free space (a copy of the game is made inside this folder the first time; your normal game is not changed).

### 1. Download
Download `DevCustom-Local2P-Kit-v*.zip` from **Releases** and unzip it anywhere.

| File | What it does |
|---|---|
| `Start-Local2P.bat` | **Main.** Starts 2–4 game windows from the kit |
| `Copy-MyMods.bat` | Copies the mods your usual game has enabled into the kit's `mods` folder |
| `Join-UsualGame.bat` | Another way to use the kit: join your usual game (see below) |
| `mods` folder | The mods the kit's games load |

### 2. Adding mods
The kit's games load **only the mods in the `mods` folder**. **DEV_CUSTOM is required.**

- **Easy way:** subscribe to DEV_CUSTOM and the mods you want to test, enable them in your usual game's mod settings, then double-click `Copy-MyMods.bat`.
- **By hand:** put each mod's folder (the one with its `.dll`/`.pck` and `.json`) into `mods`. Workshop mods are in `<Steam folder>\steamapps\workshop\content\2868840\<item id>\`. Your own builds work too. Restart the games after changing mods.

### 3. Playing
1. Double-click `Start-Local2P.bat` and enter how many windows to open (2–4). The first time, copying the game takes a few minutes.
2. **First window:** DEV_CUSTOM → ONLINE → **Host** → Standard / Blitz / Custom → character select.
3. **Other windows:** DEV_CUSTOM → ONLINE → **Join**. They connect to the host on this PC by themselves.

Each window keeps its saves and settings inside `game-copy`, apart from your normal saves. The copy is rebuilt automatically after a game update. To remove everything, delete this folder.

### Another way: with your usual game
Your usual STS2 (started from Steam) can host, with the kit's windows joining it. They then load the mods your usual game has enabled (the `mods` folder is not used).

1. In Steam, right-click Slay the Spire 2 → **Properties** → **Launch Options**: enter `--fastmp` (remove it again for normal play).
2. Start your usual game: DEV_CUSTOM → ONLINE → **Host** → mode → character select.
3. Double-click `Join-UsualGame.bat` and enter how many windows to add (1–3).
4. In each added window: DEV_CUSTOM → ONLINE → **Join**.
