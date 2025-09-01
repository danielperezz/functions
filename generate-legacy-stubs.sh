#!/usr/bin/env bash
set -euo pipefail

# --- helpers ---
make_title() {
  # underscores -> spaces; title-case each word
  local name="$1"
  echo "$name" \
    | tr '_' ' ' \
    | awk '{
        for (i=1; i<=NF; i++) {
          $i = toupper(substr($i,1,1)) substr($i,2)
        }
        print
      }'
}

# mapping: old_path,new_url
cat <<'CSV' > mappings.csv
batch_inference_v2,https://github.com/mlrun/functions/tree/master/functions/src/batch_inference_v2
feature_selection/feature_selection.ipynb,https://github.com/mlrun/functions/blob/development/functions/src/feature_selection/feature_selection.ipynb
v2_model_server/v2_model_server.ipynb,https://github.com/mlrun/functions/blob/master/functions/src/v2_model_server/v2_model_server.ipynb
silero_vad,https://github.com/mlrun/functions/tree/development/functions/src/silero_vad
transcribe,https://github.com/mlrun/functions/tree/master/functions/src/transcribe
pii_recognizer,https://github.com/mlrun/functions/tree/master/functions/src/pii_recognizer
question_answering,https://github.com/mlrun/functions/tree/master/functions/src/question_answering
sklearn_classifier/sklearn_classifier.ipynb,https://github.com/mlrun/functions/blob/master/functions/src/sklearn_classifier/sklearn_classifier.ipynb
auto_trainer,https://github.com/mlrun/functions/tree/development/functions/src/auto_trainer
batch_inference_v2/batch_inference_v2.ipynb,https://github.com/mlrun/functions/blob/master/functions/src/batch_inference_v2/batch_inference_v2.ipynb
CSV

while IFS=, read -r OLD NEW; do
  [ -z "$OLD" ] && continue

  if [[ "$OLD" == *.ipynb ]]; then
    # File case → create stub notebook
    DIR=$(dirname "$OLD")
    NAME=$(basename "$DIR")
    TITLE=$(make_title "$NAME")

    mkdir -p "$DIR"
    cat > "$OLD" <<EOF
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# $TITLE (moved)\\n",
    "\\n",
    "The content has moved to:\\n",
    "➡️ $NEW\\n"
   ]
  }
 ],
 "metadata": {},
 "nbformat": 4,
 "nbformat_minor": 5
}
EOF

  else
    # Folder case → create README.md
    NAME=$(basename "$OLD")
    TITLE=$(make_title "$NAME")

    mkdir -p "$OLD"
    cat > "$OLD/README.md" <<EOF
# $TITLE (moved)

The contents have moved to:
➡️ $NEW
EOF
  fi
done < mappings.csv

# Add and commit if there are changes
if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -m "compat: add legacy stubs for moved functions and notebooks"
  echo "✅ Legacy stubs generated and committed."
else
  echo "ℹ️ No changes to commit."
fi