param(
  [int]$Port = 5173,
  [string]$Root = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'

$mime = @{
  '.html' = 'text/html; charset=utf-8'
  '.htm'  = 'text/html; charset=utf-8'
  '.css'  = 'text/css; charset=utf-8'
  '.js'   = 'application/javascript; charset=utf-8'
  '.mjs'  = 'application/javascript; charset=utf-8'
  '.json' = 'application/json; charset=utf-8'
  '.svg'  = 'image/svg+xml'
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.gif'  = 'image/gif'
  '.webp' = 'image/webp'
  '.ico'  = 'image/x-icon'
  '.woff' = 'font/woff'
  '.woff2'= 'font/woff2'
  '.ttf'  = 'font/ttf'
  '.txt'  = 'text/plain; charset=utf-8'
  '.map'  = 'application/json; charset=utf-8'
}

$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:$Port/"
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Host "dev-server listening on $prefix (root: $Root)"

try {
  while ($listener.IsListening) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response
    try {
      $path = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath)
      if ($path -eq '/' -or $path -eq '') { $path = '/index.html' }
      $relative = $path.TrimStart('/').Replace('/', [System.IO.Path]::DirectorySeparatorChar)
      $full = Join-Path $Root $relative
      $full = [System.IO.Path]::GetFullPath($full)
      if (-not $full.StartsWith($Root, [System.StringComparison]::OrdinalIgnoreCase)) {
        $response.StatusCode = 403
        $response.Close()
        continue
      }
      if ((Test-Path $full -PathType Container)) {
        $full = Join-Path $full 'index.html'
      }
      if (-not (Test-Path $full -PathType Leaf)) {
        $response.StatusCode = 404
        $bytes = [System.Text.Encoding]::UTF8.GetBytes("404 not found: $path")
        $response.OutputStream.Write($bytes, 0, $bytes.Length)
        $response.Close()
        continue
      }
      $ext = [System.IO.Path]::GetExtension($full).ToLowerInvariant()
      $type = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { 'application/octet-stream' }
      $response.ContentType = $type
      $response.Headers['Cache-Control'] = 'no-store'
      $bytes = [System.IO.File]::ReadAllBytes($full)
      $response.ContentLength64 = $bytes.Length
      $response.OutputStream.Write($bytes, 0, $bytes.Length)
      $response.Close()
    } catch {
      try {
        $response.StatusCode = 500
        $msg = [System.Text.Encoding]::UTF8.GetBytes("500 server error: $($_.Exception.Message)")
        $response.OutputStream.Write($msg, 0, $msg.Length)
        $response.Close()
      } catch {}
    }
  }
} finally {
  $listener.Stop()
  $listener.Close()
}
