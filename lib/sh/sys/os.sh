# shellcheck shell=ksh

# Copyright 2022 Rawiri Blundell
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
################################################################################
# Provenance: https://github.com/rawiriblundell/sh_libpath
# SPDX-License-Identifier: Apache-2.0

[ -n "${_SHELLAC_LOADED_sys_os+x}" ] && return 0
_SHELLAC_LOADED_sys_os=1

# Detect the OS and populate OS information variables.
# Sets OSSTR (short OS tag), OSVER (PRETTY_NAME-style version string),
# OS, KERNEL, RELEASE, MACHTYPE, HOSTTYPE, OSBOOTTIME.
# Sets LC_ALL=C and LANG=C for consistent parsing (restored on exit).

_os_LC_ALL="${LC_ALL:-}"
_os_LANG="${LANG:-}"
LC_ALL=C
LANG=C
export LANG LC_ALL

OS=$(uname -s)
OSVER=$(uname -sr)  # default; overridden per-OS below where we can do better

case "${OS}" in
    ("AIX")
        OSSTR="${OS} $(oslevel) ($(oslevel -r))"
        [ -z "${OSSTR}" ] && OSSTR=aix
        OSVER="AIX $(oslevel)"
    ;;
    ("Darwin")
        OSSTR=mac
        OSVER="$(sw_vers -productName 2>/dev/null) $(sw_vers -productVersion 2>/dev/null)"
        : "${XDG_DATA_HOME:-$HOME/Library/Application Support}"
        : "${XDG_DATA_DIRS:-/Library/Application Support}"
        : "${XDG_CONFIG_HOME:-$HOME/Library/Application Support}"
        : "${XDG_CONFIG_DIRS:-$HOME/Library/Preferences:/Library/Application Support:/Library/Preferences}"
        : "${XDG_STATE_HOME:-$HOME/Library/Application Support}"
        : "${XDG_CACHE_HOME:-$HOME/Library/Caches}"
        : "${XDG_RUNTIME_DIR:-$HOME/Library/Application Support}"

        : "${XDG_DESKTOP_DIR:-$HOME/Desktop}"
        : "${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
        : "${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
        : "${XDG_MUSIC_DIR:-$HOME/Music}"
        : "${XDG_PICTURES_DIR:-$HOME/Pictures}"
        : "${XDG_VIDEOS_DIR:-$HOME/Videos}"
        : "${XDG_TEMPLATES_DIR:-$HOME/Templates}"
        : "${XDG_PUBLICSHARE_DIR:-$HOME/Public}"
    ;;
    ("FreeBSD")
        OSSTR=freebsd
    ;;
    ("HP-UX")
        OSSTR=hpux
    ;;
    ("Linux"|"linux-gnu"|"GNU"*)
        OSSTR=linux
        : "${XDG_DATA_HOME:-$HOME/.local/share}"
        : "${XDG_DATA_DIRS:-/usr/local/share:/usr/share}"
        : "${XDG_CONFIG_HOME:-$HOME/.config}"
        : "${XDG_CONFIG_DIRS:-/etc/xdg}"
        : "${XDG_STATE_HOME:-$HOME/.local/state}"
        : "${XDG_CACHE_HOME:-$HOME/.cache}"
        : "${XDG_RUNTIME_DIR:-/run/user/$UID}"

        : "${XDG_DESKTOP_DIR:-$HOME/Desktop}"
        : "${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
        : "${XDG_DOCUMENTS_DIR:-$HOME/Documents}"
        : "${XDG_MUSIC_DIR:-$HOME/Music}"
        : "${XDG_PICTURES_DIR:-$HOME/Pictures}"
        : "${XDG_VIDEOS_DIR:-$HOME/Videos}"
        : "${XDG_TEMPLATES_DIR:-$HOME/Templates}"
        : "${XDG_PUBLICSHARE_DIR:-$HOME/Public}"

        # OSVER = PRETTY_NAME from os-release (systemd standard, ~2012+),
        # then lsb_release, then legacy files, then uname -sr fallback.
        _os_release=
        [ -f /etc/os-release ]     && _os_release=/etc/os-release
        [ -f /usr/lib/os-release ] && : "${_os_release:=/usr/lib/os-release}"
        if [ -n "${_os_release}" ]; then
            OSVER=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            unset -v _os_release
        elif command -v lsb_release >/dev/null 2>&1; then
            OSVER=$(lsb_release -sd 2>/dev/null)
        elif [ -f /etc/redhat-release ]; then
            OSVER=$(cat /etc/redhat-release)
        elif [ -f /etc/debian_version ]; then
            OSVER="Debian $(cat /etc/debian_version)"
        fi
        # uname -sr default stands if all of the above yield nothing
    ;;
    ("NetBSD")
        OSSTR=netbsd
    ;;
    ("OpenBSD")
        OSSTR=openbsd
    ;;
    ("SunOS"|"solaris")
        OSSTR=solaris
    ;;
    (*"BSD"|*"bsd"|"DragonFly"|"Bitrig")
        OSSTR=bsd
    ;;
    ("CYGWIN"* | "MSYS"* | "MINGW"*)
        OSSTR=windows
    ;;
    ("Haiku")
        OSSTR=haiku
    ;;
    ("MINIX")
        OSSTR=minix
    ;;
    ("IRIX64")
        OSSTR=irix
    ;;
    (*)
        OSSTR=$(uname -s)
    ;;
esac

who -b > /dev/null 2>&1 && OSBOOTTIME="$(who -b)"

[ -z "${KERNEL}" ]  && KERNEL=$(uname -r)
[ -z "${RELEASE}" ] && RELEASE="${KERNEL}"

# Machine Type - identifies the system hardware
# This typically displays CPU architecture e.g. i686, ia64, sparc etc
if [ -z "${MACHTYPE}" ]; then
    # -p works on Linux, Solaris and AIX
    if uname -p >/dev/null 2>&1; then
        MACHTYPE=$(uname -p)
        # It works on Linux etc until it doesn't
        [ "${MACHTYPE}" = 'unknown' ] && MACHTYPE=$(uname -m)
    # -p is not available on HP-UX, until I know better, we use -m
    elif uname -m >/dev/null 2>&1; then
        MACHTYPE=$(uname -m)
    fi
fi

[ -z "${HOSTTYPE}" ] && HOSTTYPE="${MACHTYPE}"

readonly OSSTR OSVER OSBOOTTIME
export OSSTR OSVER OSBOOTTIME
export HOSTTYPE KERNEL MACHTYPE OS RELEASE

LC_ALL="${_os_LC_ALL}"
LANG="${_os_LANG}"
export LANG LC_ALL
unset -v _os_LC_ALL _os_LANG
