#!/bin/bash
set -eu
sshpass -p "$JB_PASSWORD" ssh "$JB_HOSTNAME" -l "$JB_USER"
