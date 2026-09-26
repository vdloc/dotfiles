local wezterm = require 'wezterm'
local act = wezterm.action
local resurrect = wezterm.plugin.require("https://github.com/MLFlexer/resurrect.wezterm")
local config = wezterm.config_builder()

-- Catppuccin Mocha palette, reused by the tab bar and status line
local c = {
  base = '#1e1e2e', mantle = '#181825', crust = '#11111b',
  surface0 = '#313244', surface1 = '#45475a', overlay0 = '#6c7086',
  text = '#cdd6f4', subtext = '#a6adc8',
  mauve = '#cba6f7', blue = '#89b4fa', peach = '#fab387',
  green = '#a6e3a1', red = '#f38ba8', rosewater = '#f5e0dc', yellow = '#f9e2af',
}

-- ==========================================================
-- 0. INPUT METHOD (ibus / ibus-bamboo for Vietnamese)
-- ==========================================================
-- Required on X11: without this WezTerm consumes keystrokes raw and never
-- forwards them to ibus, so Vietnamese tone marks never compose.
config.use_ime = true
config.xim_im_name = 'ibus'

-- ==========================================================
-- 1. AESTHETICS
-- ==========================================================
config.color_scheme = 'Catppuccin Mocha' -- Muted dark pastels (name is case-sensitive)
config.window_background_opacity = 0.95
-- Victor Mono Bold, with the Nerd Font as fallback for the icon glyphs
-- used in the tab bar and status line (Victor Mono has no Nerd patch).
config.font = wezterm.font_with_fallback {
  { family = 'Victor Mono', weight = 'Bold' },
  'JetBrains Mono Nerd Font',
}
-- Victor Mono's cursive italics for comments/keywords in editors
config.font_rules = {
  {
    italic = true,
    font = wezterm.font_with_fallback {
      { family = 'Victor Mono', weight = 'Bold', style = 'Italic' },
      'JetBrains Mono Nerd Font',
    },
  },
}
config.font_size = 14
config.line_height = 1.1

config.window_padding = { left = 8, right = 8, top = 6, bottom = 4 }
config.window_decorations = 'RESIZE' -- no title bar; tab bar is enough
config.adjust_window_size_when_changing_font_size = false
config.inactive_pane_hsb = { saturation = 0.85, brightness = 0.65 } -- dim unfocused panes
config.max_fps = 120
config.animation_fps = 60

config.default_cursor_style = 'BlinkingBar'
config.cursor_blink_rate = 600
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'

config.audible_bell = 'Disabled'
config.visual_bell = {
  fade_in_duration_ms = 75, fade_out_duration_ms = 75,
  target = 'CursorColor',
}

config.colors = {
  cursor_bg = c.rosewater,
  cursor_border = c.rosewater,
  cursor_fg = c.base,
  selection_bg = '#414559',
  selection_fg = c.text,
  scrollbar_thumb = c.surface1,
  split = c.surface1,
  visual_bell = c.surface1,
  tab_bar = {
    background = c.crust,
    new_tab = { bg_color = c.crust, fg_color = c.overlay0 },
    new_tab_hover = { bg_color = c.surface0, fg_color = c.text },
  },
}

-- ==========================================================
-- 2. TABS & STATUS BAR
-- ==========================================================
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = true
config.tab_max_width = 32
config.show_new_tab_button_in_tab_bar = true

-- Last path component of the pane's cwd (Url object on this WezTerm version)
local function cwd_basename(pane)
  local cwd = pane.current_working_dir
  if not cwd then return '' end
  local path = type(cwd) == 'userdata' and cwd.file_path or tostring(cwd)
  path = path:gsub('/$', '')
  if path == os.getenv('HOME') then return '~' end
  return path:match('([^/]+)$') or path
end

wezterm.on('format-tab-title', function(tab, tabs, panes, cfg, hover, max_width)
  local pane = tab.active_pane
  local title = tab.tab_title ~= '' and tab.tab_title or pane.title
  local dir = cwd_basename(pane)
  local zoom = pane.is_zoomed and ' 󰁌' or ''
  local label = string.format(' %d  %s  %s%s ', tab.tab_index + 1, title, dir, zoom)
  label = wezterm.truncate_right(label, max_width - 1) .. ' '

  local bg, fg = c.mantle, c.subtext
  if tab.is_active then
    bg, fg = c.mauve, c.crust
  elseif hover then
    bg, fg = c.surface0, c.text
  end
  return {
    { Background = { Color = bg } },
    { Foreground = { Color = fg } },
    { Attribute = { Intensity = tab.is_active and 'Bold' or 'Normal' } },
    { Text = label },
  }
end)

