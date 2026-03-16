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
# Sets OSSTR, OSVER, OS, KERNEL, RELEASE, MACHTYPE, HOSTTYPE,
# OSBOOTTIME, and where applicable: DistroBasedOn, DistroPkgType,
# DistroFullName, DistroCodename, DistroRevision.
# Sets LC_ALL=C and LANG=C for consistent parsing (restored on exit).

_os_LC_ALL="${LC_ALL:-}"
_os_LANG="${LANG:-}"
LC_ALL=C
LANG=C
export LANG LC_ALL

# This is the OS Name, nice and simple.
OS=$(uname -s)

case "${OS}" in
    ("AIX")
        OSSTR="${OS} $(oslevel) ($(oslevel -r))"
        [ -z "${OSSTR}" ] && OSSTR=aix
        #OSVER=
    ;;
    ("Darwin")
        OSSTR=mac
        OSVER=$(sw_vers -productVersion 2>/dev/null) ||
            OSVER=$(sw_vers | sed 1d | paste -sd ' ' - | awk -F" " '{print $2" ("$4")"}')
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
        #OSVER=
    ;;
    ("HPUX")
        OSSTR=hpux
        #OSVER=
    ;;
    ("Linux"|"linux-gnu"|"GNU"*)
        OSSTR=linux
        #OSVER=
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
        # Distro detection: os-release (systemd standard, ~2012+) preferred,
        # then lsb_release, then legacy per-distro files as last resort.
        _os_release=
        [ -f /etc/os-release ]     && _os_release=/etc/os-release
        [ -f /usr/lib/os-release ] && : "${_os_release:=/usr/lib/os-release}"

        if [ -n "${_os_release}" ]; then
            DistroFullName=$(awk -F= '/^PRETTY_NAME=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            DistroRevision=$(awk -F= '/^VERSION_ID=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            DistroCodename=$(awk -F= '/^VERSION_CODENAME=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            # Some distros embed codename in VERSION as "(Codename)"
            if [ -z "${DistroCodename}" ]; then
                DistroCodename=$(awk -F= '/^VERSION=/{gsub(/"/, "", $2); print $2}' "${_os_release}" \
                    | grep -o '([^)]*)' | tr -d '()')
            fi
            _distro_id=$(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            _distro_id_like=$(awk -F= '/^ID_LIKE=/{gsub(/"/, "", $2); print $2}' "${_os_release}")
            case "${_distro_id_like:-${_distro_id}}" in
                (*rhel*|*centos*|*fedora*)  DistroBasedOn=RedHat;    DistroPkgType=rpm      ;;
                (*debian*|*ubuntu*)         DistroBasedOn=Debian;    DistroPkgType=deb      ;;
                (*suse*)                    DistroBasedOn=SuSe;      DistroPkgType=rpm      ;;
                (*arch*)                    DistroBasedOn=Arch;      DistroPkgType=pacman   ;;
                (*gentoo*)                  DistroBasedOn=Gentoo;    DistroPkgType=ebuild   ;;
                (*slackware*)               DistroBasedOn=Slackware; DistroPkgType=pkgtools ;;
                (*alpine*)                  DistroBasedOn=Alpine;    DistroPkgType=apk      ;;
                (*)                         DistroBasedOn="${_distro_id}"                   ;;
            esac
            unset -v _os_release _distro_id _distro_id_like
        elif command -v lsb_release >/dev/null 2>&1; then
            DistroFullName=$(lsb_release -sd 2>/dev/null)
            DistroRevision=$(lsb_release -sr 2>/dev/null)
            DistroCodename=$(lsb_release -sc 2>/dev/null)
            _distro_id=$(lsb_release -si 2>/dev/null)
            case "${_distro_id}" in
                (RedHat*|CentOS*|Fedora*|AlmaLinux*|Rocky*) DistroBasedOn=RedHat; DistroPkgType=rpm ;;
                (Debian*|Ubuntu*)                            DistroBasedOn=Debian; DistroPkgType=deb ;;
                (SUSE*|openSUSE*)                            DistroBasedOn=SuSe;   DistroPkgType=rpm ;;
                (*)                                          DistroBasedOn="${_distro_id}"            ;;
            esac
            unset -v _distro_id
        else
            # Legacy per-distro files — only reached on very old systems
            if [ -f /etc/redhat-release ]; then
                DistroBasedOn=RedHat
                DistroPkgType=rpm
                DistroFullName=$(sed s/\ release.*// /etc/redhat-release)
                DistroCodename=$(sed s/.*\(// /etc/redhat-release | sed s/\)//)
                DistroRevision=$(sed s/.*release\ // /etc/redhat-release | sed s/\ .*//)
            elif [ -f /etc/SuSE-release ]; then
                DistroBasedOn=SuSe
                DistroPkgType=rpm
                DistroCodename=$(tr "\n" ' ' < /etc/SuSE-release | sed s/VERSION.*//)
                DistroRevision=$(tr "\n" ' ' < /etc/SuSE-release | sed s/.*=\ //)
            elif [ -f /etc/mandrake-release ]; then
                DistroBasedOn=Mandrake
                DistroPkgType=rpm
                DistroCodename=$(sed s/.*\(// /etc/mandrake-release | sed s/\)//)
                DistroRevision=$(sed s/.*release\ // /etc/mandrake-release | sed s/\ .*//)
            elif [ -f /etc/debian_version ]; then
                DistroBasedOn=Debian
                DistroPkgType=deb
                DistroFullName=$(grep '^DISTRIB_DESCRIPTION' /etc/lsb-release | awk -F= '{ print $2 }')
                DistroCodename=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F= '{ print $2 }')
                DistroRevision=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F= '{ print $2 }')
            elif [ -f /etc/slackware-version ]; then
                DistroBasedOn=Slackware
                DistroPkgType=pkgtools
            fi
        fi
    ;;
    ("NetBSD")
        OSSTR=netbsd
        #OSVER=
    ;;
    ("OpenBSD")
        OSSTR=openbsd
        #OSVER=
    ;;
    ("SunOS"|"solaris")
        OSSTR=solaris
        #OSVER=
    ;;
    (*"BSD"|*"bsd"|"DragonFly"|"Bitrig")
        OSSTR=bsd
        #OSVER=
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
        #OSVER=
    ;;
esac

# Mostly portable, doesn't always work, needs a little more attention
who -b > /dev/null 2>&1 && OSBOOTTIME="$(who -b)"

# This is either the kernel version (Linux) or the release version (everything else)
[ -z "${KERNEL}" ] && KERNEL=$(uname -r)

# If it's unset, set RELEASE to be the same as KERNEL
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

# This is the same as MACHTYPE
[ -z "${HOSTTYPE}" ] && HOSTTYPE="${MACHTYPE}"

readonly OSSTR OSVER OSBOOTTIME
export OSSTR OSVER OSBOOTTIME
export HOSTTYPE KERNEL MACHTYPE OS RELEASE

LC_ALL="${_os_LC_ALL}"
LANG="${_os_LANG}"
export LANG LC_ALL
unset -v _os_LC_ALL _os_LANG
