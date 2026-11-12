# Contributing to CIRCULUS

Thank you for contributing to CIRCULUS. As an exclusive platform for senior officers and academic faculty, integrity, security, and performance are top priorities.

## Code Standards
- **Python**: Follow PEP 8 guidelines. Type hints are mandatory. Use Pydantic v2 schemas for all payload validations.
- **Dart/Flutter**: Follow official Flutter style conventions. All business logic in providers/services; UI widgets remain declarative and clean.
- **SQL**: Write idempotent migrations using snake_case table and column identifiers. Always enable Row Level Security (RLS) on newly introduced tables.

## Pull Request Checklist
1. Ensure all tests in `backend/tests/` pass with zero regressions.
2. Confirm no credentials, secret tokens, or personal identifiers are committed.
3. Validate that game score submission endpoints strictly verify logic on the server.
