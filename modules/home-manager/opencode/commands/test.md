---
description: Run tests and analyze failures
agent: tester
---
# Test Command

Run the project's test suite and analyze results.

## Workflow

1. **Detect test framework** by examining build files:
   - `pom.xml` → Maven: `mvn test` or `mvn verify`
   - `build.gradle` / `build.gradle.kts` → Gradle: `./gradlew test`
   - `package.json` → npm/yarn: check scripts for `test`, `test:unit`, `test:e2e`
   - `angular.json` → Angular: `ng test --watch=false --browsers=ChromeHeadless`

2. **Run tests** using the detected command

3. **Analyze results**:
   - Parse test output for failures
   - For each failing test, identify the root cause
   - Suggest specific fixes with code examples

4. **Offer to fix** failing tests if the cause is clear

## Arguments

- `$ARGUMENTS` - Optional: specific test file, class, or pattern to run
  - Java: `-Dtest=MyTestClass` or `-Dtest=MyTestClass#testMethod`
  - Angular/Jest: `--testPathPattern=my.spec.ts`
  - If empty, run all tests

## Example Usage

```
/test
/test UserServiceTest
/test --coverage
```
