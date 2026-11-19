// Worktrees through worktrunk (`wt`), so its hooks run. One mod, two roles:
// - props {role: "status"}: the sidebar block "worktrees" (layouts/custom.json). It runs every job and
//   shows its progress under the spaces list, growing the block only while there's something to show.
// - otherwise (mod.open:worktrees, keys.json): a finder of the focused folder's repo worktrees.
//   Switching to one is immediate; creating (n) and removing (d twice) run as jobs.
//   Keys: j/k or ctrl-n/ctrl-p move, g/G first/last, o/enter switch, n new, d twice remove, r refresh, q/esc close.
//
// Other mods queue jobs through shared state (mods can't import each other):
//   setShared("worktrees.jobs", { ...(shared("worktrees.jobs") ?? {}), [id]: job })
//   { op: "switch", folder, target, create?, base?, focus?, label?, argv?, task?, tab? }: wt switch <target> in folder
//     (create: --create [--base] unless the branch exists), then shows the worktree's space (focus: false keeps the
//     shown one). argv starts an agent there with task as its first message, in a tab named tab (a new tab if the
//     space is already open).
//   { op: "remove", folder, target, label? }: closes the worktree's spaces, then wt remove <target>.
//   folder: any checkout of the repo; target: what wt takes (branch, pr:N, path); label: shown for target.
// The status block adds state ("running" | "done" | "failed") and error, and drops finished jobs.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, ScrollHandle, InputState, Input } from "gpui-base";
import { exec, run, notify, shared, setShared, spaces, panes, focused, layout, home, theme, props, closeOverlay, nextCommand, checking } from "herdr";

const KEY = "worktrees.jobs";
const BLOCK = "worktrees";
const ROW_H = 26;
const DONE_MS = 4000;
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

const jobs = () => shared(KEY) ?? {};
// change null drops the job.
const patch = (id, change) => {
  const all = { ...jobs() };
  if (change === null) delete all[id];
  else if (all[id]) all[id] = { ...all[id], ...change };
  setShared(KEY, all);
};
const queue = (job) => setShared(KEY, { ...jobs(), [`${Date.now()}-${Math.random().toString(36).slice(2, 8)}`]: job });

// Whether the shown layout has the status block that runs jobs.
function hasRunner(node = layout()) {
  if (!node || typeof node !== "object") return false;
  if (node.content?.mod === "worktrees" && node.content.props?.role === "status") return true;
  return (node.children ?? []).some((c) => hasRunner(c));
}

const tilde = (p) => (p.startsWith(home()) ? `~${p.slice(home().length)}` : p);
const inside = (p, dir) => p === dir || p.startsWith(dir + "/");

async function git(cwd, args) {
  const r = await exec("git", args, { cwd, timeout: 30_000 });
  return { ok: r.code === 0, out: r.stdout.trim(), err: (r.stderr || r.stdout).trim() };
}

// The repo a folder belongs to: { top, main } (main: the main checkout). null outside git.
async function repoOf(folder) {
  const top = await git(folder, ["rev-parse", "--show-toplevel"]);
  const common = await git(folder, ["rev-parse", "--path-format=absolute", "--git-common-dir"]);
  if (!top.ok || !common.ok) return null;
  return { top: top.out, main: common.out.replace(/\/\.git$/, "") };
}

