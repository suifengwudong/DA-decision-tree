#import "@preview/cetz:0.5.0": canvas
#import "../lib.typ": decision-tree, decision, event, leaf, decision-edge, event-edge

#canvas(length: 1cm, {
  let root = decision("root", [要带伞吗？],
    decision-edge([带伞], mark: [★], mark-color: blue,
      event("e1", [天气],
        event-edge(0.6, leaf("r1", [$-1$], color: red), label: [下雨]),
        event-edge(0.4, leaf("r2", [$-1$], color: red), label: [不下雨]),
      ),
    ),
    decision-edge([不带伞], mark: [/], mark-color: gray,
      event("e2", [天气],
        event-edge(0.6, leaf("r3", [$-10$], color: red), label: [下雨]),
        event-edge(0.4, leaf("r4", [$0$], color: red), label: [不下雨]),
      ),
    ),
  )

  decision-tree(root, config: (node-sizes: (decision: 5pt, event: 6pt)))
})
