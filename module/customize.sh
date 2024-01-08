# Error on < Android 8
if [ "$API" -lt 26 ]; then
    abort "! You can't use this module on Android < 8.0"
fi

# Remove/warn if conflicting modules are installed
if [ -d /data/adb/modules/safetynet-fix ]; then
    touch /data/adb/modules/safetynet-fix/remove
    ui_print "! Universal SafetyNet Fix (USNF) module will be removed on next reboot"
fi
if [ -d /data/adb/modules/MagiskHidePropsConf ]; then
    ui_print "! MagiskHidePropsConfig (MHPC) module may cause issues with PIF"
fi

# Replace conflicting custom ROM injection app folders to disable them
if [ -f "$MODPATH/app_replace.list" ]; then
    for APP in $(grep -v '^#' "$MODPATH/app_replace.list"); do
        if [ -d "$APP" ]; then
            HIDEDIR="$MODPATH/$APP"
            mkdir -p "$HIDEDIR"
            touch "$HIDEDIR/.replace"
            ui_print "- $(basename $APP) app disabled"
        fi
    done
fi

# Copy any custom.pif.json to updated module
if [ -f /data/adb/modules/playintegrityfix/custom.pif.json ]; then
    ui_print "- Restoring custom.pif.json"
    cp -af /data/adb/modules/playintegrityfix/custom.pif.json $MODPATH/custom.pif.json
fi

# Migrate custom.pif.json to latest defaults if needed
if [ -f "$MODPATH/custom.pif.json" ] && ! grep -q "api_level" $MODPATH/custom.pif.json; then
    ui_print "- Running migration script on custom.pif.json:"
    ui_print " "
    chmod 755 $MODPATH/migrate.sh
    sh $MODPATH/migrate.sh install $MODPATH/custom.pif.json
    ui_print " "
fi

# Clean up any leftover files from previous deprecated methods
rm -f /data/data/com.google.android.gms/cache/pif.prop /data/data/com.google.android.gms/pif.prop \
    /data/data/com.google.android.gms/cache/pif.json /data/data/com.google.android.gms/pif.json
