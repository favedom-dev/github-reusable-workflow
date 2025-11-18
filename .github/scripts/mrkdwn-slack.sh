#!/bin/bash

# --- Input Handling ---

MARKDOWN_CONTENT=""

if [ -z "$1" ]; then
    # Read from stdin
    # Removed the instructional echo to keep output clean
    MARKDOWN_CONTENT=$(cat -)
else
    # Argument provided, assume it's a file path
    MARKDOWN_FILE="$1"
    if [ ! -f "$MARKDOWN_FILE" ]; then
        echo "Error: File not found at path: $MARKDOWN_FILE" >&2 # Send errors to stderr
        exit 1
    fi
    MARKDOWN_CONTENT=$(cat "$MARKDOWN_FILE")
fi

if [ -z "$MARKDOWN_CONTENT" ]; then
    # Removed the 'Exiting' echo to keep output clean
    exit 0
fi

SLACK_TEXT="$MARKDOWN_CONTENT"

# --- Conversion Logic (Same as before) ---

# 1. Convert ALL Headers (#, ##, ###, etc.) to *Bold Text*
# SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*#{1,6}[[:space:]]+(.*)$/\*\1\*/g')
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*#{1,6}[[:space:]]*(.*)$/\*\1\*/g')

# 2. Convert Bold: **text** or __text__ to *text* (Slack's primary bold)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/(\*\*|__)(.*?)(\*\*|__)/\*\2\*/g')

# 3. Convert Italic: *text* or _text_ to _text_ (Slack's primary italic)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/(^|[[:space:]])([^\*]*)(\*|_)(.*?)(\*|_)([^\*]*)([[:space:]]|$)/\1\2_\4_\6\7/g')

# 4. Convert Links: [Text](URL) to <URL|Text> (Slack API format)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<\2|\1>/g')

# 5. Convert Blockquotes: > quote to >quote (Slack format)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*> (.*)$/>\1/g')

# 6. Convert Unordered Lists: * Item or - Item to an asterisk and a space
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*[-*][[:space:]]+(.*)$/* \1/g')

# --- Output the Final Value of SLACK_TEXT ---
# This single line is what gets captured by the calling script/command
echo "$SLACK_TEXT"