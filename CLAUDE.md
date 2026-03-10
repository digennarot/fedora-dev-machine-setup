# CLAUDE.md — AI Assistant Guide for fedora-dev-machine-setup

## Project Overview

This repository is an **Ansible automation project** that sets up a complete Fedora development environment from a clean OS install. It configures system tools, development languages, terminal customizations, editors, and productivity applications in a single, idempotent run.

- **Target OS:** Fedora 41+ (modern; originally written for Fedora 34)
- **Execution model:** Local-only (no SSH; runs on the machine being configured)
- **Estimated runtime:** 15 minutes to 1 hour depending on internet speed
- **Inspired by:** [ubuntu-dev-machine-setup](https://github.com/fazlearefin/ubuntu-dev-machine-setup)

---

## Repository Structure

```
fedora-dev-machine-setup/
├── ansible.cfg                        # Ansible configuration (local connection)
├── hosts                              # Inventory: localhost only
├── main.yml                           # Master playbook (imports all roles in order)
├── base.yml                           # Standalone: base role only
├── hashicorp.yml                      # Standalone: HashiCorp tools only
├── terminal_customizations.yml        # Standalone: terminal/font setup only
├── vim.yml                            # Standalone: Vim setup only
├── zsh.yml                            # Standalone: Zsh setup only
├── googlechrome.yml                   # Standalone: Chromium only
├── vscode.yml                         # Standalone: VS Code only
├── post_install.yml                   # Standalone: post-install reminders only
├── group_vars/all/                    # Variable definitions (one file per role)
│   ├── all.yml                        # Global vars: laptop_mode, local_username
│   ├── base.yml                       # Package lists for base role
│   ├── googlechrome.yml               # (no config needed; Chromium from Fedora repos)
│   ├── hashicorp.yml                  # HashiCorp product definitions and URLs
│   ├── privacy.yml                    # Privacy tool packages
│   ├── security.yml                   # Security packages
│   ├── terminal_customizations.yml    # Nerd Fonts version + font list
│   ├── vscode.yml                     # VS Code extension IDs
│   ├── vim.yml                        # Vim packages and plugin URLs
│   └── zsh.yml                        # Zsh plugin and theme URLs
└── roles/
    ├── base/
    │   ├── files/etc/systemd/system/fstrim.timer.d/override.conf
    │   └── tasks/main.yml
    ├── googlechrome/tasks/main.yml
    ├── hashicorp/tasks/main.yml
    ├── terminal_customizations/
    │   ├── files/.tmux.conf
    │   ├── files/tilix.dconf
    │   └── tasks/main.yml
    ├── vim/
    │   ├── files/my_configs.vim
    │   └── tasks/main.yml
    ├── vscode/tasks/main.yml
    └── zsh/
        ├── files/.zshrc
        └── tasks/main.yml
```

---

## Running the Playbooks

### Prerequisites

```bash
sudo dnf install ansible git -y
git clone git@github.com:digennarot/fedora-dev-machine-setup.git
cd fedora-dev-machine-setup
```

### Full setup (recommended)

```bash
ansible-playbook main.yml -vv \
  -e "local_username=$(id -un)" \
  -K
```

For a laptop, add `-e "laptop_mode=True"` to enable TLP power management.

### Run a single role

```bash
ansible-playbook zsh.yml -vv -e "local_username=$(id -un)" -K
```

### Key flags

| Flag | Purpose |
|------|---------|
| `-vv` | Verbose output (recommended for visibility) |
| `-e "laptop_mode=True"` | Enables TLP power management (laptops only) |
| `-e "local_username=$(id -un)"` | Passes current user to playbook |
| `-K` | Prompts for sudo/BECOME password |

> **Important:** Run as a regular user, NOT root. The playbook uses `become: yes` internally for tasks that need elevated privileges.

---

## Ansible Conventions

### Module usage

- Always use **fully qualified collection names (FQCN)**: `ansible.builtin.dnf`, `ansible.builtin.git`, `ansible.builtin.file`, `community.general.dconf`
- Use `ansible.builtin.dnf` (not `yum`) for all package management
- Use `ansible.builtin.rpm_key` (not `command: rpm --import`) for GPG key imports
- Use `ansible.builtin.get_url` to download repo files (idempotent, no shell required)
- Use `ansible.builtin.copy` with `content:` to write repo config files (idempotent)
- Use `ansible.builtin.unarchive` with `remote_src: yes` for downloading and extracting archives

### Task naming

- Task names start with a lowercase action verb and are descriptive
- Example: `"install archiving tools"`, `"clone antigen repository"`, `"set zsh as default shell"`

### Variable naming

- Variables are **prefixed by their role name**: `base_archiving_tools`, `zsh_antigen_url`, `hashicorp_products`
- Internal/computed variables use a **leading underscore**: `_hashicorp_repository_url`
- Boolean flags in the global scope use `snake_case`: `laptop_mode`, `night_light_enabled`

### Loops

- Use `loop:` (not the deprecated `with_items:`) for all iteration

### Privilege escalation

- Use `become: yes` with `become_user: "{{ local_username }}"` for tasks that should run as the target user
- Use `become: yes` (no `become_user`) for tasks requiring root

### Variable organization

- **Global variables** (`group_vars/all/all.yml`): `laptop_mode`, `local_username`
- **Role variables** (`group_vars/all/{role_name}.yml`): All role-specific config, package lists, URLs
- Package lists are YAML arrays of strings
- Conditional values use Jinja2 ternary expressions

### File placement

- Static config files belong in `roles/{role}/files/`
- They are deployed with `ansible.builtin.copy`
- Original files are backed up with a `.orig` suffix before replacement

### Idempotency

All tasks must be idempotent — running the playbook multiple times must not break anything. Prefer Ansible's built-in idempotent modules over shell/command when possible. Add `changed_when: false` to `command` tasks that are always safe to re-run (e.g., installing VS Code extensions).

### Error handling

- Use `ignore_errors: yes` sparingly and only when a failure is expected and non-critical (e.g., `dconf load` requires a live GNOME session)
- Group related tasks using `block:` constructs
- Wrap file permission modes in quotes: `mode: '0644'` not `mode: 0644`

---

## Adding New Packages or Tools

1. **Simple dnf package:** Add the Fedora package name to the appropriate list in `group_vars/all/{role}.yml`
2. **pip package:** Add to `base_developer_tools_pip3` in `group_vars/all/base.yml`
3. **New role:** Create `roles/{name}/tasks/main.yml`, add variables to `group_vars/all/{name}.yml`, and add `import_playbook` in `main.yml`
4. **New config file:** Place it in `roles/{role}/files/`, deploy with `ansible.builtin.copy` in the role task

---

## What Gets Installed (Role Summary)

| Role | Key software |
|------|-------------|
| `base` | Git, Python 3, Ruby, Go (`golang`), Node.js, Docker CE, AWS CLI, jq, fzf, eza, ranger, httpie, tmux, yt-dlp, and many CLI utilities; also installs privacy/security packages |
| `hashicorp` | Consul, Packer, Terraform, Vault (Nomad/Vagrant optional via variables) |
| `terminal_customizations` | Nerd Fonts v3 (zip archives), Tilix terminal, tmux config, tilix dconf settings |
| `vim` | Vim + vim-enhanced, amix/vimrc distribution + indentLine plugin, custom `my_configs.vim` |
| `zsh` | Zsh + Antigen + Oh-My-Zsh plugins + Bullet Train / p10k / Pure themes |
| `googlechrome` | Chromium (from Fedora dnf repos; no extra repo needed) |
| `vscode` | VS Code (Microsoft repo, rpm_key + copy-based setup) + 20+ curated extensions |
| `post_install` | Prints a manual steps reminder (no system changes) |

---

## Global Variables Reference

Defined in `group_vars/all/all.yml`:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `laptop_mode` | bool | `False` | Install TLP and laptop power tools when `True` |
| `local_username` | string | `$USER` env var | The target user's login name; override with `-e "local_username=$(id -un)"` |

---

## Package Name Notes (Fedora 41+)

These package names differ from older Fedora or Ubuntu equivalents:

| Use this | Not this | Reason |
|----------|----------|--------|
| `golang` | `golang-go` | Correct Fedora package name |
| `eza` | `exa` | `exa` is abandoned; `eza` is the maintained fork |
| `yt-dlp` | `youtube-dl` | `youtube-dl` is abandoned; `yt-dlp` is the maintained fork |
| `java-21-openjdk` | `java-11-openjdk` | Java 21 is the current LTS in Fedora 41+ |
| `python3-ipython` | `ipython3` | Correct Fedora package name |
| `python3-csvkit` | `python-csvkit` | Python 2 name; use python3 variant |
| `docker compose` (plugin) | `docker-compose` | v1 docker-compose is deprecated; use `docker-compose-plugin` and `docker compose` |

---

## Known Conventions and Gotchas

- `local_username` defaults to `$USER` from the environment; always pass explicitly with `-e "local_username=$(id -un)"` to be safe.
- The playbook installs to the **running user's home directory** for user-level config (`.zshrc`, `.tmux.conf`, vim configs). Do not run as root.
- `dconf load` tasks may fail in headless/CI environments — these are suppressed with `ignore_errors: yes`.
- The `post_install` role only prints instructions; it makes no system changes.
- Nerd Fonts are downloaded as **zip archives from GitHub releases** (v3.x) and extracted to `~/.local/share/fonts`. The version is pinned in `terminal_customizations_nerd_fonts_version`.
- The `.zshrc`, `.tmux.conf`, and `my_configs.vim` files are **overwritten** on each run (originals backed up as `.orig`). Edit source files in `roles/*/files/` for persistent changes.
- The tmux powerline integration (`/usr/share/powerline/bindings/tmux/powerline.conf`) is sourced conditionally — tmux will not error if powerline is not installed.
- fzf shell integration uses `/usr/share/fzf/shell/` (Fedora path), not `/usr/share/doc/fzf/examples/` (Debian/Ubuntu path).

---

## Customization

To persist customizations across re-runs, edit the source files in `roles/*/files/` rather than editing the deployed files in your home directory (which get overwritten).

To skip a role entirely, comment out its `import_playbook` line in `main.yml`.

To change Nerd Fonts version, update `terminal_customizations_nerd_fonts_version` in `group_vars/all/terminal_customizations.yml`.

To change the set of VS Code extensions, edit the `vscode_extensions` list in `group_vars/all/vscode.yml`.
