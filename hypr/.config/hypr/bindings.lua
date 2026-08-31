-- Personal keybindings.
--
-- hyprland.lua loads this file after Omarchy's own bindings, so a key that
-- Omarchy leaves free can simply be bound here. A key that Omarchy already
-- uses has to be unbound first, because a second binding for the same key does
-- not replace the first one.
--
-- See every binding that is live, Omarchy's defaults included:
--
--   omarchy menu keybindings --print
--
-- Note that ~/.config/hypr/bindings.conf has no effect any more. Omarchy 4
-- moved this configuration from .conf to Lua, and nothing loads the old file.
-- A binding that lives only there is dead, and Hyprland reports no error for
-- it. Check `hyprctl binds` when a shortcut does nothing.

-- Slack and Todoist.
--
-- Both are launched by DESKTOP ENTRY ID rather than by the name of the binary.
-- uwsm-app accepts either. The entry of each of these two packages carries
-- more than the binary:
--
--   slack.desktop    /usr/bin/slack --gtk-version=3 -s %U
--   todoist.desktop  env DESKTOPINTEGRATION=false /usr/bin/todoist --no-sandbox %U
--
-- Naming the entry leaves those flags with the package that owns them. Copying
-- them into this file would work today and go stale at the next update, with
-- nothing to report the drift. Omarchy's own bindings name a bare binary --
-- o.bind(..., { launch = "obsidian" }) -- which is right for an app whose entry
-- adds nothing. It is not right for these two.
--
-- `focus` turns each key into launch-or-focus: a second press goes to the
-- window that is already open in place of starting a second copy. Omarchy
-- matches the pattern against the window class, ignoring case. Both classes
-- are lowercase, and are what this reports:
--
--   hyprctl clients -j | jq -r '.[].class'

-- Omarchy binds SUPER + SHIFT + S to the Google Maps web app. Slack takes the
-- key here: it is in use all day, and Maps is one Omarchy menu search away.
hl.unbind("SUPER + SHIFT + S")
o.bind("SUPER + SHIFT + S", "Slack", { launch = "slack.desktop", focus = "^slack$" })

-- SUPER + SHIFT + T is free in Omarchy's defaults. SUPER + T, which toggles a
-- window between floating and tiling, is a different key and is left alone.
o.bind("SUPER + SHIFT + T", "Todoist", { launch = "todoist.desktop", focus = "^todoist$" })
