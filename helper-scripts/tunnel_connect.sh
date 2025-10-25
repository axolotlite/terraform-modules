#!/usr/bin/env bash
set -euo pipefail

# === Defaults / Constants ===
DEFAULT_VERSION="v10.2.0"
OS_TYPE="$(uname | tr '[:upper:]' '[:lower:]')"
BIN_DIR="$HOME/.local/bin"
APP_HOME="$HOME/.local/share/wstunnel"
PROFILE_NAME="default"
PROFILE_DIR=""
PROFILE_ENV_FILE=""
WSTUNNEL_BINARY="$BIN_DIR/wstunnel"
LAST_USED_FILE="$APP_HOME/last_used"

# === Helper functions ===
log() { printf '%s\n' "$*"; }
err() { printf 'ERROR: %s\n' "$*" >&2; }
usage() {
  cat <<EOF
Usage: $0 [--install [--version <ver>] [--os <linux|darwin>]] [--profile <name> [--secret <s> --endpoint <url> --wg-file <file>]] {start|stop}

Options/Commands:
  --install                     Install wstunnel binary (downloads to /tmp and extracts to $BIN_DIR)
    --version <ver>             Which release tag to download (default: $DEFAULT_VERSION)
    --os <linux|darwin>         OS token used in downloaded filename (default: auto-detected: $OS_TYPE)

  --profile <name>              Select or create profile (default name is "default")
    --secret <string>           Set WSTUNNEL_SECRET for the profile (hidden input in interactive mode)
    --endpoint <url>            Set ENDPOINT for the profile (e.g. ws://example.com:8080)
    --wg-file <path>            Path to WireGuard config; file will be copied into profile as wireguard.conf

  start                         Start wstunnel + WireGuard using the active profile
  stop                          Stop wstunnel + WireGuard using the active profile

Behavior:
  - If you run with --profile <name> and no start/stop action, the script enters interactive profile setup mode.
  - If you provide --profile <name> plus --secret/--endpoint/--wg-file, these values are saved non-interactively.
  - If you run --profile <name> start (or stop), saved profile values are loaded and used.
  - Profile data is stored under: $APP_HOME/<profile>/
  - WireGuard connection created/imported will be renamed to: wgc-<profile>

Examples:
  $0 --install
  $0 --install --version v10.2.0 --os linux
  $0 --profile myvpn                      # interactive setup for profile "myvpn"
  $0 --profile myvpn --secret abc --endpoint ws://x:8080 --wg-file ./wg.conf
  $0 --profile myvpn start
  $0 --profile myvpn stop
EOF
  exit 1
}

set_last_used_profile() {
  echo "$PROFILE_NAME" > "$LAST_USED_FILE"
}

load_last_used_profile() {
  if [[ -f "$LAST_USED_FILE" ]]; then
    PROFILE_NAME="$(cat "$LAST_USED_FILE")"
  else
    PROFILE_NAME="default"
  fi
}

ensure_dirs() {
  mkdir -p "$BIN_DIR"
  mkdir -p "$APP_HOME"
}

# Install wstunnel release to $BIN_DIR
install_wstunnel() {
  local version="$1"
  local os_token="$2"

  ensure_dirs

  local tmpfile="/tmp/wstunnel_${version}_${os_token}_amd64.tar.gz"
  local url="https://github.com/erebe/wstunnel/releases/download/${version}/wstunnel_${version:1}_${os_token}_amd64.tar.gz"

  log "[+] Downloading $url to $tmpfile ..."
  if ! curl -fSL -o "$tmpfile" "$url"; then
    err "Failed to download $url"
    exit 2
  fi

  log "[+] Extracting to $BIN_DIR ..."
  tar -C "$BIN_DIR" -xzf "$tmpfile" wstunnel
  if [[ -f "$BIN_DIR/wstunnel" ]]; then
    chmod +x "$BIN_DIR/wstunnel"
    log "[+] Installed $BIN_DIR/wstunnel"
    log "[!] Make sure $BIN_DIR is in your PATH (e.g. export PATH=\"\$HOME/.local/bin:\$PATH\")"
  else
    err "Extraction didn't produce wstunnel binary in $BIN_DIR"
    exit 3
  fi
}

profile_paths() {
  PROFILE_DIR="$APP_HOME/$PROFILE_NAME"
  PROFILE_ENV_FILE="$PROFILE_DIR/profile.env"
  PROFILE_PID_FILE="$PROFILE_DIR/wstunnel.pid"
  PROFILE_WG_FILE="$PROFILE_DIR/wireguard.conf"
}

confirm() {
  # confirm <message>
  local msg="${1:-Are you sure?}"
  read -r -p "$msg [y/N] " resp
  case "$resp" in
    [Yy]|[Yy][Ee][Ss]) return 0 ;;
    *) return 1 ;;
  esac
}

