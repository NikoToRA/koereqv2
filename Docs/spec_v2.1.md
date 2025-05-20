# コエレク完全仕様書 v2.1 (2025‑05‑19)

> **目的** — Devin がそのまま実装に着手できるレベルまで要件・非機能・ファイル構成・API 契約を明示する。図面 (状態遷移 / リーチマップ) は別途 Figma 共有。

---

## 1. アプリ概要

| 項目    | 内容                                    |                                       |                               |
| ----- | ------------------------------------- | ------------------------------------- | ----------------------------- |
| 想定シーン | 救急外来・在宅往診でのハンズフリー記録支援                 |                                       |                               |
| 入力    | **音声のみ** (録音 → Whisper on‑device STT) |                                       |                               |
| 出力    | AI 応答 + QR / Blob への音声・テキスト・応答保存      |                                       |                               |
| 操作原則  | *選ばせない・考えさせない* — ボタン数最小、片手親指リーチ内固定    |                                       |                               |
| 依存    | iOS 17 / Swift 5.9 / SwiftUI          |  WhisperKit 0.6 (tiny‑ja fp16 Metal)  |  azure‑ai‑openai‑swift 1.3.0  |

---

## 2. システム構成 (高レベル)

```text
[User]
  ↓ (Speech)
[iOS App]
  ├─ RecordingService      (AVAudioRecorder)
  ├─ STTService            (WhisperWrapper → .txt)
  ├─ SessionStore          (CoreData cache)
  ├─ OpenAIService         (Azure GPT‑4‑1106‑preview / GPT‑4.1 mini)
  ├─ StorageService        (Azure Blob via SAS)
  ├─ QRService             (CIQRCodeGenerator)
  └─ UI (SwiftUI Views)
```

---

## 3. フロー (時系列)

1. **施設ログイン**
      *入力*: facility\_id, sas\_token
      *処理*: Keychain 保存 → App 起動中メモリ保持
2. **ホーム**
      `新規セッション` タップ → **0 秒**で `Session(id=UUID, startedAt=Date())` 生成。
      → *仮サマリー* 行を自動挿入: `“未命名セッション (2025/05/19 08:31)”`。※サマリーは SessionVM.summary プロパティに後から再計算可。
3. **録音ループ**
      ユーザが右下録音ボタン (toggle) を押すたびに
      `RecordingService.start() → stop() → **STTService.transcribe() _(Whisper on‑device)_**  
      結果を `TranscriptChunk\` としてチャットに append。
4. **プロンプト送信**
      生成メニューをタップ → 縦展開ボタン群。
      - カルテ生成 (固定 Prompt.chart)
      - 紹介状作成 (固定 Prompt.letter)
      - AI に相談 → **相談モーダル**：`録音` or `テキスト入力` を選択。録音後 Preview なしで即送信。
      - オリジナル Prompt.custom (1 枠)
      押下で `OpenAIService.send(prompt, session.transcripts)` → 応答をチャットに append。
5. \*\*QR (左下固定) ボタンは AI 応答が生成された時のみ表示し、チャット結果と視覚的に紐付け。
6. **終了 / 保存**\*\*
      `Home` へ戻る or 自動で 30 分無操作 → `StorageService.upload(session)`
      構造は §6 参照。成功後 CoreData は削除 (設定で保持も可)。

---

## 4. UI 詳細

### 4‑1 固定フッター (overlay)

| ボタン         | 位置            | 常時?    | 備考                |
| ----------- | ------------- | ------ | ----------------- |
| 録音 (Toggle) | 右下 (最下段)      | ✔      | `.zIndex(5)`      |
| 生成メニュー      | 録音直上          | ✔      | ボタンタップで縦方向に最大4つ展開 |
| QR          | 左下 (生成メニューの上) | AI 応答時 | fade in/out       |

### 4‑2 相談モーダル 相談モーダル

```
+-------------------------+
| AI に何を相談しますか? |
| ----------------------- |
| [🎙録音]  [⌨︎入力]     |
+-------------------------+
```

録音→STT→自動送信／入力→送信ボタン。

#### 4‑3 状態エフェクト

| 状態      | 画面効果                                 |
| ------- | ------------------------------------ |
| 録音中     | 画面を 60 % ブラックで dim ＋ 上部に赤い「● REC」バナー |
| テキスト生成中 | チャット最下部に「⌛ 認識中…」スケルトンセルを表示           |

\---------------------------------------------- |

---

## 5. 非機能要件 (NFR)

| 指標            | 目標値 (SE2)      | テスト方法                  |
| ------------- | -------------- | ---------------------- |
| 録音停止→文字表示     | ≤ **1.5 s**    | Instruments signpost   |
| 送信→応答表示       | ≤ **4 s** (4G) | Azure App Insights RTT |
| RSS メモリ       | ≤ **400 MB**   | Xcode Memory Report    |
| 30 min 録音バッテリ | Δ ≤ **8 %**    | Energy Log             |
| クラッシュ率        | < 0.1 % / week | Crashlytics            |

---

## 6. ストレージ設計 (Azure Blob)

```
/{facility_id}/
   └── {session_id}/
         ├─ meta.json            // {summary, started_at, ended_at, version}
         ├─ voice_001.wav
         ├─ transcript_001.txt
         └─ ai_response_001.txt
```

*ライフサイクル*: `RETENTION_DAYS` 環境変数 (既定 90) で自動削除ポリシ。

---

## 7. データモデル (Swift)

```swift
struct Session: Identifiable, Codable {
  let id: UUID
  var startedAt: Date
  var endedAt: Date?
  var summary: String // 未命名… を自動生成
  var transcripts: [TranscriptChunk]
  var aiResponses: [AIResponse]
}

struct TranscriptChunk: Codable {
  let text: String
  let createdAt: Date
  let sequence: Int
}

enum PromptType: Codable {
  case fixed(name: String, prompt: String)
  case consult(userInput: String)          // AI に相談
  case custom(name: String, prompt: String)
}
```

---

## 8. サービス API 契約 (Devin 実装用)

| Service          | Public API                                                         | 例外           | 備考                 |
| ---------------- | ------------------------------------------------------------------ | ------------ | ------------------ |
| RecordingService | `start()`, `stop() -> URL`                                         | throws       | wav PCM 16kHz      |
| STTService       | `transcribe(url:URL) -> String`                                    | throws       | WhisperKit wrapper |
| OpenAIService    | `send(prompt: PromptType, transcript:[TranscriptChunk]) -> String` | throws       | timeout 15 s       |
| StorageService   | `upload(session:Session)`                                          | async throws | Blob path per §6   |
| QRService        | `generate(text:String) -> UIImage`                                 | –            | ECC‑L, UTF‑8       |

---

## 9. パッケージ / フォルダ構成

```
KoEReq/
  ├─ App/                  // SwiftUI entry & routing
  ├─ Models/
  ├─ Services/
  ├─ ViewModels/
  ├─ Views/
  └─ Resources/
```

---

## 10. CI/CD & テスト

* GitHub Actions → fastlane → TestFlight。
* Checks: swiftformat, swiftlint, unit (≥80 %), XCUITest (録音→QR)。
* Secrets: `AZURE_AI_KEY`, `AZURE_BLOB_SAS` stored as repo secrets.

---

## 11. 未確定 / Todo

1. **仮サマリー生成アルゴリズム** — 現在は `"未命名セッション (日時)"`。将来: LLM 抽出可。
2. **プロンプト複数登録 UI** — カスタム枠>1 の時の UX。

> **更新履歴**
> *2025‑05‑19 v2.1* — 自動サマリー挿入・相談モーダル詳細・Blob retention 追記。
