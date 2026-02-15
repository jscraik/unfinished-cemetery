---
name: brainwav-code-ios-ap
birth: 2025-08
death: 2026-01
cause: compatibility-gap
tags: [mcp, cli, ios, tooling]
repo: https://github.com/jscraik/brainwav-code-ios-ap
epitaph: "If it only works with one tool, it doesn't work."
---

## What It Wanted To Be

An iOS-friendly companion for coding workflows — a mobile bridge that could run MCP-powered commands and keep CLI tooling within reach.

## What Actually Happened

The MCP layer and CLI ergonomics never stabilized. It was brittle across tools, and in practice it only worked reliably with Claude.

## Why It Died

**Compatibility gap.** The tooling surface was too inconsistent to ship with confidence, and the cross-tool story never landed.

## What It Taught Me

1. **Cross-tool reliability is the product.**
2. **If it only works in one client, it isn’t a platform.**
3. **Prototype constraints early, before you design the surface.**
