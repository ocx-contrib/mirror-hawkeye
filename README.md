# mirror-hawkeye

OCX mirror for [HawkEye](https://github.com/fast/hawkeye). One repository,
one spec directory per package.

| Package | Spec | Publishes to | Announced as | Upstream SPDX |
|---|---|---|---|---|
| [hawkeye](https://github.com/fast/hawkeye) | [`hawkeye/mirror.yml`](hawkeye/mirror.yml) | `ghcr.io/ocx-contrib/hawkeye/hawkeye` | `ocx.sh/hawkeye/hawkeye` | `Apache-2.0` |

Each upstream release is discovered, re-bundled, smoke-tested per
`(version, platform)` and only then pushed with cascade tags, after which the
result is announced into the OCX index.

> This repository previously published the same upstream to the flat coordinate
> `ocx.sh/hawkeye`. `hawkeye/hawkeye` is the grouped successor: the tool names
> itself. Upstream's owner was the personal handle `korandoru` when that was
> chosen and moved to the `fast` org (FastLabs) with v7.0.0 — `fast` is a
> generic adjective that says nothing about the tool, so the coordinate is
> unchanged.

## Layout

```
mirror-base.yml         repo-wide policy every spec inherits via `extends:`
hawkeye/
├── mirror.yml          the spec — never at the repo root
├── metadata.json       bundle interface
├── CATALOG.md          → ocx package describe
├── logo.svg / logo.png describe assets, 512px PNG
└── tests/smoke.star    Starlark smoke test
```

`LICENSE` and `NOTICE.md` are shared at the root. Logos are **not** — each
package carries its own, because a repo-root `logo.*` sits in no workflow's
`paths:` filter, so replacing it would publish nothing until some unrelated
edit happened to fire.

⚠️ `extends:` is a **shallow** merge of top-level keys. A spec that restates
`platforms:` to change one runner drops every `containers:` entry with it, and
nothing reds — the legs simply stop existing, and every `os.features` claim
goes back to being asserted rather than verified. Restate a block in full or
not at all.

## Platforms

`hawkeye` publishes five platform entries: both Linux arches, both macOS arches
and `windows/amd64` (upstream builds no Windows ARM64).

Upstream ships **both** a `-unknown-linux-gnu` and a `-unknown-linux-musl`
build per Linux arch. This mirror carries only the **musl** one, which is fully
static — no `PT_INTERP`, no `DT_NEEDED`. The gnu twin is dynamically linked and
would drag in `libgcc_s.so.1` for no gain, so it is not published. `os.features`
states what an artifact requires *of the host*, and a static binary requires
nothing, so both Linux keys are **bare**: tagging them `+libc.musl` would be a
false requirement that hid them from every glibc host. The `alpine:3.20`
container leg in `mirror-base.yml` is what turns that claim into evidence; the
measurement itself is recorded above the `assets:` block in
`hawkeye/mirror.yml`.

The version floor is `6.3.0` because that is where the musl tarballs first
ship — below it the Linux patterns resolve zero assets, which is *silently
skipped* rather than an error, and would publish three platforms green.

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror-base.yml`, `hawkeye/mirror.yml` | hand | yes — see below |
| `hawkeye/{metadata.json,CATALOG.md,logo.*}` | hand | — |
| `hawkeye/tests/smoke.star` | hand | — |
| `.github/workflows/*.yml` | **generated — never hand-edit** | re-run when a spec changes |

```bash
ocx-mirror package pipeline generate ci --spec hawkeye/mirror.yml
```

**Name every spec.** `--spec` *appends* rather than replaces, so a command
naming a subset silently stops rendering the rest while staying green — and the
drift guard reds on a generated workflow the current spec set no longer
produces.

`verify-generated.yml` exits 65 on drift. If a generated workflow is wrong, the
spec or the renderer template is wrong — fix it there and regenerate.

Run `direnv allow` once to put the pinned toolchain on `PATH`, and invoke
`ocx-mirror` directly — never `ocx run -- ocx-mirror`, which pins
`OCX_BINARY_PIN` to the bootstrap `ocx` and false-reds the nested push.

## The binaries claim

After `strip_components`, `hawkeye` lands directly *at* the content root, so the
bundle's only PATH entry is a bare `${installPath}`. `bin_scan` only looks
*below* an `${installPath}/<dir>` entry, so `auto`/`verify` is rejected at spec
load with exit 65. `hawkeye/mirror.yml` therefore sets `bin_scan: off` and
`hawkeye/metadata.json` hand-lists `binaries: ["hawkeye"]` — the blessed shape
for this layout.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_ANNOUNCE_TOKEN` | opens the index pull request from the `ocx-contrib/index` fork |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL. GHCR pushes use the
run's own `GITHUB_TOKEN` — no registry secret needed.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets are out of scope; each
package's redistribution license is recorded in [`NOTICE.md`](NOTICE.md).
