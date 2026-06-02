# mirror-hawkeye

OCX mirror for [HawkEye](https://github.com/korandoru/hawkeye). Publishes
GitHub releases to `dev.ocx.sh/hawkeye` with cascade tags after a smoke
test per `(version, platform)`.

> **Dev target.** This mirror points at `dev.ocx.sh`, not prod `ocx.sh`.
> Promote by editing `target.registry` in `mirror.yml` (then regenerate the
> workflows).

## Editing

| File | Edit | Regenerate after |
|------|------|------------------|
| `mirror.yml` | hand | `ocx-mirror pipeline generate ci` |
| `tests/smoke.star` | hand | — |
| `metadata.json`, `CATALOG.md`, `logo.*` | hand | — |
| `.github/workflows/*.yml` | generated | re-run when `mirror.yml` changes |

CI fails on drift via `ocx-mirror pipeline generate ci --check`.

## Required secrets

| Secret | Use |
|--------|-----|
| `OCX_MIRROR_REGISTRY_TOKEN` + `OCX_MIRROR_REGISTRY_USER` | `ocx package push` to the registry |
| `OCX_MIRROR_DISCORD_HOOK` | notify-stage Discord webhook URL |

(Inherited from the `ocx-contrib` org with visibility ALL.)

## License

Apache-2.0 — see [`LICENSE`](LICENSE). Upstream assets (HawkEye binaries) are
out of scope; see [`NOTICE.md`](NOTICE.md).
