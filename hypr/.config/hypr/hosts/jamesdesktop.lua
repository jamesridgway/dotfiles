-- Host-specific Hyprland settings for jamesdesktop.
-- Loaded from hypr/monitors.lua via require_optional, so this file is only
-- picked up on the machine whose hostname matches its name.
--
-- Monitor geometry does NOT belong here. Positions and scales go in
-- monitors.lua, where Omarchy's scaling tools can find them.

-- Three DELL U2715H panels side by side. The serials are the same ones the
-- hl.monitor() rules in monitors.lua use, and the sides match the positions
-- pinned there: 2560, 5120 and 7680 on the x axis, left to right.
require("hypr.lib.workspaces").three_across({
  left = "desc:Dell Inc. DELL U2715H GH85D63P0JNS",
  centre = "desc:Dell Inc. DELL U2715H GH85D63P0ACS",
  right = "desc:Dell Inc. DELL U2715H GH85D7B70X9S",
})
