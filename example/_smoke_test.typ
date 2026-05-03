#import "@preview/cetz:0.5.0": canvas
#import "lib.typ": decision-tree, decision, event, leaf, decision-edge, event-edge

#canvas(length: 1cm, {
  let root = decision("root", [Decision],
    decision-edge([Option A], mark: [★], mark-color: blue,
      event("e1", [Chance],
        event-edge(0.8, leaf("a", [$V=0.8$], color: red), label: [Good]),
        event-edge(0.2, leaf("b", [$V=0.1$], color: red), label: [Bad]),
      )
    ),
    decision-edge([Option B], mark: [//], mark-color: gray,
      leaf("c", [$V=0.0$], color: red),
    ),
  )

  decision-tree(root)
})
