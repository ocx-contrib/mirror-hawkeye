# hawkeye/tests/smoke.star — stable across upstream hawkeye releases.
# hawkeye is a license-header checker: `check` / `format` / `remove`,
# driven by a licenserc.toml config. We assert on the CONTRACT (exit
# codes, the file named in a failure, version shape), never on
# help/version prose.
HAWKEYE = "hawkeye.exe" if ocx.target_platform.os == ocx.os.Windows else "hawkeye"

# Tier 1 + 2: liveness on the composed PATH + semver version shape.
r = ocx.run(HAWKEYE, "--version")
expect.ok(r)
expect.matches(r.stdout, r"\d+\.\d+\.\d+")

# A minimal, hermetic license-header config. inlineHeader is the template;
# git integration is disabled so the check is reproducible outside a repo.
LICENSERC = "\n".join([
    'inlineHeader = "Copyright 2026 OCX. Licensed under the Apache License, Version 2.0."',
    'includes = ["check_me.py"]',
    'useDefaultExcludes = false',
    "",
    "[git]",
    "ignore = 'disable'",
    "attrs = 'disable'",
    "",
]) + "\n"
ocx.write_file("licenserc.toml", LICENSERC)

# Tier 3a: a file WITHOUT the header must FAIL `check` (non-zero exit), and the
# failure must NAME the offending file — a bare non-zero exit would also pass a
# hawkeye that died for an unrelated reason. The message around it is prose and
# is not asserted; `check_me.py` is the computed part, the name we just wrote.
ocx.write_file("check_me.py", "print('no header here')\n")
r_missing = ocx.run(HAWKEYE, "check")
expect.ne(r_missing.exit_code, 0)
expect.contains(r_missing.stderr, "check_me.py")

# Tier 3b: let `format` insert hawkeye's OWN rendered header (correct comment
# style + the blank-line separator it requires) rather than hand-crafting a
# header that might not match byte-for-byte. `format` exits non-zero when it
# modifies a file (fixer semantics), so its exit code is not asserted; the
# proof is that `check` then PASSES — exercising the real header-matching path.
ocx.run(HAWKEYE, "format")
r_ok = ocx.run(HAWKEYE, "check")
expect.ok(r_ok)
