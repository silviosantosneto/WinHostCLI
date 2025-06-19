# Changelog

---

## [1.0.1] - 2025-06-19

### Added

- `msg()` function to standardize error and info message output using `msg/messages.json`.
- New error message key `MISSING_ARGUMENT` in `msg/messages.json`, used when the domain is missing in `--add`.
- Argument validation logic inside `addhost()` to ensure domain is provided before proceeding.

### Changed

- Replaced hardcoded error messages with dynamic calls to `msg()`.
- Improved CLI user feedback by making error messages more accurate and contextual.

### Removed

- Outdated or hardcoded error strings related to domain input.

---

## [1.0.0] - 2025-06-15

### Added

- Initial stable release of `winhostcli`.
- `add` command: add domain entries to the managed section of the Windows `hosts` file.
- `remove` command: remove domain entries from the managed section.
- Environment support via `.env`, including `DEFAULT_IP` fallback.
- Safe file editing using temp files and validation before overwriting `hosts`.
- Modular structure: `bin/winhost` (CLI) and `lib/functions` (core logic).
- Output formatting and log messages with emojis for clarity.
- Fully working on WSL, with support for Laravel-Valet like workflows.

### Changed

- N/A

### Removed

- N/A

---

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
