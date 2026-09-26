#!/usr/bin/env bash
# Symlink these dotfiles into $HOME. Existing files are moved aside to
# <file>.pre-dotfiles-<timestamp> first, so nothing is lost.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $dst"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    mv "$dst" "$dst.pre-dotfiles-$STAMP"
    echo "backup  $dst -> $dst.pre-dotfiles-$STAMP"
  fi
  ln -s "$src" "$dst"
  echo "link    $dst -> $src"
}

link zsh/.zshrc              "$HOME/.zshrc"
link zsh/.zshenv             "$HOME/.zshenv"
link wezterm/wezterm.lua     "$HOME/.config/wezterm/wezterm.lua"
link wezterm/cheatsheet.zsh  "$HOME/.config/wezterm/cheatsheet.zsh"
link starship/starship.toml  "$HOME/.config/starship.toml"
link git/delta.gitconfig     "$HOME/.config/git/delta.gitconfig"
link lazygit/config.yml      "$HOME/.config/lazygit/config.yml"

# delta is pulled in via include so ~/.gitconfig (name, email, credentials)
# stays machine-local.
if ! git config --global --get-all include.path | grep -qx '~/.config/git/delta.gitconfig'; then
  git config --global --add include.path '~/.config/git/delta.gitconfig'
  echo "git     include ~/.config/git/delta.gitconfig"
fi

[[ -e "$HOME/.zshrc.local" ]] || {
  install -m 600 /dev/null "$HOME/.zshrc.local"
  echo "created ~/.zshrc.local (put secrets / private aliases here)"
}

echo "done. open a new terminal or run: exec zsh"
