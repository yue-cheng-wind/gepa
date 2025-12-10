#!/usr/bin/env bash
set -euo pipefail

FOLDER="${1:-./src}"
OUTPUT_PDF="code_export.pdf"
OUTPUT_HTML="code_export.html"

# Create temporary HTML file
cat > "$OUTPUT_HTML" <<'HTML_START'
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>Code Export</title>
<style>
  body { font-family: 'Courier New', monospace; margin: 20px; background: #f5f5f5; }
  .file { background: white; padding: 15px; margin: 10px 0; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
  .filename { background: #333; color: #fff; padding: 10px; margin: -15px -15px 15px -15px; border-radius: 5px 5px 0 0; font-weight: bold; }
  pre { white-space: pre-wrap; word-wrap: break-word; }
  code { font-family: monospace; }
</style>
</head>
<body>
<h1>Code export from: ${FOLDER}</h1>
HTML_START

# Find files and append
find "$FOLDER" -type f \( -name '*.py' -o -name '*.md' -o -name '*.json' -o -name '*.js' -o -name '*.ts' \) -not -path "*/.venv/*" -not -path "*/.git/*" | sort | while IFS= read -r file; do
  echo "<div class='file'>" >> "$OUTPUT_HTML"
  echo "<div class='filename'>📄 $(echo "$file" | sed 's|^\./||')</div>" >> "$OUTPUT_HTML"
  echo "<pre><code>" >> "$OUTPUT_HTML"
  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' "$file" >> "$OUTPUT_HTML"
  echo "</code></pre>" >> "$OUTPUT_HTML"
  echo "</div>" >> "$OUTPUT_HTML"
done

cat >> "$OUTPUT_HTML" <<'HTML_END'
</body>
</html>
HTML_END

# Convert to PDF if wkhtmltopdf is available
if command -v wkhtmltopdf >/dev/null 2>&1; then
  wkhtmltopdf --enable-local-file-access "$OUTPUT_HTML" "$OUTPUT_PDF"
  echo "✓ PDF created: $OUTPUT_PDF"
  echo "(Also kept HTML: $OUTPUT_HTML)"
else
  echo "⚠ wkhtmltopdf not found. Created HTML file: $OUTPUT_HTML"
  echo "Install it with: brew install wkhtmltopdf"
  echo "Then convert with: wkhtmltopdf --enable-local-file-access $OUTPUT_HTML $OUTPUT_PDF"
fi