save_profile() {
  profile_paths
  mkdir -p "$PROFILE_DIR"
  # write env file with safe permissions
  umask 077
  {
    echo "WSTUNNEL_SECRET=\"${WSTUNNEL_SECRET:-}\""
    echo "ENDPOINT=\"${ENDPOINT:-}\""
    echo "WGC_FILE=\"${PROFILE_WG_FILE}\""
  } > "$PROFILE_ENV_FILE"
  umask 022
  log "[+] Saved profile to $PROFILE_ENV_FILE"
  set_last_used_profile
}

load_profile() {
  profile_paths
  if [[ -f "$PROFILE_ENV_FILE" ]]; then
    # shellcheck disable=SC1090
    # shellcheck source=/dev/null
    source "$PROFILE_ENV_FILE"
  else
    WSTUNNEL_SECRET=""
    ENDPOINT=""
    WGC_FILE=""
  fi
  # Normalize WGC_FILE variable to the copied profile path, if any
  if [[ -f "$PROFILE_WG_FILE" ]]; then
    WGC_FILE="$PROFILE_WG_FILE"
  fi
}

interactive_profile_setup() {
  profile_paths
  mkdir -p "$PROFILE_DIR"

  if [[ -f "$PROFILE_ENV_FILE" ]]; then
    log "[!] Profile '$PROFILE_NAME' already exists at $PROFILE_DIR"
    if ! confirm "Overwrite profile '$PROFILE_NAME'?"; then
      log "[+] Aborting overwrite. Exiting."
      exit 0
    fi
  fi

  # Secret - hidden
  while true; do
    read -r -s -p "Enter WSTUNNEL_SECRET: " secret_in
    echo
    if [[ -z "$secret_in" ]]; then
      log "Secret cannot be empty."
      continue
    fi
    read -r -s -p "Confirm WSTUNNEL_SECRET: " secret_confirm
    echo
    if [[ "$secret_in" != "$secret_confirm" ]]; then
      log "Secrets do not match. Try again."
      continue
    fi
    WSTUNNEL_SECRET="$secret_in"
    break
  done

  # Endpoint
  while true; do
    read -r -p "Enter ENDPOINT (e.g. ws://example.com:8080): " ep_in
    if [[ -z "$ep_in" ]]; then
      log "Endpoint cannot be empty."
      continue
    fi
    ENDPOINT="$ep_in"
    break
  done

  # WireGuard file path
  while true; do
    read -r -p "Enter path to WireGuard config file: " wgpath
    if [[ -z "$wgpath" ]]; then
      log "WireGuard path cannot be empty."
      continue
    fi
    if [[ ! -f "$wgpath" ]]; then
      log "File not found: $wgpath"
      continue
    fi
    cp "$wgpath" "$PROFILE_WG_FILE"
    chmod 600 "$PROFILE_WG_FILE"
    break
  done

  save_profile
  log "[+] Interactive setup complete for profile '$PROFILE_NAME'"
}

