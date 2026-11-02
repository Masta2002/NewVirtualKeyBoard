#!/bin/sh
##setup command=wget https://raw.githubusercontent.com/Masta2002/NewVirtualKeyBoard/main/installer.sh -O - | /bin/sh
###########
version="14.04"
description="
What is NEW :
- an old copy of the keyboard screen in the image skin (before 13.9) is
  ignored: it made Caps too wide for its frame and marked the wrong key
- correct messages after the install, also for ipk and deb
Older changes: github.com/Masta2002/NewVirtualKeyBoard/releases
"

PLUGINPATH=/usr/lib/enigma2/python/Plugins/SystemPlugins/NewVirtualKeyBoard
WORKDIR=/tmp/NewVirtualKeyBoard_update

# Download and check first - the box is only touched when the download is ok
echo " ** Download and install NewVirtualKeyBoard ** "
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR" || exit 1
if ! wget -q "https://github.com/Masta2002/NewVirtualKeyBoard/archive/refs/heads/main.tar.gz" -O main.tar.gz \
   || ! tar -xzf main.tar.gz \
   || [ ! -f "NewVirtualKeyBoard-main$PLUGINPATH/VirtualKeyBoard.py" ]; then
	echo "Download failed .. nothing was changed"
	cd /tmp
	rm -rf "$WORKDIR"
	exit 1
fi

# No full wipe: Screens/VirtualKeyBoard.py may be a symlink into the plugin
# folder and skins/kle/ holds the user's downloaded layouts. Remove only what
# 13.9 dropped and stale compiled files.
rm -rf "$PLUGINPATH/language" "$PLUGINPATH"/language_config.py* "$PLUGINPATH"/compat.py* \
	"$PLUGINPATH"/skins/NewVirtualKeyBoard*.py* "$PLUGINPATH"/skins/__init__.py* "$PLUGINPATH/skins/icons/vk"
for tier in hd fhd wqhd; do
	rm -f "$PLUGINPATH/skins/icons/menus/$tier/flag.png" "$PLUGINPATH/skins/icons/menus/$tier/history.png" "$PLUGINPATH/skins/icons/menus/$tier/settings.png"
done
for tier in nvk nvk_hd nvk_wqhd; do
	for name in key_red key_green key_yellow key_blue key_plus key_minus vkey_country; do
		rm -f "$PLUGINPATH/skins/icons/$tier/$name.png"
	done
done
find "$PLUGINPATH" -name '*.py[co]' -exec rm -f {} \; 2>/dev/null
find "$PLUGINPATH" -type d -name __pycache__ -prune -exec rm -rf {} \; 2>/dev/null

# the translation sources are not needed on the box, only the .mo files
find "NewVirtualKeyBoard-main$PLUGINPATH/locale" \( -name '*.po' -o -name '*.pot' -o -name '*.sh' \) -exec rm -f {} \; 2>/dev/null
if ! cp -r "NewVirtualKeyBoard-main/usr" /; then
	echo "Copying the files failed .. the plugin may be incomplete, run the installer again"
	cd /tmp
	rm -rf "$WORKDIR"
	exit 1
fi
# same as the ipk: the new keyboard again when the saved settings select it
sh "NewVirtualKeyBoard-main/CI/postinst.sh" >/dev/null
cd /tmp
rm -rf "$WORKDIR"

### Check if plugin installed correctly
if [ ! -f "$PLUGINPATH/VirtualKeyBoard.py" ]; then
	echo "Some thing wrong .. Plugin not installed"
	exit 1
fi

bannerLine() {
	printf '# %-71s #\n' "$1"
}

sync
echo
echo
echo "###########################################################################"
bannerLine "NewVirtualKeyBoard $version installed successfully"
bannerLine ""
if [ -L /usr/lib/enigma2/python/Screens/VirtualKeyBoard.py ]; then
	bannerLine "The new keyboard is active."
else
	bannerLine "To use it: Menu > System > NewVirtualKeyBoard setup"
fi
bannerLine ""
bannerLine "By SamSamSam (E2iPlayer), mfaraj57, RAED (fairbird) and contributors"
bannerLine "Updates and help: https://github.com/Masta2002/NewVirtualKeyBoard"
bannerLine ""
bannerLine "enigma2 restarts now."
echo "###########################################################################"
echo
killall enigma2
exit 0
