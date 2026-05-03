# DA-decision-tree

一个基于 CeTZ 的 Typst 决策树小库：提供数据结构解析（build-tree）、简单布局（layout-tree）与绘制（decision-tree）。

## 安装/使用（本地仓库）

在你的 `.typ` 文件里：

```typst
#import "@preview/cetz:0.5.0": canvas
#import "./DA-decision-tree/lib.typ": decision-tree, node-opt

#canvas(length: 1cm, {
  let root = (
    id: "root",
    opt: node-opt(kind: "decision", labels: (top: ([Decision], black))),
    children: (
      (
        (above: ([Yes], black), below: ([0.8], gray)),
        (id: "a", opt: node-opt(kind: "leaf", labels: (top: ([$V=0.1$], red))), children: ()),
      ),
      (
        (above: ([No], black), below: ([0.2], gray)),
        (id: "b", opt: node-opt(kind: "leaf", labels: (top: ([$V=0.2$], red))), children: ()),
      ),
    ),
  )

  // 可选配置覆盖
  // let cfg = (xstep: 5cm, ystep: 2.6cm)

  decision-tree(root)
})
```

## 标签支持公式

节点/边标签的 label-body 是任意 Typst `content`，可以直接写数学公式（例如 `[$V = 0.1$]`）。颜色通过 `draw.content(..., wrap: text.with(color))` 套一层样式，不会把内容强制转成字符串。

## 版本

- `0.1.0`：初始版本（含 edge labels 渲染、公式标签支持、默认布局与绘制）。
