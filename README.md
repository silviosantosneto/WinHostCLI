# WinHostCLI

**WinHostCLI** is a command-line tool designed to simplify the management of domain entries in the Windows `hosts`
file — specifically for developers working within a WSL2 (Windows Subsystem for Linux) environment.

It enables you to safely add, remove, and list custom domain mappings (such as `myproject.test`) without needing
PowerShell, administrative privileges, or manual file edits. All changes are made within a dedicated block of the
`hosts` file, ensuring that system or user-defined entries remain untouched.

Whether you're working with Laravel Valet or managing multiple local environments, WinHostCLI helps keep your
development workflow consistent, clean, and efficient — directly from the WSL terminal.

## Quick installation

```bash
git clone https://github.com/silviosantosneto/WinHostCLI.git
chmod +x WinHostCLI/bin/winhost
echo 'export PATH="$PATH:/path/to/WinHostCLI/bin"' >> ~/.bashrc # or .zshrc
source ~/.bashrc # or .zshrc
```

## Usage

### Help:

```bash
$ winhost -h
$ winhost --help
````

### Add a domain:

```bash
$ winhost -a myproject.domain
$ winhost --add myproject.domain
```

### Add a domain with a custom IP:

```bash
$ winhost --add myproject.domain 192.168.0.1
````

### Add with comment:

```bash
$ winhost --add myproject.domain "Localhost dev"
$ winhost --add myproject.domain 192.168.0.1 "Staging env"
$ winhost --add myproject.domain "Backend service" 192.168.0.20
```

### Remove a domain:

```bash
$ winhost -r myproject.domain
$ winhost --remove myproject.domain
```

### List all managed domains:

```bash
$ winhost --list
```

## Contributing

Got an idea? Found a bug?

1. Open an issue or discussion first.
2. Fork the project and create a feature branch.
3. Submit a pull request to `develop`.
4. If it's solid, it'll be reviewed and merged into the next release.
