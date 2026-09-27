# Changelog

## 0.2.0 (2026-09-27)

- 边按节点轮廓裁剪，线段不再穿过节点图形；新增 `edge-gap` 配置
- `build-tree` 递归构建：每个子节点携带其入边标签，边不再按节点 id 路由（同 id 节点不再串线）
- 子树中心改用首末子节点槽位的精确中点，父节点居中于子节点之间
- `merge-config` 对 `node-sizes` 按类别合并，覆盖单一类别不再丢失其余类别
- 边标签 `mark` 移到沿边 `mark-position`（默认 0.65）处，避免与中点方案名重叠

## 0.1.1 (2026-05-04)

- Improve release workflow: auto-detect default branch, auto-create PR to typst/packages
- Minor documentation updates

## 0.1.0 (2026-05-03)

- Initial package scaffold
- Provide `node-opt`, `build-tree`, `decision-tree`
- Render edge labels (`above`/`below`) and node labels (`top`/`right`)
- Labels accept arbitrary Typst content (including math)
