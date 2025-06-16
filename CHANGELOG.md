# Changelog

---

## [1.0.0] - 2025-06-15

### Added

- Initial stable release of `winhostctl`.
- `add` command: add domain entries to the managed section of the Windows `hosts` file.
- `remove` command: remove domain entries from the managed section.
- Environment support via `.env`, including `DEFAULT_IP` fallback.
- Safe file editing using temp files and validation before overwriting `hosts`.
- Modular structure: `bin/winhostctl` (CLI) and `lib/functions` (core logic).
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
