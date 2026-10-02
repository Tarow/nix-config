# Global Agent Instructions

## Core Principles

- Read unfamiliar files before modifying or deleting.
- Make minimal, targeted changes that match existing code style and conventions.
- Preserve existing behavior unless explicitly instructed.

## Workflow

- In Plan mode: discuss the plan directly; don't create plan files unless asked.
- Ask when requirements are ambiguous rather than guessing.
- Verify changes (typecheck/lint/test) when available before considering work done.

## Tool Usage

- Prefer parallel tool calls for independent tasks.
- Prefer dedicated tools over shell; use shell only when necessary.
- Use `edit` for targeted changes; use `write` only for new files or full replacements.

## Code Style & Comments

- Only add comments when strictly necessary. Never add comments that restate what the code clearly does.
- Comment only to explain non-obvious reasoning, complex algorithms, workarounds, or important edge cases.
- Keep comments concise and factual. Avoid verbose explanations, docstrings, or decorative comments.

## Safety & Boundaries

- **Never commit automatically.** Do not run `git commit`, `git push`, or amend commits unless explicitly asked.
- Never modify secrets, credentials, or `.env` files.
- Do not modify generated files unless explicitly instructed.

## Communication

- Be concise. Reference files with clear paths.
- Explain non-obvious reasoning briefly.
