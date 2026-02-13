#!/bin/bash
# sync-to-repo.sh

REPO=~/"_Claude Projects"/HA-Master-Repo

rsync -av ~/"_Claude Projects"/"HA Master Style Guide"/ "$REPO/style-guide/"
rsync -av "/Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/blueprints/automation/madalone/" "$REPO/automation/"
rsync -av "/Users/madalone/Library/Containers/nz.co.pixeleyes.AutoMounter/Data/Mounts/Home Assistant/SMB/config/blueprints/script/madalone/" "$REPO/script/"

echo "Sync complete. Time is money — go commit!"
