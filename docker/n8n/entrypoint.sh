#!/bin/sh
set -eu

WORKFLOW="/workflows/document-classification.json"

echo "Preparing n8n..."

if [ ! -f "$WORKFLOW" ]; then
  echo "ERROR: bundled workflow not found: $WORKFLOW" >&2
  exit 1
fi

echo "Importing bundled workflow..."
n8n import:workflow --input="$WORKFLOW"

echo "Workflow imported successfully."
echo "Starting n8n..."
exec n8n start
