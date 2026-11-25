#!/usr/bin/env bash
# ======================================================================
#  VD Modules  ::  index-consistency guard
#  Fails the pipeline when the MMRL feed is internally or externally
#  inconsistent, so a broken index never reaches GitHub Pages.
#
#  Copyright (C) 2026  VD171
#  SPDX-License-Identifier: GPL-3.0-or-later
#
#  Site           : https://vd171.ru
#  Site           : https://vd.priv8.ru
#  Source         : https://github.com/VD171/VD-Modules
#  GitHub         : @VD171 https://github.com/VD171
#  XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
#  Telegram       : @VD_Priv8 https://t.me/VD_Priv8
#  Channel        : @Priv8_VD https://t.me/Priv8_VD
#  Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
#  E-mail         : vd.priv8@pm.me
# ======================================================================
#
#  Checks:
#    1. json/config.json, json/modules.json and every modules/*/update.json
#       are valid JSON.
#    2. Every version in json/modules.json maps to a present local asset
#       (the .zip, and the changelog .md when one is set). A missing asset
#       is exactly what a 404 on the published zipUrl would be.
#    3. json/modules.json and each modules/<id>/update.json agree on the
#       version set (no index/feed drift).
#    4. Sync-source freshness (needs network; skipped when INDEX_CHECK_OFFLINE=1):
#       the update_to JSON in each track.yaml must advertise a versionCode
#       at least as high as the feed head. A lower one means `mmrl-util sync`
#       (append-only, higher-code-only) can never advance that module.
#    5. The feed never runs more than WINDOW (default 3) versions behind the
#       sync source: a bigger gap means sync has been failing silently.
#
#  Env:
#    INDEX_CHECK_OFFLINE=1   skip the remote sync-source checks (4 and 5)
#    INDEX_CHECK_WINDOW=N    trailing-window size (default 3)
# ======================================================================
set -euo pipefail

cd "$(dirname "$0")/.."

WINDOW="${INDEX_CHECK_WINDOW:-3}"
OFFLINE="${INDEX_CHECK_OFFLINE:-0}"
fail=0
err() { printf 'FAIL: %s\n' "$1" >&2; fail=1; }
info() { printf 'info: %s\n' "$1"; }

PY=python3
command -v "$PY" >/dev/null 2>&1 || { echo "python3 is required" >&2; exit 2; }

# --- 1. JSON validity ------------------------------------------------
for f in json/config.json json/modules.json modules/*/update.json; do
  if ! "$PY" -m json.tool "$f" >/dev/null 2>&1; then
    err "invalid JSON: $f"
  fi
done

# --- 2 & 3. local assets + modules.json<->update.json agreement ------
"$PY" - "$WINDOW" <<'PY' || fail=1
import json, os, sys

window = int(sys.argv[1])
rc = 0
def bad(msg):
    global rc
    print("FAIL: " + msg, file=sys.stderr); rc = 1

mods = json.load(open("json/modules.json"))
for m in mods.get("modules", []):
    mid = m["id"]
    feed = {v["versionCode"]: v for v in m.get("versions", [])}
    if not feed:
        bad(f"{mid}: no versions in modules.json"); continue
    head = max(feed)
    # 2. every asset present locally
    for vc, v in feed.items():
        for key in ("zipUrl", "changelog"):
            url = v.get(key) or ""
            if not url:
                continue
            name = url.rsplit("/", 1)[-1]
            path = os.path.join("modules", mid, name)
            if not os.path.isfile(path):
                bad(f"{mid}: {key} {vc} has no local asset ({path})")
    # 3. update.json must match modules.json version set
    uj = os.path.join("modules", mid, "update.json")
    if os.path.isfile(uj):
        u = json.load(open(uj))
        us = {x["versionCode"] for x in u.get("versions", [])}
        if us != set(feed):
            bad(f"{mid}: update.json {sorted(us)} != modules.json {sorted(feed)}")
    else:
        bad(f"{mid}: missing {uj}")
    # feed sanity: head is the newest and count stays within the window
    if len(feed) > window:
        bad(f"{mid}: feed keeps {len(feed)} versions, window is {window}")
    print(f"ok: {mid} feed head {head} ({len(feed)} versions)")
sys.exit(rc)
PY

# --- 4 & 5. sync-source freshness (remote) ---------------------------
if [ "$OFFLINE" = "1" ]; then
  info "offline mode: skipping remote sync-source checks"
else
  for ty in modules/*/track.yaml; do
    mid="$(sed -n 's/^id:[[:space:]]*//p' "$ty" | head -1)"
    update_to="$(sed -n 's/^update_to:[[:space:]]*//p' "$ty" | head -1)"
    [ -n "$update_to" ] || continue
    src="$(curl -fsSL --max-time 25 "$update_to" 2>/dev/null || true)"
    if [ -z "$src" ]; then
      info "$mid: sync source unreachable, skipping freshness check ($update_to)"
      continue
    fi
    # source max versionCode (single-version or versions[] shapes) vs feed head
    read -r src_vc feed_head <<EOF
$(printf '%s' "$src" | "$PY" - "$mid" 2>/dev/null <<'PY'
import json, sys
try:
    mid = sys.argv[1]
    src = json.load(sys.stdin)
    if "versions" in src and src["versions"]:
        svc = max(v["versionCode"] for v in src["versions"])
    else:
        svc = int(src["versionCode"])
    feed = json.load(open("json/modules.json"))
    head = 0
    for m in feed["modules"]:
        if m["id"] == mid:
            head = max(v["versionCode"] for v in m["versions"])
    print(svc, head)
except Exception:
    pass
PY
)
EOF
    if [ -z "${src_vc:-}" ] || [ -z "${feed_head:-}" ]; then
      info "$mid: could not parse source/feed versionCode, skipping"
      continue
    fi
    if [ "$src_vc" -lt "$feed_head" ]; then
      err "$mid: sync source versionCode $src_vc < feed head $feed_head (feed can never advance; fix track.yaml:update_to)"
    elif [ "$src_vc" -gt "$feed_head" ]; then
      info "$mid: sync source $src_vc ahead of feed head $feed_head (sync pending)"
    else
      info "$mid: sync source level with feed head ($feed_head)"
    fi
  done
fi

if [ "$fail" -ne 0 ]; then
  echo "index-check: FAILED" >&2
  exit 1
fi
echo "index-check: OK"
