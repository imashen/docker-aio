#!/bin/sh
set -e

# Docker Engine for Linux installation script.
# This script is intended as a convenient way to configure docker's package
# repositories and to install Docker Engine. This script is not recommended
# for production environments. Before running this script, make yourself familiar
# with potential risks and limitations, and refer to the installation manual
# at https://docs.docker.com/engine/install/ for alternative installation methods.
#
# The script:
# - Requires `root` or `sudo` privileges to run.
# - Attempts to detect your Linux distribution and version and configure your
#   package management system for you.
# - Doesn't allow you to customize most installation parameters.
# - Installs dependencies and recommendations without asking for confirmation.
# - Installs the latest stable release (by default) of Docker CLI, Docker Engine,
#   Docker Buildx, Docker Compose, containerd, and runc. When using this script
#   to provision a machine, this may result in unexpected major version upgrades
#   of these packages. Always test upgrades in a test environment before
#   deploying to your production systems.
# - Isn't designed to upgrade an existing Docker installation. When using the
#   script to update an existing installation, dependencies may not be updated
#   to the expected version, resulting in outdated versions.
#
# Source code is available at https://github.com/docker/docker-install/

VERSION="${VERSION#v}"

# The channel to install from:
#   * stable
#   * test
DEFAULT_CHANNEL_VALUE="stable"
if [ -z "$CHANNEL" ]; then
    CHANNEL=$DEFAULT_CHANNEL_VALUE
fi

DEFAULT_DOWNLOAD_URL="https://mirrors.aliyun.com/docker-ce"
if [ -z "$DOWNLOAD_URL" ]; then
    DOWNLOAD_URL=$DEFAULT_DOWNLOAD_URL
fi

DEFAULT_REPO_FILE="docker-ce.repo"
if [ -z "$REPO_FILE" ]; then
    REPO_FILE="$DEFAULT_REPO_FILE"
fi

DRY_RUN=${DRY_RUN:-}
while [ $# -gt 0 ]; do
    case "$1" in
        --channel)
            CHANNEL="$2"
            shift
            ;;
        --dry-run)
            DRY_RUN=1
            ;;
        --version)
            VERSION="${2#v}"
            shift
            ;;
        --*)
            echo "Illegal option $1"
            ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done

case "$CHANNEL" in
    stable|test)
        ;;
    *)
        >&2 echo "unknown CHANNEL '$CHANNEL': use either stable or test."
        exit 1
        ;;
esac

command_exists() {
    command -v "$@" > /dev/null 2>&1
}

version_gte() {
    if [ -z "$VERSION" ]; then
        return 0
    fi
    eval version_compare "$VERSION" "$1"
}

version_compare() (
    set +x

    yy_a="$(echo "$1" | cut -d'.' -f1)"
    yy_b="$(echo "$2" | cut -d'.' -f1)"
    if [ "$yy_a" -lt "$yy_b" ]; then
        return 1
    fi
    if [ "$yy_a" -gt "$yy_b" ]; then
        return 0
    fi
    mm_a="$(echo "$1" | cut -d'.' -f2)"
    mm_b="$(echo "$2" | cut -d'.' -f2)"

    mm_a="${mm_a#0}"
    mm_b="${mm_b#0}"

    if [ "${mm_a:-0}" -lt "${mm_b:-0}" ]; then
        return 1
    fi

    return 0
)

is_dry_run() {
    if [ -z "$DRY_RUN" ];then
        return 1
    else
        return 0
    fi
}

is_wsl() {
    case "$(uname -r)" in
        *microsoft* ) true ;; # WSL 2
        *Microsoft* ) true ;; # WSL 1
        * ) false;;
    esac
}

is_darwin() {
    case "$(uname -s)" in
        *darwin* ) true ;;
        *Darwin* ) true ;;
        * ) false;;
    esac
}

