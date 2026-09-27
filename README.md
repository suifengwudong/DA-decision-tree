# DA-decision-tree

一个基于 CeTZ 的 Typst 决策树小库：提供数据结构解析（`build-tree`）、横向层级布局（`layout-tree`）与绘制（`decision-tree`）。

## 安装/使用

本地包（已将源码注册到 `@local`）：

```typst
#import "@preview/cetz:0.5.0": canvas
#import "@local/DA-decision-tree:0.2.0": decision-tree, decision, event, leaf, decision-edge, event-edge
```

或直接从源码目录导入：

```typst
#import "./DA-decision-tree/lib.typ": decision-tree, decision, event, leaf, decision-edge, event-edge
```

最小示例：

```typst
#canvas(length: 1cm, {
  let root = decision("root", [要带伞吗？],
    decision-edge([带伞], mark: [★], mark-color: blue,
      event("e1", [天气],
        event-edge(0.6, leaf("r1", [$-1$], color: red), label: [下雨]),
        event-edge(0.4, leaf("r2", [$-1$], color: red), label: [不下雨]),
      )
    ),
    decision-edge([不带伞], mark: [/], mark-color: gray,
      event("e2", [天气],
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

## Mark 标注

所有节点和边构造器都支持 `mark` 与 `mark-color` 参数，用于在节点旁或边中间绘制符号：

| 惯例 | 含义 | 示例 |
|---|---|---|
| `mark: [★]` | 最优决策路径 | `decision-edge([方案A], child, mark: [★], mark-color: blue)` |
| `mark: [//]` | 已剪枝 / 排除分支 | `decision-edge([方案B], child, mark: [//], mark-color: gray)` |
| `mark: [!]` | 特殊节点标注 | `event("e1", [机会], ..., mark: [!])` |

- 节点 mark 显示在节点右上角（`mark-offset` 可配置）。
- 边 mark 显示在沿边 `mark-position`（默认 0.65）处，与中点方案名错开。

## 布局与配置

节点按深度横向排列，同层子树按槽位纵向排布；父节点居中于首末子节点槽位的中点。边线段按节点轮廓裁剪，端点与节点之间保留 `edge-gap` 间隙。

`decision-tree(root, config: ...)` 的 `config` 覆盖默认配置：

| 键 | 默认值 | 说明 |
|---|---|---|
| `xstep` | `4.5cm` | 深度方向的水平间距 |
| `ystep` | `2.2cm` | 同层槽位的纵向间距 |
| `node-sizes` | `(decision: 4pt, event: 5pt, leaf: 2.5pt)` | 决策方块半宽 / 事件圆半径 / 叶圆半径，按类别单独覆盖 |
| `edge-stroke` | `black` | 边颜色 |
| `edge-width` | `1pt` | 边线宽 |
| `edge-gap` | `1pt` | 边端与节点轮廓的间隙 |
| `label-offset-top` | `10pt` | `top` 节点标签的偏移 |
| `label-offset-right` | `10pt` | `right` 节点标签的偏移 |
| `label-offset-edge` | `6pt` | 边标签相对边中点的纵向偏移 |
| `mark-offset` | `7pt` | 节点 mark 的偏移 |
| `mark-position` | `0.65` | 边 mark 在边上的位置比例（0..1） |

```typst
#decision-tree(root, config: (xstep: 5cm, node-sizes: (event: 6pt)))
```

## 标签支持公式

节点/边标签的 label-body 是任意 Typst `content`，可以直接写数学公式（例如 `[$V = 0.1$]`）。颜色通过 `draw.content(..., wrap: text.with(color))` 套一层样式，不会把内容强制转成字符串。

## 版本

- `0.1.0`：初始版本（含 edge labels 渲染、公式标签支持、默认布局与绘制）。
- `0.1.1`：实现 `mark` 功能：节点与边均支持 `mark`/`mark-color` 参数；简化 `merge-config`。
- `0.2.0`：边按节点轮廓裁剪；`build-tree` 递归构建、边按路径而非 id 路由；子树中心取精确中点；`node-sizes` 按类别合并；边 mark 位置可配置。
