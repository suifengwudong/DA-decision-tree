// DA-decision-tree — Decision tree library for Typst using CeTZ
// Modules: data structures, tree building, layout, rendering, high-level API.

#import "@preview/cetz:0.5.0": canvas, draw

// ===== DATA STRUCTURES =====

// Node options: kind (decision/event/leaf), labels (positioned content), mark (optional symbol)
#let node-opt(kind: "decision", labels: (:), mark: none, mark-color: red) = {
  (kind: kind, labels: labels, mark: mark, mark-color: mark-color)
}

#let internal-node(id, opt, children) = (id: id, opt: opt, children: children)

// ===== TREE BUILDING =====

// Parse tree description and build internal structure with edges.
// Returns (tree-node, edges-list) where edges include from/to IDs and edge-labels.
#let build-tree(descr, parent-id: none) = {
  let current-id = descr.id
  let opt = descr.opt
  let children-desc = descr.children
  let child-nodes = ()
  let edges = ()

  for child-item in children-desc {
    let (edge-labels, child-dict) = if "child-desc" in child-item {
      (child-item.at("edge-labels"), child-item.at("child-desc"))
    } else {
      (child-item.at(0), child-item.at(1))
    }

    let (child-struct, child-edges) = build-tree(child-dict, parent-id: current-id)
    child-nodes.push(child-struct)
    edges.push((from: current-id, to: child-struct.id, edge-labels: edge-labels))
    edges += child-edges
  }

  (internal-node(current-id, opt, child-nodes), edges)
}

// ===== LAYOUT & RENDERING =====

// Default tree rendering configuration
#let default-tree-config = (
  xstep: 4.5cm,                    // horizontal spacing (depth)
  ystep: 2.2cm,                    // vertical spacing (siblings)

  node-sizes: (
    decision: 4pt,
    event: 5pt,
    leaf: 2.5pt,
  ),

  edge-stroke: black,
  edge-width: 1pt,

  label-offset-top: 10pt,          // offset for "top" node labels
  label-offset-right: 10pt,        // offset for "right" node labels
  label-offset-edge: 6pt,          // offset perpendicular to edge for edge labels

  edge-label-orientation: "horizontal",
)

#let merge-config(user-config) = {
  let merged = default-tree-config
  if type(user-config) == "dictionary" {
    for (key, value) in user-config {
      merged.insert(key, value)
    }
  }
  merged
}

// Assign positions to nodes based on depth and sibling order
#let layout-tree(node, config, path: "0", depth: 0, slot-start: 0) = {
  let xstep = config.xstep
  let ystep = config.ystep

  if node.children.len() == 0 {
    let node-pos = (path: path, id: node.id, opt: node.opt, x: depth * xstep, y: slot-start * ystep)
    return ((node-pos,), (), 1, slot-start)
  }

  let nodes = ()
  let edges-layout = ()
  let child-slot = slot-start
  let first-center = none
  let last-center = none
  let total-span = 0

  let child-index = 0
  for child in node.children {
    let child-path = path + "-" + str(child-index)
    let (child-nodes, child-edges, child-span, child-center) = layout-tree(child, config, path: child-path, depth: depth + 1, slot-start: child-slot)
    nodes += child-nodes
    edges-layout += child-edges
    edges-layout.push((from: path, to: child-path))
    if first-center == none { first-center = child-center }
    last-center = child-center
    child-slot += child-span
    total-span += child-span
    child-index += 1
  }

  let center-slot = int((first-center + last-center) / 2)
  nodes += ((path: path, id: node.id, opt: node.opt, x: depth * xstep, y: center-slot * ystep),)
  (nodes, edges-layout, total-span, center-slot)
}

// Draw a single node based on kind and size from config
#let draw-node(pos, opt, config) = {
  let sizes = config.node-sizes

  if opt.kind == "decision" {
    let sz = sizes.at("decision", default: 4pt)
    draw.rect((pos.at(0) - sz, pos.at(1) - sz), (pos.at(0) + sz, pos.at(1) + sz), fill: none, stroke: config.edge-stroke)
  } else if opt.kind == "event" {
    let rad = sizes.at("event", default: 5pt)
    draw.circle(pos, radius: rad, fill: none, stroke: config.edge-stroke)
  } else if opt.kind == "leaf" {
    let rad = sizes.at("leaf", default: 2.5pt)
    draw.circle(pos, radius: rad, fill: black, stroke: none)
  }
}

// Draw all edges with optional labels
#let draw-edges(node-positions, layout-edges, edges, config) = {
  let id-to-pos = (:)
  for item in node-positions {
    id-to-pos.insert(item.id, (item.x, item.y))
  }

  for layout-e in layout-edges {
    let from-item = node-positions.find(item => item.path == layout-e.from)
    let to-item = node-positions.find(item => item.path == layout-e.to)
    if from-item != none and to-item != none {
      draw.line((from-item.x, from-item.y), (to-item.x, to-item.y), stroke: config.edge-stroke)
    }
  }

  for e in edges {
    let from-pos = id-to-pos.at(e.from, default: none)
    let to-pos = id-to-pos.at(e.to, default: none)

    if from-pos != none and to-pos != none and "edge-labels" in e {
      let labels = e.edge-labels
      let mid-x = (from-pos.at(0) + to-pos.at(0)) / 2
      let mid-y = (from-pos.at(1) + to-pos.at(1)) / 2
      let offset = config.label-offset-edge

      for (dir, label-data) in labels {
        let label-body = label-data.at(0)
        let color = label-data.at(1)

        if dir == "above" {
          draw.content((mid-x, mid-y + offset), label-body, anchor: "south", wrap: text.with(color))
        } else if dir == "below" {
          draw.content((mid-x, mid-y - offset), label-body, anchor: "north", wrap: text.with(color))
        }
      }
    }
  }
}

// Draw all node labels
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
  }
}

// ===== HIGH-LEVEL API =====

// Main entry point: build, layout, and render a decision tree.
// Labels accept arbitrary Typst content (including math), and color is applied via CeTZ content wrap.
#let decision-tree(root-desc, config: (:)) = {
  let cfg = merge-config(config)

  let (tree, edges) = build-tree(root-desc)
  let (node-positions, layout-edges, ..) = layout-tree(tree, cfg)

  draw-edges(node-positions, layout-edges, edges, cfg)

  for node-item in node-positions {
    draw-node((node-item.x, node-item.y), node-item.opt, cfg)
  }

  draw-labels(node-positions, cfg)
}
