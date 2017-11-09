#!/usr/bin/env bash

#__author__  = "Jeff White [karttoon]"
#__email__   = "karttoon@gmail.com"
#__version__ = "1.0.0"
#__date__    = "09NOV2017"

# Path to your VMX file
VMXPATH=''

# Guest VM snapshot name
SNAPNAME='curtain'

# Guest VM details
USERNAME=''
PASSWORD=''

# Clean-up old files
rm output.html &> /dev/null
rm desktop.png &> /dev/null 

# Revert to pristine state
echo "[+] Reverting to snapshot - $SNAPNAME"
vmrun revertToSnapshot "$VMXPATH" "$SNAPNAME"

# Start the VM in the background
echo "[+] Starting headless VM"
vmrun start "$VMXPATH" nogui

# Give the VM some time to spin up and potentially avoid issues
sleep 5

# Copy primary PowerShell Curtain script that handles parsing
echo "[+] Copying curtain.ps1 to virtual Guest"
vmrun -gu "$USERNAME" -gp "$PASSWORD" CopyFileFromHostToGuest "$VMXPATH" ./curtain.ps1 "C:\curtain\curtain.ps1"

# Copy the target file over
echo "[+] Sending target file to detonate"
#FILENAME="C:\\curtain\\$1"
vmrun -gu "$USERNAME" -gp "$PASSWORD" CopyFileFromHostToGuest "$VMXPATH" "$1" "C:\\curtain\\$1"

# Run the script
echo "[+] Launching Curtain PS script for - $1"
vmrun -gu "$USERNAME" -gp "$PASSWORD" runProgramInGuest "$VMXPATH" -noWait -activeWindow -interactive 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' "powershell -ep bypass C:\curtain\curtain.ps1"

# Sleep might need to be adjusted depending on sample but usually this happens almost immediately upon execution (downloads/etc might take longer)
echo "[!] Sleeping for 10 seconds to let malware doing its thang..."
sleep 10

# Copy back over the resulting output
echo "[+] Transferring output from script"
vmrun -gu "$USERNAME" -gp "$PASSWORD" CopyFileFromGuestToHost "$VMXPATH" "C:\curtain\output.html" ./output.html

# Grab a screenshot of the VM
echo "[+] Grabbing a screenshot of the desktop"
vmrun -gu "$USERNAME" -gp "$PASSWORD" captureScreen "$VMXPATH" desktop.png

# Kill the VM so it doesn't continue to run
echo "[+] Killing virtual Guest"
vmrun stop "$VMXPATH"

# Launch website with parsed data
echo "[+] Launching site..."
open output.html
