// tmux-style prefix. Opened by the prefix key (keys.json). While open, the focused
// pane's border is bright; the next key runs its binding from keys.toml, then closes.

import { View } from "gpui-kit";
import { h_flex } from "gpui-base";
import { run, props, closeOverlay, theme, layout, readTextFile, appHome, commands } from "herdr";

const FALLBACK_COLOR = "accent";

function parseToml(text) {
  const out = {};
  let sec = out;
  for (const raw of text.split("\n")) {
    const line = raw.trim();
    if (!line || line.startsWith("#")) continue;
    const s = line.match(/^\[([^\]]+)\]$/);
    if (s) { sec = out[s[1].trim()] = {}; continue; }
    const kv = line.match(/^(?:"((?:[^"\\]|\\.)*)"|'([^']*)'|([^=\s]+))\s*=\s*(?:"((?:[^"\\]|\\.)*)"|'([^']*)')/);
    if (kv) sec[kv[1] ?? kv[2] ?? kv[3]] = kv[4] ?? kv[5];
  }
  return out;
}

// The pane-frame node of the active-tab block.
function findFrame(node) {
  if (!node || typeof node !== "object") return null;
  if (node.content?.tab === "active" && node.content.pane) return node.content.pane;
  for (const v of Object.values(node)) {
    const f = findFrame(v);
    if (f) return f;
  }
  return null;
}

function setBorder(color) {
  const tree = JSON.parse(JSON.stringify(layout()));
  const frame = findFrame(tree);
  if (!frame) return null;
  // The overlay holds the keyboard, so the pane isn't "focused": light up border and focus alike.
  const prev = { border: frame.border, focus: frame.focus ?? { width: 1, color: FALLBACK_COLOR } };
  const look = typeof color === "string" ? { border: { width: 2, color }, focus: { width: 2, color } } : color;
  frame.border = look.border;
  frame.focus = look.focus;
  run("layout.set", { layout: tree });
  return prev;
}

function invoke(action) {
  const i = action.indexOf(":");
  const name = i < 0 ? action : action.slice(0, i);
  if (i < 0) return run(name, {});
  const val = action.slice(i + 1);
  // keys.json shorthand: value fills the command's first argument.
  const cmd = commands().find((c) => c.name === name);
  const arg = cmd?.args?.[0]?.name;
  if (!arg) return run(name, {});
  return run(name, { [arg]: /^\d+$/.test(val) && arg === "index" ? Number(val) : val });
}

export default class Prefix extends View {
  init(_props, cx) {
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.timer.after(150, () => this.handle.focus());
    this.bindings = {};
    this.color = "ansi11";
    cx.spawn(async (cx) => {
      const text = await readTextFile(`${appHome()}/mods/prefix/keys.toml`);
      const cfg = parseToml(text ?? "");
      this.bindings = cfg.bindings ?? {};
      this.color = cfg.prefix?.color ?? this.color;
      this.arm();
      cx.notify();
    });
  }

  arm() {
    this.prev = setBorder(this.color);
  }

  async close(_cx) {
    if (this.prev) setBorder(this.prev);
  }

  key(e, cx) {
    const k = e.key;
    if (["shift", "control", "alt", "meta", "super", "capslock"].includes(k)) return;
    const action = this.bindings[e.key_char] ?? this.bindings[e.keystroke];
    closeOverlay(props().overlay);
    if (action && k !== "escape") invoke(action);
    cx.stop_propagation();
  }

  render(cx) {
    const t = theme();
    // Invisible: only captures the next key while the border is highlighted.
    return h_flex().id("prefix").track_focus(this.handle).on_key_down((e, cx) => this.key(e, cx)).size_full();
  }
}
