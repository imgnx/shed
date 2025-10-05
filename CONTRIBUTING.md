# Contributing

Thanks for your interest in improving shed! This repo is intentionally small and friendly to contributions.

## Development
- Requirements: bash, GNU coreutils, optional `shellcheck` for linting.
- Run tests: `make test`
- Lint (optional): `make lint`
- Install locally: `make install` (may require sudo depending on `PREFIX`).

## Tests
Tests are simple shell scripts in `tests/`. The runner `tests/run.sh` finds and runs `test_*.sh`.

- Add new tests as `tests/test_<name>.sh`.
- Keep tests POSIX/bash-compatible and fast.
- Prefer testing flags/usage, exit codes, and mode parsing over platform-specific side effects.

## Versioning
Update the version string in `bin/shed` when making user-visible changes and add a changelog entry in `CHANGELOG.md`.

## Code style
- Use `set -euo pipefail` and defensive checks.
- Prefer small, composable functions in shell.
- Keep platform-specific logic isolated where possible.

## CI
GitHub Actions runs lint and tests on macOS and Ubuntu on push/PR.

## License
By contributing, you agree that your contributions are licensed under the MIT License.

