# DA-decision-tree

一个基于 CeTZ 的 Typst 决策树小库：提供数据结构解析（build-tree）、简单布局（layout-tree）与绘制（decision-tree）。

## 安装/使用（本地仓库）

在你的 `.typ` 文件里：

```typst
#import "@preview/cetz:0.5.0": canvas
#import "./DA-decision-tree/lib.typ": decision-tree, decision, event, leaf, decision-edge, event-edge

#canvas(length: 1cm, {
  let root = decision("root", [要带伞吗？],
    decision-edge([带伞],
      event("e1", [],
        event-edge(0.6, leaf("r1", [$-1$], color: red), label: [下雨]),
        event-edge(0.4, leaf("r2", [$-1$], color: red), label: [不下雨]),
      )
    ),
    decision-edge([不带伞],
      event("e2", [],
        event-edge(0.6, leaf("r3", [$-10$], color: red), label: [下雨]),
        event-edge(0.4, leaf("r4", [$0$],   color: red), label: [不下雨]),
      )
    ),
  )

  decision-tree(root)
})
```

## DSL 说明

| 构造器 | 用途 | 节点形状 |
|---|---|---|
| `decision(id, label, ..branches)` | 决策节点，子边为可选方案 | 方块 |
| `event(id, label, ..outcomes)` | 随机事件节点，子边带概率 | 圆圈 |
| `leaf(id, label)` | 叶节点（终止） | 实心小圆 |
| `decision-edge(label, child)` | 决策边，标注方案名称 | — |
| `event-edge(prob, child, label: ...)` | 事件边，标注概率与可选描述 | — |

`decision-edge` 与 `event-edge` 明确区分两类边：决策节点的边代表"可选方案"（无概率），事件节点的边代表"随机结果"（有概率）。

## 标签支持公式

节点/边标签的 label-body 是任意 Typst `content`，可以直接写数学公式（例如 `[$V = 0.1$]`）。颜色通过 `draw.content(..., wrap: text.with(color))` 套一层样式，不会把内容强制转成字符串。

## 版本

- `0.1.0`：初始版本（含 edge labels 渲染、公式标签支持、默认布局与绘制）。
- `0.2.0`：新增 `decision` / `event` / `leaf` / `decision-edge` / `event-edge` DSL 构造器，明确区分决策边与事件边。
