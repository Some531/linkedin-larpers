#!/bin/zsh
# PhilAlert demo: simulates tapping the alert link in the SMS.
# Double-click this file in Finder — no typing needed.

export DEVELOPER_DIR=/Applications/Xcode.app/Contents/Developer
SIM=3E54FDC6-9BF2-4C31-86FF-A7AA55B08690   # iPhone 16 Pro

echo "PhilAlert SMS-link demo"
echo "-----------------------"

# 1. Make sure the simulator is booted and visible.
xcrun simctl boot "$SIM" 2>/dev/null
xcrun simctl bootstatus "$SIM" -b >/dev/null 2>&1
open -a Simulator

# 2. Make sure the app is running (also gets past a cold start).
xcrun simctl launch "$SIM" ph.rdy.HandaPH >/dev/null 2>&1
sleep 2

# 3. Show the SMS on screen (Messages-style preview inside the app).
if xcrun simctl openurl "$SIM" "handaph://sms-demo"; then
    echo ""
    echo "✅ Look at the Simulator window:"
    echo "   - If iOS asks 'Open in PhilAIert?', click Open."
    echo "   - You will SEE the SMS as a message bubble from PAGASA-ALERT."
    echo "   - Tap the blue link in the bubble -> the alert opens."
else
    echo ""
    echo "❌ Something failed. Is the app installed? Open Xcode and press ⌘R once,"
    echo "   then double-click this file again."
fi
echo ""
read -k 1 "?Press any key to close..."
