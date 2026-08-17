-- Host-specific Hyprland settings for jamesp1.
-- Loaded from hypr/monitors.lua via require_optional, so this file is only
-- picked up on the machine whose hostname matches its name.
--
-- Monitor geometry does NOT belong here -- put that in monitors.lua as a
-- `desc:` rule so it follows the panel rather than the machine. This file is
-- for settings that are genuinely global and can't be expressed per-output.

-- 2560x1600 panel at 1.6 scale; GTK apps need the integer step above it.
hl.env("GDK_SCALE", "2")
