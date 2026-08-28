-- A fixed workspace-to-monitor layout, shared by the three-monitor machines.
--
-- Hyprland's default is to hand workspaces out in the sequence it discovers
-- monitors, so `Super + 3` lands on whichever screen happened to claim it that
-- boot. Binding each workspace to a monitor makes the number a place: the same
-- key reaches the same screen on every machine, after every reboot and after
-- every replug.
--
-- This lives in hypr/lib/ rather than in monitors.lua because it is loaded from
-- the per-host files, and only the hosts with three screens load it. A rule
-- that names an absent monitor is not obviously inert the way an hl.monitor()
-- rule is -- Hyprland has to put the workspace somewhere -- so the layout is
-- not left lying around on machines it does not describe.

local M = {}

-- Workspaces by screen position, in the sequence they sit on the desk. The
-- FIRST number of each row is that monitor's default workspace: the one
-- Hyprland shows there when it has no other reason to choose.
--
-- The centre screen takes 1-4 because it is the one being looked at, and 1 is
-- where a session starts. The flanking screens continue upwards outward-left
-- then outward-right, so the numbers still read left to right across the desk:
--
--   left        centre        right
--   5 6 7       1 2 3 4       8 9 10
local ROWS = {
  { side = "left", workspaces = { 5, 6, 7 } },
  { side = "centre", workspaces = { 1, 2, 3, 4 } },
  { side = "right", workspaces = { 8, 9, 10 } },
}

-- Apply the layout to three monitors laid out side by side.
--
-- `monitors` is a table with `left`, `centre` and `right` keys. Each value is
-- an output selector of the same form hl.monitor() takes -- use the "desc:..."
-- string, not a connector name, for the reason given in monitors.lua: a
-- connector name moves when a cable changes port.
--
-- The workspaces are NOT persistent. An empty one disappears from the bar
-- until something opens on it, which keeps the bar honest about what is
-- running. The binding survives regardless: `Super + 6` recreates workspace 6
-- on the left screen. Add `persistent = true` to the spec below to show all ten
-- at all times instead.
function M.three_across(monitors)
  for _, row in ipairs(ROWS) do
    local monitor = monitors[row.side]
    if not monitor then
      error("hypr.lib.workspaces: no monitor given for the " .. row.side .. " screen")
    end

    for index, workspace in ipairs(row.workspaces) do
      hl.workspace_rule({
        workspace = tostring(workspace),
        monitor = monitor,
        default = index == 1,
      })
    end
  end
end

return M
