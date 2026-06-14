# PWA Markdown Editor

一個可安裝、可離線使用的 Markdown Editor / Viewer。畫面風格接近 ChatGPT，支援左側 Markdown 編輯、右側即時預覽、多檔管理、程式碼高亮、工具列快速插入語法、LocalStorage 自動儲存、列印與 PWA 離線使用。

---

## 主要功能

| 功能 | 說明 |
|---|---|
| **Markdown 編輯器** | 左側編輯 Markdown，右側即時預覽 |
| **分割 / 編輯 / 預覽模式** | 可在「編輯」、「分割」、「預覽」三種模式切換 |
| **ChatGPT 風格預覽** | 標題、段落、清單、引用、表格與程式碼區塊採用深色 ChatGPT 風格 |
| **多檔管理** | 側欄列出已開啟的 `.md` / `.markdown` / `.txt` 檔，可快速切換或刪除 |
| **開檔 / 儲存** | 可開啟本機 Markdown / Text 檔，並儲存回原檔或另存 |
| **拖曳開檔** | 可直接把 `.md`、`.markdown`、`.txt` 拖進頁面，並顯示拖曳提示 |
| **工具列** | 可快速插入粗體、斜體、刪除線、標題、清單、待辦、引用、程式碼、連結、圖片、表格與分隔線 |
| **程式碼高亮** | 使用 highlight.js 與 `github-dark` 主題，並提供程式碼「複製」按鈕 |
| **字數統計** | 支援 CJK 字元與英文詞統計 |
| **自動儲存** | 每 3 秒自動儲存目前文件到 LocalStorage |
| **列印模式** | 列印時自動隱藏側欄、header、編輯區與分隔線，輸出乾淨預覽內容 |
| **PWA 安裝** | 支援安裝到桌面或手機主畫面 |
| **桌面檔案關聯** | 在支援的 Chromium 桌面瀏覽器中，安裝後可從作業系統直接用 MD Editor 開啟 `.md` / `.markdown` |
| **多視窗 / 多 instance** | 桌面版安裝型 PWA 可同時開多個 MD Editor 視窗，每個視窗各自維持自己的工作區狀態 |
| **外部變更偵測 / Reload** | 以檔案 handle 開啟的文件若被外部修改，編輯器會自動提示 reload |
| **開檔 history 管理** | 支援清空目前開啟清單，並避免同一個檔案在 history 中重複出現 |
| **分享到 MD Editor** | 在支援 Web Share Target 的裝置上，可從系統分享面板把 `.md` / `.markdown` 分享到 MD Editor |
| **離線使用** | 透過 Service Worker 快取必要資源，安裝後可離線開啟 |
| **深色主題** | 預設深色背景 `#212121`，accent 使用 ChatGPT 綠 `#10a37f` |

---

## 專案結構

```text
MDeditor/
├── index.html                    # 主程式，包含 UI、Markdown 編輯、預覽與 PWA 啟動邏輯
├── manifest.json                 # PWA manifest，註冊檔案關聯與 share target
├── icon.svg                      # PWA icon
├── sw.js                         # Service Worker，負責離線快取與分享資料轉送
├── scripts/mdeditor-serve.sh     # 啟動本機 HTTP server
├── scripts/mdeditor-systemd-user.sh
│                                 # 安裝/啟停 systemd --user 服務
└── systemd/user/                 # user-mode systemd units
```

---

## 本機啟動方式

PWA 需要在 `localhost` 或 HTTPS 環境下執行。開發時最簡單的方式是用本機靜態伺服器。

### 方法 1：使用 Python

```bash
cd MDeditor
python -m http.server 8080
```

然後開啟：

```text
http://localhost:8080
```

### 方法 2：使用 Node.js serve

```bash
cd MDeditor
npx serve .
```

---

## 使用方式

### 編輯器內操作

1. 點 `＋ 新建文件` 建立新文件。
1. 點 `📂 Open Markdown` 匯入 `.md`、`.markdown` 或 `.txt`。
2. 也可直接把 `.md` / `.markdown` / `.txt` 拖進頁面。
3. 用上方工具列快速插入標題、清單、程式碼、連結、表格與數學式。
4. 點 `💾 Save` 儲存；若瀏覽器支援 File System Access API，會直接回寫原檔。

### PWA / 檔案關聯更新

如果你之前安裝過舊版 MD Editor，而且它曾經關聯過 `.txt`：

