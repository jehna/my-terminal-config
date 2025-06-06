#!/bin/bash
set -euo pipefail

# Keep mac alive for the execution of a task
caffeinate -sm "$@"