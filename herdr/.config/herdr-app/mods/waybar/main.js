// An Omarchy-style Waybar: the shown space's tabs on the left, agents on the
// right. Click a tab: select it.

import { View, div } from "gpui-kit";
import { h_flex } from "gpui-base";
import { agents, run, spaces, theme } from "herdr";

const MARKS = { working: "*", blocked: "!", done: "+" };

export default class Waybar extends View {
  render(cx) {
    const t = theme();
    const shown = spaces().find((s) => s.active);
    const tabs = (shown?.tabs ?? []).filter((tab) => !tab.settled);
    const counts = {};
    for (const a of agents()) counts[a.status] = (counts[a.status] ?? 0) + 1;

    const tab = (tb) => div()
      .id(`waybar-tab-${tb.id}`)
      .flex_none()
      .max_w(180)
      .truncate()
      .px(6)
      .text_color(tb.active ? t.foreground : t.dim)
      .when(tb.active, (el) => el.font_semibold())
      .on_mouse_down("left", (_e, cx) => cx.stop_propagation())
      .on_click(() => run("tab.select", { id: tb.id }))
      .child(tb.zoomed ? `${tb.name} Z` : tb.name);

    const agent = (status) => div()
      .flex_none()
      .px(6)
      .text_color(t[status])
      .child(`${MARKS[status]}${counts[status]}`);

    return h_flex()
      .id("waybar")
      .size_full()
      .items_center()
      .pl(80)
      .pr(10)
      .bg(t.background)
      .text_color(t.foreground)
      .text_size(12)
      .child(h_flex().flex_1().min_w(0).items_center().overflow_hidden().children(tabs.map(tab)))
      .child(h_flex().flex_none().items_center()
        .children(["blocked", "done", "working"].filter((s) => counts[s]).map(agent)));
  }
}
