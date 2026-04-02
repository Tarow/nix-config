---
description: Create a conventional commit with review
---
# Commit Command

Create a conventional commit with review and confirmation.

## Workflow

1. **Review changes**:
   ```bash
   git status
   git diff --cached  # staged changes
   git diff           # unstaged changes
   ```

2. **Analyze the changes** and determine:
   - Type: `feat`, `fix`, `refactor`, `test`, `docs`, `style`, `chore`, `perf`, `ci`, `build`
   - Scope: affected module, component, or area (optional but recommended)
   - Description: concise summary of what changed and why

3. **Generate commit message** in conventional format:
   ```
   type(scope): description

   [optional body with more details]

   [optional footer: BREAKING CHANGE, Closes #123, etc.]
   ```

4. **Show the proposed commit**:
   - Display the generated message
   - Show summary of files to be committed
   - Ask for confirmation before proceeding

5. **Stage and commit**:
   - If unstaged changes exist, ask which to include
   - Create the commit with the approved message

6. **Optionally push** if requested via arguments

## Arguments

- `$ARGUMENTS` - Optional flags:
  - `--push` or `-p`: Push to remote after committing
  - `--all` or `-a`: Stage all changes before committing
  - Custom message override (if provided, skip generation)

## Commit Message Guidelines

- Use imperative mood: "add feature" not "added feature"
- First line ≤ 72 characters
- Reference issues when applicable: `Closes #123`
- Mark breaking changes: `BREAKING CHANGE: description`

## Example Usage

```
/commit
/commit --push
/commit -a -p
/commit fix: correct null pointer in UserService
```
