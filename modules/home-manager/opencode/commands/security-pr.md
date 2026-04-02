---
description: Security-focused review of a GitHub PR
agent: security
---
# Security PR Review Command

Perform a security-focused review of a GitHub pull request, produce structured comments, and optionally post them after approval.

## Workflow

1. **Load the PR review skill**:
   - Use the `skill` tool to load `pr-review` before generating findings.

2. **Identify the PR**:
   - If `$ARGUMENTS` is empty, ask the user for a PR URL or number.
   - Otherwise, use `$ARGUMENTS` as the PR selector.

3. **Fetch PR context** (use `gh`):
   - `gh pr view $ARGUMENTS --json number,title,body,author,baseRefName,headRefName,headRefOid,files,repo`
   - `gh pr diff $ARGUMENTS`

4. **Security review focus**:
   - Input validation, injection risks (SQL, command, template)
   - Authentication/authorization bypasses
   - Sensitive data exposure/logging
   - Dependency and config risks
   - Broken access control, SSRF, path traversal, deserialization

5. **Approval step before posting**:
   - Show the structured review output.
   - Ask the user to approve or reject posting to GitHub.

6. **Post to GitHub only if approved**:
   - For each line-level finding, post a comment:
     - `gh api repos/{owner}/{repo}/pulls/{number}/comments \
        --field path=<file> \
        --field line=<line> \
        --field side=RIGHT \
        --field commit_id=<headRefOid> \
        --field body="<comment>"`
   - Post the overall summary as a review comment:
     - `gh pr review $ARGUMENTS --comment --body "<summary markdown>"`
   - If any posting fails, stop and report the error.

## Arguments

- `$ARGUMENTS` - PR URL, branch, or number accepted by `gh pr view`

## Example Usage

```
/security-pr 123
/security-pr https://github.com/org/repo/pull/123
```
