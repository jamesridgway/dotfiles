# dotfiles

Personal configuration for [Omarchy](https://omarchy.org/) 4.
[GNU Stow](https://www.gnu.org/software/stow/) controls the files.

The [Omarchy Manual's Dotfiles chapter](https://omarchy.org/manual/dotfiles/)
tells you to use Stow. The manual says that `~/.config` is yours:

> Omarchy is primarily configured through the so-called dotfiles that live in
> `~/.config`. Those are considered your files for your changes.
>
> If you end up making a lot of changes to tweak your own setup, it's a good
> idea to backup all these dotfiles. Stow is a great way to do that.

## Layout

Each top-level directory is a stow *package*. In a package, the path is the
same as the path below `$HOME`:

```
omarchy/.config/omarchy/branding/about.txt   ->   ~/.config/omarchy/branding/about.txt
```

| Package     | Contents                                                                                         |
|-------------|--------------------------------------------------------------------------------------------------|
| `omarchy`   | About text, screensaver text, `shell.json` (bar layout, idle times), wallpaper, post-update hook |
| `hypr`      | `monitors.lua`, the per-host files in `hypr/hosts/`, the workspace layout in `hypr/lib/`         |
| `kitty`     | Terminal configuration                                                                           |
| `btop`      | Resource monitor                                                                                 |
| `tmux`      | tmux configuration                                                                               |
| `git`       | git aliases and defaults                                                                         |
| `autostart` | 1Password autostart entry                                                                        |
| `ssh`       | 1Password SSH agent (`IdentityAgent`)                                                            |

## Install on a new machine

```bash
sudo pacman -S --needed stow
git clone git@github.com:jamesridgway/dotfiles.git ~/projects/dotfiles
cd ~/projects/dotfiles
./bootstrap
```

The `bootstrap` script does these steps:

1. Find each package.
2. Set the mode of `ssh/.ssh/config` to 600.
3. Do a test run, and show the plan.
4. Ask you for approval.
5. Make the symbolic links.
6. Install the packages that the configuration assumes.
7. Install the third-party plugins in `plugins.txt`.
8. Run the scripts in `setup/` that changed since the last run.

The test run looks for a file that is already at a target path. The script
compares each such file with the copy in this repo. When every one of these
files is equal to its copy, byte for byte, the script offers to replace them
with symbolic links. It moves each file aside before it makes the links, and
it puts each file back if the run stops for any reason before the links exist.

When any of these files differs from its copy, the script stops and changes
nothing. It lists every file with a mark: `≠` for a file that differs, and `=`
for a file that is equal and that the script will handle on the next run. For
each `≠` file, delete the file to keep the repo's version, or run
`stow --adopt` (see below) to keep the file's content.

If all the symbolic links are already correct, the script tells you that there
is no work to do.

The script exits with status 0 when it finds no problem. It exits with status 1
when it finds a conflict, or when a package or a plugin does not install. A
package or a plugin that does not install stops neither the other packages and
plugins nor the rest of the run.

## Packages

Step 6 installs the tools that the configuration in this repo assumes, but that
no package depends on. At present there is one: `hyprmon-bin`, which supplies
the `hyprmon` command.

The step tests for the command, not for the package. It installs a missing one
with `yay`, or with `paru` if there is no `yay`. It does not pass
`--noconfirm`, because an AUR build asks you to read a `PKGBUILD` and `sudo`
asks for a password.

Note that HyprMon writes monitor rules to `~/.config/hypr/hyprmon.lua` and adds
`require("hyprmon")` to the end of `hyprland.lua`. Hyprland gives the last rule
that matches a monitor, so those rules beat the rules in `hypr/monitors.lua`,
and this repo does not track them. Use HyprMon to work out an arrangement. Then
copy the result into `hypr/monitors.lua` and delete the `require` line.

The script writes colour when the output goes to a terminal. It writes plain
text to a file or to a pipe, and it obeys the `NO_COLOR` variable.

To install the packages without the script:

```bash
stow --no-folding -t "$HOME" omarchy hypr kitty btop tmux git autostart ssh
chmod 600 ssh/.ssh/config
```

Always use `--no-folding`. Without this option, Stow can replace a full
directory with one symbolic link. With this option, the directories stay, and
Stow makes a symbolic link for each file. This is necessary in
`~/.config/omarchy/`, because Omarchy writes its own files into the same
directories. Those files must not go into this repo.

To remove a package: `stow -D -t "$HOME" <package>`.

## How Omarchy writes to the linked files

Omarchy uses two different methods to write to these files. The results of the
two methods are not the same.

**Method 1: `cp -f`.** `omarchy-refresh-config` uses `cp -f`. This command
writes through a symbolic link, and the link stays. The new content from
Omarchy goes into this repo, where you see it as a usual `git diff`. Examine
the change. Then keep it, or remove it. This is the most important reason for
this setup.

**Method 2: `sed -i`.** `omarchy-hyprland-monitor-scaling` uses `sed -i`. This
command does not write through a symbolic link. It writes a temporary file and
moves that file over the target. The result is a regular file in the position
of the symbolic link. The repo then has no connection to `~/.config/`, and you
get no error message.

Do not try to stop method 2 with a multi-line table. A table on more than one
line makes the `sed -i` search fail, but it also breaks Omarchy. Four Omarchy
tools read `monitors.lua` with regular expressions. They understand only the
layout of Omarchy's own file. If a parse fails, Omarchy restores an old scale
after a lock, an unlock, or a similar event. The display then changes to a
scale that you did not select, and no tool reports an error.

Therefore `hypr/monitors.lua` keeps Omarchy's layout:

- Keep the two `local omarchy_gdk_scale` and `local omarchy_monitor_scale`
  lines. Keep each one at the start of a line. Do not change the spacing.
- Keep each `hl.monitor()` call on one line.

Therefore method 2 stays possible. This is acceptable, because the result is
visible and easy to repair. `./bootstrap` reports a conflict for the file. This
command makes the symbolic link again and keeps the new content:

```bash
stow --adopt --no-folding -t "$HOME" hypr
git diff        # examine what Omarchy wrote, then keep it or remove it
```

## Per-host configuration

All machines use the same `hypr/monitors.lua`. The `output = ""` rule sets the
scale of the panel of the machine that you are on. Leave that panel to this
rule, because Omarchy writes the scale of the current panel to it.

Give the panel of a different machine its own rule. Such a rule uses `desc:` to
select a monitor. Therefore a rule for a panel that you did not connect has no
effect. The rules for all machines stay in one file. This also gives correct
results when you connect a laptop to a dock.

`desc:` makes a match on the start of the text `<make> <model> <serial>`. Use
the make and the model to select every panel of one type. Add the serial to
select one panel. The serial is the only way to tell two identical panels
apart.

To find the string for a rule:

```bash
hyprctl -j monitors all | jq -r '.[].description'
```

`jamesdesktop` has three identical DELL U2715H panels. Each one therefore has a
rule with a serial. Each rule also gives a position, in place of `auto`,
because `auto` puts the panels in the sequence that Hyprland finds them, and
that sequence is not the sequence on the desk.

`GDK_SCALE` is not in a per-host file. It is `omarchy_gdk_scale` in
`monitors.lua`, because `omarchy-hyprland-monitor-scaling` writes it together
with the monitor scale. A second copy in a per-host file becomes stale.

Put other per-machine settings in `hypr/hosts/<hostname>.lua`. Hyprland loads
this file if the file exists. If the file does not exist, Hyprland continues and
gives no error message.

Git has its own per-host mechanism. The last lines of `git/.config/git/config`
include `~/.config/git/config.local`. That file is not in this repo. Write the
settings of one machine into it, for example a work email:

```ini
[user]
	email = james@example.com
```

Git reads the include after the rest of the config, so a value in
`config.local` wins. Git gives no error when the file does not exist, so a
machine without the file uses the defaults from this repo. Note that
`git config --global user.email` does not show the result, because `--global`
reads one file without its includes. Use `git config user.email` to see the
value that git really uses.

These are four results from Hyprland 0.56.2. The first two come from
`CMonitorRuleManager::get()` and `CMonitor::matchesStaticSelector()` in the
source code:

- **A specific rule has priority over the `output = ""` fallback rule.** The
  sequence of the rules has no effect. Do not sort the rules. Hyprland compares
  an empty selector with the NAME of the output, and a name is never empty.
  Therefore the fallback rule matches nothing in the main loop. Hyprland uses
  it only in a second loop, after no specific rule made a match.
- **Between two specific rules, the last rule wins.** Hyprland reads the rules
  in reverse sequence and uses the first match. A `desc:` rule has no priority
  over a rule that gives the name of an output. Therefore a file that Hyprland
  loads after `monitors.lua` replaces these rules, and gives no message. This
  is what `hyprmon.lua` does. Read the note in the **Packages** section.
- **Hyprland changes an incorrect scale to the nearest correct scale, and gives
  no message.** A scale is correct only if it divides the pixel dimensions of
  the panel into whole numbers. On a 2560x1600 panel, a scale of 1.5 gives
  1706.67 pixels, and Hyprland changes the scale to 1.6. If Hyprland does not
  use the scale that you set, do the calculation first. Then examine the rule.
- **Do not use `os.getenv("HOSTNAME")` to select the per-host file.**
  `HOSTNAME` is a bash shell variable, and bash does not export it. Therefore
  the Lua code in Hyprland reads `nil`. `require_optional` gives no error for a
  module that it cannot find. Therefore the per-host file never loads, and
  nothing tells you about the failure. Read `/etc/hostname` in place of the
  variable.

### Workspaces on the three-monitor machines

`jamestccsbox` and `jamesdesktop` each have three panels side by side. Both pin
the same workspace numbers to the same positions on the desk:

| Left    | Centre     | Right    |
|---------|------------|----------|
| 5 6 7   | 1 2 3 4    | 8 9 10   |

Hyprland otherwise gives workspaces to monitors in the sequence that it finds
the monitors. Therefore `Super + 3` reaches a different screen after a reboot or
a replug. The rules make the number a place instead.

`hypr/lib/workspaces.lua` holds the layout. Each host file calls it with the
three `desc:` strings of that machine:

```lua
require("hypr.lib.workspaces").three_across({
  left = "desc:Dell Inc. DELL U2415 7MT0177S3UNL",
  centre = "desc:Dell Inc. DELL U2415 07MT01624065L",
  right = "desc:Dell Inc. DELL U2415 07MT016231KCL",
})
```

The first workspace of each row is that monitor's default: 5 on the left, 1 in
the centre, 8 on the right. These are the workspaces that a session starts with.

The workspaces are not persistent. An empty workspace leaves the bar until
something opens on it. The rule still holds, so `Super + 6` makes workspace 6 on
the left screen again. To show all ten at all times, add `persistent = true` to
the `hl.workspace_rule` call in `hypr/lib/workspaces.lua`.

The layout is in the per-host files and not in `hypr/monitors.lua`, unlike the
monitor rules. A monitor rule for a panel that you did not connect has no
effect. A workspace rule for a panel that you did not connect does not behave
the same way, because Hyprland must put the workspace on some monitor.

A rule applies when Hyprland makes the workspace. A workspace that already
exists stays on its monitor until the next login.

Test the rules with:

```bash
hyprctl -j workspacerules | jq -r '.[] | "\(.workspaceString) -> \(.monitor)"'
hyprctl dispatch 'hl.dsp.focus({ workspace = "6" })'
hyprctl -j monitors | jq -r '.[] | select(.focused) | .name'
```

Note the Lua form of `hyprctl dispatch`. Hyprland 0.56 reads the configuration
with a Lua parser, and it rejects the old `hyprctl dispatch workspace 6` with
`')' expected near '6'`. `hyprctl keyword` gives `keyword can't work with
non-legacy parsers`, and `hyprctl eval` takes its place.

## SSH

`~/.ssh/config` tells ssh to use the 1Password agent:

```
Host *
	IdentityAgent ~/.1password/agent.sock
```

With this setting, git-over-ssh and git signature operations work, and no
private key is on the disk.

This setting replaced an `export SSH_AUTH_SOCK=...` line in `.zshrc`. Commit
`b8ff26b` added that line, and commit `b3b3ad9` deleted it with the other zsh
files. `IdentityAgent` is better, because it limits the agent to ssh. The
environment variable gave the agent to all processes.

Note: ssh does not accept a configuration file that the group or other users
can write to. Git records only the executable bit. Therefore a new clone gives
mode 644. The `bootstrap` script sets mode 600. If you use `stow` directly, set
the mode yourself.

## Plugins

Omarchy has two kinds of shell plugin, and this repo treats them differently.

**First-party plugins** are part of the Omarchy package. You do not install
them. There are 37 of them on this system.

**Third-party plugins** are git clones in `~/.config/omarchy/plugins/`. This
repo does not track that directory, because each plugin is its own git repo.
`plugins.txt` records the id and the git URL of each one instead. `bootstrap`
reads that file and installs the plugins that are absent.

`shell.json` decides which plugins are on. A plugin is on when `shell.json`
refers to its id, either in `bar.layout` or in the `plugins` array. First-party
plugins that are not bar widgets are always on. This repo tracks `shell.json`,
so the on/off state of every plugin arrives with the other files. Only the code
of a third-party plugin is missing on a new machine, and `plugins.txt` supplies
that.

To add a plugin to this repo:

```bash
omarchy plugin add <git-url> --enable       # install it and switch it on
jq -r .id ~/.config/omarchy/plugins/<dir>/manifest.json
```

Put the id and the URL in `plugins.txt`. Then commit `plugins.txt` and the
`shell.json` change together.

Note: `omarchy-plugin-add` stops with an error when the plugin is already
installed. Therefore `bootstrap` tests for the directory of each plugin first.

## Setup scripts

`setup/` holds scripts that change the system and not `$HOME`. It is not a stow
package, and `bootstrap` never stows it.

There are two scripts at present.

`setup/plymouth` — Plymouth draws the screen during start-up, which includes
the prompt for the disk encryption passphrase. The script gives a background
colour, a text colour and a logo to `omarchy-plymouth-set`. That command also
makes the SDDM login screen agree with those colours. It then builds the
initramfs again, because the theme goes inside the initramfs. There is no
second command to run.

`setup/wallpaper` — the stow phase links the Curve wallpaper from the
`omarchy` package into `~/.config/omarchy/backgrounds/tokyo-night/`, which
adds it to the Omarchy background switcher (`Super+Ctrl+Space`). This script
then makes it the current background with `omarchy-theme-bg-set`. On a machine
whose theme is not tokyo-night, the script changes nothing.

These scripts need root and they are slow, so `bootstrap` runs a script only
when something changed. It makes a SHA-256 hash of the script. The hash also
covers each file next to the script whose name starts with the name of the
script. `setup/plymouth` and
`setup/plymouth-logo.png` are therefore hashed together, and a change to either
one causes a new run. `bootstrap` keeps the hash of the last good run in
`.state/`. `.gitignore` excludes that directory, because the hash describes the
machine and not the repo. A new machine has no `.state/`, so each script runs
one time.

Run the scripts again when nothing changed:

```bash
./bootstrap --force-setup
```

Start `./bootstrap` from a terminal. The scripts need a password for sudo, and
`bootstrap` asks for it before the first script starts. A pipe or a scheduled
job has no terminal. Such a run reports that it cannot ask for a password, and
it makes no change.

To change the start-up screen, edit the colours in `setup/plymouth` or replace
`setup/plymouth-logo.png`. Then run `./bootstrap`. Look at a change first with
`omarchy plymouth preview`, which writes a PNG and changes nothing. Remove the
change with `omarchy plymouth reset`.

## What this repo does not contain

- **Secrets and application data** — browser profiles, `1Password/`, `gh/`,
  `k9s/`, and cloud credentials. The `ssh` package contains `config` only.
  `.gitignore` excludes all other files in `~/.ssh`. Therefore you cannot
  commit a private key by accident.
- **`~/.config/omarchy/current/`** — Omarchy makes these symbolic links again
  each time that you run `omarchy theme set`.
- **`~/.config/omarchy/plugins/`** — each third-party plugin is its own git
  repo. `plugins.txt` records the git URL of each one, and `bootstrap` installs
  them.
- **`.state/`** — the hash of the last good run of each script in `setup/`. It
  describes this machine, so a new machine runs each script one time.
- **`*.bak` and `*.omarchy-upgrade-to-*.bak`** — backup files from Omarchy.
  Their names contain a date and a time. See `.gitignore`.
- **`~/.config/hypr/hyprlock.conf` and `hypridle.conf`** — Omarchy 4 does not
  use these files. The `hyprlock` and `hypridle` programs are not installed on
  this system. Quickshell locks the screen with `omarchy-shell lock lock`. The
  idle times are the `idle.lock` and `idle.screensaver` values in `shell.json`.

## Branding

The About art and the screensaver art are UTF-8 braille characters, not images.
Therefore git shows the differences between two versions correctly.

`omarchy branding about image` reads a PNG file or an SVG file. It sends the
file to `omarchy-transcode-ascii` with a width of 54 columns and a height of 26
rows. Then it writes the result.

```bash
omarchy branding about image        # make the art again from an image file
omarchy branding about text         # edit the art directly
omarchy branding about reset        # put back the default art from Omarchy
```

`omarchy branding screensaver` has the same three commands.

## History

Commit `b3b3ad9` deleted the previous configuration for Ubuntu and GNOME. That
configuration used powerline, terminator, zsh, and Test Kitchen CI. This repo
did not move those files to Omarchy. To read them, examine commit `b8ff26b`.
That commit is the last commit before the deletion.
