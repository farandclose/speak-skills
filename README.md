# speak-skills

Hear your AI agent's responses as natural spoken audio. Works with Claude Code, Codex CLI, Gemini CLI, and any agent that supports the SKILL.md standard.

## Install

```bash
git clone https://github.com/farandclose/speak-skills.git
cd speak-skills
bash install.sh
```

Or one-liner:

```bash
curl -sL https://raw.githubusercontent.com/farandclose/speak-skills/main/install.sh | bash
```

The installer auto-detects Claude Code, Codex CLI, and installs to `~/.agents/skills/` for universal discovery.

## Skills

| Skill | Command | What it does |
|-------|---------|--------------|
| **speak** | `/speak` | One-off: narrates the last response as audio |
| **vocal** | `/vocal` | Session mode: auto-narrates responses that merit it |

### /speak

Rewrites the last response as a ~150-word spoken narration and plays it via TTS.

### /vocal

Activates auto-speak for the session. After each response, the agent decides:

- **Skip**: brainstorming, Q&A, code output, quick confirmations
- **Narrate**: task completions, explanations, analysis, recommendations

Narrated responses show the text and prompt `Hear it? (y)` for deferred playback — avoids overlapping audio when running multiple agent tabs.

## TTS Engines

| Priority | Engine | Setup | Quality | Saves .mp3? |
|----------|--------|-------|---------|-------------|
| 1 | ElevenLabs | `ELEVENLABS_API_KEY` | Best | Yes |
| 2 | OpenAI TTS | `OPENAI_API_KEY` | Good | Yes |
| 3 | macOS `say` | None | Basic | No |

Engine is auto-selected based on available API keys.

## Configuration

Edit `~/.agent-speak/.env`:

```bash
# ElevenLabs
ELEVENLABS_API_KEY=your-key-here
ELEVENLABS_VOICE_ID=21m00Tcm4TlvDq8ikWAM    # Rachel (default)
ELEVENLABS_MODEL_ID=eleven_flash_v2_5         # Fastest, lowest cost

# OpenAI
OPENAI_API_KEY=sk-your-key-here
OPENAI_TTS_VOICE=nova                         # Options: alloy, echo, fable, onyx, nova, shimmer
OPENAI_TTS_MODEL=tts-1                        # Use tts-1-hd for higher quality

# macOS
SAY_VOICE=Samantha                            # Run: say -v '?' to list voices
```

## Audio Files

API-based engines save `.mp3` files to `~/.agent-speak/audio/`:

```
~/.agent-speak/audio/2026-03-22_143022.mp3
```

## Requirements

- `curl` and `jq` (for API-based TTS)
- `afplay` (macOS) or `mpg123` (Linux) for audio playback
- No dependencies for macOS `say` fallback

## License

MIT
