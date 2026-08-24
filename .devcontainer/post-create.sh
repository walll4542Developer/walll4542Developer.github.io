#!/usr/bin/env bash

set -eu
corepack enable
pnpm install --frozen-lockfile
pnpm run build
