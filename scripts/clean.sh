#!/bin/bash

BOXES_DIR="$HOME/.local/share/gnome-boxes/images"

echo ""
echo "  Cleaning up temp and backup files in $BOXES_DIR..."
echo ""

shopt -s nullglob
files=("$BOXES_DIR"/*.bak "$BOXES_DIR"/*-compressed.qcow2 "$BOXES_DIR"/*.raw "$BOXES_DIR"/*-small.qcow2 "$BOXES_DIR"/*-trimmed.qcow2)

if [ ${#files[@]} -eq 0 ]; then
    echo "  Nothing to clean."
    exit 0
fi

echo "  Files to remove:"
for f in "${files[@]}"; do
    echo "    $(du -sh "$f" | cut -f1)  $f"
done

echo ""
read -p "  Delete all? (y/N): " -n 1 -r
echo
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "  Aborted." && exit 0

for f in "${files[@]}"; do
    rm "$f"
    echo "  Removed: $f"
done
echo ""
echo "  Done."
echo ""