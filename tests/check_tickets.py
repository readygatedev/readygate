#!/usr/bin/env python3
"""Check ReadyGate tickets against the writing rules. Usage: check_tickets.py <feature-dir> [min_ac] [max_br] [max_ac]"""
import re, sys, glob, os
d = sys.argv[1]; MIN_AC = int(sys.argv[2]) if len(sys.argv) > 2 else 3
MAX_BR = int(sys.argv[3]) if len(sys.argv) > 3 else 8; MAX_AC = int(sys.argv[4]) if len(sys.argv) > 4 else 8
WANT = ['Description', 'Scope', 'Business rules', 'Acceptance criteria', 'Happy path', 'Dependencies', 'Dev notes']
files = sorted(glob.glob(os.path.join(d, '*.md')))
fails = 0
if not files:
    print(f'FAIL no tickets in {d}'); sys.exit(1)
nums = sorted(int(re.search(r'-(\d+)\.md$', f).group(1)) for f in files)
if nums != list(range(1, len(nums) + 1)):
    print(f'FAIL numbering has gaps: {nums}'); fails += 1
for f in files:
    s = open(f).read(); name = os.path.basename(f); problems = []
    title = s.splitlines()[0]
    if not title.startswith('# '): problems.append('line 1 is not a "# " title')
    secs = re.findall(r'^## (.+)$', s, re.M)
    if secs != WANT: problems.append(f'sections {secs}')
    brs = set(re.findall(r'\*\*BR-(\d+)', s))
    acs = re.findall(r'\*\*AC-(\d+)(?: \(([^)]*)\))?', s)
    real = [c for _, c in acs if c and c != 'standard']
    cited = {n for c in real for n in re.findall(r'BR-(\d+)', c)}
    untagged = [a for a, c in acs if not c]
    if untagged: problems.append(f'ACs without tag: {untagged}')
    if brs - cited: problems.append(f'BRs not covered by an AC: {sorted(brs - cited)}')
    if len(brs) > MAX_BR: problems.append(f'{len(brs)} BRs > {MAX_BR}')
    if len(acs) > MAX_AC: problems.append(f'{len(acs)} ACs > {MAX_AC}')
    if len(real) < MIN_AC and '[Bug]' not in title: problems.append(f'only {len(real)} non-standard ACs (< {MIN_AC}) and not a bug')
    code = re.findall(r'`[^`]*(?:/|\.tsx?|\.py|\(\))[^`]*`|\bsrc/\S+', s)
    if code: problems.append(f'code references: {code[:3]}')
    bad = re.findall(r'\[[ x]\]|\bTBC\b|to be confirmed|open question|story points?', s, re.I)
    if bad: problems.append(f'forbidden: {bad}')
    print(('FAIL ' if problems else 'ok   ') + f'{name}  BR={len(brs)} AC={len(acs)}  {title[2:70]}')
    for p in problems: print('       - ' + p)
    fails += bool(problems)
sys.exit(1 if fails else 0)
