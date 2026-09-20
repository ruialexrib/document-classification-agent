#!/bin/sh
set -eu

WORKFLOW="/workflows/document-classification.json"

if [ -f "$WORKFLOW" ]; then
  echo "Importing bundled workflow..."
  n8n import:workflow --input="$WORKFLOW" || echo "Workflow import skipped or already present."
fi

exec n8n start
