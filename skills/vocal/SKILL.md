---
name: vocal
description: Use when the user invokes /vocal to enable auto-speak mode for the current session
---

# Vocal Session

Auto-speak mode is now active for this session.

## Behavior

After each response, judge which mode applies:

### Skip audio entirely

- Brainstorming, Q&A, rapid back-and-forth where the agent is asking questions
- Code output, file listings, diffs, tables
- Quick confirmations ("Done", "Updated", "Fixed")
- Tool-heavy responses with minimal prose

### Deferred narration (all other narration-worthy responses)

Use for task completions, final answers, explanations, insights, analysis, summaries, recommendations.

1. Rewrite the response as spoken narration (under 150 words, no markdown, no code, conversational tone)
2. Pre-generate the audio in the background immediately using the speak skill's `run.sh` (located at `../speak/run.sh` relative to this skill):

```bash
echo "narration text" | <speak-skill-directory>/run.sh &>/dev/null &
```

3. Append the narration text and a playback prompt to the response:

```
Narration Text:
--------------
<the narration text>

Hear it? (y)
```

4. If the user responds with `y`, play the most recent `.mp3` from `~/.agent-speak/audio/`:

```bash
afplay "$(ls -t ~/.agent-speak/audio/*.mp3 | head -1)"
```

5. If the user responds with anything else, continue the conversation normally — the audio is already saved if they want it later.
