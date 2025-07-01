# Changelog

---

## [1.1.0] - 2025-06-28

### Added

- Support for inline comments in `--add`.
- `--list` command to display all managed domains in a formatted table.
- Output for table headers using ANSI codes.

### Changed

- Refactored argument parsing using `get_ip` and `get_comment`
- Improved formatting and help message output

### Removed

- none

---

## [1.0.1] - 2025-06-19

### Added

- `msg()` message system and `msg/messages.json`
- Domain validation with specific error message

### Changed

- Replaced static messages with `msg()` calls

### Removed

- Hardcoded error strings

---

## [1.0.0] - 2025-06-15

### Added

- Initial stable release of winhostcli.
- `--add` command: add domain entries to a safe, dedicated section in the Windows `hosts` file.
- `--remove` command: remove domains previously added by the CLI.
- Support for `.env` file with configurable `DEFAULT_IP_ADDRESS`.
- Safe file operations using temporary files to prevent data loss.
- Modular architecture with a split between CLI entry (`bin/winhost`) and core logic (`lib/functions`).
- User-friendly CLI output with emojis for clarity and better UX.
- Compatibility with WSL and Laravel Valet development environments.
- Designed to only manage entries inside its own section — never touches unrelated lines.

### Changed

- N/A

### Removed

- N/A

---

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),  
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