# Start service using loaded profile
start_service() {
  set_last_used_profile
  load_profile
  # checks
  if [[ -z "${WSTUNNEL_SECRET:-}" ]]; then err "WSTUNNEL_SECRET is not set in profile. Aborting."; exit 4; fi
  if [[ -z "${ENDPOINT:-}" ]]; then err "ENDPOINT is not set in profile. Aborting."; exit 5; fi
  if [[ -z "${WGC_FILE:-}" || ! -f "${WGC_FILE}" ]]; then err "WGC file not found in profile at ${WGC_FILE}. Aborting."; exit 6; fi
  if [[ ! -x "$WSTUNNEL_BINARY" ]]; then err "wstunnel binary not found at $WSTUNNEL_BINARY. Run with --install first."; exit 7; fi

  profile_paths

  # launch wstunnel
  log "[+] Starting wstunnel for profile '$PROFILE_NAME'..."
  nohup "$WSTUNNEL_BINARY" client --http-upgrade-path-prefix "$WSTUNNEL_SECRET" \
    -L "udp://51820:127.0.0.1:51820?timeout_sec=0" "$ENDPOINT" >/dev/null 2>&1 &
  local pid=$!
  echo "$pid" > "$PROFILE_PID_FILE"
  log "[+] wstunnel launched (pid: $pid)"

  # Import WireGuard
  log "[+] Importing WireGuard config ..."
  # Capture nmcli output to extract imported connection name
  IMPORT_OUT=$(nmcli connection import type wireguard file "$WGC_FILE" 2>&1) || {
    err "nmcli import failed: $IMPORT_OUT"
    return 8
  }
  # Example success text: "Connection 'wg0' (UUID ...) successfully imported."
  IMPORT_NAME=$(printf '%s' "$IMPORT_OUT" | sed -n "s/Connection '\([^']*\)'.*/\1/p" | head -n1 || true)
  if [[ -z "$IMPORT_NAME" ]]; then
    # fallback: try to find most-recent wireguard connection created
    IMPORT_NAME=$(nmcli -t -f NAME,TYPE connection show | awk -F: '$2=="wireguard"{print $1}' | tail -n1 || true)
  fi

  if [[ -z "$IMPORT_NAME" ]]; then
    err "Could not determine imported WireGuard connection name. Import output:"
    printf '%s\n' "$IMPORT_OUT"
    return 9
  fi

  NEW_NAME="wgc-${PROFILE_NAME}"
  log "[+] Renaming imported connection '$IMPORT_NAME' -> '$NEW_NAME'"
  nmcli connection modify "$IMPORT_NAME" connection.id "$NEW_NAME" || {
    err "Failed to rename connection '$IMPORT_NAME' to '$NEW_NAME'."
    return 10
  }

  # Bring it up
  log "[+] Bringing up WireGuard connection '$NEW_NAME' ..."
  nmcli connection up "$NEW_NAME" || {
    err "Failed to bring up connection '$NEW_NAME'."
    return 11
  }

  log "[+] Service started for profile '$PROFILE_NAME'."
}

# Stop service for a profile
stop_service() {
  set_last_used_profile
  profile_paths
  load_profile

  # kill wstunnel
  if [[ -f "$PROFILE_PID_FILE" ]]; then
    pid=$(cat "$PROFILE_PID_FILE" || true)
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
      log "[+] Stopping wstunnel (pid: $pid) ..."
      kill "$pid" || true
      rm -f "$PROFILE_PID_FILE"
      log "[+] wstunnel stopped."
    else
      log "[!] No running wstunnel process found for pid '$pid'. Removing pid file."
      rm -f "$PROFILE_PID_FILE"
    fi
  else
    log "[!] No pid file at $PROFILE_PID_FILE"
  fi

  # bring down and delete wireguard connection
  WG_NAME="wgc-${PROFILE_NAME}"
  if nmcli -t -f NAME connection show | grep -Fxq "$WG_NAME"; then
    log "[+] Bringing down WireGuard connection '$WG_NAME' ..."
    nmcli connection down "$WG_NAME" || true
    log "[+] Deleting WireGuard connection '$WG_NAME' ..."
    nmcli connection delete "$WG_NAME" || true
    log "[+] WireGuard connection removed."
  else
    log "[!] WireGuard connection '$WG_NAME' not found. Skipping removal."
  fi

  log "[+] Service stopped for profile '$PROFILE_NAME'."
}

# === CLI parse ===
if [[ $# -lt 1 ]]; then usage; fi

# Defaults for install options (may be changed with flags)
INSTALL_FLAG=0
INSTALL_VERSION="$DEFAULT_VERSION"
INSTALL_OS="$OS_TYPE"

# Temp holders for profile set values
ARG_PROFILE=""
ARG_SECRET=""
ARG_ENDPOINT=""
ARG_WG_FILE=""

# Action (start/stop)
ACTION=""

# Parse args (simple loop)
while [[ $# -gt 0 ]]; do
  case "$1" in
    --install) INSTALL_FLAG=1; shift ;;
    --version) INSTALL_VERSION="${2:-}"; shift 2 ;;
    --os) INSTALL_OS="${2:-}"; shift 2 ;;
    --profile) ARG_PROFILE="${2:-}"; shift 2 ;;
    --secret) ARG_SECRET="${2:-}"; shift 2 ;;
    --endpoint) ARG_ENDPOINT="${2:-}"; shift 2 ;;
    --wg-file) ARG_WG_FILE="${2:-}"; shift 2 ;;
    start) ACTION="start"; shift ;;
    stop) ACTION="stop"; shift ;;
    -h|--help) usage ;;
    *) err "Unknown argument: $1"; usage ;;
  esac
done

