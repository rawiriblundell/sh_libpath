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

# @description Detect the OS and populate OS information variables.
#   Sets OSSTR, OSVER, OSTYPE, OS, KERNEL, RELEASE, MACHTYPE, HOSTTYPE, MACH,
#   OSBOOTTIME, and where applicable: DistroBasedOn, DistroPkgType,
#   DistroFullName, DistroCodename, DistroRevision.
#   Sets LC_ALL=C and LANG=C for consistent parsing.
#
# @exitcode 0 Always
get_os_info() {
    # Idempotent: skip if already run
    [ -n "${OSSTR+x}" ] && return 0

    LC_ALL=C
    LANG=C
    export LANG LC_ALL

    # This is the OS Name, nice and simple.
    OS=$(uname -s)

    case "${OS}" in
        ("AIX")
            OSSTR="${OS} $(oslevel) ($(oslevel -r))"
            [ -z "${OSTYPE}" ] && OSTYPE=aix
            [ -z "${OSSTR}" ] && OSSTR=aix
            #OSVER=
        ;;
        ("Darwin")
            OSSTR=mac
            OSVER="$(sw_vers | sed 1d | paste -sd ' ' - | awk -F" " '{print $2" ("$4")"}')"
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

            [ -z "${OSTYPE}" ] && OSTYPE=mac
            # For macOS, sw_vers output:
            # ProductName:    Mac OS X
            # ProductVersion: 10.2.3
            # BuildVersion:   6G30
            OIFS="$IFS"; IFS=$'\n'
            set -- $(sw_vers)
            DIST=$(printf -- '%s' "$1" | tr "\n" ' ' | sed 's/ProductName:[ ]*//')
            VERSION=$(printf -- '%s' "$2" | tr "\n" ' ' | sed 's/ProductVersion:[ ]*//')
            BUILD=$(printf -- '%s' "$3" | tr "\n" ' ' | sed 's/BuildVersion:[ ]*//')
            IFS="$OIFS"
        ;;
        ("FreeBSD")
            OSSTR=freebsd
            #OSVER=
        ;;
        ("HPUX")
            [ -z "${OSTYPE}" ] && OSTYPE=hpux
            OSSTR=hpux
            #OSVER=
        ;;
        ("Linux"|"linux-gnu"|"GNU"*)
            OSSTR=linux
            [ -z "${OSTYPE}" ] && OSTYPE=linux-gnu
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
            # Operating System
            # For versions that have 'PRETTY_NAME' in e.g. /etc/os-release
            if grep -q "^PRETTY_NAME.*[0-9]" /etc/os-release 2>/dev/null; then
              operSys=$(awk -F "=" '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
            # Sometimes PRETTY_NAME does not include version info, so we build it manually, and
            # for older versions with /etc/os-release but not PRETTY_NAME, we try to construct it
            elif grep -qhE "^NAME=|^VERSION=" /etc/os-release 2>/dev/null; then
              operSys=$(awk -F "=" '/^NAME=|^VERSION=/{print $2}' /etc/os-release | tr -d '"' | paste -sd ' ' -)
            # For everything else, we just try to get whatever we can
            else
              operSys=$(grep -Ehi -m 1 'red hat|fedora|cent|enterprise|debian|ubuntu|slack|suse|gentoo' /etc/*release* /etc/*version* 2>/dev/null \
                | grep "[0-9]" | head -n 1 | sed -e 's/^.*NAME=//' -e 's/DISTRIB_ID=//' -e 's/=//')
            fi
            # Be aware: this attempt to give a portable fallback is still problematic
            # e.g. in a container, the host /proc/version will be given
            if [ -z "${operSys}" ]; then
              operSys=$(</proc/version)
            fi

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
                DistroFullName=$(grep '^DISTRIB_DESCRIPTION' /etc/lsb-release | awk -F=  '{ print $2 }')
                DistroCodename=$(grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }')
                DistroRevision=$(grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }')
            elif [ -f /etc/slackware-version ]; then
                DistroBasedOn=Slackware
                DistroPkgType=pkgtools
                DistroFullName=
                DistroCodename=
                DistroRevision=
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
            [ -z "${OSTYPE}" ] && OSTYPE=solaris
            ARCH=$(uname -p)
            OSSTR=$(uname -a)
            export ARCH OSSTR
            OSSTR=solaris
            #OSVER=
        ;;
        (*"BSD"|*"bsd"|"DragonFly"|"Bitrig")
            [ -z "${OSTYPE}" ] && OSTYPE=bsd
            OSSTR=bsd
            #OSVER=
        ;;
        ("CYGWIN"* | "MSYS"* | "MINGW"*)
            [ -z "${OSTYPE}" ] && OSTYPE=Windows
        ;;
        ("Haiku")
            [ -z "${OSTYPE}" ] && OSTYPE=Haiku
        ;;
        ("MINIX")
            [ -z "${OSTYPE}" ] && OSTYPE=MINIX
        ;;
        ("IRIX64")
            [ -z "${OSTYPE}" ] && OSTYPE=IRIX
        ;;
        (*)
            OSSTR=$(uname -s)
            #OSVER=
        ;;
    esac

    # Mostly portable, doesn't always work, needs a little more attention
    if who -b > /dev/null 2>&1; then
        OSBOOTTIME="$(who -b)"
    fi

    readonly OSSTR OSVER OSBOOTTIME
    export OSSTR OSVER OSBOOTTIME

    # This is either the kernel version (Linux) or the release version (everything else)
    if [ -z "${KERNEL}" ]; then KERNEL=$(uname -r); fi

    # If it's unset, set RELEASE to be the same as KERNEL
    if [ -z "${RELEASE}" ]; then RELEASE="${KERNEL}"; fi

    # Machine Type - identifies the system hardware
    # This typically displays CPU architecture e.g. i686, ia64, sparc etc
    if [ -z "${MACHTYPE}" ]; then
      # -p works on Linux, Solaris and AIX
      if uname -p >/dev/null 2>&1; then
        MACHTYPE=$(uname -p)
      # -p is not available on HP-UX, until I know better, we use -m
      elif uname -m >/dev/null 2>&1; then
        MACHTYPE=$(uname -m)
      fi
    fi

    # This is the same as MACHTYPE
    if [ -z "${HOSTTYPE}" ]; then HOSTTYPE="${MACHTYPE}"; fi

    MACH=$(uname -m)

    export HOSTTYPE KERNEL MACH MACHTYPE OS

    OSSTR="${OS} ${DistroBasedOn} ${RELEASE} (${DistroCodename} ${KERNEL} ${MACH})"
}
