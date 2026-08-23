-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- This file follows Omarchy's own layout (/usr/share/omarchy/config/hypr/
-- monitors.lua) on purpose. Four Omarchy tools parse this file with regexes --
-- omarchy-hyprland-monitor-scaling, -clamshell, -internal and -internal-mirror
-- -- and they all expect that layout. A hand-rolled structure puts you outside
-- the contract they assume, and they then fail in ways that report no error:
--
--   * The two `local omarchy_*_scale` lines below are what the scaling tool
--     rewrites. Keep both, keep them at the start of a line, and keep the
--     spacing exactly as it is.
--
--   * Keep every hl.monitor() call on ONE line. Omarchy's monitor recovery
--     logic understands only the single-line form. A multi-line table makes
--     that parse fail, and Omarchy then restores a remembered scale after a
--     lock/unlock -- the display changes to a scale you did not ask for.
--
-- The cost of following the contract is that the scaling tool rewrites this
-- file with `sed -i`, which renames a temporary file over the target and so
-- replaces the stow symlink with a regular file. That is the lesser problem:
-- `./bootstrap` reports it, and one command repairs it and captures the change:
--
--   stow --adopt --no-folding -t "$HOME" hypr && git diff
--
-- Three Hyprland behaviours worth knowing. Numbers 1 and 2 are what
-- CMonitorRuleManager::get() and CMonitor::matchesStaticSelector() do in the
-- v0.56.2 source; number 3 is observed:
--
--   1. A specific rule always beats the `output = ""` catch-all, whatever the
--      order. The catch-all matches nothing in the main loop -- an empty
--      selector is compared against the output NAME, which is never empty --
--      so it is reached only by a second pass that runs after no specific rule
--      has matched. You do not need to sort these by specificity.
--
--   2. Between two SPECIFIC rules, the last one defined wins. The main loop
--      walks the rules in reverse and returns the first match, and a `desc:`
--      rule has no priority over a rule that names an output. This matters
--      because hyprland.lua loads this file BEFORE any other monitor config,
--      so a later file silently overrides everything below. See the note on
--      HyprMon further down.
--
--   3. Hyprland silently snaps an invalid scale to the nearest valid one. A
--      scale is valid only if it divides the panel's pixel dimensions into
--      whole numbers -- on 2560x1600, scale 1.5 gives 1706.67px and is
--      rejected in favour of 1.6. If a scale here seems to be ignored, check
--      the arithmetic before suspecting the rule.

-- Scale for the panel of whichever machine this is. `Super + /` and
-- `Super + Alt + /` step through the presets and rewrite these two lines, so
-- the value here is whatever you last chose. GDK_SCALE is the integer step
-- above the monitor scale, because GTK only honours whole numbers.
local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 1.6

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Panels on OTHER machines get an explicit rule here, matched on `desc:` so the
-- rule follows the panel rather than the machine. A rule for a panel that isn't
-- connected is inert, so every machine's rules can live in this one file. Leave
-- the panel of the machine you are on to the catch-all above, so Omarchy can
-- keep managing its scale.
--
-- `desc:` is a PREFIX match against "<make> <model> <serial>". Match on make
-- and model to catch every panel of one type. Include the serial to single out
-- one panel, which is the only way to tell identical panels apart.
--
-- Find the strings to match with:
--   hyprctl -j monitors all | jq -r '.[].description'
--
-- jamesp1's internal panel is BOE 0x0AE0, 2560x1600@165. It uses the catch-all.

-- jamesdesktop: three DELL U2715H at 2560x1440, side by side, left to right.
-- The serial is what identifies each one, because all three are the same model
-- and because a connector name (DP-2, HDMI-A-1) moves when a cable changes
-- port. Position is pinned rather than "auto", so the arrangement survives a
-- reboot, a replug and a machine rebuild.
--
-- The row starts at x=2560, not at 0. That is deliberate only in the sense that
-- it is what the arrangement already was. Hyprland does not need the origin to
-- be occupied.
hl.monitor({ output = "desc:Dell Inc. DELL U2715H GH85D63P0JNS", mode = "preferred", position = "2560x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL U2715H GH85D63P0ACS", mode = "preferred", position = "5120x0", scale = 1 })
hl.monitor({ output = "desc:Dell Inc. DELL U2715H GH85D7B70X9S", mode = "preferred", position = "7680x0", scale = 1 })

-- HyprMon (the `hyprmon` TUI, installed by ./bootstrap) writes its own rules to
-- ~/.config/hypr/hyprmon.lua and appends `require("hyprmon")` to the END of
-- hyprland.lua. By behaviour 2 above, those rules therefore beat the three
-- rules here, and hyprmon.lua is not tracked in this repo -- so the arrangement
-- that actually applies would live nowhere. Use HyprMon to work out a layout,
-- then copy the result into this file and remove the require line.

-- Settings that are global and cannot be expressed per-monitor belong in a
-- per-host file: hypr/hosts/<hostname>.lua, loaded below if it exists and
-- skipped silently if it doesn't. This is the same require_optional mechanism
-- Omarchy uses for its own theme overrides.
--
-- Read the hostname from /etc/hostname, NOT from os.getenv("HOSTNAME").
-- HOSTNAME is a bash shell variable that bash does not export, so Hyprland's
-- Lua sees nil for it and would silently load nothing at all -- require_optional
-- skips a missing module without complaint, so that failure is invisible.
local function hostname()
  local f = io.open("/etc/hostname", "r")
  if f then
    local name = f:read("l")
    f:close()
    if name and name ~= "" then
      return (name:gsub("%s+$", ""))
    end
  end
  return os.getenv("HOSTNAME") or "unknown"
end

require("default.hypr.require_optional").module("hypr.hosts." .. hostname())
