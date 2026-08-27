-- Host-specific Hyprland settings for jamestccsbox.
-- Loaded from hypr/monitors.lua via require_optional, so this file is only
-- picked up on the machine whose hostname matches its name.
--
-- Monitor geometry does NOT belong here. Positions and scales go in
-- monitors.lua, where Omarchy's scaling tools can find them.

-- Three DELL U2415 panels side by side. The serials are the same ones the
-- hl.monitor() rules in monitors.lua use, and the sides match the positions
-- pinned there: -2976, -1056 and 864 on the x axis, left to right.
require("hypr.lib.workspaces").three_across({
  left = "desc:Dell Inc. DELL U2415 7MT0177S3UNL",
  centre = "desc:Dell Inc. DELL U2415 07MT01624065L",
  right = "desc:Dell Inc. DELL U2415 07MT016231KCL",
})
