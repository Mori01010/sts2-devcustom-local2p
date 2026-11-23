# DEV_CUSTOM ローカルマルチ起動キット / Local Multiplayer Kit

Slay the Spire 2 用MOD **DEV_CUSTOM** の ONLINE モードを、**1台のPCで2〜4人分のウィンドウを開いて** テストするためのキットです。
いつものゲーム（Steamから起動）がホストになり、このキットで起動した追加のゲームが参加者になります。

> 本キットとMODは一部AIを使用して作成しています。

## 必要なもの
- Steam版 Slay the Spire 2
- Workshop の **DEV_CUSTOM** をサブスクライブし、ゲームのMOD設定で有効にしておく
- 空き容量 約3GB（初回にゲームのコピーをこのフォルダ内に作ります）

## 使い方
1. ZIPを好きな場所に解凍する（パスに日本語が入っていても大丈夫です）
2. Steamのライブラリで Slay the Spire 2 を右クリック → **プロパティ** → **起動オプション** に `--fastmp` と入力
   （ホストがSteamを通さず、このPC上で部屋を作れるようになります。普段遊ぶときは消してください）
3. いつものゲームを起動し、**DEV_CUSTOM → ONLINE → ホスト → モード → キャラ選択** まで進める
4. 解凍したフォルダの **`Start-Local2P.bat`** をダブルクリックし、追加するゲームの数（1〜3）を入力
   - 初回はゲームのコピーに数分かかります
5. 追加で開いたゲームで **DEV_CUSTOM → ONLINE → 参加** を押す（このPCのホストに自動でつながります）

- 追加のゲームは、いつものゲームで有効にしているMODを同じように読み込みます
- 追加のゲームのセーブ・設定はこのフォルダの `game-copy` の中に保存され、普段のセーブには影響しません
- ゲームが更新されたら、次に起動したときにコピーを自動で作り直します
- 不要になったら、フォルダごと削除するだけで元に戻ります（起動オプションの `--fastmp` も消してください）

---

## English
Test DEV_CUSTOM's ONLINE mode with **2–4 game windows on one PC**. Your usual game (started from Steam) hosts, and the games this kit starts join it.

> This kit and the mod were made partly with AI.

**You need:** Steam's Slay the Spire 2, **DEV_CUSTOM** subscribed on the Workshop and enabled in the game's mod settings, and about 3 GB of free space (a copy of the game is made inside this folder the first time).

1. Unzip anywhere.
2. In Steam, right-click Slay the Spire 2 → **Properties** → **Launch Options**: enter `--fastmp` (remove it again for normal play).
3. Start your usual game and go to **DEV_CUSTOM → ONLINE → Host → mode → character select**.
4. Double-click **`Start-Local2P.bat`** and enter how many extra windows to open (1–3). The first time, copying the game takes a few minutes.
5. In each extra window, press **DEV_CUSTOM → ONLINE → Join**. It connects to the host on this PC by itself.

The extra windows load the same mods your usual game has enabled. Their saves and settings stay inside `game-copy` in this folder and never touch your normal saves. To remove everything, delete this folder (and the `--fastmp` launch option).
