// Service Worker — MDeditor (with MathJax support)
const CACHE_NAME = 'md-editor-v2';

const PRECACHE = [
  './',
  './index.html',
  './manifest.json',
  'https://fonts.googleapis.com/css2?family=Sora:wght@400;500;600&family=JetBrains+Mono:wght@400;500&display=swap',
  'https://cdn.jsdelivr.net/npm/marked@12/marked.min.js',
  'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/github-dark.min.css',
  'https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js',
  // MathJax 3 入口（其餘子模組由 MathJax 自身動態載入後也會被 runtime cache 攔截）
  'https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-svg.js'
];

// Install：預先快取
self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => {
      return Promise.allSettled(
        PRECACHE.map(url =>
          cache.add(url).catch(err => console.warn('[SW] precache failed:', url, err))
        )
      );
    }).then(() => self.skipWaiting())
  );
});

// Activate：清除舊版快取
self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys().then(keys =>
      Promise.all(
        keys.filter(k => k !== CACHE_NAME).map(k => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

// Fetch：cache-first，未命中則網路請求並存入快取
self.addEventListener('fetch', event => {
  // 只處理 GET，略過 chrome-extension 等非 http(s) scheme
  if (event.request.method !== 'GET') return;
  const url = new URL(event.request.url);
  if (!['http:', 'https:'].includes(url.protocol)) return;

  event.respondWith(
    caches.match(event.request).then(cached => {
      if (cached) return cached;
      return fetch(event.request).then(response => {
        // 只快取成功的回應（status 200）
        if (response && response.status === 200 && response.type !== 'opaque') {
          const clone = response.clone();
          caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone));
        }
        return response;
      }).catch(() => {
        // 離線且無快取時，對 HTML 請求回傳主頁
        if (event.request.destination === 'document') {
          return caches.match('./index.html');
        }
      });
    })
  );
});