# Handle install immediately (then continue if other args provided)
if [[ "$INSTALL_FLAG" -eq 1 ]]; then
  install_wstunnel "$INSTALL_VERSION" "$INSTALL_OS"
fi

# If no explicit --profile given, try to load last_used
if [[ -n "$ARG_PROFILE" ]]; then
  PROFILE_NAME="$ARG_PROFILE"
else
  load_last_used_profile
fi

profile_paths

# If user provided profile AND no action -> interactive or non-interactive setup
if [[ -n "${ARG_PROFILE:-}" && -z "$ACTION" ]]; then
  # If non-interactive values provided, save them; else do interactive
  if [[ -n "${ARG_SECRET:-}" || -n "${ARG_ENDPOINT:-}" || -n "${ARG_WG_FILE:-}" ]]; then
    # Non-interactive save: require at least secret + endpoint + wg-file, else prompt for missing ones
    if [[ -z "${ARG_SECRET:-}" ]]; then
      read -r -s -p "Enter WSTUNNEL_SECRET: " tmpsec
      echo
      ARG_SECRET="$tmpsec"
    fi
    if [[ -z "${ARG_ENDPOINT:-}" ]]; then
      read -r -p "Enter ENDPOINT (e.g. ws://example.com:8080): " tmpend
      ARG_ENDPOINT="$tmpend"
    fi
    if [[ -z "${ARG_WG_FILE:-}" ]]; then
      while true; do
        read -r -p "Enter path to WireGuard config file: " tmpwg
        if [[ -f "$tmpwg" ]]; then
          ARG_WG_FILE="$tmpwg"
          break
        fi
        log "File not found: $tmpwg"
      done
    fi

    # Confirm overwrite if exists
    if [[ -f "$PROFILE_ENV_FILE" ]]; then
      if ! confirm "Profile '$PROFILE_NAME' exists. Overwrite?"; then
        log "[+] Aborting; profile not overwritten."
        exit 0
      fi
    fi

    # Copy WG file into profile
    mkdir -p "$PROFILE_DIR"
    cp "$ARG_WG_FILE" "$PROFILE_WG_FILE"
    chmod 600 "$PROFILE_WG_FILE"
    WSTUNNEL_SECRET="$ARG_SECRET"
    ENDPOINT="$ARG_ENDPOINT"
    WGC_FILE="$PROFILE_WG_FILE"
    save_profile
    log "[+] Non-interactive profile '$PROFILE_NAME' saved."
    exit 0
  else
    # Fully interactive setup
    interactive_profile_setup
    exit 0
  fi
fi

# If action is start/stop we need a profile; ensure profile dir exists and load it
if [[ -n "$ACTION" ]]; then
  profile_paths
  if [[ ! -d "$PROFILE_DIR" || ! -f "$PROFILE_ENV_FILE" ]]; then
    err "Profile '$PROFILE_NAME' does not exist or is not configured. Run with --profile $PROFILE_NAME to create it."
    exit 12
  fi

  # If user also passed overrides via ARG_* before invoking start/stop, handle saving them
  if [[ -n "${ARG_SECRET:-}" || -n "${ARG_ENDPOINT:-}" || -n "${ARG_WG_FILE:-}" ]]; then
    # prompt for missing ones if partial
    if [[ -n "${ARG_SECRET:-}" ]]; then WSTUNNEL_SECRET="$ARG_SECRET"; fi
    if [[ -n "${ARG_ENDPOINT:-}" ]]; then ENDPOINT="$ARG_ENDPOINT"; fi
    if [[ -n "${ARG_WG_FILE:-}" ]]; then
      if [[ ! -f "$ARG_WG_FILE" ]]; then err "Provided wg file not found: $ARG_WG_FILE"; exit 13; fi
      cp "$ARG_WG_FILE" "$PROFILE_WG_FILE"
      chmod 600 "$PROFILE_WG_FILE"
      WGC_FILE="$PROFILE_WG_FILE"
    fi
    # Load existing then override
    load_profile
    # merge overrides
    : "${WSTUNNEL_SECRET:=${WSTUNNEL_SECRET:-}}"
    : "${ENDPOINT:=${ENDPOINT:-}}"
    : "${WGC_FILE:=${WGC_FILE:-}}"
    save_profile
    log "[+] Profile '$PROFILE_NAME' updated with provided overrides."
  fi

  # Run action
  case "$ACTION" in
    start) start_service ;;
    stop) stop_service ;;
    *) usage ;;
  esac

  exit 0
fi

# If we fall through, print usage
usage
