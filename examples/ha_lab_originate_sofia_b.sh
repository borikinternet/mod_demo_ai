#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

examples/ha_lab_cli.sh originate sofia/internal/sip:9196@127.0.0.1:5070 '&park()'