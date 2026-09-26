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