deprecation_notice() {
    distro=$1
    distro_version=$2
    echo
    printf "\033[91;1mDEPRECATION WARNING\033[0m\n"
    printf "    This Linux distribution (\033[1m%s %s\033[0m) reached end-of-life and is no longer supported by this script.\n" "$distro" "$distro_version"
    echo   "    No updates or security fixes will be released for this distribution, and users are recommended"
    echo   "    to upgrade to a currently maintained version of $distro."
    echo
    printf   "Press \033[1mCtrl+C\033[0m now to abort this script, or wait for the installation to continue."
    echo
    sleep 10
}

get_distribution() {
    lsb_dist=""
    if [ -r /etc/os-release ]; then
        lsb_dist="$(. /etc/os-release && echo "$ID")"
    fi
    echo "$lsb_dist"
}

echo_docker_as_nonroot() {
    if is_dry_run; then
        return
    fi
    if command_exists docker && [ -e /var/run/docker.sock ]; then
        (
            set -x
            $sh_c 'docker version'
        ) || true
    fi

    echo
    echo "================================================================================"
    echo
    if version_gte "20.10"; then
        echo "To run Docker as a non-privileged user, consider setting up the"
        echo "Docker daemon in rootless mode for your user:"
        echo
        echo "    dockerd-rootless-setuptool.sh install"
        echo
        echo "Visit https://docs.docker.com/go/rootless/ to learn about rootless mode."
        echo
    fi
    echo
    echo "To run the Docker daemon as a fully privileged service, but granting non-root"
    echo "users access, refer to https://docs.docker.com/go/daemon-access/"
    echo
    echo "WARNING: Access to the remote API on a privileged Docker daemon is equivalent"
    echo "         to root access on the host. Refer to the 'Docker daemon attack surface'"
    echo "         documentation for details: https://docs.docker.com/go/attack-surface/"
    echo
    echo "================================================================================"
    echo
}

check_forked() {
    if command_exists lsb_release; then
        set +e
        lsb_release -a -u > /dev/null 2>&1
        lsb_release_exit_code=$?
        set -e

        if [ "$lsb_release_exit_code" = "0" ]; then
            cat <<-EOF
            You're using '$lsb_dist' version '$dist_version'.
            EOF

            lsb_dist=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'id' | cut -d ':' -f 2 | tr -d '[:space:]')
            dist_version=$(lsb_release -a -u 2>&1 | tr '[:upper:]' '[:lower:]' | grep -E 'codename' | cut -d ':' -f 2 | tr -d '[:space:]')

            cat <<-EOF
            Upstream release is '$lsb_dist' version '$dist_version'.
            EOF
        else
            if [ -r /etc/debian_version ] && [ "$lsb_dist" != "ubuntu" ] && [ "$lsb_dist" != "raspbian" ]; then
                if [ "$lsb_dist" = "osmc" ]; then
                    lsb_dist=raspbian
                else
                    lsb_dist=debian
                fi
                dist_version="$(sed 's/\/.*//' /etc/debian_version | sed 's/\..*//')"
                case "$dist_version" in
                    12)
                        dist_version="bookworm"
                    ;;
                    11)
                        dist_version="bullseye"
                    ;;
                    10)
                        dist_version="buster"
                    ;;
                    9)
                        dist_version="stretch"
                    ;;
                    8)
                        dist_version="jessie"
                    ;;
                esac
            fi
        fi
    fi
}

