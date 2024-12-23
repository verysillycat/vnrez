CONFIG_DIR="$HOME/.config/vnrez"
CONFIG_FILE="$CONFIG_DIR/config.conf"

if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

ez="https://api.e-z.host/files"
nest="https://nest.rip/api/files/upload"

temp_file="/tmp/screenshot.png"
response="/tmp/upload.json"
response_video="/tmp/upload_video.json"
gif_pending_file="/tmp/gif_pending"

if [[ "$1" == "auto" ]]; then
	handle_auto="$2"
else
	handle_auto="$1"
fi

if [ "$1" = "auto" ]; then
	kooha_last_time="/tmp/.vnrez_kooha_last-time"
else
	kooha_last_time="$CONFIG_DIR/last_time"
fi

if [ "$1" = "auto" ]; then
	kooha_dir="$HOME/Videos/Kooha"
fi

if [ "$1" = "auto" ]; then
	lockfile="/tmp/.vnrez.lck"
else
	lockfile="$CONFIG_DIR/.script.lck"
fi

upload_lockfile="$CONFIG_DIR/.upload.lck"

if [ "$service" = "e-z" ]; then
	auth=$ez_auth
elif [ "$service" = "nest" ]; then
	auth=$nest_auth
fi

if [ "$service" = "e-z" ]; then
	url=$ez
elif [ "$service" = "nest" ]; then
	url=$nest
fi

valid_cases=(
    "--help"
    "-h"
    "config"
    "reinstall"
    "upload"
    "-u"
    "shot"
    "record"
)

shot_args=(
    "--gui"
    "--full"
    "--screen"
)

record_args=(
    "--sound"
    "--fullscreen-sound"
    "--fullscreen"
    "--no-sound"
    "--gif"
	"--abort"
)
