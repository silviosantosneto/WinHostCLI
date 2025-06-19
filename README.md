<p align="center">
  <img src="https://lh3.googleusercontent.com/d/17pK2krk6QIRGQTEQHd9sSnuB2EygfOrZ" alt="Logo" width="300"/>
<p align="center">
  <a href="https://github.com/silviosantosneto/winhostcli/releases">
    <img alt="Version" src="https://img.shields.io/github/v/release/silviosantosneto/winhostcli" >
  </a>
  <a href="https://github.com/silviosantosneto/winhostcli/blob/main/LICENSE">
    <img alt="GitHub License" src="https://img.shields.io/github/license/silviosantosneto/winhostcli">
  </a>
  <a href="https://www.gnu.org/software/bash/">
    <img src="https://img.shields.io/badge/Shell-bash-informational" alt="Shell">
  </a>
</p>

---

## Why winhostcli?

I built **winhostcli** because I got tired of editing the Windows `hosts` file every time I needed a custom domain like `myproject.test` while working inside WSL. Using `localhost` just didn't cut it for local development.

This tool saves time, prevents mistakes, and keeps your system clean. If you're using Laravel Valet on WSL or just want an easier way to manage your dev domains, this might be exactly what you need.

## What it does

- Adds domains to the `hosts` file using a *dedicated and safe section*.
- Removes entries it previously added.
- Defaults to `127.0.0.1`, but supports custom IPs via `.env`.
- Never touches lines outside its block.
- Plays nice with aliases and scripts.
- Designed to integrate smoothly with Laravel Valet on WSL.

### Example output
```bash
# Block added to hosts:
# =========== Start winhostcli generated Hosts. Do not change. ============
127.0.0.1               myproject.test
# ================== End winhostcli end generated Hosts. ==================
```

## Quick installation

```bash
git clone https://github.com/silviosantosneto/winhostcli.git
chmod +x winhostcli/bin/winhost
echo 'export PATH="$PATH:/path/to/winhostcli/bin"' >> ~/.bashrc # or .zshrc
source ~/.bashrc # or .zshrc
```

## Usage

```bash
# --------------------------- Help ----------------------------
winhost -h
winhost --help

# ------------------------ Add a domain ------------------------
winhost -a myproject.test
winhost --add myproject.test

# ---- Add a domain with a custom IP (from .env or manually) ----
winhost --add myproject.test 192.168.0.1

# ----------------------- Remove a domain -----------------------
winhost -r myproject.test
winhost --remove myproject.test
```

### Sample session
```bash
$ winhost --add myproject.test
✔️ Domain myproject.test added

$ winhost --add myproject.test 192.168.0.1
✔️ Domain myproject.test pointing to 192.168.0.1 added

$ winhost --remove myproject.test
✔️ Domain myproject.test removed
```

> winhostcli only touches what it creates. Your custom `hosts` entries are safe.

## Under the hood

- Core logic lives in `lib/functions`, modular and clean.
- Uses a `.env` file to set the default IP.
- Manipulates `hosts` using temporary files for safety.
- Bash and zsh compatible.
- Inspired by Laravel Valet & Homestead, but works independently.

## Contributing

Got an idea? Found a bug?

1. Open an issue or discussion first.
2. Fork the project and create a feature branch.
3. Submit a pull request to `develop`.
4. If it's solid, it'll be reviewed and merged into the next release.

---

**MIT License** – Free to use, modify, and distribute. Just don’t blame me if your toaster tries to run this. 😉

Thanks for checking it out — and may your `hosts` file stay clean and your domains always resolve. 🙌
