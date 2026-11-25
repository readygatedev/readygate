#!/usr/bin/env python3
"""Find and read pm.config.yaml without third-party packages (PyYAML is used when available).
Usage: pmconfig.py <start-dir> <dotted.key>  → prints the value or nothing.
       pmconfig.py --check <pm.config.yaml>     → "ok", or the problems (exit 1)."""
import os, sys

def find_config(start):
    d = os.path.abspath(start)
    while True:
        p = os.path.join(d, "pm.config.yaml")
        if os.path.isfile(p):
            return p
        nd = os.path.dirname(d)
        if nd == d:
            return None
        d = nd

def _strip(v):
    v = v.split(" #", 1)[0].strip()
    if len(v) >= 2 and v[0] == v[-1] and v[0] in "\"'":
        v = v[1:-1]
    return v

def _simple_parse(text):
    """Nested mappings of scalars only (enough for the keys ReadyGate's scripts need)."""
    root, stack = {}, [(-1, {})]
    stack[0] = (-1, root)
    for raw in text.splitlines():
        if not raw.strip() or raw.lstrip().startswith("#") or raw.lstrip().startswith("- "):
            continue
        indent = len(raw) - len(raw.lstrip())
        line = raw.strip()
        if ":" not in line:
            continue
        key, _, val = line.partition(":")
        key = _strip(key)
        while stack and stack[-1][0] >= indent:
            stack.pop()
        parent = stack[-1][1]
        val = _strip(val)
        if val == "":
            child = {}
            parent[key] = child
            stack.append((indent, child))
        else:
            parent[key] = None if val in ("null", "~") else val
    return root

def load(path):
    text = open(path, encoding="utf-8").read()
    try:
        import yaml  # type: ignore
        return yaml.safe_load(text) or {}
    except Exception:
        return _simple_parse(text)

def get(cfg, dotted, default=None):
    v = cfg
    for k in dotted.split("."):
        if not isinstance(v, dict) or k not in v:
            return default
        v = v[k]
    return default if v is None else v

def check(path):
    """Validate a config: parses, and has the keys ReadyGate needs. Returns a list of problems."""
    problems = []
    try:
        text = open(path, encoding="utf-8").read()
    except OSError as e:
        return [f"can't read {path}: {e}"]
    try:
        import yaml  # type: ignore
        try:
            cfg = yaml.safe_load(text) or {}
        except yaml.YAMLError as e:
            return [f"YAML error: {e}"]
    except ImportError:
        for n, line in enumerate(text.splitlines(), 1):
            if "\t" in line[: len(line) - len(line.lstrip())]:
                problems.append(f"line {n}: tab used for indentation (use spaces)")
            body = line.split(" #", 1)[0].rstrip()
            if body.strip() and not body.lstrip().startswith(("#", "- ")) and ":" not in body:
                problems.append(f"line {n}: expected 'key: value'")
        cfg = _simple_parse(text)
    if not isinstance(cfg, dict):
        return problems + ["the file must be a mapping of keys"]
    for key in ("version", "project", "repos", "tickets"):
        if key not in cfg:
            problems.append(f"missing top-level key: {key}")
    mode = str(get(cfg, "mode", "code"))
    if mode not in ("code", "greenfield"):
        problems.append(f"mode must be code or greenfield, not {mode}")
    if get(cfg, "repos.product.path") is None:
        problems.append("missing repos.product.path (use 'none' for greenfield)")
    return problems


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--check":
        errs = check(sys.argv[2])
        print("ok" if not errs else "\n".join(errs))
        sys.exit(1 if errs else 0)
    p = find_config(sys.argv[1] if len(sys.argv) > 1 else ".")
    if p and len(sys.argv) > 2:
        v = get(load(p), sys.argv[2])
        if v is not None:
            print(v)
    elif p:
        print(p)
