#!/bin/bash

# --- Input Handling ---

MARKDOWN_CONTENT=""

if [ -z "$1" ]; then
    # No argument provided, read from stdin (e.g., piped variable or interactive input)
    echo "Reading Markdown content from standard input (stdin). Press Ctrl+D when finished."
    MARKDOWN_CONTENT=$(cat -)
else
    # Argument provided, assume it's a file path
    MARKDOWN_FILE="$1"
    if [ ! -f "$MARKDOWN_FILE" ]; then
        echo "Error: File not found at path: $MARKDOWN_FILE"
        exit 1
    fi
    MARKDOWN_CONTENT=$(cat "$MARKDOWN_FILE")
fi

# Check if content is empty before processing
if [ -z "$MARKDOWN_CONTENT" ]; then
    echo "No Markdown content provided. Exiting."
    exit 0
fi

SLACK_TEXT="$MARKDOWN_CONTENT"

# --- Conversion Logic ---

# 1. Convert ALL Headers (#, ##, ###, etc.) to *Bold Text*
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*#{1,6}[[:space:]]+(.*)$/\*\1\*/g')

# 2. Convert Bold: **text** or __text__ to *text* (Slack's primary bold)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/(\*\*|__)(.*?)(\*\*|__)/\*\2\*/g')

# 3. Convert Italic: *text* or _text_ to _text_ (Slack's primary italic)
# Note: This regex is designed to be careful with asterisks that are not part of bold text.
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/(^|[[:space:]])([^\*]*)(\*|_)(.*?)(\*|_)([^\*]*)([[:space:]]|$)/\1\2_\4_\6\7/g')

# 4. Convert Links: [Text](URL) to <URL|Text> (Slack API format)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/\[([^]]+)\]\(([^)]+)\)/<\2|\1>/g')

# 5. Convert Blockquotes: > quote to >quote (Slack format)
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*> (.*)$/>\1/g')

# 6. Convert Unordered Lists: * Item or - Item to an asterisk and a space
SLACK_TEXT=$(echo "$SLACK_TEXT" | sed -E 's/^[[:space:]]*[-*][[:space:]]+(.*)$/* \1/g')

# --- Output ---

echo -e "\n--- Converted Slack mrkdwn ---\n"
echo "$SLACK_TEXT"
echo -e "\n----------------------------\n"
