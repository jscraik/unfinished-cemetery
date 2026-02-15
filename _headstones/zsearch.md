---
name: zSearch
birth: 2026-01
death: 2026-02
cause: policy-risk
tags: [mcp, cli, search, tos]
repo: https://github.com/jscraik/zSearch
epitaph: "If the rules can ban users, the tool can't ship."
---

## What It Wanted To Be

A fast search surface for Z.AI tools and MCP workflows — a CLI and MCP server that could index, query, and automate agent discovery.

## What Actually Happened

Some of the most useful features flirted with platform policy limits and required brittle integrations. The results were inconsistent and sometimes failed in production-like conditions.

## Why It Died

**Policy risk.** The work crossed into TOS gray areas, and the reliability story wasn’t strong enough to justify that risk.

## What It Taught Me

1. **If the policies are hostile, the roadmap is imaginary.**
2. **Reliability is a prerequisite for trust.**
3. **Don’t ship tools that can put users at risk.**
