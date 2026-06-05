#!/bin/bash
# Restart Policy Studio — double-click this from Finder/Desktop.
#
# Brings Policy Studio back after it has been closed (e.g. File -> Exit) or
# after the container engine / Mac restarted. It restarts the existing
# Policy Studio container (which relaunches both KasmVNC and Policy Studio)
# and reopens the browser. Works with Docker Desktop, Rancher Desktop
# (dockerd or containerd), Podman, Colima, OrbStack.
#
# Author: generated for the apim-docker-dev-tools project.

imagePrefix="lacg/axway_policystudio"

# Keep the Terminal window open at the end so the user can read any message.
pause() { echo; read -r -p "Press Return to close this window."; }

# Find a container runtime whose daemon actually responds.
findDocker() {
  local candidates=(
    docker nerdctl podman
    "$HOME/.rd/bin/docker" "$HOME/.rd/bin/nerdctl"
    "/Applications/Rancher Desktop.app/Contents/Resources/resources/darwin/bin/docker"
    "/Applications/Docker.app/Contents/Resources/bin/docker"
    /opt/homebrew/bin/docker /opt/homebrew/bin/nerdctl /opt/homebrew/bin/podman
    /usr/local/bin/docker /usr/local/bin/nerdctl /usr/local/bin/podman
  )
  local c bin
  for c in "${candidates[@]}"; do
    if [[ "$c" == /* ]]; then
      [[ -x "$c" ]] && bin="$c" || bin=""
    else
      bin="$(command -v "$c" 2>/dev/null)"
    fi
    [[ -z "$bin" ]] && continue
    if "$bin" info >/dev/null 2>&1; then
      DOCKER="$bin"
      return 0
    fi
  done
  return 1
}

echo "Restarting Policy Studio..."
echo

if ! findDocker; then
  echo "Could not reach a container engine."
  echo "Please start Rancher Desktop (or Docker Desktop) and try again."
  pause
  exit 1
fi

echo "Using container engine: $DOCKER"

# Most recent Policy Studio container (running or stopped).
cid="$("$DOCKER" ps -a --format '{{.ID}} {{.Image}}' 2>/dev/null \
        | awk -v p="$imagePrefix" 'index($2, p) == 1 {print $1; exit}')"

if [[ -z "$cid" ]]; then
  echo "No Policy Studio container found on this machine yet."
  echo "Start it first with the 'policystudio' script, for example:"
  echo "    ./policystudio 7.7.0.20260228"
  pause
  exit 1
fi

echo "Restarting container $cid ..."
if ! "$DOCKER" restart "$cid" >/dev/null; then
  echo "Failed to restart the container. Try starting it again with the policystudio script."
  pause
  exit 1
fi

# Figure out which host port maps to KasmVNC's 6901 so we open the right URL.
port="$("$DOCKER" port "$cid" 6901 2>/dev/null | head -1 | sed 's/.*://')"
[[ -z "$port" ]] && port="6901"

echo "Policy Studio is starting. Opening http://localhost:${port} ..."
sleep 5
open "http://localhost:${port}"

echo "Done. (credentials: axway / axway1)"
exit 0
