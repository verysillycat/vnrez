if [ -f "$CONFIG_FILE" ]; then
	source "$CONFIG_FILE"
fi

check_root() {
	if [[ $EUID -eq 0 ]]; then
		echo -e "\e[31mThis script should not be run as root.\e[0m"
		sleep 1.8
		exit 1
	fi
}

check_variables() {
	if [[ -z "$service" ]]; then
		echo "Service is not set."
		echo "Edit the configuration file with config argument to add the service."
		notify-send "Service is not set." 'Edit the configuration file to add the service.' -a "VENZ Recorder"
		exit 1
	fi

	if [[ -z "$auth" ]]; then
		if [[ ! "$service" = none ]]; then
			echo "API Key is not set."
			echo "Edit the configuration file with config argument to add the API Key."
			notify-send "API Key is not added." 'Edit the configuration file to add the API Key.' -a "VENZ Recorder"
			exit 1
		fi
	fi

	if [[ -z "$encoder" && ! ("$XDG_SESSION_TYPE" == "wayland" && ("$XDG_CURRENT_DESKTOP" == "GNOME" || "$XDG_CURRENT_DESKTOP" == "KDE" || "$XDG_CURRENT_DESKTOP" == "COSMIC")) ]]; then
		echo "Encoder is not set."
		echo "Edit the configuration file with config argument to add the encoder."
		notify-send "Encoder is not set." 'Edit the config file to add the encoder.' -a "VENZ Recorder"
		exit 1
	fi

	if [[ -z "$pixelformat" && ! ("$XDG_SESSION_TYPE" == "wayland" && ("$XDG_CURRENT_DESKTOP" == "GNOME" || "$XDG_CURRENT_DESKTOP" == "KDE" || "$XDG_CURRENT_DESKTOP" == "COSMIC")) ]]; then
		echo "Pixelformat is not set."
		echo "Edit the configuration file with config argument to add the pixelformat."
		notify-send "Pixelformat is not set." 'Edit the config file to add the pixelformat.' -a "VENZ Recorder"
		exit 1
	fi
}

check_dependencies() {
	local missing_dependencies=()
	local dependencies=("jq" "curl" "flameshot")

	if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
		if [[ "$XDG_CURRENT_DESKTOP" == "GNOME" || "$XDG_CURRENT_DESKTOP" == "KDE" || "$XDG_CURRENT_DESKTOP" == "COSMIC" ]]; then
			dependencies+=("wl-copy" "kooha")
		else
			dependencies+=("wl-copy" "slurp" "wlr-randr")
			if ! command -v "wf-recorder" &>/dev/null && ! command -v "wl-screenrec" &>/dev/null; then
				missing_dependencies+=("wf-recorder or wl-screenrec")
			fi
		fi
	else
		dependencies+=("xclip" "slop" "ffmpeg" "xdpyinfo")
	fi

	for dep in "${dependencies[@]}"; do
		if ! command -v "$dep" &>/dev/null; then
			missing_dependencies+=("$dep")
		fi
	done

	if [ ${#missing_dependencies[@]} -ne 0 ]; then
		local formatted_deps=$(IFS=, echo "${missing_dependencies[*]}")
		formatted_deps=${formatted_deps//,/, }
		formatted_deps=${formatted_deps//wl-copy/wl-clipboard}
		formatted_deps=$(echo "$formatted_deps" | sed 's/, \([^,]*\)$/ \& \1/')
		echo -e "\e[31mMissing Dependencies: \033[37;7m${formatted_deps}\033[0m\e[0m"
		echo "These are the required dependencies, install them and try again."
		notify-send "Missing Dependencies" "${formatted_deps}" -a "VNEZ"
		exit 1
	fi
}
