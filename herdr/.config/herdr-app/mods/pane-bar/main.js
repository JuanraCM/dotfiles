// The bar above the panes: the shown space's tabs on the left, agents on the
// right, lined up with the panes' edges. Click a tab: select it.

import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, layout, run, settings, spaces, theme } from "herdr";

const MARKS = { working: "*", blocked: "!", done: "+" };
// The panes' gap and unfocused border (layouts/custom.json).
const GAP = 10;
const BORDER = "#595959aa";

function find(node, id) {
  if (node?.id === id) return node;
  for (const child of node?.children ?? []) {
    const found = find(child, id);
    if (found) return found;
  }
  return null;
}

// Where the panes start: past the sidebar and the work row's padding and gap,
// and never under the macOS window buttons.
function edges() {
  const root = layout(), sidebar = find(root, "sidebar"), work = find(root, "work");
  const pad = Array.isArray(work?.padding) ? work.padding[1] : work?.padding ?? 0;
  const left = sidebar && !sidebar.hidden ? pad + (sidebar.size?.px ?? 0) + (work?.gap ?? 0) : pad;
  const lights = root?.traffic_lights ? (root.traffic_lights[0] + 64) / settings().zoom : 0;
  return { left: Math.max(left, lights), right: pad };
}

export default class PaneBar extends View {
  render(cx) {
    const t = theme();
    const shown = spaces().find((s) => s.active);
    const tabs = (shown?.tabs ?? []).filter((tab) => !tab.settled);
    const counts = {};
    for (const a of agents()) counts[a.status] = (counts[a.status] ?? 0) + 1;

    const tab = (tb) => div()
      .id(`pane-bar-tab-${tb.id}`)
      .flex_none()
      .max_w(180)
      .truncate()
      .text_color(tb.active ? t.foreground : t.muted)
      .when(tb.active, (el) => el.font_semibold())
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(() => run("tab.select", { id: tb.id }))
      .child(tb.zoomed ? `${tb.name} Z` : tb.name);

    const agent = (status) => div()
      .flex_none()
      .text_color(t[status])
      .child(`${MARKS[status]}${counts[status]}`);

    const { left, right } = edges();
    return div()
      .id("pane-bar")
      .size_full()
      .flex()
      .pt(GAP)
      .pl(left)
      .pr(right)
      .bg(t.background)
      .child(h_flex()
        .flex_1()
        .items_center()
        .gap(14)
        .px(12)
        .border(2)
        .border_color(BORDER)
        .text_color(t.foreground)
        .text_size(13)
        .child(h_flex().flex_1().min_w(0).gap(14).items_center().overflow_hidden().children(tabs.map(tab)))
        .child(h_flex().flex_none().gap(10).items_center()
          .children(["blocked", "done", "working"].filter((s) => counts[s]).map(agent))));
  }
}
