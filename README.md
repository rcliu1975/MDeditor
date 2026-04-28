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
| **新建 / 開檔 / 另存** | 可新建文件、開啟本機 Markdown 檔、另存為 `.md` |
| **拖曳開檔** | 可直接把 `.md`、`.markdown`、`.txt` 拖進頁面 |
| **工具列** | 可快速插入粗體、斜體、刪除線、標題、清單、待辦、引用、程式碼、連結、圖片、表格與分隔線 |
| **程式碼高亮** | 使用 highlight.js 與 `github-dark` 主題，並提供程式碼「複製」按鈕 |
| **字數統計** | 支援 CJK 字元與英文詞統計 |
| **自動儲存** | 每 3 秒自動儲存目前文件到 LocalStorage |
| **列印模式** | 列印時自動隱藏側欄、header、編輯區與分隔線，輸出乾淨預覽內容 |
| **PWA 安裝** | 支援安裝到桌面或手機主畫面 |
| **離線使用** | 透過 Service Worker 快取必要資源，安裝後可離線開啟 |
| **深色主題** | 預設深色背景 `#212121`，accent 使用 ChatGPT 綠 `#10a37f` |

---

## 專案結構

```text
md-viewer/
├── index.html      # 主程式，包含 UI、Markdown 編輯、預覽、PWA manifest 注入與 Service Worker 註冊
├── manifest.json   # 靜態 manifest fallback；正常情況下會被 index.html 產生的動態 manifest 取代
└── sw.js           # Service Worker，負責離線快取
```

---

## 本機啟動方式

PWA 需要在 `localhost` 或 HTTPS 環境下執行。開發時最簡單的方式是用本機靜態伺服器。

### 方法 1：使用 Python

```bash
cd md-viewer
python -m http.server 8080
```

然後開啟：

```text
http://localhost:8080
```

### 方法 2：使用 Node.js serve

```bash
cd md-viewer
npx serve .
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

## 推薦方式：Cloudflare Tunnel

推薦優先使用 Cloudflare Tunnel。它不一定需要登入帳號即可快速產生 HTTPS tunnel，免費、穩定，也比 ngrok 少一些憑證與網路限制問題。

### 啟動流程

開兩個命令列視窗。

#### 視窗 1：啟動本機 server

```bat
cd /d C:\你的專案資料夾
python -m http.server 8080
```

#### 視窗 2：啟動 Cloudflare Tunnel

```bat
cloudflared tunnel --url http://localhost:8080
```

Cloudflare Tunnel 會產生一個 HTTPS 網址，例如：

```text
https://example.trycloudflare.com
```

用手機或其他電腦開啟這個 HTTPS 網址，就可以測試並安裝 PWA。

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

`index.html` 一開始仍保留：

```html
<link rel="manifest" href="manifest.json" />
<link rel="apple-touch-icon" id="apple-icon" />
```

頁面載入後，`injectManifest()` 會執行以下流程：

```text
index.html 載入
  → injectManifest() 執行
    → makeIconBlob(192) / makeIconBlob(512)
    → Canvas 產生 192px 與 512px PNG icon
    → 設定 apple-touch-icon
    → 建立新的 manifest JSON
    → 用 Blob URL 產生動態 manifest
    → 覆蓋 <link rel="manifest"> 的 href
```

正常情況下，瀏覽器最後會使用動態產生的 manifest。

`manifest.json` 主要是 fallback。可能會被使用的情況包括：

1. JavaScript 尚未執行完成前，瀏覽器先讀取原本的 `manifest.json`。
2. `injectManifest()` 執行失敗，例如 Canvas、Blob URL 或 JavaScript 被瀏覽器限制。
3. 使用者關閉 JavaScript。
4. 瀏覽器或 PWA 檢查工具直接讀取原始 `<link rel="manifest" href="manifest.json">`。
5. Service Worker 預先快取清單中仍包含 `./manifest.json`，因此離線快取時也會保留這個 fallback 檔案。

如果確定只使用支援動態 manifest 的瀏覽器，也可以把 `manifest.json` 視為備用檔；但保留它比較安全。




