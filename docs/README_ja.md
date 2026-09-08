# 🇯🇵 NotesMy — macOS向けAIセカンドブレイン＆画面端スティッキーノート

<p align="center">
  <img src="../assets/app_icon_1024.png" alt="NotesMy App Icon" width="128" height="128" style="border-radius: 28px; box-shadow: 0 8px 24px rgba(0,0,0,0.25);" />
</p>

<h2 align="center">画面端から滑らかに展開する付箋ノート ＆ パーソナルナレッジマネジメント</h2>

<p align="center">
  <a href="../README.md">🇬🇧 English</a> · 
  <a href="README_tr.md">🇹🇷 Türkçe</a> · 
  <a href="README_de.md">🇩🇪 Deutsch</a> · 
  <a href="README_fr.md">🇫🇷 Français</a> · 
  <a href="README_es.md">🇪🇸 Español</a> · 
  <a href="README_pt.md">🇧🇷 Português</a> · 
  <a href="README_it.md">🇮🇹 Italiano</a> · 
  <a href="README_ru.md">🇷🇺 Русский</a> · 
  <strong>[🇯🇵 日本語](README_ja.md)</strong> · 
  <a href="README_ko.md">🇰🇷 한국어</a> · 
  <a href="README_ar.md">🇸🇦 العربية</a> · 
  <a href="README_zh.md">🇨🇳 中文</a>
</p>

<p align="center">
  <a href="https://github.com/mehmetefeaytas/notesmy/releases"><img src="https://img.shields.io/github/v/release/mehmetefeaytas/notesmy?style=for-the-badge&color=8B5CF6" alt="Release" /></a>
  <a href="https://github.com/mehmetefeaytas/homebrew-tap"><img src="https://img.shields.io/badge/Homebrew-Cask%E5%AF%BE%E5%BF%9C-orange?style=for-the-badge&logo=homebrew" alt="Homebrew" /></a>
  <img src="https://img.shields.io/badge/macOS-13.0%2B-blue?style=for-the-badge&logo=apple" alt="macOS 13+" />
  <img src="https://img.shields.io/badge/Swift-6.0-F05138?style=for-the-badge&logo=swift" alt="Swift 6" />
  <img src="https://img.shields.io/badge/アーキテクチャ-Universal%20(ARM64%20%2B%20x86__64)-green?style=for-the-badge" alt="Universal Binary" />
  <img src="https://img.shields.io/badge/プライバシー-100%25%20完全オンデバイス-success?style=for-the-badge" alt="プライバシー" />
  <img src="https://img.shields.io/badge/ライセンス-Apache%202.0-yellow?style=for-the-badge" alt="Apache 2.0" />
</p>

---

## 🎬 実演デモ動画

<p align="center">
  <img src="../assets/demo.gif" alt="NotesMy デモ動画" width="100%" style="border-radius: 12px; box-shadow: 0 12px 36px rgba(0,0,0,0.25);" />
</p>
<p align="center">
  <em>高解像度画面キャプチャ：画面端からの滑らかなスライド表示、クイックノート作成、自由自在な付箋ボード、そして即座のOCRテキスト抽出。（<a href="../assets/demo.mp4">60fps MP4をダウンロード</a>）</em>
</p>

---

## ⚡ NotesMyとは？

**NotesMy** は、画面端から瞬時に呼び出せる付箋メモの手軽さ（*Unclutter* や *SideNotes* のような利便性）と、相互リンクで広がる知識ベース（*Obsidian* や *Apple Notes* のような深み）を融合させた、macOS専用の超高速オープンソースアプリです。

**Swift 6、SwiftUI、AppKit** を用いて100%ネイティブに開発されており、メニューバーに静かに常駐し、カーソルを画面端に合わせるかショートカットを押すだけで滑らかにスライド展開します。

### ✨ 主な特徴

- 🪟 **エッジドック（Edge Deck）：** 画面端にマウスを合わせると、扇形に広がるアニメーションで作成したノートが一覧表示されます。
- 🔄 **アプリ内自動アップデート機能：** 設定画面から直接GitHub Releasesの更新を確認、変更履歴（Changelog）の閲覧、DMGダウンロード進捗バー、1クリックでの自動適用に対応。
- ⌨️ **矢印キーでのカテゴリ移動：** 左右の矢印キー（`←` / `→`）または左右のボタンで、タグやカテゴリを滑らかに横スクロール・切り替え可能。
- 🗑️ **クイック削除＆休眠ノートの自動整理：** ノートカード上のボタンから1クリックで素早く削除。30日以上更新のない古いノートを自動検出して一括アーカイブ。
- ⚙️ **安心のウィンドウ制御：** 設定画面の赤い閉じるボタンを押してもアプリ全体が終了することはありません。全データ消去時には2段階の安全確認ダイアログを表示。
- 🧠 **物理演算＆AIナレッジグラフ：** クーロン・フック力学シミュレーション、Jaccard概念類似度、双方向リンク `[[WikiLinks]]` を備え、選択したノートとの結合を鮮やかな発光実線で視覚化。
- 🔍 **画面OCR＆画像AI文字認識：** 画面の任意の領域をドラッグ選択するだけで、Apple Visionを用いて画像を瞬時にテキストへ変換。
- 🎙️ **オンデバイス音声入力：** Apple SiliconのNPUを活用し、12言語の音声をリアルタイムで文字起こし。データ通信なしでプライバシーを保護。
- 📌 **自由配置ボード（Sticky Board）：** 無限に広がるコルクボード上で、ノートカードをドラッグ＆ドロップして自由に配置・拡大縮小。
- 🎨 **ミニマルなパステルカラー：** macOSのデザインに調和する6色の優しいパステルカラー、リッチなMarkdown、チェックリスト、コード表示に対応。
- 🛡️ **テレメトリなし＆100%オフライン：** 外部サーバーへの通信やユーザー追跡は一切行いません。すべてのAIモデルはMac本体で完結します。

