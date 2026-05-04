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

## Mark 标注

所有节点和边构造器都支持 `mark` 与 `mark-color` 参数，用于在节点旁或边中间绘制符号：

| 惯例 | 含义 | 示例 |
|---|---|---|
| `mark: [★]` | 最优决策路径 | `decision-edge([方案A], child, mark: [★], mark-color: blue)` |
| `mark: [//]` | 已剪枝 / 排除分支 | `decision-edge([方案B], child, mark: [//], mark-color: gray)` |
| `mark: [!]` | 特殊节点标注 | `event("e1", [机会], ..., mark: [!])` |

- 节点 mark 显示在节点右上角（`mark-offset` 可配置）。
- 边 mark 显示在边的中点处（覆盖在线上）。

## 标签支持公式

节点/边标签的 label-body 是任意 Typst `content`，可以直接写数学公式（例如 `[$V = 0.1$]`）。颜色通过 `draw.content(..., wrap: text.with(color))` 套一层样式，不会把内容强制转成字符串。

## 版本

- `0.1.0`：初始版本（含 edge labels 渲染、公式标签支持、默认布局与绘制）。
- `0.1.1`：实现 `mark` 功能：节点与边均支持 `mark`/`mark-color` 参数；简化 `merge-config`。

## 发布到 Typst 包仓库（自动化）

仓库包含 GitHub Actions 工作流 `.github/workflows/release.yml`：当你推送标签 `vX.Y.Z` 时，会把当前版本推送到你 fork 的 `typst/packages`（`packages/preview` 路径）并自动在 `typst/packages` 创建 PR。

准备工作：
- Fork https://github.com/typst/packages 到你的账号（例如 `你的用户名/packages`）。
- 在本仓库 Secrets 配置 `REGISTRY_TOKEN`（PAT；需要能 push 你的 fork，并能对 `typst/packages` 创建 PR）。

发布步骤：
1. 更新 `typst.toml` 的 `version`，并补充 `CHANGELOG.md`。
2. 打标签并推送：`git tag v0.1.1 && git push origin v0.1.1`。
