# herdr-app config

Read `~/.config/herdr-app/AGENTS.md` first. It is Herdr's guide to the mod API.

- Stow links this folder into `~/.config/herdr-app`. Run `stow herdr` from `~/dotfiles` after you add a file.
- Edit `layouts/custom.json`. Do not edit the shipped layouts or mods.
- After each mod change, run `herdr-app check ~/.config/herdr-app/mods/<name>`.

## Keys

Bind each pane or picker to a `ctrl-shift-<key>` key in `keys.json`. Read `keys.json` first, and use a key that is not in it.

## Look

Pickers and notifications look like the panes in `layouts/custom.json` (Omarchy style).

- Set `"frame": "none"` in the picker's `mod.json` overlay.
- Draw the frame in the mod: `.bg(t.background).border(2).border_color(frameColor(t))`. Copy `frameColor` from `mods/github`. It reads the focused-pane border color from the layout.
- Do not use rounded corners.

## Keyboard control

Each pane and picker must work from the keyboard only. Use `mods/github` and `mods/worktrees` as the models.

| Key | Action |
|---|---|
| `j`/`k`, `ctrl-n`/`ctrl-p` | Move down or up |
| `g`/`G` | Go to the first or last row |
| `o`/`enter` | Do the main action |
| `r` | Refresh |
| `q`/`esc` | Close |

- Use one letter for each other action.
- Make the user press the key two times for a destructive action, for example `d d`.
- Show the keys in a footer line.

## Worktrees

Do not run `wt` or `git worktree` from a mod. Add a job to the `worktrees` mod. That mod runs `wt`, shows the progress in the sidebar, and opens the space.

```js
const job = { op: "switch", folder: dir, target: `pr:${n}`, label: `repo#${n}` };
setShared("worktrees.jobs", { ...(shared("worktrees.jobs") ?? {}), [`${Date.now()}-${n}`]: job });
closeOverlay(props().overlay);
```

| Field | Value |
|---|---|
| `op` | `"switch"` or `"remove"` |
| `folder` | A checkout of the repo. Use `focused().cwd`. |
| `target` | A branch, `pr:N`, or a worktree path |
| `create`, `base` | `switch` only. Set `create: true` to make a new branch from `base`. |
| `focus` | `switch` only. Set `false` to open the space in the background. |
| `label` | The text that the sidebar shows |
| `argv`, `task`, `tab` | `switch` only. Start an agent (`argv`) in the worktree space with `task` as its first message, in a tab named `tab`. If the space is open, the agent starts in a new tab. |

- Use a job only to create or remove a worktree. If the worktree exists, select its space. Do not add a job.
- Make sure that `folder` is in the correct repo before you add the job.
- Do not remove the `worktrees` block from `layouts/custom.json`. That block runs the jobs.
- If you need a new operation, add it to `mods/worktrees/main.js`. Then update this section.