wezterm.on('update-status', function(window, pane)
  -- Left: show a badge while the leader key or a key table is active
  local mode = window:active_key_table()
  if window:leader_is_active() then mode = 'LEADER' end
  if mode then
    window:set_left_status(wezterm.format {
      { Background = { Color = c.peach } },
      { Foreground = { Color = c.crust } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = '  ' .. mode:upper() .. ' ' },
    })
  else
    window:set_left_status('')
  end

  -- GIT_BRANCH is set by a precmd hook in ~/.zshrc (no git process spawned here)
  local branch = pane:get_user_vars().GIT_BRANCH
  local git = {}
  if branch and branch ~= '' then
    git = {
      { Foreground = { Color = c.green } },
      { Text = '  ' .. branch .. ' ' },
      { Foreground = { Color = c.overlay0 } },
      { Text = '│' },
    }
  end

  window:set_right_status(wezterm.format {
    table.unpack(git),
  } .. wezterm.format {
    { Foreground = { Color = c.mauve } },
    { Text = ' 󱂬 ' .. window:active_workspace() .. ' ' },
    { Foreground = { Color = c.overlay0 } },
    { Text = '│' },
    { Foreground = { Color = c.blue } },
    { Text = ' 󱑎 ' .. wezterm.strftime('%a %d/%m %H:%M') .. ' ' },
  })
end)
config.status_update_interval = 1000

-- ==========================================================
-- 3. SESSIONS (resurrect.wezterm)
-- ==========================================================
-- Autosave every 5 min. Guarded so a config reload doesn't stack timers.
if not wezterm.GLOBAL.resurrect_autosave then
  wezterm.GLOBAL.resurrect_autosave = true
  resurrect.state_manager.periodic_save { interval_seconds = 300, save_workspaces = true }
end

-- Remember which workspace was saved last so startup can bring it back
local function mark_current(name)
  pcall(resurrect.state_manager.write_current_state, name, 'workspace')
end
wezterm.on('resurrect.state_manager.periodic_save.finished', function()
  mark_current(wezterm.mux.get_active_workspace())
end)

-- Restore the last saved workspace on launch. `wezterm start -- cmd` and
-- any failed restore (no saved state yet) fall back to a plain window.
wezterm.on('gui-startup', function(cmd)
  if cmd and cmd.args then
    wezterm.mux.spawn_window(cmd)
    return
  end
  local ok = resurrect.state_manager.resurrect_on_gui_startup()
  if not ok or #wezterm.mux.all_windows() == 0 then
    wezterm.mux.spawn_window(cmd or {})
  end
end)

-- Toast when a command that ran >= 10s finishes in a pane you aren't
-- looking at. CMD_DONE = "exit|seconds|command|nonce", set from ~/.zshrc.
wezterm.on('user-var-changed', function(window, pane, name, value)
  if name ~= 'CMD_DONE' then return end
  local active = window:active_pane()
  if window:is_focused() and active and active:pane_id() == pane:pane_id() then return end
  local st, secs, cmd = value:match('^(%d+)|(%d+)|(.-)|%d+$')
  if not st then return end
  local icon = st == '0' and '✔' or '✘ exit ' .. st
  window:toast_notification('WezTerm ' .. icon, cmd .. '  (' .. secs .. 's)', nil, 4000)
end)

-- Current pane's cwd as a plain path (Url object on this WezTerm version)
local function pane_cwd(pane)
  local cwd = pane:get_current_working_dir()
  if not cwd then return nil end
  return type(cwd) == 'userdata' and cwd.file_path or tostring(cwd):gsub('^file://[^/]*', '')
end

-- Project picker: ~/Projects/* plus zoxide's most-used dirs, each opened
-- as its own workspace named after the folder.
local function project_choices()
  local seen, choices = {}, {}
  local function add(path)
    path = path:gsub('/$', '')
    if path == '' or seen[path] then return end
    seen[path] = true
    table.insert(choices, { id = path, label = path:gsub('^' .. wezterm.home_dir, '~') })
  end
  for _, dir in ipairs(wezterm.glob(wezterm.home_dir .. '/Projects/*/')) do add(dir) end
  local ok, out = wezterm.run_child_process { '/usr/bin/zoxide', 'query', '--list' }
  if ok then
    local n = 0
    for line in out:gmatch('[^\n]+') do
      n = n + 1
      if n > 40 then break end
      add(line)
    end
  end
  return choices
