#!/bin/bash
set -e

# swap-traffic.sh - Simple Blue-Green Traffic Switching Script
# Usage: ./swap-traffic.sh [blue-to-green|green-to-blue]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE_FILE="$SCRIPT_DIR/../.active-environment"
DIRECTION="${1:-auto}"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "Blue-Green Traffic Switching Script"
echo "========================================"

# Create state file if it doesn't exist (default to Blue active)
if [ ! -f "$STATE_FILE" ]; then
    echo "blue" > "$STATE_FILE"
    echo "Initialized state file. Blue is active by default."
fi

# Read current active environment
CURRENT_ACTIVE=$(cat "$STATE_FILE")
echo -e "Current active environment: ${BLUE}$CURRENT_ACTIVE${NC}"

# Determine direction
if [ "$DIRECTION" = "auto" ]; then
    if [ "$CURRENT_ACTIVE" = "blue" ]; then
        DIRECTION="blue-to-green"
    else
        DIRECTION="green-to-blue"
    fi
    echo "Auto-detected direction: $DIRECTION"
fi

# Perform the switch
case "$DIRECTION" in
    blue-to-green)
        if [ "$CURRENT_ACTIVE" != "blue" ]; then
            echo -e "${RED}Error: Blue is not currently active. Current: $CURRENT_ACTIVE${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Switching traffic from Blue to Green...${NC}"
        
        # Health check on Green before switching
        echo "🏥 Running health check on Green environment..."
        if ! curl -f -s http://localhost:8081/health > /dev/null 2>&1; then
            echo -e "${RED}Green environment health check failed!${NC}"
            echo "   Make sure Green is running: docker-compose up -d gym-app-green"
            exit 1
        fi
        echo -e "${GREEN}Green environment is healthy${NC}"
        
        # Switch traffic (in real scenario, this would update load balancer/DNS)
        echo "green" > "$STATE_FILE"
        
        echo -e "${GREEN}Traffic switched: Blue → Green${NC}"
        echo -e "   ${GREEN}Green is now ACTIVE${NC}"
        echo -e "   ${BLUE}Blue is now STANDBY${NC}"
        ;;
        
    green-to-blue)
        if [ "$CURRENT_ACTIVE" != "green" ]; then
            echo -e "${RED}Error: Green is not currently active. Current: $CURRENT_ACTIVE${NC}"
            exit 1
        fi
        
        echo -e "${YELLOW}Switching traffic from Green to Blue...${NC}"
        
        # Health check on Blue before switching
        echo "🏥 Running health check on Blue environment..."
        if ! curl -f -s http://localhost:8080/health > /dev/null 2>&1; then
            echo -e "${RED}Blue environment health check failed!${NC}"
            echo "   Make sure Blue is running: docker-compose up -d gym-app"
            exit 1
        fi
        echo -e "${GREEN}Blue environment is healthy${NC}"
        
        # Switch traffic (in real scenario, this would update load balancer/DNS)
        echo "blue" > "$STATE_FILE"
        
        echo -e "${GREEN}Traffic switched: Green → Blue${NC}"
        echo -e "   ${BLUE}Blue is now ACTIVE${NC}"
        echo -e "   ${GREEN}Green is now STANDBY${NC}"
        ;;
        
    *)
        echo -e "${RED}Invalid direction: $DIRECTION${NC}"
        echo "Usage: $0 [blue-to-green|green-to-blue|auto]"
        exit 1
        ;;
esac

# Display status
echo ""
echo "Current Status:"
echo "=================="
NEW_ACTIVE=$(cat "$STATE_FILE")
if [ "$NEW_ACTIVE" = "blue" ]; then
    echo -e "${BLUE}ACTIVE:${NC}   Blue  (http://localhost:8080)"
    echo -e "${GREEN}STANDBY:${NC} Green (http://localhost:8081)"
else
    echo -e "${GREEN}ACTIVE:${NC}   Green (http://localhost:8081)"
    echo -e "${BLUE}STANDBY:${NC} Blue  (http://localhost:8080)"
fi

echo ""
echo "✅ Traffic switch complete!"
echo ""
echo "💡 Tips:"
echo "   - Run health checks: curl http://localhost:808[0|1]/health"
echo "   - View logs: docker logs gym-app or gym-app-backup"
echo "   - Rollback: ./swap-traffic.sh (runs auto switch back)"

exit 0