# CLAUDE.md — AI Assistant Guide for fedora-dev-machine-setup

## Project Overview

This repository is an **Ansible automation project** that sets up a complete Fedora development environment from a clean OS install. It configures system tools, development languages, terminal customizations, editors, and productivity applications in a single, idempotent run.

- **Target OS:** Fedora 30+ (tested on Fedora 34)
- **Execution model:** Local-only (no SSH; runs on the machine being configured)
- **Estimated runtime:** 15 minutes to 1 hour depending on internet speed
- **Inspired by:** [ubuntu-dev-machine-setup](https://github.com/fazlearefin/ubuntu-dev-machine-setup)

---

## Repository Structure

```
fedora-dev-machine-setup/
├── ansible.cfg                        # Ansible configuration (local transport)
├── hosts                              # Inventory: localhost only
├── main.yml                           # Master playbook (imports all roles in order)
├── base.yml                           # Standalone: base role only
├── hashicorp.yml                      # Standalone: HashiCorp tools only
├── terminal_customizations.yml        # Standalone: terminal/font setup only
├── vim.yml                            # Standalone: Vim setup only
├── zsh.yml                            # Standalone: Zsh setup only
├── googlechrome.yml                   # Standalone: Chrome/Chromium only
├── vscode.yml                         # Standalone: VS Code only
├── post_install.yml                   # Standalone: post-install reminders only
├── group_vars/all/                    # Variable definitions (one file per role)
│   ├── all.yml                        # Global vars: laptop_mode, local_username
│   ├── base.yml                       # Packages lists for base role
│   ├── googlechrome.yml               # Chrome repo URL
│   ├── hashicorp.yml                  # HashiCorp product definitions and URLs
│   ├── privacy.yml                    # Privacy tool packages
│   ├── security.yml                   # Security packages
│   ├── terminal_customizations.yml    # Nerd Fonts download URLs
│   ├── vscode.yml                     # VS Code extension IDs
│   ├── vim.yml                        # Vim plugin/config URLs
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
  -e "{ laptop_mode: True }" \
  -e "local_username=$(id -un)" \
  -K
```

### Run a single role

```bash
ansible-playbook zsh.yml -vv -e "local_username=$(id -un)" -K
```

### Key flags

| Flag | Purpose |
|------|---------|
| `-vv` | Verbose output (recommended for visibility) |
| `-e "laptop_mode: True"` | Enables TLP power management (laptops only) |
| `-e "local_username=$(id -un)"` | Passes current user to playbook (required) |
| `-K` | Prompts for sudo/BECOME password |

> **Important:** Run as a regular user, NOT root. The playbook uses `become: yes` internally for tasks that need elevated privileges.

---

## Ansible Conventions

### Module usage

- Always use **fully qualified collection names (FQCN)**: `ansible.builtin.dnf`, `ansible.builtin.git`, `ansible.builtin.file`, `community.general.dconf`
- Use `ansible.builtin.dnf` (not `yum`) for all package management

### Task naming

- Task names start with a lowercase action verb and are descriptive
- Example: `"install archiving tools"`, `"clone antigen repository"`, `"set zsh as default shell"`

### Variable naming

- Variables are **prefixed by their role name**: `base_archiving_tools`, `zsh_antigen_url`, `hashicorp_products`
- Internal/computed variables use a **leading underscore**: `_hashicorp_repository_url`
- Boolean flags in the global scope use `snake_case`: `laptop_mode`, `night_light_enabled`

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

All tasks must be idempotent — running the playbook multiple times must not break anything. Prefer Ansible's built-in idempotent modules over shell commands where possible.

### Error handling

- Use `ignore_errors: yes` sparingly and only when a failure is expected and non-critical (e.g., dconf settings that require a live GNOME session)
- Group related tasks using `block:` constructs

---

## Adding New Packages or Tools

1. **Simple package install:** Add the package name to the appropriate list in `group_vars/all/{role}.yml`
2. **New role:** Create `roles/{name}/tasks/main.yml`, add variables to `group_vars/all/{name}.yml`, and import in `main.yml`
3. **New config file:** Place it in `roles/{role}/files/`, deploy it with `ansible.builtin.copy` in the role's task file

---

## What Gets Installed (Role Summary)

| Role | Key software |
|------|-------------|
| `base` | Git, Python 3, Ruby, Go, Node.js, Docker, AWS CLI, jq, fzf, ranger, httpie, tmux, and many CLI utilities |
| `hashicorp` | Consul, Packer, Terraform, Vault (Nomad/Vagrant optional via variables) |
| `terminal_customizations` | Nerd Fonts, Tilix terminal, tmux config, tilix dconf settings |
| `vim` | Vim with amix/vimrc distribution + indentLine plugin, custom `my_configs.vim` |
| `zsh` | Zsh + Antigen + Oh-My-Zsh plugins + Bullet Train / p10k / Pure themes |
| `googlechrome` | Chromium (open-source) |
| `vscode` | VS Code with 30+ curated extensions (Python, Go, Docker, Terraform, etc.) |
| `post_install` | Prints a manual steps reminder (no system changes) |

---

## Global Variables Reference

Defined in `group_vars/all/all.yml`:

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `laptop_mode` | bool | `False` | Install TLP and laptop power tools when `True` |
| `local_username` | string | *(must be passed via CLI)* | The target user's login name |

---

## Known Conventions and Gotchas

- The `local_username` variable **must be passed at runtime** via `-e "local_username=$(id -un)"`. It has no default value.
- The playbook installs to the **running user's home directory** for user-level config (`.zshrc`, `.tmux.conf`, vim configs). Do not run as root.
- dconf tasks (`community.general.dconf`) may produce errors in headless environments — these are suppressed with `ignore_errors: yes`.
- The `post_install` role only prints instructions; it makes no system changes.
- Nerd Fonts are downloaded as zip archives from GitHub and extracted directly to `~/.local/share/fonts`.
- The `.zshrc`, `.tmux.conf`, and `my_configs.vim` files deployed by the playbook are **overwritten** on each run (originals are backed up as `.orig`).

---

## Customization

To persist customizations across re-runs, edit the source files in `roles/*/files/` rather than editing the deployed files in your home directory (which get overwritten).

To skip a role entirely, comment out its `import_playbook` line in `main.yml`.

To change the set of VS Code extensions, edit the `vscode_extensions` list in `group_vars/all/vscode.yml`.