// The repo's checkouts, the main one first: { path, branch, main }.
async function checkouts(main) {
  const r = await git(main, ["worktree", "list", "--porcelain"]);
  if (!r.ok) throw new Error(r.err || "git worktree list failed");
  const out = [];
  for (const block of r.out.split(/\n\n+/)) {
    const lines = block.split("\n");
    const path = lines.find((l) => l.startsWith("worktree "))?.slice(9);
    if (!path || lines.some((l) => l === "bare" || l.startsWith("prunable"))) continue;
    const branch = lines.find((l) => l.startsWith("branch "))?.slice(7).replace(/^refs\/heads\//, "") ?? null;
    out.push({ path, branch, main: out.length === 0 });
  }
  return out;
}

// Where a space is now: its first terminal's live folder, else where it was made.
function place(s) {
  const tabs = new Set((s.tabs ?? []).map((t) => t.id));
  return panes().find((p) => tabs.has(p.tab) && p.cwd)?.cwd || s.folder || null;
}

// The local spaces showing a checkout (not one of the other checkouts nested in it).
function spacesAt(path, all) {
  return spaces().filter((s) => {
    const at = !s.machine && place(s);
    return at && inside(at, path) && !all.some((c) => c !== path && c.length > path.length && inside(at, c));
  });
}

function focusedFolder() {
  const f = focused();
  const s = spaces().find((s) => s.id === f?.space);
  return f?.cwd || (s && place(s)) || null;
}

async function wt(folder, args) {
  // stdin isn't a terminal, so a hook approval prompt fails instead of hanging.
  const r = await exec("wt", [...args, "--format=json"], { cwd: folder, timeout: 600_000 });
  if (r.code !== 0) {
    const err = r.stderr.trim() || `wt exited with ${r.code}`;
    const hint = /approv/i.test(err) ? `\nRun \`wt ${args.join(" ")}\` in ${tilde(folder)} once to approve its hooks.` : "";
    throw new Error(err + hint);
  }
  try {
    return JSON.parse(r.stdout);
  } catch {
    return {};
  }
}

const verb = (j) => (j.op === "remove" ? "removing" : j.create ? "creating" : "switching to");
const doneText = (j) => (j.op === "remove" ? "removed" : "ready");

export default class Worktrees extends View {
  init(_props, cx) {
    this.status = props()?.role === "status";
    if (this.status) return this.initStatus(cx);
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.timer.after(150, () => this.handle.focus());
    this.scroll = ScrollHandle.new();
    this.repo = undefined; // undefined: looking, null: not in git
    this.list = [];
    this.at = 0;
    this.confirm = null; // the path d was pressed on once
    this.error = null;
    this.running = new Set(); // this repo's running jobs, to reload once one finishes
    this.creating = false; // n: typing a new branch name
    this.input = InputState.new({ placeholder: "new branch name" });
    this.input.on("submit", (_e, cx) => {
      this.create();
      cx.notify();
    });
    cx.spawn(async (cx) => {
      for (;;) if ((await nextCommand()) === "focus") this.handle.focus();
    });
    this.load(cx);
  }

  // Status role: runs jobs one at a time (they share the repo's git locks).

  initStatus(cx) {
    this.pumping = false;
    this.height = null;
    if (checking()) return;
    // A restart interrupted whatever was running; finished ones are old news.
    for (const [id, j] of Object.entries(jobs())) {
      if (j.state === "running") patch(id, { state: "failed", error: "Interrupted: Herdr restarted" });
      else if (j.state === "done") patch(id, null);
    }
    cx.spawn(async (cx) => this.pump(cx));
  }

  async pump(cx) {
    if (this.pumping) return;
    this.pumping = true;
    for (;;) {
      const next = Object.entries(jobs()).find(([, j]) => !j.state);
      if (!next) break;
      const [id, job] = next;
      // repo: the main checkout, so the finder knows its jobs.
      patch(id, { state: "running", repo: (await repoOf(job.folder).catch(() => null))?.main ?? job.folder });
      try {
        const path = job.op === "remove" ? await this.remove(job) : await this.switch(job);
        patch(id, { state: "done", path });
        cx.timer.after(DONE_MS, () => patch(id, null));
      } catch (e) {
        const error = String(e?.message ?? e);
        patch(id, { state: "failed", error });
        notify({ title: `Worktree ${job.label ?? job.target} failed`, body: error, level: "error" });
      }
    }
    this.pumping = false;
  }

  async switch(job) {
    // An existing branch (local or on a remote) is checked out rather than created.
    const exists = job.create && (await git(job.folder, ["for-each-ref", "--count=1", `refs/heads/${job.target}`, `refs/remotes/*/${job.target}`])).out;
    const create = job.create && !exists;
    const target = create ? ["--create", job.target, ...(job.base ? ["--base", job.base] : [])] : [job.target];
    const { path } = await wt(job.folder, ["switch", ...target, "--no-cd"]);
    if (!path) throw new Error("worktrunk returned no worktree path");
    const agent = job.argv?.length ? { argv: job.argv, task: job.task, tab: job.tab } : null;
    this.show(path, job.focus ?? true, await this.paths(path), agent);
    return path;
  }

  async remove(job) {
    const repo = await repoOf(job.folder);
    if (!repo) throw new Error(`${tilde(job.folder)} is not in a git repository`);
    const all = await checkouts(repo.main);
    const c = all.find((c) => c.path === job.target || c.branch === job.target);
    if (!c) throw new Error(`No worktree for ${job.target}`);
    if (c.main) throw new Error("That's the repository's main checkout");
    // Check before closing its spaces: wt refuses a dirty worktree anyway.
    const status = await git(c.path, ["--no-optional-locks", "status", "--porcelain"]);
    if (status.out) throw new Error(`${c.branch ?? tilde(c.path)} has uncommitted changes`);
    for (const s of spacesAt(c.path, all.map((c) => c.path))) run("space.close", { id: s.id, confirmed: true });
    await wt(repo.main, ["remove", c.branch ?? c.path, "--foreground"]);
    return c.path;
  }

  async paths(path) {
    const repo = await repoOf(path);
    return repo ? (await checkouts(repo.main)).map((c) => c.path) : [path];
  }

  // Selects the checkout's space, else opens one. Unnamed, so the spaces list nests it under its repo.
  // agent {argv, task, tab}: starts it there, in a new tab if the space is already open.
  show(path, focus, all, agent = null) {
    const s = spacesAt(path, all)[0];
    if (s && agent) run("tab.new", { space: s.id, folder: path, name: agent.tab, argv: agent.argv, task: agent.task, focus });
    else if (s && focus) run("space.select", { id: s.id });
    else if (!s) run("space.new", { folder: path, focus, ...(agent && { tab: agent.tab, argv: agent.argv, task: agent.task }) });
  }

  renderStatus(cx) {
    const t = theme();
    const list = Object.entries(jobs());
    if (!checking()) {
      if (!this.pumping && list.some(([, j]) => !j.state)) cx.spawn(async (cx) => this.pump(cx));
      const height = list.length ? list.length * ROW_H + 8 : 0;
      if (height !== this.height) {
        this.height = height;
        cx.spawn(async () => run("layout.resize", { id: BLOCK, px: height }));
      }
    }
    const row = ([id, j]) => {
      const name = j.label ?? j.target;
      const [icon, color, text] =
        j.state === "failed"
          ? [div().child("✗"), t.ansi1, `${name}: ${j.error?.split("\n")[0] ?? "failed"}`]
          : j.state === "done"
            ? [div().child("✓"), t.ansi2, `${name} ${doneText(j)}`]
            : [j.state ? div().frames(SPINNER, 90) : div().child("·"), t.accent, `${verb(j)} ${name}`];
      return h_flex()
        .id(`job-${id}`)
        .h(ROW_H)
        .flex_none()
        .px(12)
        .gap(8)
        .items_center()
        .text_size(12)
        .cursor_pointer()
        .hover((s) => s.bg(t.hover))
        // A failed job stays until clicked; a done switch goes to its space.
        .on_click(() => {
          if (j.state === "failed") patch(id, null);
          else if (j.state === "done" && j.op === "switch") this.show(j.path, true, [j.path]);
        })
        .child(div().w(12).flex_none().text_color(color).child(icon))
        .child(div().flex_1().min_w(0).truncate().text_color(j.state === "failed" ? t.ansi1 : t.muted).child(text));
    };
    return v_flex().id("worktrees-status").size_full().py(4).overflow_hidden().children(list.map(row));
  }

  // Finder role.

  load(cx) {
    if (checking()) return;
    cx.spawn(async (cx) => {
      try {
        const dir = focusedFolder();
        if (!dir) throw new Error("No focused terminal folder");
        this.repo = await repoOf(dir);
        if (!this.repo) throw new Error(`${tilde(dir)} is not in a git repository`);
        this.list = await checkouts(this.repo.main);
        this.at = Math.min(this.at, Math.max(0, this.list.length - 1));
        this.error = null;
      } catch (e) {
        this.error = String(e?.message ?? e);
      }
      cx.notify();
    });
  }

  // This repo's job for a checkout, if any.
  jobOf(c) {
    return Object.values(jobs()).find((j) => j.repo === this.repo?.main && (j.target === c.branch || j.target === c.path));
  }

  move(to) {
    const n = this.list.length;
    this.at = n ? Math.max(0, Math.min(n - 1, to)) : 0;
    this.scroll.scroll_to_item(this.at);
  }

  close() {
    if (props()?.overlay) closeOverlay(props().overlay);
  }

  enqueue(job) {
    if (!hasRunner()) {
      this.error = "This layout has no worktrees status block to run jobs";
      return false;
    }
    queue({ ...job, folder: this.repo.main });
    return true;
  }

  // The worktree exists: no wt needed, only its space.
  switchTo(c) {
    if (!c) return;
    this.close();
    this.show(c.path, true, this.list.map((c) => c.path));
  }

  startCreate(cx) {
    if (!this.repo) return;
    this.creating = true;
    this.input.set_value("");
    // The input mounts on the next render: focus it once it's there.
    cx.timer.after(50, () => this.input.focus());
  }

  stopCreate() {
    this.creating = false;
    this.handle.focus();
  }

  create() {
    const branch = this.input.value().trim();
    if (!branch) return;
    if (this.enqueue({ op: "switch", create: true, target: branch, label: branch })) this.close();
    else this.stopCreate();
  }

  removeAt(c) {
    if (!c) return;
    if (c.main) this.error = "That's the repository's main checkout";
    else if (this.confirm !== c.path) this.confirm = c.path;
    else {
      this.confirm = null;
      this.enqueue({ op: "remove", target: c.branch ?? c.path, label: c.branch ?? tilde(c.path) });
    }
  }

  key(e, cx) {
    const k = e.key, ctrl = e.modifiers.control;
    const c = this.list[this.at];
    // While typing a branch name, keys belong to the input (enter submits it).
    if (this.creating) {
      if (k !== "escape") return;
      this.stopCreate();
      cx.stop_propagation();
      return cx.notify();
    }
    if (k !== "d") this.confirm = null;
    if (ctrl && k === "n") this.move(this.at + 1);
    else if (ctrl && k === "p") this.move(this.at - 1);
    else if (ctrl) return;
    else if (k === "j" || k === "down") this.move(this.at + 1);
    else if (k === "k" || k === "up") this.move(this.at - 1);
    else if (e.key_char === "G") this.move(this.list.length - 1);
    else if (k === "g") this.move(0);
    else if (k === "o" || k === "enter") this.switchTo(c);
    else if (k === "n") this.startCreate(cx);
    else if (k === "d") this.removeAt(c);
    else if (k === "r") this.load(cx);
    else if (k === "q" || k === "escape") return this.close();
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  row(c, index, t, all) {
    const selected = index === this.at;
    const job = this.jobOf(c);
    const badge = (text, color) => div().flex_none().px(6).rounded(4).text_size(11).border_1().border_color(color).text_color(color).child(text);
    const open = spacesAt(c.path, all).length > 0;
    return h_flex()
      .id(`wt-${c.path}`)
      .h(30)
      .flex_none()
      .px(10)
      .gap(10)
      .items_center()
      .rounded(6)
      .cursor_pointer()
      .when(selected, (s) => s.bg(t.selected))
      .hover((s) => s.bg(selected ? t.selected : t.hover))
      .on_click((_e, cx) => {
        this.at = index;
        this.switchTo(c);
        cx.notify();
      })
      .child(div().flex_none().max_w(260).truncate().text_color(selected ? t.foreground : t.muted).child(c.branch ?? "detached"))
      .child(div().flex_1().min_w(0).truncate().text_size(12).text_color(t.dim).child(tilde(c.path)))
      .when(this.confirm === c.path, (s) => s.child(div().flex_none().text_size(12).text_color(t.ansi1).child("d again to remove")))
      .when(Boolean(job && job.state !== "failed" && job.state !== "done"), (s) =>
        s.child(div().flex_none().text_size(12).text_color(t.accent).frames(SPINNER.map((f) => `${f} ${job.op === "remove" ? "removing" : "updating"}`), 90)),
      )
      .when(c.path === this.repo?.top, (s) => s.child(badge("here", t.accent)))
      .when(open && c.path !== this.repo?.top, (s) => s.child(badge("open", t.dim)))
      .when(c.main, (s) => s.child(badge("main", t.dim)));
  }

  render(cx) {
    if (this.status) return this.renderStatus(cx);
    const t = theme();
    // Reload once one of this repo's jobs finishes (a removed worktree goes from the list).
    const running = new Set(Object.entries(jobs()).filter(([, j]) => j.repo === this.repo?.main && j.state === "running").map(([id]) => id));
    const finished = [...this.running].some((id) => !running.has(id));
    this.running = running;
    if (finished) this.load(cx);
    const all = this.list.map((c) => c.path);
    const hints = this.creating ? "↵ create · esc cancel" : "j/k move · o switch · n new · d d remove · r refresh · q close";
    return v_flex()
      .id("worktrees")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .size_full()
      .min_h(0)
      .p(12)
      .gap(6)
      .bg(t.popover)
      .text_size(13)
      .child(
        h_flex()
          .flex_none()
          .px(10)
          .gap(10)
          .items_center()
          .child(div().text_size(15).font_semibold().text_color(t.foreground).child("Worktrees"))
          .child(
            div()
              .flex_1()
              .min_w(0)
              .truncate()
              .text_size(12)
              .text_color(this.error ? t.ansi1 : t.dim)
              .child(this.error ? this.error.split("\n")[0] : this.repo ? tilde(this.repo.main) : "…"),
          ),
      )
      .when(this.creating, (s) =>
        s.child(
          Input.new(this.input)
            .flex_none()
            .h(32)
            .px(10)
            .items_center()
            .rounded(6)
            .border(1)
            .border_color(t.accent)
            .bg(t.background)
            .text_color(t.foreground),
        ),
      )
      .child(
        v_flex()
          .id("wt-list")
          .max_h(480)
          .overflow_y_scrollbar()
          .track_scroll(this.scroll)
          .children(this.list.map((c, i) => this.row(c, i, t, all))),
      )
      .child(div().flex_none().px(10).text_size(11).text_color(t.dim).child(hints));
  }
}
