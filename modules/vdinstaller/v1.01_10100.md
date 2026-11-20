<!--
  ======================================================================
   VD INSTALLER  ::  frictionless root sideload installer
   Install sideload APKs as root (single/batch/split), no friction: KernelSU/APatch/Magisk WebUI.

   Copyright (C) 2026  VD171
   SPDX-License-Identifier: AGPL-3.0-or-later

   Free software under the GNU AGPL v3 or later. NETWORK COPYLEFT: run a
   modified version, even as a service, and you MUST offer its source.

   Site           : https://vd171.ru
   Site           : https://vd.priv8.ru
   Source         : https://github.com/VD171/VD-Installer
   GitHub         : @VD171 https://github.com/VD171
   XDA-Developers : @VD171 https://xdaforums.com/m/vd171.4699873/
   XDA thread     : https://xdaforums.com/t/VD-Installer.4809504/
   Telegram       : @VD_Priv8 https://t.me/VD_Priv8
   Channel        : @Priv8_VD https://t.me/Priv8_VD
   Discord        : @VD.Priv8 https://discord.com/users/1296831918989639721
   E-mail         : vd.priv8@pm.me
  ======================================================================
-->

# Changelog

All notable changes to VDInstaller are documented here. This file is English only.

## v1.01

- First release. Frictionless root sideload installer (KernelSU / APatch / Magisk WebUI).
- Install modes: single APK, folder batch, grouped split archive (`.xapk` / `.apkm` / `.apks` / `.zip`), loose split folder.
- 3-way Play Protect package verifier toggle (keep as it was / always on / always off) with a stealth-tell warning on always-off; the exact prior state is restored by default.
- Best-effort Developer Verification toggle (a root install is already ADB-exempt from it).
- Play install-source spoof: installer at install time (`-i`) and initiator via an ABX-aware `packages.xml` edit.
- Install flags: allow test packages, grant all runtime permissions, target user, bypass low target SDK block.
- Detached install with live progress and cancel; uninstall.
- Bundled `jq` + `abx2xml` / `xml2abx` for all four ABIs, each with a `PROVENANCE.json`.
- VDLU flashless, signed, incremental self-update.
- 22-language WebUI.

<!-- doc-footer -->

---

> _This documentation was generated with Claude (Anthropic) and is maintained by VD171. Corrections and improvements are welcome; see [CONTRIBUTING.md](CONTRIBUTING.md)._
