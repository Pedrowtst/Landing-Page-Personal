param(
  [string]$Dir = 'assets/models/dumbbell/textures',
  [int]$MaxSize = 1024,
  [int]$Quality = 90
)

Add-Type -AssemblyName System.Drawing

$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
$params = New-Object System.Drawing.Imaging.EncoderParameters 1
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
  [System.Drawing.Imaging.Encoder]::Quality,
  [long]$Quality
)

$files = Get-ChildItem -Path $Dir -Filter *.png
foreach ($file in $files) {
  $original = [System.Drawing.Image]::FromFile($file.FullName)
  $w = $original.Width
  $h = $original.Height
  $newW = if ($w -gt $MaxSize) { $MaxSize } else { $w }
  $newH = if ($h -gt $MaxSize) { $MaxSize } else { $h }
  if ($w -gt $h -and $w -gt $MaxSize) {
    $newH = [int]($h * $MaxSize / $w)
    $newW = $MaxSize
  } elseif ($h -gt $w -and $h -gt $MaxSize) {
    $newW = [int]($w * $MaxSize / $h)
    $newH = $MaxSize
  }

  $bitmap = New-Object System.Drawing.Bitmap $newW, $newH
  $g = [System.Drawing.Graphics]::FromImage($bitmap)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
  $g.DrawImage($original, 0, 0, $newW, $newH)

  $outPath = [System.IO.Path]::ChangeExtension($file.FullName, '.jpg')
  $bitmap.Save($outPath, $jpegCodec, $params)

  $g.Dispose()
  $bitmap.Dispose()
  $original.Dispose()

  $oldKb = [math]::Round($file.Length / 1KB, 1)
  $newKb = [math]::Round((Get-Item $outPath).Length / 1KB, 1)
  Write-Host ("{0}: {1}x{2} {3} KB -> {4}x{5} {6} KB" -f $file.Name, $w, $h, $oldKb, $newW, $newH, $newKb)
}

Write-Host "done"
