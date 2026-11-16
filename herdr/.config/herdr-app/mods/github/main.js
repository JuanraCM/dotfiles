// GitHub work: my open PRs and the PRs where my review is directly requested.
// One `gh api graphql` call feeds both lists (gh handles auth). Opened with ctrl-shift-g (keys.json).
// Keys: j/k or ctrl-n/ctrl-p move, ctrl-d/ctrl-u jump, g/G first/last, o/enter open in browser, r refresh, q/esc close.

import { View, div } from "gpui-kit";
import { v_flex, h_flex, ScrollHandle } from "gpui-base";
import { exec, theme, props, closeOverlay, nextCommand, checking } from "herdr";

const QUERY = `
fragment pr on PullRequest {
  number title url isDraft
  repository { nameWithOwner }
  author { login }
  commits(last: 1) { nodes { commit { statusCheckRollup { state } } } }
}
query {
  mine: search(query: "is:pr is:open archived:false author:@me sort:updated-desc", type: ISSUE, first: 50) { nodes { ...pr } }
  reviews: search(query: "is:pr is:open archived:false user-review-requested:@me sort:updated-desc", type: ISSUE, first: 50) { nodes { ...pr } }
}`;

const REFRESH_MS = 120_000;
const SPINNER = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"];

// statusCheckRollup.state -> [glyph, label, theme color]
const CI = {
  SUCCESS: ["✓", "passed", "ansi2"],
  FAILURE: ["✗", "failed", "ansi1"],
  ERROR: ["✗", "failed", "ansi1"],
  PENDING: [null, "running", "ansi3"],
  EXPECTED: [null, "running", "ansi3"],
};

const ciOf = (pr) => CI[pr.commits.nodes[0]?.commit.statusCheckRollup?.state] ?? ["·", "no checks", "dim"];

