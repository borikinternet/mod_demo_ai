#!/bin/bash

set -euo pipefail

cd "$(dirname "$0")/.."

examples/ha_lab_cli.sh originate loopback/9196/default '&park()'