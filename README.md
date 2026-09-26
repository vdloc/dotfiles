# dotfiles

zsh + WezTerm setup for Ubuntu (X11, GNOME), Catppuccin Mocha everywhere.

| Path | What |
|---|---|
| `zsh/.zshrc` | oh-my-zsh (git, autosuggestions, syntax-highlighting), starship, mise, fzf, zoxide, eza aliases, WezTerm hooks |
| `zsh/.zshenv` | cargo env |
| `wezterm/wezterm.lua` | leader `Ctrl+a`, tabs/panes/workspaces, project picker, session save/restore (resurrect.wezterm), git branch in status bar, toast on long commands, Claude/lazygit splits |
| `wezterm/cheatsheet.zsh` | hotkey summary printed in every new tab (`keys` to reprint, `NO_KEYS=1` to hide) |
| `starship/starship.toml` | minimal two-line prompt |
| `git/delta.gitconfig` | delta side-by-side diffs, included from `~/.gitconfig` |
| `lazygit/config.yml` | Catppuccin colours, delta diffs |

## Install

```sh
git clone https://github.com/vdloc/dotfiles ~/dotfiles
~/dotfiles/install.sh   # symlinks into $HOME, backs up anything it replaces
```

Tools (Homebrew): `brew install starship eza git-delta lazygit mise`
Apt: `zsh fzf fd-find bat zoxide`, oh-my-zsh + `zsh-autosuggestions`, `zsh-syntax-highlighting` in `$ZSH_CUSTOM/plugins`.
Fonts: Victor Mono, JetBrains Mono Nerd Font.

## Windows

`wezterm.lua` detects Windows and opens WSL instead of a native shell, so the
whole zsh setup runs unchanged inside WSL.

1. In PowerShell: `wsl --install -d Ubuntu`, then `winget install wez.wezterm`.
2. Inside WSL: install zsh, oh-my-zsh, Homebrew tools (see Install), then
   `git clone https://github.com/vdloc/dotfiles ~/dotfiles && ~/dotfiles/install.sh`.
3. Link the WezTerm config on the Windows side (PowerShell):
   ```powershell
   git clone https://github.com/vdloc/dotfiles $HOME\dotfiles
   New-Item -ItemType Directory -Force $HOME\.config\wezterm
   Copy-Item $HOME\dotfiles\wezterm\wezterm.lua $HOME\.config\wezterm\
   ```
4. Install fonts on Windows (WezTerm draws them): Victor Mono, JetBrains Mono Nerd Font.
5. Distro not named `Ubuntu`? Edit `config.default_domain = 'WSL:<name>'` (`wsl -l -v`).

Vietnamese input: UniKey / EVKey work directly (`use_ime = true`); the ibus
settings only apply on Linux.

## Secrets

Nothing secret lives here. `~/.zshrc` sources `~/.zshrc.local` (mode 600, git-ignored)
for API keys and private aliases; prefer GNOME keyring via `secret-tool lookup`.

## WezTerm keys (after `Ctrl+a`)

| Keys | Action |
|---|---|
| `\|` `-` `x` `z` `o` `s` `r` | split right / down, close, zoom, pick pane, swap, resize mode |
| `c` `n` `p` `1-9` `Tab` `,` `<` `>` | new tab, next, prev, jump, last, rename, move |
| `w` `W` `h` `l` `S` `R` | workspaces, new workspace, prev/next, save session, restore |
| `f` `C` `G` `g` `e` | project picker, Claude Code split, lazygit, ask Claude, edit config |
| `[` `/` `u` `↑` `↓` | copy mode, search, open URL, jump between prompts |

`Alt+hjkl` moves between panes, `Alt+Shift+hjkl` resizes.