1. 先移除舊版已安裝的 PWA。
2. 重新用 Chrome 或 Edge 開啟 `http://localhost:8080` 或 `https://MDeditor.kennylab.online`。
3. 重新安裝 PWA。

這樣作業系統與瀏覽器才會重新註冊新的檔案關聯，套用新的 `.md` / `.markdown` / `.txt` 設定。

### 多 instance 行為

- 安裝型 PWA 在桌面 Chromium 瀏覽器中，現在會用新視窗處理新的啟動，而不是強制導回既有視窗。
- 每個視窗的文件列表與編輯內容會存在各自的 `sessionStorage`，避免多個視窗互相覆蓋暫存工作區。
- 如果你先前已安裝舊版單 instance PWA，請移除後重新安裝，讓新的 manifest 設定生效。

### systemd user mode 操作

第一次安裝：

```bash
cd MDeditor
chmod +x scripts/mdeditor-serve.sh scripts/mdeditor-systemd-user.sh
./scripts/mdeditor-systemd-user.sh install
```

日常管理：

```bash
./scripts/mdeditor-systemd-user.sh status
./scripts/mdeditor-systemd-user.sh start
./scripts/mdeditor-systemd-user.sh restart
./scripts/mdeditor-systemd-user.sh stop
./scripts/mdeditor-systemd-user.sh logs
```

只補建 Cloudflare DNS route：

```bash
./scripts/mdeditor-systemd-user.sh route-dns
```

---

## 安裝成 PWA

啟動本機 server 後，用 Chrome 或 Edge 開啟頁面。

```text
http://localhost:8080
```

如果 PWA 條件符合，網址列右側會出現安裝按鈕：

```text
⊕  安裝 MD Editor
```

點擊後即可安裝到桌面或主畫面。

### 直接從作業系統開啟文字檔

在支援 `file_handlers` 的 Chromium 桌面瀏覽器中，重新安裝或更新 PWA 後，作業系統的「開啟方式 / Open with」會出現 `MD Editor`，可直接把 `.md`、`.markdown`、`.txt` 交給程式開啟。

注意：

- Windows / macOS / Linux 主要取決於 Chrome 或 Edge 是否支援 PWA File Handling。
- Android 目前不保證提供同等的「點檔案直接選 PWA 開啟」整合；可改用 App 內開檔、拖放，或從分享面板導入作為備案。

### Android 分享到 MD Editor

安裝或重新安裝 PWA 後，在 Android 的檔案管理器、筆記 App 或其他支援分享檔案的 App 中，選擇分享 `.md`、`.markdown` 檔案時，若瀏覽器與系統支援 Web Share Target，分享面板會出現 `MD Editor`。

限制：

- 這依賴安裝型 PWA 與 Chromium 的 Web Share Target 支援。
- 第一次更新 `manifest.json` 後，通常需要移除舊版 PWA 再重新安裝，系統才會重新註冊分享目標。
- 目前分享進來的檔案會以新文件方式匯入編輯器，不會直接回寫來源 App。

---

## 手機測試與 PWA 安裝

手機可以用三種方式連到電腦上的本機 server：

| 方式 | 網址類型 | 可瀏覽 | 可安裝 PWA | 說明 |
|---|---|---:|---:|---|
| `localhost` | `http://localhost:8080` | ✅ | ✅ | 只適用在同一台電腦本機 |
| 局域網 IP | `http://192.168.x.x:8080` | ✅ | ❌ | 可用來測試畫面，但通常不是 HTTPS，不能完整測 PWA |
| Cloudflare Tunnel / ngrok | HTTPS tunnel URL | ✅ | ✅ | 適合手機測試與安裝 PWA |

局域網 IP 很適合快速測試手機版畫面，但若要安裝成 PWA，需要 HTTPS，因此要搭配 Cloudflare Tunnel 或 ngrok。

---

## 使用 ngrok

ngrok 也可以把本機 `http://localhost:8080` 轉成公開 HTTPS 網址，符合 PWA 安裝條件。

### 第一次設定

1. 到 ngrok 官網註冊帳號。
2. 下載 Windows 版 `ngrok.exe`，例如放在：

```text
D:\bin_prog\ngrok.exe
```

3. 設定 authtoken：

```bat
ngrok config add-authtoken 你的token
```

### 每次啟動流程

開兩個命令列視窗。

#### 視窗 1：啟動本機 server

