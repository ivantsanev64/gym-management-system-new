#!/bin/bash
set -e

echo "EMERGENCY ROLLBACK INITIATED"

# Switch traffic back to Blue (previous version)
echo "Switching traffic to Blue environment..."
./scripts/swap-traffic.sh green-to-blue

# Verify health
echo "Checking health..."
curl -f https://yourgym.com/health || exit 1

# Send notification
echo "Rollback complete. Blue environment is now active."
echo "Sending notifications..."
./scripts/notify-team.sh "Rollback executed successfully"