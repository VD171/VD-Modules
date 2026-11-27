<!--
  VD Modules: architecture and release pipeline.
  Copyright (C) 2026  VD171. SPDX-License-Identifier: GPL-3.0-or-later
-->

# VD Modules: architecture and pipeline

How this repository turns a module release into an entry your root manager can
install and keep updated. This is reference material for maintainers, users only
need the [README](../README.md).

## What the repository holds

```
json/config.json          mmrl-util source of truth (name, description, max_num)
json/modules.json          generated index served to MMRL clients
modules/<id>/track.yaml    per-module tracking (enable, source, update_to, added)
modules/<id>/update.json   per-module version list (mirror of this module's slice)
modules/<id>/<ver>.zip     the flashable asset for each retained version
modules/<id>/<ver>.md      per-version changelog (when the source provides one)
assets/                    repository cover art
tools/index-check.sh       index-consistency guard (see below)
.github/workflows/         the sync-build-deploy pipeline
```

The live feed is published to GitHub Pages at
`https://vd171.github.io/VD-Modules/` and added to MMRL from that URL.

## How a release lands

A new module version reaches users through five stages:

1. **Source release.** The module's own repository (for example
   `VD171/VD-Backup`) bumps its channel JSON and publishes a GitHub release
   asset: the flashable zip. The channel JSON that this repo follows is named
   per module in `modules/<id>/track.yaml` as `update_to`.

2. **Sync.** Every six hours (cron `0 */6 * * *`) and on manual dispatch, the
   `sync` job runs `mmrl-util sync`. For each module it reads `update_to`,
   compares the advertised `versionCode` against the feed head, and **appends
   only versions whose versionCode is higher**. It downloads the asset into
   `modules/<id>/`, writes the per-version changelog `.md` when the source
   carries one, and refreshes `update.json` and `json/modules.json`.

3. **Index and push.** `mmrl-util index --push` commits the refreshed feed and
   pushes it, authored as `github-actions[bot]`.

4. **Build and overlay.** The `build` job renders the repository into `_site`
   with Jekyll, then overlays the orphan `vdlu-feed` branch (content-addressed
   VDLU incremental-update blobs and signed manifests) on top, unprocessed. A
   `.nojekyll` marker is dropped into `_site` so Pages serves those blobs
   byte-for-byte.

5. **Deploy.** The `deploy` job publishes `_site` to GitHub Pages.

### Cadence and window

- The pipeline runs on a 6-hour cron, so a source release is visible in the feed
  within at most six hours (sooner via manual `workflow_dispatch`).
- The feed keeps a **trailing window of the 3 newest versions** per module.
  Older zips and changelogs age out as new ones are appended. Retained versions
  are contiguous by release order, newest last.

## The append-only trap, and the guard

`mmrl-util sync` only ever appends versions **higher** than the current feed
head. That makes one failure mode silent: if a module's `update_to` points at a
channel whose versionCode is **lower** than the feed head, the module can never
advance through the feed again, no matter how many times sync runs.

Two rules follow:

- `track.yaml:update_to` must point at the channel that carries the module's
  **shipping** release, the same channel the module's own `module.prop`
  `updateJson` uses. Do not point it at a stale or secondary channel.
- `tools/index-check.sh` enforces this. On every pipeline run (and locally) it:
  validates every JSON, checks that every `modules.json` version has its local
  asset present (a missing asset is what a 404 on the published `zipUrl` would
  be), checks that `update.json` and `modules.json` agree per module, and, with
  network access, fails when any sync source advertises a versionCode **below**
  the feed head, or when the feed is running more than the window behind the
  source. Run it offline with `INDEX_CHECK_OFFLINE=1` to skip the remote checks.

## Per-version changelog, and the COPG-VD exception

When a source's channel JSON carries a `changelog` URL, sync writes a
per-version `modules/<id>/<ver>.md` and links it from the feed. VD-Backup,
VD-dropbear and VDGoogle do this, so every retained version shows its own notes.

**COPG-VD is a documented exception.** Upstream serves a single rolling
`CHANGELOG.md` rather than per-version notes, and the older retained COPG-VD
versions were synced before that changelog was wired into its channel JSON, so
their feed `changelog` field is empty by history. Newer COPG-VD versions do
carry a per-version `.md` once the source advertises it. The empty entries age
out of the trailing window on their own, they are expected, not a defect, and do
not need backfilling.

## Hosting note

The pipeline runs on GitHub Actions and publishes to GitHub Pages, so the
automated feed advances on the GitHub remote.

---

```
+----------------------------------------------------------------------+
|  VD171  --  Priv8                                                     |
|  Site           : https://vd171.ru                                   |
|  Site           : https://vd.priv8.ru                                |
|  Source         : https://github.com/VD171/VD-Modules                |
|  GitHub         : @VD171     https://github.com/VD171                 |
|  XDA-Developers : @VD171     https://xdaforums.com/m/vd171.4699873/   |
|  Telegram       : @VD_Priv8  https://t.me/VD_Priv8                    |
|  Channel        : @Priv8_VD  https://t.me/Priv8_VD                    |
|  Discord        : @VD.Priv8  https://discord.com/users/1296831918989639721 |
|  E-mail         : vd.priv8@pm.me                                     |
+----------------------------------------------------------------------+
```