---

## 🍺 Homebrewでのインストール

macOSで最も推奨されるインストールおよびアップデート手順：

```bash
# 1. カスタムTapリポジトリを追加
brew tap mehmetefeaytas/tap

# 2. NotesMyをインストール
brew install --cask notesmy
```

### アップデート
```bash
brew upgrade --cask notesmy
```

### 手動インストール（DMG）
Universal DMGファイルを直接ダウンロードしたい場合は、[GitHub Releases](https://github.com/mehmetefeaytas/notesmy/releases/latest) から最新バージョンを入手できます。

> **Gatekeeperの警告について（初回起動時）：** NotesMyはオープンソースとして無償配布されているため、初回起動時に開発元確認のメッセージが表示される場合があります。`/Applications` 内の `NotesMy.app` を右クリックして「**開く**」を選択するか、ターミナルで以下を実行してください：
> ```bash
> xattr -cr /Applications/NotesMy.app
> ```

---

## 📸 実際の画面プレビュー

<table width="100%">
  <tr>
    <td width="50%">
      <h3 align="center">🗂️ 全ノート一覧＆セマンティック検索</h3>
      <img src="../assets/preview-allnotes.png" alt="NotesMy 全ノート一覧" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🪟 画面端スライド式エッジドック</h3>
      <img src="../assets/preview-edge-deck.png" alt="NotesMy Edge Deck" width="100%" />
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3 align="center">📝 ミニマルなノートエディタ</h3>
      <img src="../assets/preview-note.png" alt="NotesMy エディタ" width="100%" />
    </td>
    <td width="50%">
      <h3 align="center">🎨 パステル調アプリアイコン</h3>
      <img src="../assets/app_icon_1024.png" alt="NotesMy アイコン" width="60%" style="display: block; margin: 0 auto;" />
    </td>
  </tr>
</table>

---

## 💎 機能一覧マトリックス

| 段階 | 機能名 | 提供状態 | 実装技術 |
| :--- | :--- | :---: | :--- |
| **V1 — 基本機能** | パステル調テキスト＆チェックリストノート | ✅ | ネイティブSwiftUI TextEditor |
| **V1 — 基本機能** | 画面端に吸着する展開式カードドック | ✅ | AppKit フローティングNSPanel |
| **V1 — 基本機能** | タグ、カテゴリ、ピン留め、お気に入り | ✅ | ローカルJSONストレージ |
| **V1 — 基本機能** | 矢印キー（`←` / `→`）によるカテゴリ横移動 | ✅ | AppKit Event Monitor + ScrollViewReader |
| **V1 — 基本機能** | カード上からのクイックワンクリック削除 | ✅ | Swift Action Handler |
| **V1 — 基本機能** | クリップボード履歴自動キャプチャ | ✅ | NSPasteboard Monitor |
| **V1 — 基本機能** | カラーピッカー＆サイズ変更可能ウィンドウ | ✅ | AppKit NSWindow + SwiftUI |
| **V2 — 高度な機能** | 12言語対応の音声入力（文字起こし） | ✅ | Apple SFSpeechRecognizer |
| **V2 — 高度な機能** | 画面切り取りOCRによる瞬時テキスト抽出 | ✅ | Apple Vision + screencapture |
| **V2 — 高度な機能** | 自由配置が可能な付箋ボード（コルクボード） | ✅ | ドラッグ＆ドロップ対応SwiftUI Canvas |
| **V2 — 高度な機能** | 30日以上経過した休眠ノートの自動整理 | ✅ | タイムスタンプ判定エンジン |
| **V2 — 高度な機能** | 自然言語による日付・リマインダー自動認識 | ✅ | NSDataDetector + UserNotifications |
| **V2 — 高度な機能** | ベクトル埋め込みによるセマンティック検索 | ✅ | Apple NaturalLanguage Embeddings |
| **V3 — 連携機能** | アプリ内アップデート確認＆GitHub自動連携 | ✅ | GitHub REST API + URLSession |
| **V3 — 連携機能** | Webクリッパー（URLの要約・抽出） | ✅ | WebKit + URLSession |
| **V3 — 連携機能** | ワンクリックでのカレンダー（.ics）書き出し | ✅ | RFC 5545 カレンダージェネレータ |
| **V3 — 連携機能** | Apple純正メモ＆リマインダーへの転送 | ✅ | NSSharingService + EventKit |
| **V3 — 連携機能** | プライベートCloudKit同期＆ローカルバックアップ | ✅ | Apple CloudKit Container |
| **V3 — 連携機能** | ノートのバージョン履歴＆タイムトラベル復元 | ✅ | 差分スナップショット管理 |
| **V4 — セカンドブレイン** | クーロン・フック物理演算AIナレッジグラフ | ✅ | 物理シミュレーション + Canvas |
| **V4 — セカンドブレイン** | 選択時の鮮やかな発光実線ネットワーク | ✅ | SwiftUI ベクターグラフィック描画 |
| **V4 — セカンドブレイン** | 双方向リンク `[[WikiLinks]]` と逆引き検索 | ✅ | 正規表現リンクパーサー |
| **V4 — セカンドブレイン** | ノート全体を対象としたオンデバイスAI対話 | ✅ | 端末内ローカルRAGアーキテクチャ |
| **V4 — セカンドブレイン** | 本日の行動計画とタスク自動抽出 | ✅ | 自然言語タスク抽出エンジン |
| **V4 — セカンドブレイン** | 散らかった思考の整理＆自動フォーマット | ✅ | Apple Intelligence NLPエンジン |

---

## 🌍 対応言語一覧（全12言語）

NotesMyはmacOSの言語設定を自動認識し、以下の言語でUI翻訳および音声認識を提供します：

| 国旗 | 言語 | 国旗 | 言語 | 国旗 | 言語 |
| :---: | :--- | :---: | :--- | :---: | :--- |
| 🇬🇧 | English | 🇹🇷 | Türkçe | 🇩🇪 | Deutsch |
| 🇫🇷 | Français | 🇪🇸 | Español | 🇧🇷 | Português (ブラジル) |
| 🇮🇹 | Italiano | 🇷🇺 | Русский | 🇯🇵 | 日本語 |
| 🇰🇷 | 한국어 | 🇸🇦 | العربية (RTL) | 🇨🇳 | 简体中文 |

---

## ⌨️ グローバルキーボードショートカット

すべてのショートカットは「**設定 → ショートカット**」から変更できます：

| 初期ショートカット | 動作 | 説明 |
| :--- | :--- | :--- |
| `⌥⌘N` | **新規ノート** | 画面上に独立した付箋ノートを瞬時に作成 |
| `⌥⌘V` | **クイック取り込み** | クリップボードのテキストを新しいノートとして保存 |
| `⌥⌘L` | **全ノート一覧** | 検索・分類ができるメイン管理ウィンドウを開く |
| `⌥⌘B` | **付箋ボード** | 自由なコルクボード画面を開く |
| `⌥⌘A` | **アーカイブ** | 保存されたアーカイブノートを表示 |
| `⌃⌥⌘H` | **ドックの表示切替** | 画面端のスライドドックを開閉 |
| `Esc` | **ノートを閉じる** | 最前面の編集画面を閉じる |

---

## 📈 Star獲得の推移

[![Star History Chart](https://api.star-history.com/svg?repos=mehmetefeaytas/notesmy&type=Date)](https://star-history.com/#mehmetefeaytas/notesmy&Date)

---

## 👥 コントリビューター

新機能の提案、バグ報告、プルリクエストをいつでも歓迎しています！

<a href="https://github.com/mehmetefeaytas/notesmy/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=mehmetefeaytas/notesmy" alt="コントリビューター" />
</a>

コントリビューション手順については [CONTRIBUTING.md](../CONTRIBUTING.md) をご覧ください。

---

## 💖 スポンサー・ご支援

NotesMyが日々の作業効率化に役立ちましたら、ぜひ開発支援やコーヒーの差し入れをお願いいたします：

<p align="center">
  <a href="https://github.com/sponsors/mehmetefeaytas"><img src="https://img.shields.io/badge/GitHub%20Sponsors-支援する-EA4AAA?style=for-the-badge&logo=githubsponsors" alt="GitHub Sponsors" /></a>
</p>

---

## 📬 お問い合わせ・リンク

ご質問やコラボレーションのご相談はお気軽にどうぞ：

- 📧 **メール:** [efeyapiyor@gmail.com](mailto:efeyapiyor@gmail.com)
- 💼 **LinkedIn:** [Mehmet Efe Aytaş](https://linkedin.com/in/mehmetefeaytas)
- 🐙 **GitHub:** [@mehmetefeaytas](https://github.com/mehmetefeaytas)

---

## 🛡️ プライバシーと安全性

- **完全オフライン動作:** 外部サーバーへの通信は行いません。テレメトリや追跡スクリプトも皆無です。
- **透明なローカルファイル:** ノートデータは `~/Library/Application Support/NotesMy/notes.json` に安全に保管されます。
- **CloudKit同期:** 同期を有効にした場合でも、個人のプライベートiCloud領域とのみ通信します。

---

## 📄 ライセンス

NotesMyは **Apache License 2.0** のもとで公開されています。詳細は [LICENSE](../LICENSE) をご確認ください。

Developed with ❤️ by **[Mehmet Efe Aytaş](https://github.com/mehmetefeaytas)**.
