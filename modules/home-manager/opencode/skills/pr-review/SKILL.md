---
name: pr-review
description: Structured PR review output for GitHub posting
---
# PR Review Skill

Structured output format for pull request reviews that can be posted to GitHub.

## When to Use

Load this skill when:
- Reviewing a pull request for posting comments to GitHub
- You need line-level feedback in a structured format
- Using `/review-pr` or `/security-pr` commands

## Output Format

### Line-Level Findings

Use fenced code blocks with `review` language for each finding:

```review
file: src/main/java/com/example/UserService.java
line: 42
severity: MAJOR
comment: |
  This method catches `Exception` which is too broad. Consider catching specific exceptions
  like `SQLException` or `IOException` to avoid swallowing unexpected errors.
  
  ```java
  // Instead of:
  catch (Exception e) { ... }
  
  // Use:
  catch (SQLException | IOException e) { ... }
  ```
```

### Severity Levels

- **CRITICAL**: Security vulnerabilities, data loss risks, breaking bugs - must fix before merge
- **MAJOR**: Bugs, significant design issues, performance problems - should fix before merge
- **MINOR**: Code quality issues, missing tests, style inconsistencies - nice to fix
- **SUGGESTION**: Optional improvements, alternative approaches - for consideration

### General Observations

After line-level findings, include a summary section:

```markdown
## Summary

**Overall Assessment**: [APPROVE | REQUEST_CHANGES | COMMENT]

### What's Good
- List positive aspects of the PR
- Acknowledge good patterns and decisions

### Cross-Cutting Concerns
- Issues that span multiple files
- Architectural observations
- Testing coverage gaps

### Recommendations
- Prioritized list of suggested improvements
```

## Formatting Guidelines

1. **Be specific**: Reference exact file paths and line numbers
2. **Be constructive**: Explain why something is an issue and how to fix it
3. **Use code examples**: Show the suggested fix when possible
4. **Prioritize**: List CRITICAL and MAJOR issues first
5. **Be concise**: Keep comments focused and actionable

## Example Complete Review

```review
file: src/main/java/com/example/AuthController.java
line: 28
severity: CRITICAL
comment: |
  SQL injection vulnerability. User input is concatenated directly into the query.
  
  Use parameterized queries instead:
  ```java
  PreparedStatement stmt = conn.prepareStatement("SELECT * FROM users WHERE id = ?");
  stmt.setString(1, userId);
  ```
```

```review
file: src/main/java/com/example/AuthController.java
line: 45
severity: MAJOR
comment: |
  Password is logged in plain text. Remove this log statement or mask the sensitive data.
```

```review
file: src/test/java/com/example/AuthControllerTest.java
line: 12
severity: MINOR
comment: |
  Test method name doesn't follow naming convention. Consider:
  `shouldReturnUnauthorizedWhenTokenExpired()` instead of `test1()`
```

## Summary

**Overall Assessment**: REQUEST_CHANGES

### What's Good
- Clean separation of concerns between controller and service layers
- Good use of dependency injection

### Cross-Cutting Concerns
- No input validation on any endpoint
- Missing error handling for database connection failures

### Recommendations
1. Fix the SQL injection vulnerability (CRITICAL)
2. Remove password logging (MAJOR)
3. Add input validation middleware
4. Improve test naming conventions
