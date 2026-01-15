#!/bin/bash

# Configuration
FRONTEND_NS="frontend"
FRONTEND_SVC="fe-frontend"
LOCAL_PORT=8080
TARGET_PORT=8080
URL="http://localhost:$LOCAL_PORT"

echo "🚀 Starting Bookstore Application..."

# 1. Check if Pods are Running
echo "🔍 Checking pod status..."
STATUS=$(kubectl get pods -A | grep -E 'frontend|backend|database' | grep -v 'Running' | grep -v 'Completed')

if [ ! -z "$STATUS" ]; then
    echo "⚠️ Some pods are not in Running state:"
    echo "$STATUS"
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
else
    echo "✅ All core pods are running."
fi

# 2. Handle Existing Port-Forwarding
EXISTING_PID=$(lsof -t -i:$LOCAL_PORT)
if [ ! -z "$EXISTING_PID" ]; then
    echo "🔄 Port $LOCAL_PORT is already in use by PID $EXISTING_PID."
    read -p "Kill existing process and restart? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill $EXISTING_PID
        sleep 1
    else
        echo "Exiting."
        exit 1
    fi
fi

# 3. Start Port-Forwarding in Background
echo "📡 Establishing port-forward to $FRONTEND_SVC..."
kubectl port-forward -n $FRONTEND_NS svc/$FRONTEND_SVC $LOCAL_PORT:$TARGET_PORT > /dev/null 2>&1 &
PF_PID=$!

# Wait for port-forward to be ready
sleep 2

# Check if port-forwarding started successfully
if ! kill -0 $PF_PID > /dev/null 2>&1; then
    echo "❌ Failed to start port-forwarding. Please check kubectl logs."
    exit 1
fi

echo "✅ Port-forwarding active on pid $PF_PID."

# 4. Open Browser
echo "🌍 Opening application in browser: $URL"
if command -v xdg-open > /dev/null; then
    xdg-open "$URL"
elif command -v open > /dev/null; then
    open "$URL"
else
    echo "Browser could not be opened automatically. Please navigate to: $URL"
fi

echo "--------------------------------------------------"
echo "Application is running! Close this terminal to stop."
echo "--------------------------------------------------"

# Keep script running to maintain port-forward
wait $PF_PID
