#!/usr/bin/env bash

BASE_DIR="."
OUTPUT_FILE="frontend_dump.txt"
PACKAGE_FILTER="$1"

# Limpiar archivo
> "$OUTPUT_FILE"

# =========================
# Extensiones relevantes Next.js / React
# =========================
INCLUDE_EXTENSIONS=(
  "*.js" "*.jsx"
  "*.ts" "*.tsx"
  "*.json"
  "*.md"
  "*.css" "*.scss"
  "*.env"
  "*.yml" "*.yaml"
)

# =========================
# Construir expresión find
# =========================
FIND_EXPR=""
for ext in "${INCLUDE_EXTENSIONS[@]}"; do
  FIND_EXPR+=" -iname \"$ext\" -o"
done
FIND_EXPR=${FIND_EXPR::-3}

# =========================
# Ejecutar find base
# =========================
if [ -n "$PACKAGE_FILTER" ]; then
  FIND_CMD="find \"$BASE_DIR\" -type f \( $FIND_EXPR \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.next/*' \
    -not -path '*/out/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/coverage/*' \
    -path \"*/$PACKAGE_FILTER/*\""
else
  FIND_CMD="find \"$BASE_DIR\" -type f \( $FIND_EXPR \) \
    -not -path '*/node_modules/*' \
    -not -path '*/.next/*' \
    -not -path '*/out/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.git/*' \
    -not -path '*/coverage/*'"
fi

# =========================
# Procesar archivos
# =========================
eval "$FIND_CMD" | sort | while read -r file; do

  relative_path="${file#./}"

  echo "### $relative_path" >> "$OUTPUT_FILE"
  echo "" >> "$OUTPUT_FILE"

  cat "$file" >> "$OUTPUT_FILE"

  echo -e "\n\n" >> "$OUTPUT_FILE"

done

echo "Dump generado en: $OUTPUT_FILE"