# APIM Docker Dev Tools

This is a repository with the scripts, docker-compose and dockerfiles for the Policy Studio, Configuration Studio and the Package Deploy Tools for Axway API Gateway in Linux x86-64 version.

As there are versions for Win32 and Linux, but no macOS versions, we need containers that brings a way to close these gaps and allows to run on a Mac these tools in a more easier way.

---

To run one of these tools, copy the scripts `policystudio`, `configurationstudio`, `esexplorer` and `tools` from `/Scripts` to any location on your host Mac and make them executable (`chmod +x`).

### Prerequisites

* **Container runtime** — Docker Desktop, Rancher Desktop, Podman, Colima, or OrbStack. The scripts auto-detect whichever is installed.
* **XQuartz** — required only for legacy versions (7.5.x / 7.6.x / 7.7.20.xx). Not needed for 7.7.0.20260228 and newer.
* **Browser** — Chrome or Firefox recommended. Safari does not support KasmVNC's WebSocket connections.

If an image is not on your host machine it will be pulled automatically, which may take a few minutes.

#### Apple Silicon (M1/M2/M3/M4) Macs

The container images are x86-64 and run under emulation on Apple Silicon. **Rancher Desktop with VZ + Rosetta** is the recommended setup for best performance and compatibility.

1. Install [Rancher Desktop](https://rancherdesktop.io/)
2. Open Rancher Desktop preferences and set:
   - **Virtual Machine Type**: VZ (Apple Virtualization Framework)
   - **Rosetta**: Enabled
   - Kubernetes can be disabled if not needed
3. The scripts will auto-detect Rancher Desktop — no additional configuration required.

> **Note:** Podman with QEMU emulation also works but may experience crashes in KasmVNC's WEBP encoder. If you use Podman, the image build auto-selects an aarch64 KasmVNC RPM to avoid this, but Rancher Desktop + Rosetta provides the most stable experience.

#### Container runtime socket (`DOCKER_HOST`)

The scripts auto-detect the container runtime binary. If you use a `docker` CLI that needs a custom socket (e.g. Podman), add this to your `~/.zshrc`:

```shell
# Auto-detect container runtime socket
if [ -S "$HOME/.rd/docker.sock" ]; then
  export DOCKER_HOST="unix://$HOME/.rd/docker.sock"
elif [ -S "/var/run/docker.sock" ]; then
  export DOCKER_HOST="unix:///var/run/docker.sock"
else
  export DOCKER_HOST="unix://$(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}' 2>/dev/null)"
fi
```

This checks for Rancher Desktop, Docker Desktop, and Podman in that order.

---

## Versions 7.7.0.20260228 and later — KasmVNC (browser-based)

These versions use KasmVNC — no XQuartz needed. The browser opens automatically at `http://localhost:6901` (credentials: `axway` / `axway1`). Your `~/apiprojects` folder is mounted directly into the container so you can open and save policy project files from Finder or VS Code.

### Usage

#### Policy Studio

```shell
./policystudio 7.7.0.20260228
```

By default (KasmVNC versions) the container starts with `--restart unless-stopped`, so Policy Studio comes back automatically after the Mac sleeps or the container engine restarts. Pass `--no-restart` to opt out.

To run multiple instances simultaneously, use the `-p` flag to assign a different port to each:

```shell
./policystudio -p 6902 7.7.0.20260228
```

**Mapping extra folders into the container.** Use `-m`/`--mount` (repeatable) to map additional host folders — for example to open Git checkouts of gateway code directly inside Policy Studio. The syntax is the same `host:container[:ro]` form as `docker -v`:

```shell
./policystudio 7.7.0.20260228 \
    -m ~/git/axway-gtwy-code:/home/axway/apiprojects/axway-gtwy-code \
    -m ~/git/axway-dmz-gtwy-code:/home/axway/apiprojects/axway-dmz-gtwy-code
```

> Mount the repos *into* `/home/axway/apiprojects/<name>` rather than symlinking from the host `apiprojects` folder — the container engine does not follow host symlinks across the VM boundary.

Full option list:

```shell
./policystudio <version> [-p port] [-m host:container]... [--no-restart] [-v]
```

### Policy Studio file access

All data for a version lives under `~/axway/<version>/` on your Mac:

| Host path | Container path | Purpose |
|---|---|---|
| `~/axway/7.7.0.20260228/apiprojects` | `/home/axway/apiprojects` | Policy project files |
| `~/axway/7.7.0.20260228/policystudio/configuration` | `/opt/axway/policystudio/configuration/login` | Saved connections & login tokens |
| `~/axway/7.7.0.20260228/policystudio/licenses` | `/opt/axway/policystudio/conf/licenses` | Axway license file (optional) |

All directories are created automatically on first run. Place your `licensekey.lic` in the licenses folder before starting if you need one.

Any folders passed with `-m`/`--mount` are mounted on top of this layout — typically under `/home/axway/apiprojects/<name>` so they show up alongside the default projects inside Policy Studio.

---

## Versions up to 7.7.20.xx — XQuartz (X11 forwarding)

These containers use X11 forwarding to display the GUI on macOS via XQuartz.

### Usage

#### Policy Studio

```shell
./policystudio 7.5.3
./policystudio 7.5.3.13
./policystudio 7.7.20.03
```

#### Configuration Studio

```shell
./configurationstudio 7.5.3
./configurationstudio 7.5.3.13
./configurationstudio 7.7.20.03
```

#### ES Explorer

```shell
./esexplorer 7.5.3
./esexplorer 7.5.3.13
./esexplorer 7.7.20.03
```

---

## Built With

* Rocky Linux 9 (7.7.0.20260228 and newer)
* CentOS 7/8 (legacy versions)

## Author

* [Luiz Garcia](https://github.com/u/lacg)
