#!/bin/bash
set -eu
sshpass -p "$PEZ_PASSWORD" ssh "$PEZ_JUMPBOX"
