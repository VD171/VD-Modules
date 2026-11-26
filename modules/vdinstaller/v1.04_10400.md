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

## v1.04

- Updated the VDLU self-update engine to v8: incremental updates are now ABI-aware (the plan skips files for ABIs this device does not use, so updates download less and apply faster), and a stale or out-of-order update plan self-heals on boot instead of risking a downgrade.
- The module now presents consistently as "VD Installer": the WebUI title, a README wordmark with badges, per-language WebUI screenshots, and the README, language switcher, Contacts block and project links canonicalized across all 22 languages.
- Hardened the release and CI tooling further: a live-feed verification guard (a release is not declared done until the published update feed serves the new version) plus i18n-parity, provenance and zip-orphan checks.

## v1.03

- Updated the VDLU self-update engine to v5: it follows the trust-anchor rule, so a device that already trusts the signing key keeps updating cleanly; it applies safer download size limits (128 MiB per archive, 2 MiB per file), reports clearer TLS diagnostics when an update check fails, and defers the apply step while an install is busy.
- Auto-update on WebUI open is now on by default, so the module keeps itself current without a manual check.
- Hardened the release and CI tooling (blocking ShellCheck, pinned actions, a SELinux staging lint, and a binary-refresh workflow) and standardized the contact banner across every vendored script and workflow.

## v1.02

- Fixed split and archive installs (`.apkm` / `.apks` / `.xapk` and multi-APK folders): they were failing with "install-write failed" because Android's package installer, running as the system server, could not read the staged files. The APKs are now staged where it can read them, and a failure now reports the installer's real reason.
- Install failures show a plain-language hint (verifier, storage, signature mismatch, already installed, low target SDK, unreadable APK) next to the raw message.
- New: one-tap restore of the original install-source, and a Recent activity log in the About tab.
- Ships as a single universal zip (the per-ABI split is gone).
- The install hints now name the Options tab in each language, and the Spanish / French / Italian strings regained their accents.
- Wiki: a per-document language index, and fixed empty labels on the Ukrainian pages.

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

> _This documentation was generated with Claude (Anthropic) and is maintained by VD171. Corrections and improvements are welcome, see [CONTRIBUTING.md](CONTRIBUTING.md)._
