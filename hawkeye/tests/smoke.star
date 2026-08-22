# hawkeye/tests/smoke.star — stable across upstream hawkeye releases.
# hawkeye is a license-header checker: `check` / `format` / `remove`,
# driven by a licenserc.toml config. We assert on the CONTRACT (exit
# codes, the file named in a failure, version shape), never on
# help/version prose.
#
# ─── Why this script branches on the MAJOR ──────────────────────────────────
#
# v7.0.0 is a rewrite. It replaced BOTH the config schema and the report
# stream, and accepts no v6 aliases — there is no single config both majors
# load:
#
#   v6                             v7
#   inlineHeader = "…"             [header]  text = "…"
#   includes = [ … ]               [files]   includes = [ … ]
#   useDefaultExcludes = false     (removed — v7 ships no default blacklist)
#   [git] attrs = 'disable'        [git]     file_attrs = "disable"
#
#   report on STDERR               reports on STDOUT; logs/errors on STDERR
#
# Feeding v7 a v6 config is not a soft failure — it is `unknown field 'attrs',
# expected 'ignore' or 'file_attrs'`, exit 2. A bare `exit_code != 0` in 3a
# would have GREEN-LIT that as "missing header detected"; only the file-name
# assertion caught it. Hence 3a now pins v7's exact exit code as well.
#
# The spec floor is 6.3.0 (first musl asset), so BOTH majors are in range and a
# backfill re-tests every one of them. A single-major script would red every v6
# leg — and one red version kills the whole test job, so nothing publishes.
#
# Branching lives inside `def`s: this dialect rejects a top-level `if`
# statement (conditional *expressions* are fine — see HAWKEYE below).
HAWKEYE = "hawkeye.exe" if ocx.target_platform.os == ocx.os.Windows else "hawkeye"

# Tier 1 + 2: liveness on the composed PATH + semver version shape.
r = ocx.run(HAWKEYE, "--version")
expect.ok(r)
expect.matches(r.stdout, r"\d+\.\d+\.\d+")

def semver_major(text):
    # First X.Y.Z-shaped token wins. Both majors print a bare semver, but in
    # different places: v7 emits one line, `hawkeye 7.0.0`; v6 emits a block
    # whose second line is `version: 6.5.1`. FIRST is what keeps v6's later
    # `rustc 1.93.1` line from being read as the tool version.
    for tok in text.replace("\n", " ").split(" "):
        p = tok.split(".")
        if len(p) == 3 and p[0].isdigit() and p[1].isdigit() and p[2].isdigit():
            return int(p[0])
    fail("no X.Y.Z token in `%s --version` output: %s" % (HAWKEYE, text))

MAJOR = semver_major(r.stdout)

# A minimal, hermetic license-header config in the running major's own schema.
# The template is inline; git integration is disabled so the check is
# reproducible outside a repository.
HEADER = "Copyright 2026 OCX. Licensed under the Apache License, Version 2.0."

def licenserc(major):
    if major >= 7:
        return "\n".join([
            "[header]",
            'text = "%s"' % HEADER,
            "",
            "[files]",
            'includes = ["check_me.py"]',
            "",
            "[git]",
            'ignore = "disable"',
            'file_attrs = "disable"',
            "",
        ])
    return "\n".join([
        'inlineHeader = "%s"' % HEADER,
        'includes = ["check_me.py"]',
        "useDefaultExcludes = false",
        "",
        "[git]",
        "ignore = 'disable'",
        "attrs = 'disable'",
        "",
    ])

ocx.write_file("licenserc.toml", licenserc(MAJOR))

# Tier 3a: a file WITHOUT the header must FAIL `check`, and the report must
# NAME the offending file — a bare non-zero exit would also pass a hawkeye that
# died for an unrelated reason (exactly how v7 first broke this test). v7
# documents stable exit-code categories — 1 = a change is required, 2 = a
# config or runtime error — so pin 1 exactly; v6 guarantees no such split and
# gets `!= 0` plus the same file-name proof. The message around the name is
# prose and is not asserted; `check_me.py` is the computed part, the name we
# just wrote.
def assert_reports_missing_header(res):
    if MAJOR >= 7:
        expect.eq(res.exit_code, 1)
        expect.contains(res.stdout, "check_me.py")
    else:
        expect.ne(res.exit_code, 0)
        expect.contains(res.stderr, "check_me.py")

ocx.write_file("check_me.py", "print('no header here')\n")
assert_reports_missing_header(ocx.run(HAWKEYE, "check"))

# Tier 3b: let `format` insert hawkeye's OWN rendered header (correct comment
# style + the blank-line separator it requires) rather than hand-crafting a
# header that might not match byte-for-byte. Its exit code is NOT asserted —
# it is the one place the majors legitimately disagree: v6 exits non-zero when
# it modifies a file (fixer semantics), v7 exits 0 unless `--fail-on-change` is
# given. The proof is that `check` then PASSES, exercising the real
# header-matching path.
ocx.run(HAWKEYE, "format")
r_ok = ocx.run(HAWKEYE, "check")
expect.ok(r_ok)
