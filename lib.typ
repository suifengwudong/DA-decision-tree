// DA-decision-tree — Decision tree library for Typst using CeTZ
// Modules: data structures, tree building, layout, rendering, high-level API.

#import "@preview/cetz:0.5.0": canvas, draw

// ===== DATA STRUCTURES =====

// Node options: kind (decision/event/leaf), labels (positioned content), mark (optional symbol)
#let node-opt(kind: "decision", labels: (:), mark: none, mark-color: red) = {
  (kind: kind, labels: labels, mark: mark, mark-color: mark-color)
}

// ===== TREE BUILDING =====

// Build the internal tree: every child is stored together with the labels of
// the edge that leads to it, so rendering never has to route edges by node id.
#let build-tree(descr) = (
  id: descr.id,
  opt: descr.opt,
  children: descr.children.map(item => (
    edge-labels: item.at("edge-labels"),
    node: build-tree(item.at("child-desc")),
  )),
)

// ===== LAYOUT =====

// Default tree rendering configuration
#let default-tree-config = (
  xstep: 4.5cm,                    // horizontal spacing (depth)
  ystep: 2.2cm,                    // vertical spacing (siblings)

  node-sizes: (
    decision: 4pt,                 // half width of the decision square
    event: 5pt,                    // radius of the event circle
    leaf: 2.5pt,                   // radius of the leaf dot
  ),

  edge-stroke: black,
  edge-width: 1pt,
  edge-gap: 1pt,                   // clearance between an edge end and its node outline

  label-offset-top: 10pt,          // offset for "top" node labels
  label-offset-right: 10pt,        // offset for "right" node labels
  label-offset-edge: 6pt,          // offset perpendicular to edge for edge labels
  mark-offset: 7pt,                // offset for node mark symbols
  mark-position: 0.65,             // where an edge mark sits along the edge (0..1)
)

// Merge user configuration over the defaults, merging node-sizes key by key
// so that overriding one node kind keeps the others.
#let merge-config(user-config) = {
  let base = default-tree-config
  if type(user-config) != "dictionary" { return base }

  let merged = base + user-config
  if "node-sizes" in user-config and type(user-config.node-sizes) == "dictionary" {
    merged.node-sizes = base.node-sizes + user-config.node-sizes
  }
  merged
}

// Assign positions to nodes based on depth and sibling order.
// Returns (nodes, edges, span, center):
//   nodes  — one record per node: (path, id, opt, x, y)
//   edges  — one record per edge: (from, to, edge-labels), from/to are node paths
//   span   — number of sibling slots consumed by this subtree
//   center — slot index of this subtree's center
#let layout-tree(node, config, path: "0", depth: 0, slot-start: 0) = {
  let xstep = config.xstep
  let ystep = config.ystep

  if node.children.len() == 0 {
    return (
      nodes: ((path: path, id: node.id, opt: node.opt, x: depth * xstep, y: slot-start * ystep),),
      edges: (),
      span: 1,
      center: slot-start,
    )
  }

  let nodes = ()
  let edges = ()
  let child-slot = slot-start
  let first-center = none
  let last-center = none
  let total-span = 0

  for (index, child) in node.children.enumerate() {
    let child-path = path + "-" + str(index)
    let sub = layout-tree(child.node, config, path: child-path, depth: depth + 1, slot-start: child-slot)

    nodes += sub.nodes
    edges += sub.edges
    edges.push((from: path, to: child-path, edge-labels: child.edge-labels))

    if first-center == none { first-center = sub.center }
    last-center = sub.center
    child-slot += sub.span
    total-span += sub.span
  }

  // Exact midpoint (may fall between sibling slots) keeps a parent centered
  // over its first and last child instead of snapping onto one of them.
  let center-slot = (first-center + last-center) / 2
  nodes.push((path: path, id: node.id, opt: node.opt, x: depth * xstep, y: center-slot * ystep))
  (nodes: nodes, edges: edges, span: total-span, center: center-slot)
}

// ===== RENDERING =====

// Outline of a node: ("rect", half-size) or ("circle", radius).
#let node-shape(opt, config) = {
  let sizes = config.node-sizes
  if opt.kind == "decision" { ("rect", sizes.at("decision", default: 4pt)) }
  else if opt.kind == "event" { ("circle", sizes.at("event", default: 5pt)) }
  else if opt.kind == "leaf" { ("circle", sizes.at("leaf", default: 2.5pt)) }
  else { ("circle", 0pt) }
}

// Fraction of the vector toward the target at which the node outline is hit.
#let trim-factor(shape, off, gap) = {
  let (kind, size) = shape
  let dx = off.at(0)
  let dy = off.at(1)
  let unit = 1pt
  let dist = calc.sqrt((dx / unit) * (dx / unit) + (dy / unit) * (dy / unit)) * unit
  if dist == 0pt { return 0 }

  let ratio = if kind == "rect" {
    (size + gap) / calc.max(calc.abs(dx), calc.abs(dy))
  } else {
    (size + gap) / dist
  }
  calc.min(ratio, 0.5)
}

// Draw a single node based on its kind.
#let draw-node(pos, opt, config) = {
  let (shape, size) = node-shape(opt, config)

  if opt.kind == "decision" {
    draw.rect(
      (pos.at(0) - size, pos.at(1) - size),
      (pos.at(0) + size, pos.at(1) + size),
      fill: none,
      stroke: config.edge-stroke,
    )
  } else if opt.kind == "event" {
    draw.circle(pos, radius: size, fill: none, stroke: config.edge-stroke)
  } else if opt.kind == "leaf" {
    draw.circle(pos, radius: size, fill: black, stroke: none)
  }
}

