#!/bin/bash

# --- Input Handling ---
MARKDOWN_CONTENT=""

if [ -z "$1" ]; then
    MARKDOWN_CONTENT=$(cat -)
else
    MARKDOWN_FILE="$1"
    if [ ! -f "$MARKDOWN_FILE" ]; then
        echo "Error: File not found at path: $MARKDOWN_FILE" >&2
        exit 1
    fi
    MARKDOWN_CONTENT=$(cat "$MARKDOWN_FILE")
fi

if [ -z "$MARKDOWN_CONTENT" ]; then
    exit 0
fi

SLACK_TEXT="$MARKDOWN_CONTENT"

# --- Conversion Logic ---

# 1. Convert ALL Headers (#, ##, ###, etc.) to *Bold Text*
#    This targets lines starting with 1 to 6 hashes, making them bold.
#    Note: The space after the hash is optional in this regex: [[:space:]]*
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*#{1,6}[[:space:]]*(.*)$/\*\1\*/g')

# 2. Convert Explicit Bold: **text** or __text__ to *text* (Slack's primary bold)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/(\*\*|__)(.*?)(\*\*|__)/\*\2\*/g')

# 3. CONVERSION FOR LINKS: [Text](URL) to <URL|Text> (Slack API format)
#    This is critical for your PR Body content.
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<\2|\1>/g')

# 4. Convert Blockquotes: > quote to >quote (Slack format)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*> (.*)$/>\1/g')

# 5. Convert Unordered Lists: * Item or - Item to an asterisk and a space
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*[-*][[:space:]]+(.*)$/* \1/g')

# 6. (OPTIONAL) Safer Italic Conversion: targets single * and _ only when not inside a word
#    We omit the complex italic rule here to prevent corruption of package names.

# --- Output the Final Value ---
echo "$SLACK_TEXT"
