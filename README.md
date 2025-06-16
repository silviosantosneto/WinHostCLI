<p align="center">
  <img src="https://lh3.googleusercontent.com/d//1NT9rOH2gatgjWsCT4wFsdCIbuwdzNlXt" alt="Logo" width="300"/>
</p>
<p align="center">
  <a href="https://github.com/silviosantosneto/winhostctl/releases">
    <img src="https://img.shields.io/github/v/release/silviosantosneto/winhostctl?style=for-the-badge" alt="Version">
  </a>
  <a href="https://github.com/silviosantosneto/winhostctl/blob/develop/LICENSE">
    <img src="https://img.shields.io/github/license/silviosantosneto/winhostctl?style=for-the-badge" alt="License">
  </a>
  <a href="https://www.gnu.org/software/bash/">
    <img src="https://img.shields.io/badge/Shell-bash-informational?style=for-the-badge&logo=gnu-bash" alt="Shell">
  </a>
</p>


Hi! 👋  
This is `winhostctl`, a little tool I built out of sheer frustration with manually editing the Windows `hosts` file from WSL. If you've been there, you know the pain.

At some point, I got tired of opening `nano /mnt/c/Windows/System32/drivers/etc/hosts` every time I wanted to test a local domain. I wanted a simple CLI that *just worked*, respected the file, and didn’t mess with unrelated lines. So… I made one.

## 🚀 Version 1.0.0

After a few iterations and a lot of terminal testing, I'm happy to finally release **v1.0.0**:  
👉 https://github.com/silviosantosneto/winhostctl/releases/tag/v1.0.0

It's stable, predictable, and (I think) does one thing really well.

## ✅ What it actually does

- Adds domains to the `hosts` file using a *dedicated section* it can safely manage.
- Removes entries it previously added.
- Defaults to `127.0.0.1`, but you can configure the IP via `.env`.
- Doesn’t touch anything outside its section, ever.
- Works great with Laravel Valet on WSL (which is part of why I built it).
- Plays nice with aliases and is safe to script around.

You end up with a section like this:

```
# =========== Start winhostctl generated Hosts. Do not change. ============
127.0.0.1           myproject.test
# ================== End winhostctl end generated Hosts. ==================
```

## 🧩 How to install (the quick version)

```bash
git clone https://github.com/silviosantosneto/winhostctl.git
chmod +x winhostctl/bin/winhost
echo 'export PATH="$PATH:/path/to/winhostctl/bin"' >> ~/.bashrc   # or .zshrc
source ~/.bashrc    # or .zshrc
```

## ⚙️ How I use it

```bash
# See the built-in help
winhostctl --help

# Add a domain
winhostctl add mysite.test

# Add a domain with a custom IP
winhostctl add mysite.test 192.168.0.1

# Remove it later
winhostctl remove mysite.test
```

## 💡 Example

```bash
$ winhost mysite.test
✔️ Domain mysite.test added

$ winhost mysite.test 192.168.0.1
✔️ Domain mysite.test pointing to 192.168.0.1 added

$ winhostctl remove mysite.test
✔️ Domain mysite.test removed
```

> ⚠️ I made it so the script only touches the block it owns. Your other `hosts` entries are safe.

## 🎯 Why I built this

Honestly? I just didn’t want to install another tool or mess with PowerShell or Admin permissions every time I wanted to test a `.test` domain.  
This script works from WSL and handles the `hosts` file with care. It’s tiny, fast, and you can tweak it if you want.

## 🛠 Under the hood

- The logic lives in `lib/functions`, separate from the CLI wrapper.
- The IP is configurable in '.env' (defaults to `127.0.0.1`).
- It uses temp files for safety.
- Compatible with bash and zsh.
- Inspired by Laravel Valet and Homestead, but not tied to them.

## 🤝 Want to help?

1. Open an issue or idea first.
2. Fork the repo and create a feature branch.
3. Send a PR to `develop`.
4. If it’s solid, I’ll merge it into the next version.

---

**MIT License** – do whatever you want, just don’t blame me if your computer catches fire.  
(But seriously, it should be fine. I use this every day.)

Thanks for reading — hope it helps! 🙌

— Silvio Santos Neto
