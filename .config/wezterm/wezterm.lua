-- Pull in the wezterm API
local wezterm = require 'wezterm'
local act = wezterm.action

-- This will hold the configuration.
local config = wezterm.config_builder()

config.enable_tab_bar = false
config.font_size = 14
config.color_scheme = 'Gruvbox Dark (Gogh)'
config.font = wezterm.font { family = 'FiraCode Nerd Font Mono', weight = 'Medium' }
config.font_rules = {
  {
    intensity = 'Half',
    font = wezterm.font { family = 'FiraCode Nerd Font Mono', weight = 'Regular' },
  },
  {
    intensity = 'Bold',
    italic = true,
    font = wezterm.font {
      family = 'SauceCodePro Nerd Font Mono',
      weight = 'Bold',
      style = 'Italic',
    },
  },
  {
    italic = true,
    intensity = 'Half',
    font = wezterm.font {
      family = 'SauceCodePro Nerd Font Mono',
      weight = 'DemiBold',
      style = 'Italic',
    },
  },
  {
    italic = true,
    intensity = 'Normal',
    font = wezterm.font {
      family = 'SauceCodePro Nerd Font Mono',
      style = 'Italic',
    },
  },
}

config.mouse_bindings = {
  {
    event = { Down = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.SelectTextAtMouseCursor 'Block',
  },
  {
    event = { Drag = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.ExtendSelectionToMouseCursor 'Block',
  },
  {
    event = { Up = { streak = 1, button = 'Left' } },
    mods = 'CTRL',
    action = act.CompleteSelection 'ClipboardAndPrimarySelection',
  },
}

-- disable OpenType ligatures
config.harfbuzz_features = {
  'calt=0',
  'clig=0',
  'liga=0',
}

-- config.font = wezterm.font_with_fallback {
  -- 'FiraCode Nerd Font Mono',
  -- 'SauceCodePro Nerd Font Mono',
-- }

-- italic = { family = "SauceCodePro Nerd Font Mono", style = "Italic" }
return config
