---
description: Review a GitHub PR and optionally post comments
agent: reviewer
---
# Review PR Command

Review a GitHub pull request, produce structured comments, and optionally post them to GitHub after approval.

## Workflow

1. **Load the PR review skill**:
   - Use the `skill` tool to load `pr-review` before generating findings.

2. **Identify the PR**:
   - If `$ARGUMENTS` is empty, ask the user for a PR URL or number.
   - Otherwise, use `$ARGUMENTS` as the PR selector.

3. **Fetch PR context** (use `gh`):
   - `gh pr view $ARGUMENTS --json number,title,body,author,baseRefName,headRefName,headRefOid,files,repo`
   - `gh pr diff $ARGUMENTS`

4. **Review the changes**:
   - Use the `pr-review` skill output format.
   - Provide line-level findings in `review` blocks and a summary section.

5. **Approval step before posting**:
   - Show the full structured review output.
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
/review-pr 123
/review-pr https://github.com/org/repo/pull/123
```
