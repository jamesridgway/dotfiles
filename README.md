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
| `hypr`      | `monitors.lua` and the per-host files in `hypr/hosts/`                                           |
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

The test run looks for a file that is already at a target path. If it finds
such a file, the script stops and changes nothing. If all the symbolic
links are already correct, the script tells you that there is no work to do.

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
select a monitor. `desc:` is the make and the model of the panel. Therefore a
rule for a panel that you did not connect has no effect. The rules for all
machines stay in one file. This also gives correct results when you connect a
laptop to a dock.

To find the string for a rule:

```bash
hyprctl -j monitors all | jq -r '.[].description'
```

`GDK_SCALE` is not in a per-host file. It is `omarchy_gdk_scale` in
`monitors.lua`, because `omarchy-hyprland-monitor-scaling` writes it together
with the monitor scale. A second copy in a per-host file becomes stale.

Put other global settings in `hypr/hosts/<hostname>.lua`. Hyprland loads this
file if the file exists. If the file does not exist, Hyprland continues and
gives no error message.

These are three results of tests with Hyprland 0.56.2:

- **A `desc:` rule has priority over the `output = ""` fallback rule.** The
  sequence of the rules has no effect. Do not sort the rules.
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

## What this repo does not contain

- **Secrets and application data** — browser profiles, `1Password/`, `gh/`,
  `k9s/`, and cloud credentials. The `ssh` package contains `config` only.
  `.gitignore` excludes all other files in `~/.ssh`. Therefore you cannot
  commit a private key by accident.
- **`~/.config/omarchy/current/`** — Omarchy makes these symbolic links again
  each time that you run `omarchy theme set`.
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
