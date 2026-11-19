# Sourced by the module scripts before any curl use. The bundled curl is a Termux build with a
# baked-in default CA bundle path (/data/data/com.termux/.../cert.pem) that is absent on real
# devices, so https fails with rc 77. Build a bundle from the device trust store and export
# CURL_CA_BUNDLE, which overrides that default. Cached under the state dir; no-op if already set
# or if no trust store is found (curl then keeps its own default - no regression).
if [ -z "${CURL_CA_BUNDLE:-}" ]; then
  _vdcab="${STATE:-/data/adb/vdbackup}/.ca-bundle.pem"
  if [ ! -s "$_vdcab" ]; then
    for _vdd in /apex/com.android.conscrypt/cacerts /system/etc/security/cacerts /etc/security/cacerts; do
      [ -d "$_vdd" ] && cat "$_vdd"/* 2>/dev/null
    done > "$_vdcab" 2>/dev/null
  fi
  if [ -s "$_vdcab" ]; then export CURL_CA_BUNDLE="$_vdcab"; else rm -f "$_vdcab" 2>/dev/null; fi
  unset _vdcab _vdd
fi
