<p align="center">
  <img src="https://lh3.googleusercontent.com/d/1LKv9ZI8SF0bHln5M_AxhJxYUYcY01PBN" alt="Logo" width="300"/>
</p>
<p align="center">
  <a href="https://github.com/silviosantosneto/winhostctl/releases">
    <img src="https://img.shields.io/github/v/release/silviosantosneto/winhostctl" alt="Version">
  </a>
  <a href="https://github.com/silviosantosneto/winhostctl/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/silviosantosneto/winhostctl" alt="License">

  </a>
  <a href="https://www.gnu.org/software/bash/">
    <img src="https://img.shields.io/badge/Shell-bash-informational" alt="Shell">
  </a>
</p>


Hi! 👋  
I built winhostctl because I really don’t like using localhost as a domain when working with Valet on WSL. I wanted to use custom domains like myproject.test, but doing that on Ubuntu inside WSL meant editing the Windows hosts file manually — and that gets old fast.

So, I wrote a script that handles it for me. Clean, safe, and zero hassle.If you're also tired of jumping through hoops just to map a local domain, this tool might save you a few headaches.


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
127.0.0.1               myproject.test
# ================== End winhostctl end generated Hosts. ==================
```

## 🧩 How to install (the quick version)

```bash
git clone https://github.com/silviosantosneto/winhostctl.git
chmod +x winhostctl/bin/winhost
echo 'export PATH="$PATH:/path/to/winhostctl/bin"' >> ~/.bashrc # or .zshrc
source ~/.bashrc # or .zshrc
```

## ⚙️ How I use it

```bash
# --------------------------- Help ----------------------------
# See the built-in help
winhost -h
# See the long help
winhost --help

# ------------------------ Add a domain ------------------------
# Add a domain
winhost -a myproject.test
# Using the long form
winhost --add myproject.test

# --------------- Add a domain with a custom IP ----------------
winhost -a myproject.test 192.168.0.1
# Using the long form
winhost --add myproject.test 192.168.0.1

# ----------------------- Remove a domain -----------------------
# Remove a domain
winhost -r myproject.test
# Using the long form
winhost --remove myproject.test
```

## 💡 Example

```bash
$ winhost --add myproject.test
✔️ Domain myproject.test added

$ winhost --add myproject.test 192.168.0.1
✔️ Domain myproject.test pointing to 192.168.0.1 added

$ winhost --remove myproject.test
✔️ Domain myproject.test removed
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
**MIT License** – feel free to use, clone, and remix — just don’t blame me if Windows claps back with a blue screen and your fan starts screaming.
Works fine here… so far. 🤞

Thanks for stopping by — may your hosts stay clean and your terminals crash-free! 🙌