end

-- ==========================================================
-- 4. KEYBINDINGS
-- ==========================================================
config.leader = { key = 'a', mods = 'CTRL', timeout_milliseconds = 1000 }

config.keys = {
  -- Send a literal Ctrl-a (start of line in the shell) with Leader Ctrl-a
  { key = 'a', mods = 'LEADER|CTRL', action = act.SendKey { key = 'a', mods = 'CTRL' } },

  -- --- Splitting (Leader + | or -) ---
  { key = '|', mods = 'LEADER|SHIFT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'LEADER', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
  { key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = true } },
  { key = 'z', mods = 'LEADER', action = act.TogglePaneZoomState },
  { key = 'o', mods = 'LEADER', action = act.PaneSelect { alphabet = 'asdfghjkl' } },
  { key = 's', mods = 'LEADER', action = act.PaneSelect { mode = 'SwapWithActive', alphabet = 'asdfghjkl' } },

  -- --- Pane navigation (Alt + hjkl) / resize (Alt + Shift + hjkl) ---
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'H', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 3 } },
  { key = 'L', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 3 } },
  { key = 'K', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 2 } },
  { key = 'J', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 2 } },
  -- Leader + r: sticky resize mode (hjkl repeat, Esc/Enter to exit)
  { key = 'r', mods = 'LEADER', action = act.ActivateKeyTable { name = 'resize_pane', one_shot = false } },

  -- --- Tabs ---
  { key = 'c', mods = 'LEADER', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'n', mods = 'LEADER', action = act.ActivateTabRelative(1) },
  { key = 'p', mods = 'LEADER', action = act.ActivateTabRelative(-1) },
  { key = 'Tab', mods = 'LEADER', action = act.ActivateLastTab },
  { key = '<', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(-1) },
  { key = '>', mods = 'LEADER|SHIFT', action = act.MoveTabRelative(1) },
  { key = ',', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Rename tab:',
      action = wezterm.action_callback(function(window, _, line)
        if line then window:active_tab():set_title(line) end
      end),
    },
  },

  -- --- Workspaces ---
  { key = 'w', mods = 'LEADER', action = act.ShowLauncherArgs { flags = 'FUZZY|WORKSPACES' } },
  { key = 'W', mods = 'LEADER|SHIFT', action = act.PromptInputLine {
      description = 'New workspace name:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(act.SwitchToWorkspace { name = line }, pane)
        end
      end),
    },
  },
  { key = 'l', mods = 'LEADER', action = act.SwitchWorkspaceRelative(1) },
  { key = 'h', mods = 'LEADER', action = act.SwitchWorkspaceRelative(-1) },

  -- --- Copy / search / select ---
  { key = '[', mods = 'LEADER', action = act.ActivateCopyMode },
  { key = '/', mods = 'LEADER', action = act.Search { CaseInSensitiveString = '' } },
  { key = 'Space', mods = 'CTRL|SHIFT', action = act.QuickSelect },
  -- Leader + u: pick a URL on screen and open it
  { key = 'u', mods = 'LEADER', action = act.QuickSelectArgs {
      label = 'open url',
      patterns = { 'https?://\\S+' },
      action = wezterm.action_callback(function(window, pane)
        wezterm.open_with(window:get_selection_text_for_pane(pane))
      end),
    },
  },
  -- Jump between shell prompts (needs OSC 133 shell integration)
  { key = 'UpArrow', mods = 'LEADER', action = act.ScrollToPrompt(-1) },
  { key = 'DownArrow', mods = 'LEADER', action = act.ScrollToPrompt(1) },
  { key = 'k', mods = 'CTRL|SHIFT', action = act.Multiple {
      act.ClearScrollback 'ScrollbackAndViewport',
      act.SendKey { key = 'L', mods = 'CTRL' },
    },
  },

  -- --- Projects / tools ---
  -- Leader + f: fuzzy-pick a project, open it as its own workspace
  { key = 'f', mods = 'LEADER', action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.InputSelector {
        title = 'Projects',
        fuzzy = true,
        choices = project_choices(),
        action = wezterm.action_callback(function(win, p, id, label)
          if not id then return end
          win:perform_action(act.SwitchToWorkspace {
            name = id:match('([^/]+)$'),
            spawn = { cwd = id },
          }, p)
        end),
      }, pane)
    end),
  },
  -- Leader + C: Claude Code in a right split, same folder
  { key = 'C', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SplitPane {
        direction = 'Right',
        size = { Percent = 45 },
        command = {
          args = { 'zsh', '-ic', 'claude' },
          cwd = pane_cwd(pane),
          set_environment_variables = { NO_KEYS = '1' },
        },
      }, pane)
    end),
  },
  -- Leader + G: lazygit in a new tab for the current folder
  { key = 'G', mods = 'LEADER|SHIFT', action = wezterm.action_callback(function(window, pane)
      window:perform_action(act.SpawnCommandInNewTab {
        args = { 'zsh', '-ic', 'lazygit' },
        cwd = pane_cwd(pane),
        set_environment_variables = { NO_KEYS = '1' },
      }, pane)
    end),
  },

  -- --- Command palette & config ---
  { key = 'p', mods = 'CTRL|SHIFT', action = act.ActivateCommandPalette },
  -- nvim isn't installed and $EDITOR is unset, so fall back to vim
  { key = 'e', mods = 'LEADER', action = act.SpawnCommandInNewTab {
      args = { os.getenv('EDITOR') or 'vim', wezterm.config_file },
    },
  },

  -- --- AI: Leader + g asks Claude in a bottom split ---
  -- Runs in its own pane so it never types into vim/Claude Code in the
  -- current pane; the question is passed via env so quotes are safe.
  { key = 'g', mods = 'LEADER', action = act.PromptInputLine {
      description = 'Ask Claude:',
      action = wezterm.action_callback(function(window, pane, line)
        if line and line ~= '' then
          window:perform_action(act.SplitPane {
            direction = 'Down',
            size = { Percent = 40 },
            command = {
              args = { 'zsh', '-ic', [[
print -P "%F{magenta}❯ ${ASK_Q}%f"; print -P "%F{8}thinking…%f\n"
claude -p "$ASK_Q"
print -P "\n%F{8}── press any key to close ──%f"; read -sk1]] },
              set_environment_variables = { ASK_Q = line, NO_KEYS = '1' },
            },
          }, pane)
        end
      end),
    },
  },

  -- --- Sessions ---
  -- Leader + S: save current workspace
  {
    key = 'S',
    mods = 'LEADER|SHIFT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
      mark_current(win:active_workspace())
      win:toast_notification('WezTerm', 'Session saved: ' .. win:active_workspace(), nil, 2000)
    end),
  },
  -- Leader + R: fuzzy-pick a saved state and restore it
  {
    key = 'R',
    mods = 'LEADER|SHIFT',
    action = wezterm.action_callback(function(win, pane)
      resurrect.fuzzy_loader.fuzzy_load(win, pane, function(id, label)
        local state = resurrect.state_manager.load_state(id, 'workspace')
        resurrect.workspace_state.restore_workspace(state, {
          window = win,
          relative = true,
          restore_text = true,
          on_pane_restore = resurrect.tab_state.default_on_pane_restore,
        })
      end)
    end),
  },
}