export default class GitHub extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.timer.after(150, () => this.handle.focus());
    this.scroll = ScrollHandle.new();
    this.mine = [];
    this.reviews = [];
    this.at = 0;
    this.loading = false;
    this.error = null;
    this.updated = null;
    // As a pane, pane.go hands over the keyboard with "focus".
    cx.spawn(async (cx) => {
      for (;;) if ((await nextCommand()) === "focus") this.handle.focus();
    });
    if (checking()) return;
    this.refresh(cx);
    cx.timer.every(REFRESH_MS, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    if (this.loading) return;
    this.loading = true;
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const r = await exec("gh", ["api", "graphql", "-f", `query=${QUERY}`]);
        if (r.code !== 0) throw new Error(r.stderr.trim() || `gh exited with ${r.code}`);
        const { data } = JSON.parse(r.stdout);
        this.mine = data.mine.nodes;
        this.reviews = data.reviews.nodes;
        this.error = null;
        this.updated = new Date();
      } catch (e) {
        this.error = String(e?.message ?? e);
      }
      this.loading = false;
      cx.notify();
    });
  }

  get items() {
    return [...this.mine, ...this.reviews];
  }

  move(to) {
    const n = this.items.length;
    this.at = n ? Math.max(0, Math.min(n - 1, to)) : 0;
    // List children: header, mine (or placeholder), header, reviews (or placeholder).
    const i = this.at < this.mine.length ? 1 + this.at : 2 + Math.max(1, this.mine.length) + (this.at - this.mine.length);
    this.scroll.scroll_to_item(i);
  }

  open(pr) {
    if (pr) exec("open", [pr.url]);
  }

  key(e, cx) {
    const k = e.key, ctrl = e.modifiers.control;
    if (ctrl && k === "n") this.move(this.at + 1);
    else if (ctrl && k === "p") this.move(this.at - 1);
    else if (ctrl && k === "d") this.move(this.at + 5);
    else if (ctrl && k === "u") this.move(this.at - 5);
    else if (ctrl) return;
    else if (k === "j" || k === "down") this.move(this.at + 1);
    else if (k === "k" || k === "up") this.move(this.at - 1);
    else if (e.key_char === "G") this.move(this.items.length - 1);
    else if (k === "g") this.move(0);
    else if (k === "o" || k === "enter") this.open(this.items[this.at]);
    else if (k === "r") this.refresh(cx);
    else if ((k === "q" || k === "escape") && props()?.overlay) return closeOverlay(props()?.overlay);
    else return;
    cx.stop_propagation();
    cx.notify();
  }

  row(pr, index, t, showAuthor) {
    const [glyph, ci, ciColor] = ciOf(pr);
    const selected = index === this.at;
    const badge = (text, color) => div().flex_none().px(6).rounded(4).text_size(11).border_1().border_color(color).text_color(color).child(text);
    return h_flex()
      .id(`pr-${pr.url}`)
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
        this.open(pr);
        cx.notify();
      })
      .child(
        glyph
          ? div().w(14).flex_none().text_color(t[ciColor]).child(glyph)
          : div().w(14).flex_none().text_color(t[ciColor]).frames(SPINNER, 90),
      )
      .child(div().flex_none().text_color(t.dim).child(`${pr.repository.nameWithOwner.split("/")[1]}#${pr.number}`))
      .child(div().flex_1().min_w(0).truncate().text_color(selected ? t.foreground : t.muted).child(pr.title))
      .when(showAuthor, (s) => s.child(div().flex_none().text_size(12).text_color(t.dim).child(`@${pr.author?.login ?? "ghost"}`)))
      .child(pr.isDraft ? badge("draft", t.dim) : badge("ready", t.accent))
      .child(div().w(64).flex_none().text_size(12).text_color(t[ciColor]).child(ci));
  }

  section(title, prs, offset, t, showAuthor) {
    const header = h_flex()
      .flex_none()
      .px(10)
      .pt(10)
      .pb(4)
      .gap(6)
      .text_size(11)
      .font_semibold()
      .text_color(t.dim)
      .child(title.toUpperCase())
      .child(div().text_color(t.muted).child(String(prs.length)));
    const rows = prs.length
      ? prs.map((pr, i) => this.row(pr, offset + i, t, showAuthor))
      : [div().flex_none().h(30).px(10).text_color(t.dim).child(this.updated ? "Nothing here" : "…")];
    return [header, ...rows];
  }

  render(cx) {
    const t = theme();
    const status = this.error
      ? div().text_color(t.ansi1).truncate().child(this.error.split("\n")[0])
      : this.loading
        ? div().text_color(t.dim).frames(SPINNER.map((s) => `${s} refreshing`), 90)
        : div().text_color(t.dim).child(this.updated ? `updated ${this.updated.toTimeString().slice(0, 5)}` : "");
    const hints = "j/k move · o open · r refresh" + (props()?.overlay ? " · q close" : "");
    return v_flex()
      .id("github")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .size_full()
      .min_h(0)
      .p(12)
      .gap(6)
      .bg(props()?.overlay ? t.popover : t.background)
      .text_size(13)
      .child(
        h_flex()
          .flex_none()
          .px(10)
          .gap(10)
          .items_center()
          .child(div().text_size(15).font_semibold().text_color(t.foreground).child("GitHub"))
          .child(div().flex_1().min_w(0).text_size(12).child(status)),
      )
      .child(
        v_flex()
          .id("gh-list")
          .when(!props()?.overlay, (s) => s.flex_1().min_h(0))
          .when(!!props()?.overlay, (s) => s.max_h(560))
          .overflow_y_scrollbar()
          .track_scroll(this.scroll)
          .children([
            ...this.section("My pull requests", this.mine, 0, t, false),
            ...this.section("Review requests", this.reviews, this.mine.length, t, true),
          ]),
      )
      .child(div().flex_none().px(10).text_size(11).text_color(t.dim).child(hints));
  }
}
