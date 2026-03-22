#!/usr/bin/env bash
set -euo pipefail

# Speak skill — TTS synthesis and playback
# Input: text via argument or stdin
# Auto-selects engine: ElevenLabs > OpenAI > macOS say
# Cross-platform: macOS (afplay) and Linux (mpg123)

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Load API keys from .env if present (check skill dir, then home)
for env_path in "$SCRIPT_DIR/.env" "$HOME/.agent-speak/.env"; do
  if [ -f "$env_path" ]; then
    set -a
    source "$env_path"
    set +a
    break
  fi
done

TEXT="${1:-$(cat)}"

if [ -z "$TEXT" ]; then
  echo "Error: No text provided" >&2
  exit 1
fi

AUDIO_DIR="$HOME/.agent-speak/audio"
mkdir -p "$AUDIO_DIR"
TIMESTAMP=$(date +%Y-%m-%d_%H%M%S)
OUTPUT="$AUDIO_DIR/$TIMESTAMP.mp3"

play_audio() {
  local file="$1"
  if command -v afplay &>/dev/null; then
    afplay "$file"
  elif command -v mpg123 &>/dev/null; then
    mpg123 -q "$file"
  elif command -v aplay &>/dev/null; then
    aplay -q "$file" 2>/dev/null || echo "aplay cannot play mp3. Install mpg123." >&2
  else
    echo "No audio player found. File saved to: $file" >&2
  fi
}

# --- ElevenLabs ---
if [ -n "${ELEVENLABS_API_KEY:-}" ]; then
  VOICE_ID="${ELEVENLABS_VOICE_ID:-21m00Tcm4TlvDq8ikWAM}"  # Rachel (default)
  MODEL_ID="${ELEVENLABS_MODEL_ID:-eleven_flash_v2_5}"

  HTTP_CODE=$(curl -s -w "%{http_code}" \
    "https://api.elevenlabs.io/v1/text-to-speech/$VOICE_ID" \
    -H "xi-api-key: $ELEVENLABS_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg text "$TEXT" --arg model "$MODEL_ID" \
      '{text: $text, model_id: $model}')" \
    --output "$OUTPUT")

  if [ "$HTTP_CODE" -ge 400 ]; then
    echo "ElevenLabs API error (HTTP $HTTP_CODE)" >&2
    cat "$OUTPUT" >&2
    rm -f "$OUTPUT"
    exit 1
  fi

  play_audio "$OUTPUT"
  echo "engine=elevenlabs"
  echo "file=$OUTPUT"
  exit 0
fi

# --- OpenAI TTS ---
if [ -n "${OPENAI_API_KEY:-}" ]; then
  VOICE="${OPENAI_TTS_VOICE:-nova}"
  MODEL="${OPENAI_TTS_MODEL:-tts-1}"

  HTTP_CODE=$(curl -s -w "%{http_code}" \
    "https://api.openai.com/v1/audio/speech" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -H "Content-Type: application/json" \
    -d "$(jq -n --arg text "$TEXT" --arg voice "$VOICE" --arg model "$MODEL" \
      '{model: $model, voice: $voice, input: $text}')" \
    --output "$OUTPUT")

  if [ "$HTTP_CODE" -ge 400 ]; then
    echo "OpenAI TTS API error (HTTP $HTTP_CODE)" >&2
    cat "$OUTPUT" >&2
    rm -f "$OUTPUT"
    exit 1
  fi

  play_audio "$OUTPUT"
  echo "engine=openai"
  echo "file=$OUTPUT"
  exit 0
fi

# --- macOS say (default, no file saved) ---
if command -v say &>/dev/null; then
  VOICE="${SAY_VOICE:-Samantha}"
  say -v "$VOICE" "$TEXT"
  echo "engine=say"
  echo "file=none"
  exit 0
fi

echo "Error: No TTS engine available. Set OPENAI_API_KEY or ELEVENLABS_API_KEY, or use macOS." >&2
exit 1