```bat
cd /d C:\你的專案資料夾
python -m http.server 8080
```

#### 視窗 2：啟動 ngrok tunnel

```bat
D:\bin_prog\ngrok http 8080
```

ngrok 會產生一個 HTTPS 網址，例如：

```text
https://a1b2-123-456-789.ngrok-free.app
```

用手機或其他電腦開啟這個網址，就可以測試與安裝 PWA。

### ngrok 出現 SSL 憑證驗證失敗

如果 ngrok 出現 SSL 憑證驗證失敗，常見原因是公司、學校網路或 proxy 攔截 TLS 連線。

可以直接改用以下其中一種方式處理。

#### 方法 A：設定 ngrok legacy backend

```bat
ngrok config edit
```

在 `ngrok.yml` 中確認或加入：

```yaml
version: "2"
authtoken: 你的token
tunnel_backend: legacy
```

存檔後重新啟動 ngrok。

#### 方法 B：設定 proxy

```bat
ngrok http 8080 --proxy-url=http://你的proxy位址:port
```

#### 方法 C：改用 Cloudflare Tunnel

```bat
cloudflared tunnel --url http://localhost:8080
```

---

## 局域網 IP 測試

如果手機和電腦在同一個 Wi-Fi，可以直接用電腦的局域網 IP 開啟。

先查電腦 IP：

```bat
ipconfig
```

找到 IPv4 位址，例如：

```text
192.168.1.100
```

手機瀏覽器開啟：

```text
http://192.168.1.100:8080
```

局域網 IP 適合快速測試手機版 UI、編輯、預覽與開檔功能。不過因為它通常是 HTTP，不是 HTTPS，所以不能完整測試 Service Worker 與 PWA 安裝。

若要在手機安裝成 PWA，請改用 Cloudflare Tunnel 或 ngrok 產生的 HTTPS 網址。

---

## 安裝後離線使用

| 情境 | 可否使用 | 說明 |
|---|---:|---|
| 第一次開啟網站 | ❌ | 需要網路載入資源 |
| 第一次安裝 PWA | ❌ | 需要 HTTPS 或 localhost |
| 安裝後 tunnel 關掉 | ✅ | 已快取的 PWA 仍可開啟 |
| 完全斷網後開啟 PWA | ✅ | Service Worker 會提供快取內容 |
| 開啟從未快取過的新資源 | ❌ | 仍需要網路 |

Service Worker 會預先快取：

```text
./
./index.html
./manifest.json
Google Fonts CSS
marked.js
highlight.js CSS
highlight.js JS
```

第一次透過 `localhost` 或 HTTPS tunnel 成功載入後，這些資源會被快取。之後即使 tunnel 關掉，已安裝的 PWA 仍可離線使用。

LocalStorage 儲存限制：

目前文件內容會儲存在瀏覽器 LocalStorage。LocalStorage 適合小型文件與最近工作狀態，不適合大量 Markdown 文件或大型圖片內容。

---

## PWA Icon 與 Manifest 設計

目前改用靜態檔案：

- `manifest.json` 定義 PWA metadata、`.md` / `.markdown` / `.txt` 檔案關聯與 Web Share Target
- `icon.svg` 作為安裝圖示
- `sw.js` 負責離線快取，並把 share target 傳入的內容暫存後轉交給 `index.html`

如果更新了 `manifest.json` 的檔案關聯、分享目標或 icon，已安裝的 PWA 通常需要移除再重新安裝，系統才會完整套用新設定。

---

## 安全限制

目前專案已加上基本安全硬化：

- Markdown 預覽輸出的 HTML 會先經過簡化 sanitization，避免直接注入任意標籤、事件屬性與危險連結。
- 頁面已設定 `Content-Security-Policy`，限制 script、style、font、image 與 worker 的來源。
- 預覽中的外部連結會自動加上 `target="_blank"` 與 `rel="noopener noreferrer"`。

目前仍有幾個刻意保留的限制與取捨：

- 這不是完整的 HTML 白名單 sanitizer；若未來要支援更複雜的內嵌 HTML，建議改用成熟函式庫，例如 `DOMPurify`。
- 預覽允許 `data:image/...`，是為了保留常見 Markdown 內嵌圖片用法；如果部署情境更嚴格，可以再收緊。
- Service Worker 目前主要服務靜態資源離線快取，不處理更進階的版本控管、內容驗證或資料同步。
