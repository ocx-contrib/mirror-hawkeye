# NOTICE

This repository packages and redistributes upstream software published by
[FastLabs](https://github.com/fast). The Apache-2.0 license in
[`LICENSE`](LICENSE) covers the OCX pipeline files authored here. It does
**not** cover any upstream-derived asset — each package's redistributed bytes
carry their own license, recorded below.

Each package's logo is reproduced for catalog identification only, under
nominative fair use. The marks remain the property of their respective owners
and no endorsement is implied.

| Package | GHCR path | Upstream SPDX |
|---|---|---|
| `hawkeye` | `ghcr.io/ocx-contrib/hawkeye/hawkeye` | `Apache-2.0` |

---

## `hawkeye`

Upstream: <https://github.com/fast/hawkeye>
Published to `ghcr.io/ocx-contrib/hawkeye/hawkeye`.

| Component | SPDX | Holder |
|---|---|---|
| HawkEye (`hawkeye`) | **Apache-2.0** | Copyright HawkEye contributors |

Permissive; redistribution of the compiled binary is granted provided the
license and any NOTICE are retained. Upstream ships a `LICENSE` file *inside*
every release archive, so the Apache-2.0 text travels with the redistributed
bytes. The published binaries statically link third-party Rust crates under
permissive licenses, enumerated in upstream's `Cargo.lock`.

Only the `-unknown-linux-musl` Linux builds are redistributed; the
`-unknown-linux-gnu` twins are not published. Both are upstream artifacts under
the same license — the selection is a linkage decision, not a licensing one.

The HawkEye name is used for catalog identification under nominative fair use.
The logo shipped with this package is an OCX-authored lettermark, not an
official HawkEye mark.

No modifications are made to any upstream artifact in this repository; they are
republished byte-for-byte inside an OCX bundle.