do_install() {
    echo "# Executing docker install script, commit: $SCRIPT_COMMIT_SHA"

    if command_exists docker; then
        cat >&2 <<-'EOF'
            Warning: the "docker" command appears to already exist on this system.

            If you already have Docker installed, this script can cause trouble, which is
            why we're displaying this warning and provide the opportunity to cancel the
            installation.

            If you installed the current Docker package using this script and are using it
            again to update Docker, you can safely ignore this message.

            You may press Ctrl+C now to abort this script.
        EOF
        ( set -x; sleep 20 )
    fi

    user="$(id -un 2>/dev/null || true)"

    sh_c='sh -c'
    if [ "$user" != 'root' ]; then
        if command_exists sudo; then
            sh_c='sudo -E sh -c'
        elif command_exists su; then
            sh_c='su -c'
        else
            cat >&2 <<-'EOF'
            Error: this installer needs the ability to run commands as root.
            We are unable to find either "sudo" or "su" available to make this happen.
            EOF
            exit 1
        fi
    fi

    case "$(uname -m)" in
        *64)
            ;;
        *)
            cat >&2 <<-'EOF'
            Error: you are trying to install Docker on a non 64-bit platform.
            This script currently only supports 64-bit platforms.
            EOF
            exit 1
            ;;
    esac

    if is_darwin; then
        if ! command_exists brew; then
            cat >&2 <<-EOF
            Homebrew (brew) was not found.
            Please install brew first and try again.
            Instructions can be found at https://brew.sh/
            EOF
            exit 1
        fi
        (
            set -x
            brew install docker
        )
        exit 0
    fi

    if is_wsl; then
        cat >&2 <<-EOF
        Error: WSL 2 installation is not supported with this script.
        Please use Docker Desktop for Windows.
        At https://www.docker.com/products/docker-desktop
        EOF
        exit 1
    fi

    lsb_dist=$( get_distribution )
    lsb_dist="$(echo "$lsb_dist" | tr '[:upper:]' '[:lower:]')"

    case "$lsb_dist" in
        ubuntu|debian|raspbian)
            if command_exists lsb_release; then
                dist_version="$(lsb_release --codename | cut -f2)"
            fi
            if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                dist_version="$(. /etc/os-release && echo "$VERSION_CODENAME")"
            fi
        ;;
        centos|rhel|ol|sles)
            if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
            fi
        ;;
        *)
            if command_exists lsb_release; then
                dist_version="$(lsb_release --codename | cut -f2)"
            fi
            if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
                dist_version="$(. /etc/os-release && echo "$VERSION_CODENAME")"
            fi
        ;;
    esac

    # Run setup for each distro accordingly
    case "$lsb_dist" in
        ubuntu|debian|raspbian)
            (
                set -x
                $sh_c 'apt-get update -qq >/dev/null'
                $sh_c 'DEBIAN_FRONTEND=noninteractive apt-get install -y -qq apt-transport-https ca-certificates curl >/dev/null'
                $sh_c 'mkdir -p /etc/apt/keyrings && curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
                $sh_c 'curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | apt-key add -qq -'
                $sh_c "echo 'deb [arch=$(dpkg --print-architecture)] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $dist_version $CHANNEL' > /etc/apt/sources.list.d/docker.list"
                $sh_c 'apt-get update -qq >/dev/null'
                $sh_c 'DEBIAN_FRONTEND=noninteractive apt-get install -y -qq docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin >/dev/null'
            )
            echo_docker_as_nonroot
            exit 0
            ;;
        centos|rhel|ol)
            (
                set -x
                $sh_c 'yum install -y -q yum-utils'
                $sh_c 'yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo'
                $sh_c 'yum makecache fast'
                $sh_c 'yum install -y -q docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin'
            )
            echo_docker_as_nonroot
            exit 0
            ;;
        sles)
            (
                set -x
                $sh_c 'zypper install -y -q libseccomp2 curl'
                $sh_c 'curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/sles/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg'
                $sh_c 'zypper addrepo -G -c -f https://mirrors.aliyun.com/docker-ce/linux/sles/$dist_version/docker-ce.repo'
                $sh_c 'zypper refresh'
                $sh_c 'zypper -n install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin'
            )
            echo_docker_as_nonroot
            exit 0
            ;;
        *)
            cat >&2 <<-'EOF'
            Error: this installer does not support the distribution you are using.
            EOF
            exit 1
            ;;
    esac
}

do_install
