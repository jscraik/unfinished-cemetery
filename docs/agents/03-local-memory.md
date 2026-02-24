# Local memory workflow

Use durable memory only when cross-run context is needed.

## Required flow before writing memory
1. `bootstrap(mode="minimal", include_questions=true, session_id="repo:unfinished-cemetery:task:<id>")`
2. `search(query="...", session_id="repo:unfinished-cemetery:task:<id>")`

## Storage rules
- Store durable facts only (`observation` or `learning`).
- Use stable tags that match repo topics (for example: `jekyll`, `content`, `workflows`).
- Never store secrets, tokens, keys, or PII.