-- Leader + 1..9: jump to tab
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'LEADER', action = act.ActivateTab(i - 1) })
end

config.key_tables = {
  resize_pane = {
    { key = 'h', action = act.AdjustPaneSize { 'Left', 2 } },
    { key = 'l', action = act.AdjustPaneSize { 'Right', 2 } },
    { key = 'k', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'j', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'Escape', action = 'PopKeyTable' },
    { key = 'Enter', action = 'PopKeyTable' },
  },
}

-- ==========================================================
-- 5. MOUSE & LINKS
-- ==========================================================
config.hyperlink_rules = wezterm.default_hyperlink_rules()

config.mouse_bindings = {
  -- Right click opens the link under the cursor
  {
    event = { Up = { streak = 1, button = 'Right' } },
    mods = 'NONE',
    action = act.OpenLinkAtMouseCursor,
  },
  -- Plain left click only selects; Ctrl + click opens links
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'NONE',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.OpenLinkAtMouseCursor,
  },
}

-- ==========================================================
-- 6. MISC
-- ==========================================================
config.default_prog = { 'zsh', '-l' }
config.scrollback_lines = 20000
config.enable_scroll_bar = false
config.warn_about_missing_glyphs = false
config.window_close_confirmation = 'AlwaysPrompt'
config.skip_close_confirmation_for_processes_named = {
  'bash', 'sh', 'zsh', 'fish', 'tmux',
}

return config
