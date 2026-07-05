#!/usr/bin/env bash

input=$(cat)

# Use python3 to parse JSON (jq not available)
parse() {
  python3 -c "
import sys, json
try:
    data = json.loads(sys.stdin.read())
    keys = '$1'.split('.')
    val = data
    for k in keys:
        if isinstance(val, dict):
            val = val.get(k)
        else:
            val = None
        if val is None:
            break
    print(val if val is not None else '')
except Exception:
    print('')
" <<< "$input"
}

# Working directory
cwd=$(parse "cwd")

# Context window tokens and percentage
total_input_tokens=$(parse "context_window.total_input_tokens")
used_pct=$(parse "context_window.used_percentage")

# Format token count (e.g. 12345 → 12.3k)
if [ -n "$total_input_tokens" ] && [ "$total_input_tokens" -ge 1000 ] 2>/dev/null; then
  token_display=$(python3 -c "print(f'{$total_input_tokens/1000:.1f}k')")
elif [ -n "$total_input_tokens" ] && [ "$total_input_tokens" -gt 0 ] 2>/dev/null; then
  token_display="${total_input_tokens}"
else
  token_display="0"
fi

# Context percentage display
if [ -n "$used_pct" ] && [ "$used_pct" != "0" ]; then
  ctx_pct=$(python3 -c "print(f'{float($used_pct):.0f}')")
  ctx_str="${token_display} tokens (${ctx_pct}% used)"
else
  ctx_str="${token_display} tokens"
fi

# Transcript path
transcript_path=$(parse "transcript_path")

# Session duration from transcript timestamps
duration_str="--"
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  duration_str=$(python3 - "$transcript_path" <<'EOF'
import sys, re, json
from datetime import datetime

path = sys.argv[1]
timestamps = []
with open(path, errors='replace') as f:
    for line in f:
        m = re.search(r'"timestamp"\s*:\s*"([^"]+)"', line)
        if m:
            ts = m.group(1)
            try:
                timestamps.append(datetime.fromisoformat(ts.replace('Z', '+00:00')))
            except Exception:
                pass

if len(timestamps) >= 2:
    diff = int((timestamps[-1] - timestamps[0]).total_seconds())
    h, rem = divmod(diff, 3600)
    m, s = divmod(rem, 60)
    if h > 0:
        print(f"{h}h {m}m {s}s")
    elif m > 0:
        print(f"{m}m {s}s")
    else:
        print(f"{s}s")
else:
    print("--")
EOF
  )
fi

# Total cost from transcript
cost_str="\$0.0000"
if [ -n "$transcript_path" ] && [ -f "$transcript_path" ]; then
  cost_str=$(python3 - "$transcript_path" <<'EOF'
import sys, re

path = sys.argv[1]
total = 0.0
with open(path, errors='replace') as f:
    for line in f:
        for m in re.finditer(r'"costUSD"\s*:\s*([0-9.]+)', line):
            try:
                total += float(m.group(1))
            except Exception:
                pass
print(f"${total:.4f}")
EOF
  )
fi

# Build the status line using ANSI dim colors
printf "\033[2m[ctx: %s]  [dir: %s]  [cost: %s]  [duration: %s]\033[0m" \
  "$ctx_str" "$cwd" "$cost_str" "$duration_str"


