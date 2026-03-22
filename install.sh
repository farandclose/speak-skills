#!/usr/bin/env bash
set -euo pipefail

# speak-skills installer
# Installs speak + vocal skills for Claude Code, Codex CLI, and other agents

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_SRC="$REPO_DIR/skills"

echo "=== speak-skills installer ==="
echo ""

# --- Detect platforms ---
INSTALLED=()

# Claude Code
CLAUDE_SKILLS="$HOME/.claude/skills"
if [ -d "$HOME/.claude" ]; then
  mkdir -p "$CLAUDE_SKILLS/speak" "$CLAUDE_SKILLS/vocal"
  cp "$SKILLS_SRC/speak/SKILL.md" "$CLAUDE_SKILLS/speak/"
  cp "$SKILLS_SRC/speak/run.sh" "$CLAUDE_SKILLS/speak/"
  chmod +x "$CLAUDE_SKILLS/speak/run.sh"
  cp "$SKILLS_SRC/vocal/SKILL.md" "$CLAUDE_SKILLS/vocal/"
  INSTALLED+=("Claude Code -> $CLAUDE_SKILLS")
fi

# Codex CLI
CODEX_SKILLS="$HOME/.codex/skills"
if [ -d "$HOME/.codex" ]; then
  mkdir -p "$CODEX_SKILLS/speak" "$CODEX_SKILLS/vocal"
  cp "$SKILLS_SRC/speak/SKILL.md" "$CODEX_SKILLS/speak/"
  cp "$SKILLS_SRC/speak/run.sh" "$CODEX_SKILLS/speak/"
  chmod +x "$CODEX_SKILLS/speak/run.sh"
  cp "$SKILLS_SRC/vocal/SKILL.md" "$CODEX_SKILLS/vocal/"
  INSTALLED+=("Codex CLI -> $CODEX_SKILLS")
fi

# Universal ~/.agents/skills/ (Gemini CLI, others)
AGENTS_SKILLS="$HOME/.agents/skills"
mkdir -p "$AGENTS_SKILLS/speak" "$AGENTS_SKILLS/vocal"
cp "$SKILLS_SRC/speak/SKILL.md" "$AGENTS_SKILLS/speak/"
cp "$SKILLS_SRC/speak/run.sh" "$AGENTS_SKILLS/speak/"
chmod +x "$AGENTS_SKILLS/speak/run.sh"
cp "$SKILLS_SRC/vocal/SKILL.md" "$AGENTS_SKILLS/vocal/"
INSTALLED+=("Universal -> $AGENTS_SKILLS")

# --- Set up .env ---
ENV_DIR="$HOME/.agent-speak"
mkdir -p "$ENV_DIR/audio"

if [ ! -f "$ENV_DIR/.env" ]; then
  cp "$REPO_DIR/.env.example" "$ENV_DIR/.env"
  echo ""
  echo "Created $ENV_DIR/.env — add your API keys there."
else
  echo ""
  echo "Existing $ENV_DIR/.env found — not overwritten."
fi

# Also symlink .env into each installed skill's speak directory
for dir in "$CLAUDE_SKILLS/speak" "$CODEX_SKILLS/speak" "$AGENTS_SKILLS/speak"; do
  if [ -d "$dir" ] && [ ! -f "$dir/.env" ]; then
    ln -sf "$ENV_DIR/.env" "$dir/.env" 2>/dev/null || true
  fi
done

# --- Summary ---
echo ""
echo "Installed to:"
for target in "${INSTALLED[@]}"; do
  echo "  - $target"
done
echo ""
echo "Skills available:"
echo "  /speak  — one-off narration of the last response"
echo "  /vocal  — auto-speak mode for the session"
echo ""
echo "Audio files saved to: $ENV_DIR/audio/"
echo ""
echo "Next: edit $ENV_DIR/.env with your API keys."
echo "  No API key needed for macOS (uses built-in 'say')."
echo ""
echo "Done."
