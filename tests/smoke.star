# tests/smoke.star — stable across upstream hawkeye releases.
# hawkeye is a license-header checker: `check` / `format` / `remove`,
# driven by a licenserc.toml config. We assert on the CONTRACT (exit
# codes, version shape), never on help/version prose.
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

HEADER = "# Copyright 2026 OCX. Licensed under the Apache License, Version 2.0.\n"

# Tier 3a: a file WITHOUT the header must FAIL `check` (non-zero exit).
ocx.write_file("check_me.py", "print('no header here')\n")
r_missing = ocx.run(HAWKEYE, "check")
expect.ne(r_missing.exit_code, 0)

# Tier 3b: the SAME file WITH the header must PASS `check` (exit 0). This is
# the strongest liveness proof — it exercises the real header-matching path.
ocx.write_file("check_me.py", HEADER + "print('has header')\n")
r_ok = ocx.run(HAWKEYE, "check")
expect.ok(r_ok)
