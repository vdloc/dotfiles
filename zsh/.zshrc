# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # prompt comes from starship (see below)

# zsh-syntax-highlighting must stay last.
# (zsh-autocomplete removed: it fights fzf over Tab / Ctrl-R)
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

# History: big, shared across tabs, no duplicates
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY

source $ZSH/oh-my-zsh.sh

alias ls='eza --group-directories-first'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# eza listings (git status column, icons from the Nerd Font)
alias ll='eza -alF --git --icons=auto --group-directories-first'
alias la='eza -a --icons=auto --group-directories-first'
alias l='eza -F --icons=auto'
alias lt='eza --tree --level=2 --icons=auto --git-ignore'
alias lg='lazygit'

alias recent-branches="git branch --sort=-committerdate"
alias vscode="code ."
alias update-shell="exec zsh"
alias update="sudo apt update"
alias upgrade="sudo apt upgrade"
alias install="sudo apt install"
alias edit-config="vim ~/.zshrc"
alias restore-stash="git stash apply"
alias stash="git stash"
alias search-history="history | grep "
alias update-master="git checkout master && git pull && git checkout -"
alias update-dev="git checkout develop || git checkout develop_new && git pull && git checkout -"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


export DOTNET_ROOT=$HOME/.dotnet
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools

# pnpm
export PNPM_HOME="/home/vdloc/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# ---- vitefast: pnpm create vite + auto git + auto run dev ----
vitefast() {
  # Usage: vitefast project-name
  # Example: vitefast myapp

  if [[ -z "$1" ]]; then
    echo "Usage: vitefast <project-name>"
    return 1
  fi

  PROJECT_NAME="$1"

  echo "Creating Vite project: $PROJECT_NAME"
  pnpm create vite "$PROJECT_NAME"   # interactive template selection

  cd "$PROJECT_NAME" || return 1

  echo "Installing dependencies..."
  pnpm install

  echo "Initializing Git repository..."
  git init -b main
  git add .
  git commit -m "Initial commit"

  echo "Starting dev server..."
  pnpm dev
}
# ---- End function ----

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin

# OpenClaw Completion
[[ -r ~/.openclaw/completions/openclaw.zsh ]] && source ~/.openclaw/completions/openclaw.zsh
[[ -x /home/linuxbrew/.linuxbrew/bin/brew ]] && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

# Added by Antigravity CLI installer
export PATH="/home/vdloc/.local/bin:$PATH"

# opencode
export PATH=/home/vdloc/.opencode/bin:$PATH

export PATH=$PATH:/usr/local/go/bin

# dcg: warn if hook was silently removed from Claude Code settings
if command -v dcg &>/dev/null && command -v jq &>/dev/null; then
  if [ -f "$HOME/.claude/settings.json" ] && \
     ! jq -e '.hooks.PreToolUse[]? | select(.hooks[]?.command | test("dcg$"))' \
       "$HOME/.claude/settings.json" &>/dev/null; then
    printf '\033[1;33m[dcg] Hook missing from ~/.claude/settings.json — run: dcg install\033[0m\n'
  fi
fi

# >>> productivity tools >>>
# Remove this whole block to revert.

# Ubuntu ships these under different binary names
alias fd='fdfind'
alias bat='batcat'

# fzf: Ctrl-R fuzzy history, Ctrl-T file picker, Alt-C cd
if [ -d /usr/share/doc/fzf/examples ]; then
  source /usr/share/doc/fzf/examples/key-bindings.zsh
  source /usr/share/doc/fzf/examples/completion.zsh
fi
export FZF_DEFAULT_COMMAND='fdfind --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
export FZF_CTRL_T_OPTS="--preview 'batcat --color=always --style=numbers --line-range=:200 {}'"

# zoxide: `z <partial-dir>` jumps to frecent dirs, `zi` for interactive pick
eval "$(zoxide init zsh)"
# <<< productivity tools <<<

# bun completions
[ -s "/home/vdloc/.bun/_bun" ] && source "/home/vdloc/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# context7 API key from GNOME keyring
export CONTEXT7_API_KEY="$(secret-tool lookup service context7 key api 2>/dev/null)"

# Machine-local secrets / private aliases (not in the dotfiles repo)
[[ -r ~/.zshrc.local ]] && source ~/.zshrc.local

# Prompt: starship (config in ~/.config/starship.toml)
eval "$(starship init zsh)"

# mise: per-project tool versions + env from mise.toml / .tool-versions.
# Loaded after nvm so mise wins inside projects that pin versions.
eval "$(mise activate zsh)"

# WezTerm: OSC 133 prompt marks (Leader+Up/Down jumps), cwd + user vars
[[ $TERM_PROGRAM == WezTerm && -r /etc/profile.d/wezterm.sh ]] && source /etc/profile.d/wezterm.sh

# WezTerm hotkey cheatsheet on each new tab/pane (`keys` to reprint)
[[ -r ~/.config/wezterm/cheatsheet.zsh ]] && source ~/.config/wezterm/cheatsheet.zsh

# WezTerm user vars: GIT_BRANCH for the status bar, CMD_DONE to notify
# when a command that ran >= 10s finishes in a background tab.
if [[ $TERM_PROGRAM == WezTerm ]] && (( $+functions[__wezterm_set_user_var] )); then
  zmodload zsh/datetime
  typeset -g __wez_cmd_start=0 __wez_cmd=
  __wez_preexec() { __wez_cmd_start=$EPOCHSECONDS; __wez_cmd=$1 }
  __wez_precmd() {
    local st=$?
    __wezterm_set_user_var GIT_BRANCH "$(git branch --show-current 2>/dev/null)"
    if (( __wez_cmd_start && EPOCHSECONDS - __wez_cmd_start >= 10 )); then
      __wezterm_set_user_var CMD_DONE "$st|$(( EPOCHSECONDS - __wez_cmd_start ))|${__wez_cmd[1,60]}|$EPOCHSECONDS"
    fi
    __wez_cmd_start=0
    return $st
  }
  preexec_functions+=(__wez_preexec)
  precmd_functions=(__wez_precmd $precmd_functions)
fi