// Draw all edges trimmed to the node outlines, with optional labels and marks.
#let draw-edges(pos, layout-edges, config) = {
  let gap = config.edge-gap

  for e in layout-edges {
    let a = pos.at(e.from)
    let b = pos.at(e.to)
    let dx = b.x - a.x
    let dy = b.y - a.y
    let off = (dx, dy)

    let from-factor = trim-factor(node-shape(a.opt, config), off, gap)
    let to-factor = trim-factor(node-shape(b.opt, config), off, gap)
    let p0 = (a.x + from-factor * dx, a.y + from-factor * dy)
    let p1 = (b.x - to-factor * dx, b.y - to-factor * dy)

    draw.line(p0, p1, stroke: config.edge-stroke)

    let labels = e.edge-labels
    let mid-x = (p0.at(0) + p1.at(0)) / 2
    let mid-y = (p0.at(1) + p1.at(1)) / 2
    let offset = config.label-offset-edge
    let mark-t = config.mark-position

    for (dir, label-data) in labels {
      let label-body = label-data.at(0)
      let color = label-data.at(1)

      if dir == "above" {
        draw.content((mid-x, mid-y + offset), label-body, anchor: "south", wrap: text.with(color))
      } else if dir == "below" {
        draw.content((mid-x, mid-y - offset), label-body, anchor: "north", wrap: text.with(color))
      } else if dir == "mark" {
        // Mark symbol drawn at mark-position along the edge (e.g. "★" optimal, "//" pruned)
        let mx = p0.at(0) + mark-t * (p1.at(0) - p0.at(0))
        let my = p0.at(1) + mark-t * (p1.at(1) - p0.at(1))
        draw.content((mx, my), label-body, anchor: "center", wrap: text.with(color))
      }
    }
  }
}

// Draw all node labels and marks.
#let draw-labels(node-positions, config) = {
  for node-item in node-positions {
    let opt = node-item.opt
    for (dir, label-data) in opt.labels {
      let label-body = label-data.at(0)
      let color = label-data.at(1)
      if dir == "top" {
        draw.content((node-item.x, node-item.y + config.label-offset-top), label-body, anchor: "south", wrap: text.with(color))
      } else if dir == "right" {
        draw.content((node-item.x + config.label-offset-right, node-item.y), label-body, anchor: "west", wrap: text.with(color))
      }
    }
    // Draw optional mark symbol at top-right of the node
    if opt.mark != none {
      draw.content(
        (node-item.x + config.mark-offset, node-item.y + config.mark-offset),
        opt.mark,
        anchor: "south-west",
        wrap: text.with(opt.mark-color),
      )
    }
  }
}

// ===== DSL CONSTRUCTORS =====

// Leaf node: a terminal node with a value label.
// Usage: leaf("id", [label])  — optional: mark: [★], mark-color: red
#let leaf(id, label, color: black, mark: none, mark-color: red) = (
  id: id,
  opt: node-opt(kind: "leaf", labels: (top: (label, color)), mark: mark, mark-color: mark-color),
  children: (),
)

// Decision node (square): children are decision-edge items representing choices.
// Usage: decision("id", [label], decision-edge(...), ...)  — optional: mark: [★]
#let decision(id, label, ..branches, color: black, mark: none, mark-color: red) = (
  id: id,
  opt: node-opt(kind: "decision", labels: (top: (label, color)), mark: mark, mark-color: mark-color),
  children: branches.pos(),
)

// Event node (circle): children are event-edge items representing random outcomes.
// Usage: event("id", [label], event-edge(...), ...)  — optional: mark: [!]
#let event(id, label, ..outcomes, color: black, mark: none, mark-color: red) = (
  id: id,
  opt: node-opt(kind: "event", labels: (top: (label, color)), mark: mark, mark-color: mark-color),
  children: outcomes.pos(),
)

// Decision edge: links a decision node to a child via a named choice label.
// Usage: decision-edge([Choice], child)  — optional: mark: [★] for optimal, mark: [//] for pruned
#let decision-edge(label, child, color: black, mark: none, mark-color: black) = {
  let edge-labels = (above: (label, color))
  if mark != none { edge-labels.insert("mark", (mark, mark-color)) }
  (edge-labels: edge-labels, child-desc: child)
}

// Event edge: links an event node to a child with a probability and optional description.
// Usage: event-edge(0.6, child)  — optional: label: [Outcome], mark: [//]
#let event-edge(prob, child, label: none, prob-color: gray, label-color: black, mark: none, mark-color: black) = {
  let edge-labels = (below: ([#prob], prob-color))
  if label != none { edge-labels.insert("above", (label, label-color)) }
  if mark != none { edge-labels.insert("mark", (mark, mark-color)) }
  (edge-labels: edge-labels, child-desc: child)
}

// ===== HIGH-LEVEL API =====

// Main entry point: build, layout, and render a decision tree.
// Labels accept arbitrary Typst content (including math), and color is applied via CeTZ content wrap.
#let decision-tree(root-desc, config: (:)) = {
  let cfg = merge-config(config)

  let tree = build-tree(root-desc)
  let layout = layout-tree(tree, cfg)
  let nodes = layout.nodes

  let pos = (:)
  for item in nodes { pos.insert(item.path, (x: item.x, y: item.y, opt: item.opt)) }

  draw-edges(pos, layout.edges, cfg)

  for item in nodes {
    draw-node((item.x, item.y), item.opt, cfg)
  }

  draw-labels(nodes, cfg)
}
