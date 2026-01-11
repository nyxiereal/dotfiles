#!/usr/bin/env python3

import json
import subprocess
import sys

# Known/expected partitions - these won't trigger the module to show
KNOWN_PARTITIONS = {
    "sda1", "zram0", "nvme0n1p1", "nvme0n1p2"
}

def run_command(cmd):
    """Run a command and return its output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except subprocess.CalledProcessError as e:
        return None

def get_lsblk_data():
    """Get lsblk output as JSON with filesystem information"""
    try:
        output = run_command("lsblk --fs -J -o NAME,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,FSAVAIL,FSUSE%,MOUNTPOINTS")
        if output:
            return json.loads(output)
    except (json.JSONDecodeError, subprocess.CalledProcessError):
        return None
    return None

def find_new_drives():
    """Find drives/partitions that are not in the known list"""
    data = get_lsblk_data()
    if not data:
        return []
    
    new_partitions = []
    
    def process_device(device, parent_name=""):
        name = device.get("name", "")
        size = device.get("size", "")
        type_val = device.get("type", "")
        fstype = device.get("fstype", "")
        fsver = device.get("fsver", "")
        label = device.get("label", "")
        uuid = device.get("uuid", "")
        fsavail = device.get("fsavail", "")
        fsuse = device.get("fsuse%", "")
        mountpoints = device.get("mountpoints", [])
        
        # Skip if it's a known partition
        if name in KNOWN_PARTITIONS:
            return
            
        # For partitions that are not known, add them
        if type_val == "part" and name not in KNOWN_PARTITIONS:
            mount_info = ", ".join([mp for mp in mountpoints if mp]) if mountpoints else "Not mounted"
            
            # Build detailed filesystem info
            fs_info = []
            if fstype:
                fs_info.append(f"Type: {fstype}")
            if fsver:
                fs_info.append(f"Version: {fsver}")
            if label:
                fs_info.append(f"Label: {label}")
            if fsavail:
                fs_info.append(f"Available: {fsavail}")
            if fsuse:
                fs_info.append(f"Used: {fsuse}")
            if uuid:
                fs_info.append(f"UUID: {uuid}")
            
            new_partitions.append({
                "name": name,
                "size": size,
                "mountpoints": mount_info,
                "fstype": fstype,
                "label": label,
                "fs_info": fs_info
            })
        
        # Process children recursively
        for child in device.get("children", []):
            process_device(child, name)
    
    for device in data.get("blockdevices", []):
        process_device(device)
    
    return new_partitions

def sync_drives():
    """Sync and send notification"""
    try:
        subprocess.run(["sync"], check=True)
        subprocess.run(["notify-send", "Sync finished!"], check=False)
    except subprocess.CalledProcessError:
        subprocess.run(["notify-send", "Sync failed!"], check=False)

def unmount_new_drives():
    """Safely unmount new drives and send notification"""
    new_partitions = find_new_drives()
    
    if not new_partitions:
        subprocess.run(["notify-send", "No removable drives to unmount"], check=False)
        return
    
    # Sync first
    try:
        subprocess.run(["sync"], check=True)
    except subprocess.CalledProcessError:
        subprocess.run(["notify-send", "Sync failed before unmounting!"], check=False)
        return
    
    success_count = 0
    failed_drives = []
    
    for partition in new_partitions:
        name = partition["name"]
        if partition["mountpoints"] != "Not mounted":
            try:
                # Try to unmount
                subprocess.run(["umount", f"/dev/{name}"], check=True)
                success_count += 1
            except subprocess.CalledProcessError:
                failed_drives.append(name)
    
    # Send notification
    if failed_drives:
        subprocess.run([
            "notify-send", 
            "Unmount partially failed", 
            f"Failed to unmount: {', '.join(failed_drives)}"
        ], check=False)
    elif success_count > 0:
        subprocess.run([
            "notify-send", 
            "Drives unmounted successfully", 
            f"Unmounted {success_count} drive(s)"
        ], check=False)
    else:
        subprocess.run(["notify-send", "No mounted drives to unmount"], check=False)

def main():
    if len(sys.argv) > 1:
        if sys.argv[1] == "sync":
            sync_drives()
            return
        elif sys.argv[1] == "unmount":
            unmount_new_drives()
            return
    
    # Default behavior: check for new drives and output JSON for waybar
    new_partitions = find_new_drives()
    
    if not new_partitions:
        # No new drives detected - don't show the module
        print(json.dumps({"text": "", "class": "hidden"}))
        return
    
    # Format the display text
    if len(new_partitions) == 1:
        partition = new_partitions[0]
        display_name = partition['label'] if partition['label'] else partition['name']
        text = f"🔌 {display_name} ({partition['size']})"
    else:
        text = f"🔌 {len(new_partitions)} drives"
    
    # Create detailed tooltip with all partition info
    tooltip_lines = []
    for partition in new_partitions:
        # Header line with name, size, and mount status
        header = f"📱 {partition['name']} ({partition['size']})"
        if partition['label']:
            header += f" - {partition['label']}"
        tooltip_lines.append(header)
        
        # Mount point info
        tooltip_lines.append(f"   📍 {partition['mountpoints']}")
        
        # Filesystem details
        if partition['fs_info']:
            for info in partition['fs_info']:
                tooltip_lines.append(f"   🔧 {info}")
        
        tooltip_lines.append("")  # Empty line between drives
    
    # Remove the last empty line
    if tooltip_lines and tooltip_lines[-1] == "":
        tooltip_lines.pop()
    
    tooltip = "\n".join(tooltip_lines)
    
    output = {
        "text": text,
        "tooltip": tooltip,
        "class": "drive-detected"
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    main()