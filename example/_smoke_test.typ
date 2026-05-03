#import "@preview/cetz:0.5.0": canvas
#import "lib.typ": decision-tree, node-opt

#canvas(length: 1cm, {
  let root = (
    id: "root",
    opt: node-opt(kind: "decision", labels: (top: ([Root], black))),
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

  decision-tree(root)
})
