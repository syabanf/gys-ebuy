export function printHtml(title: string, bodyHtml: string) {
  const iframe = document.createElement('iframe')
  Object.assign(iframe.style, { position: 'fixed', right: '0', bottom: '0', width: '0', height: '0', border: '0' })
  document.body.appendChild(iframe)
  const doc = iframe.contentWindow?.document
  if (!doc) return
  doc.open()
  doc.write(`<!doctype html><html><head><meta charset="utf-8"><title>${title}</title><style>
    *{box-sizing:border-box} body{font-family:Inter,system-ui,-apple-system,sans-serif;color:#18181b;padding:40px;margin:0}
    .head{display:flex;justify-content:space-between;align-items:flex-start;border-bottom:2px solid #137A40;padding-bottom:16px}
    .logo{height:40px;width:40px;border-radius:8px;background:#137A40;color:#fff;font-weight:800;display:flex;align-items:center;justify-content:center}
    h1{font-size:18px;margin:0} .muted{color:#71717a;font-size:12px}
    .grid{display:flex;gap:40px;margin-top:20px} .grid>div{flex:1}
    table{width:100%;border-collapse:collapse;margin-top:20px;font-size:13px}
    th,td{text-align:left;padding:8px 6px;border-bottom:1px solid #e4e4e7} .r{text-align:right}
    tfoot td{border:none;padding-top:6px} .tot{font-weight:800;font-size:15px;color:#137A40}
    h3{font-size:12px;text-transform:uppercase;letter-spacing:.05em;color:#71717a;margin:0 0 6px}
  </style></head><body>${bodyHtml}</body></html>`)
  doc.close()
  iframe.contentWindow?.focus()
  setTimeout(() => {
    iframe.contentWindow?.print()
    setTimeout(() => document.body.removeChild(iframe), 800)
  }, 300)
}
