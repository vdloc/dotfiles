# Hotkey cheatsheet printed at the top of each new WezTerm tab/pane.
# Sourced from ~/.zshrc. Run `keys` to show it again.

keys() {
  local m=$'\e[38;2;203;166;247m' b=$'\e[38;2;137;180;250m' p=$'\e[38;2;250;179;135m'
  local d=$'\e[38;2;108;112;134m' r=$'\e[0m'
  print -r -- "${d}── ${p}WezTerm${d}  leader = ${p}Ctrl+a${d} ─────────────────────────────────${r}"
  print -r -- "  ${m}Panes${r}  ${b}| -${r} split  ${b}x${r} close  ${b}z${r} zoom  ${b}o${r} pick  ${b}s${r} swap  ${b}r${r} resize  ${b}Alt+hjkl${r} move"
  print -r -- "  ${m}Tabs${r}   ${b}c${r} new  ${b}n p${r} next/prev  ${b}1-9${r} jump  ${b}Tab${r} last  ${b},${r} rename  ${b}< >${r} move"
  print -r -- "  ${m}Space${r}  ${b}w${r} workspaces  ${b}W${r} new  ${b}h l${r} prev/next  ${b}S${r} save  ${b}R${r} restore"
  print -r -- "  ${m}Find${r}   ${b}[${r} copy mode  ${b}/${r} search  ${b}u${r} open url  ${b}↑ ↓${r} prompts  ${b}Ctrl+Shift+Space${r} quick select"
  print -r -- "  ${m}Tools${r}  ${b}f${r} projects  ${b}C${r} Claude split  ${b}G${r} lazygit  ${b}g${r} ask Claude  ${b}e${r} edit config"
  print -r -- "  ${m}Misc${r}   ${b}Ctrl+Shift+P${r} palette  ${b}Ctrl+Shift+K${r} clear  ${d}· toast when a 10s+ command ends in a background tab${r}"
  print -r -- "${d}── ${p}Shell${d} ────────────────────────────────────────────────────────${r}"
  print -r -- "  ${b}Ctrl+R${r} history  ${b}Ctrl+T${r} files  ${b}Alt+C${r} cd  ${b}z${r}/${b}zi${r} jump dir  ${b}→${r} accept suggestion"
  print -r -- "  ${b}ll${r} list+git  ${b}lt${r} tree  ${b}lg${r} lazygit  ${b}git diff${r} side-by-side (delta)  ${b}mise use node@22${r} pin per project"
  print -r -- "${d}  run ${b}keys${d} to show again · ${b}NO_KEYS=1${d} in env to hide${r}"
}

# Show once per pane: WEZTERM_PANE is unique per pane, and the exported marker
# stops nested shells (exec zsh, subshells) in the same pane from repeating it.
if [[ -o interactive && $TERM_PROGRAM == WezTerm && -z $NO_KEYS \
      && $_KEYS_SHOWN_PANE != $WEZTERM_PANE ]]; then
  export _KEYS_SHOWN_PANE=$WEZTERM_PANE
  keys
fi
