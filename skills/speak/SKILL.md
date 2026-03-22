---
name: speak
description: Use when the user invokes /speak to hear the last Claude response as natural spoken audio via TTS
---

# Speak

Rewrites your last response as spoken narration and plays it as audio.

## Steps

### 1. Rewrite as narration

Take your most recent response from conversation context. Rewrite it as natural spoken narration:

- **Under 150 words** (~60 seconds spoken)
- No markdown, no code blocks, no bullet points, no headers
- Conversational tone — as if explaining to a colleague over coffee
- Preserve the key message and insights
- Use short sentences. Vary rhythm. Make it sound human.

### 2. Synthesize and play

Run the `run.sh` script in this skill's directory, passing the narration text via stdin:

```bash
echo "Your narration text here" | <this-skill-directory>/run.sh
```

The script auto-selects the TTS engine:

| Priority | Condition | Engine |
|----------|-----------|--------|
| 1 | `ELEVENLABS_API_KEY` set | ElevenLabs (highest quality) |
| 2 | `OPENAI_API_KEY` set | OpenAI TTS |
| 3 | Neither set | macOS `say` (zero dependencies) |

API-based engines save a timestamped `.mp3` to `~/.agent-speak/audio/`.

## Common Mistakes

- Including markdown syntax in the narration (`**bold**`, `- bullets`, `` `code` ``)
- Exceeding 150 words — audio drags past 60 seconds
- Narrating code literally instead of describing what it does
- Using written-English constructions that sound awkward spoken ("the aforementioned", "as follows:")
