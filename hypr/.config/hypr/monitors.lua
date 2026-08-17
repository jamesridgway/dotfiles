-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all
--
-- This file is shared across every machine. Monitor rules are matched by
-- `desc:` (the panel's make + model), so a rule for a panel that isn't
-- connected is simply inert. All machines' rules live here together, and
-- docking/undocking a laptop is handled without extra work.
--
-- Find the string to match with:
--   hyprctl -j monitors all | jq -r '.[].description'
--
-- Two behaviours worth knowing, both verified on Hyprland 0.56.2:
--
--   1. A specific `desc:` rule beats the `output = ""` catch-all regardless of
--      the order they appear in. You do not need to sort these by specificity.
--
--   2. Hyprland silently snaps an invalid scale to the nearest valid one. A
--      scale is valid only if it divides the panel's pixel dimensions into
--      whole numbers -- on 2560x1600, scale 1.5 gives 1706.67px and is
--      rejected in favour of 1.6. If a scale here seems to be ignored, check
--      the arithmetic before suspecting the rule.

-- jamesp1 -- internal panel, 2560x1600@165 HiDPI. 2560/1.6 = 1600, 1600/1.6 = 1000.
hl.monitor({ output = "desc:BOE 0x0AE0", mode = "preferred", position = "auto", scale = 1.6 })

-- Fallback for any panel without a rule above.
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-- GDK_SCALE is a single global env var, so it can't be expressed per-monitor
-- like the rules above. Anything in that category belongs in a per-host file:
-- hypr/hosts/<hostname>.lua, loaded below if it exists and skipped silently if
-- it doesn't. This is the same require_optional mechanism Omarchy uses for its
-- own theme overrides.
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
