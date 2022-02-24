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

case $(uname -s) in
    ("AIX")
        OSSTR=aix
        #OSVER=
        # Known uptime formats
        # 12:55pm  up 105 days, 21 hrs,  2 users, load average: 0.26, 0.26, 0.26 --> 9147600
        # 1:41pm   up 105 days, 21:46,   2 users, load average: 0.28, 0.28, 0.27 --> 9150360
        # 05:26PM  up           1:16,    1 user,  load average: 0.33, 0.21, 0.20 --> 4560
        # 06:13PM  up           2:03,    1 user,  load average: 1.16, 1.07, 0.91 --> 7380
        # 08:43AM  up 29 mins,           1 user,  load average: 0.09, 0.18, 0.21 --> 1740
        # 08:47AM  up 66 days,  18:34,   1 user,  load average: 2.25, 2.43, 2.61 --> 5769240
        # 08:45AM  up 76 days,  34 mins, 1 user,  load average: 2.25, 2.43, 2.61 --> 5769240
        get_uptime() {
            _uptime=$(uptime | sed -e 's/^.*up//g' -e 's/[0-9]* user.*//g')
            case ${_uptime} in
                ( *day* ) _up_days=$(write "${_uptime}" | sed -e 's/days\{0,1\},.*//g') ;;
                ( * ) _up_days="0" ;;
            esac

            case ${_uptime} in
                ( *:* )
                    _up_hours=$(write "${_uptime}" | sed -e 's/.*days\{0,1\},//g' -e 's/:.*//g')
                    _up_mins=$(write "${_uptime}" | sed -e 's/.*days\{0,1\},//g' -e 's/.*://g' -e 's/,.*//g')
                ;;
                ( *hr* )
                    _up_hours=$(write "${_uptime}" | sed -e 's/hrs\{0,1\},.*//g' -e 's/.*,//g')
                    _up_mins=0
                ;;
                ( *min* )
                    _up_hours=0
                    _up_mins=$(write "${_uptime}" | sed -e 's/mins\{0,1\},.*//g' -e 's/.*hrs\{0,1\},//g' -e 's/.*days\{0,1\},//g')
                ;;
                ( * )
                    _up_hours="0"
                    _up_mins=0
                ;;
            esac

            write $(((_up_days*86400)+(_up_hours*3600)+(_up_mins*60)))
            unset -v _uptime _up_hours _up_mins
        }
    ;;
    ("Darwin")
        OSSTR=mac
        OSVER="$(sw_vers | sed 1d | paste -sd ' ' - | awk -F" " '{print $2" ("$4")"}')"
        get_uptime() {
            write "$(get_epoch) - $(sysctl -n kern.boottime | cut -d' ' -f 4,7 | tr ',' '.' | tr -d ' ')" | bc
        }
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
        get_uptime() {
            # Calculate the uptime in seconds since epoch compatible to /proc/uptime in linux
            _up_seconds=$(( $(get_epoch) - $(sysctl -n kern.boottime  | cut -f1 -d\, | awk '{print $4}') ))
            # pgrep is not appropriate (or even available?) here
            # shellcheck disable=SC2009
            _idle_seconds=$(ps axw | grep "[i]dle" | awk '/idle/{print $4}' | cut -f1 -d':' )
            write "${_up_seconds} ${_idle_seconds}"
            unset -v _up_seconds _idle_seconds            
        }
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
        get_uptime() {
            if var_is_unset "${MK_IS_DOCKERIZED}"; then
                cat /proc/uptime
            else
                write "$(($(get_epoch) - $(stat -c %Z /dev/pts)))"
            fi    
        }
        # Operating System
        # For versions that have 'PRETTY_NAME' in e.g. /etc/os-release
        if nullgrep "^PRETTY_NAME.*[0-9]" /etc/os-release; then
        operSys=$(awk -F "=" '/^PRETTY_NAME=/{print $2}' /etc/os-release | tr -d '"')
        # Sometimes PRETTY_NAME does not include version info, so we build it manually, and
        # for older versions with /etc/os-release but not PRETTY_NAME, we try to construct it
        elif nullgrep -hE "^NAME=|^VERSION=" /etc/os-release; then 
        operSys=$(awk -F "=" '/^NAME=|^VERSION=/{print $2}' /etc/os-release | tr -d '"' | paste -sd ' ' -)
        # For everything else, we just try to get whatever we can
        else
        operSys=$(grep -Ehi -m 1 'red hat|fedora|cent|enterprise|debian|ubuntu|slack|suse|gentoo' /etc/*release* /etc/*version* 2>/dev/null \
            | grep "[0-9]" | head -n 1 | sed -e 's/^.*NAME=//' -e 's/DISTRIB_ID=//' -e 's/=//')
        fi
        # Be aware: this attempt to give a portable fallback is still problematic
        # e.g. in a container, the host /proc/version will be given
        if [[ -z ${operSys} ]]; then
        operSys=$(</proc/version)
        fi
    ;;
    ("NetBSD")
        OSSTR=netbsd
        #OSVER=
        get_uptime() {
            write "$(get_epoch) - $(sysctl -n kern.boottime | cut -d' ' -f 4,7 | tr ',' '.' | tr -d ' ')" | bc
        }
    ;;
    ("OpenBSD")
        OSSTR=openbsd
        #OSVER=
        get_uptime() {
            write "$(get_epoch) - $(sysctl -n kern.boottime | cut -d' ' -f 4,7 | tr ',' '.' | tr -d ' ')" | bc
        }
    ;;
    ("SunOS"|"solaris")
        OSSTR=solaris
        #OSVER=
        get_uptime() {
            # Solaris doesn't always give a consistent output on uptime, thus include side information
            # Tested in VM for solaris 10/11
            _ctime=$(nawk 'BEGIN{print srand()}')
            _btime=$(kstat '-p' 'unix:::boot_time' 2>&1|grep 'boot_time'|awk '{print $2}')
            write $((_ctime - _btime));
            write '[uptime_solaris_start]'
            uname -a
            zonename
            uptime
            kstat -p unix:0:system_misc:snaptime
            write '[uptime_solaris_end]'
            unset -v _ctime _btime 
        }
    ;;
    (*"BSD"|*"bsd"|"DragonFly"|"Bitrig")
        OSSTR=bsd
        #OSVER=
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

---

LC_ALL=C
LANG=C
export LANG LC_ALL

# Ensure that PATH covers everything we can possibly think of
# We order it with xpg6/4 first to help Solaris to not be such a precious tulip
PATH=/usr/xpg6/bin:/usr/xpg4/bin:/usr/kerberos/bin:/usr/kerberos/sbin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:/opt/csw/bin:/opt/csw/sbin:/opt/sfw/bin:/opt/sfw/sbin:/usr/sfw/bin:/usr/sfw/sbin:$PATH

# We sanitise the PATH variable to only include
# directories that exist on the host.
newPath=
# Split the PATH out into individual loop elements
for dir in `echo "${PATH}" | tr ":" "\n"`; do
  # If the directory exists, add it to the newPath variable
  if [ -d "${dir}" ]; then
    newPath="${newPath}:${dir}"
  fi
done

# If a leading colon sneaks in, get rid of it
if echo "${newPath}" | grep "^:" >/dev/null 2>&1; then
  newPath=`echo "${newPath}" | cut -d ":" -f2-`
fi

# Now assign our freshly built newPath variable and export it
PATH="${newPath}"
export PATH

# This is either the kernel version (Linux) or the release version (everything else)
if [ -z "${KERNEL}" ]; then KERNEL=`uname -r`; fi

# If it's unset, set RELEASE to be the same as KERNEL
if [ -z "${RELEASE}" ]; then RELEASE="${KERNEL}"; fi

# Machine Type - identifies the system hardware
# This typically displays CPU architecture e.g. i686, ia64, sparc etc
if [ -z "${MACHTYPE}" ]; then
  # -p works on Linux, Solaris and AIX
  if uname -p >/dev/null 2>&1; then
    MACHTYPE=`uname -p`
  # -p is not available on HP-UX, until I know better, we use -m
  elif uname -m >dev/null 2>&1; then
    MACHTYPE=`uname -m`
  fi
fi

# This is the same as MACHTYPE
if [ -z "${HOSTTYPE}" ]; then HOSTTYPE="${MACHTYPE}"; fi

MACH=`uname -m`

# This is the OS Name, nice and simple.
OS=`uname -s`

export HOSTTYPE KERNEL MACH MACHTYPE OS

# Now we check against OS, ensure that OSTYPE is set and some other useful info
case ${OS} in
  "Linux" | "linux-gnu" | "GNU"*)
  if [ -z "${OSTYPE}" ]; then OSTYPE=linux-gnu; export OSTYPE; fi

	if [ -f /etc/redhat-release ]; then
      DistroBasedOn=RedHat
      DistroPkgType=rpm
      DistroFullName=`sed s/\ release.*// /etc/redhat-release`
      DistroCodename=`sed s/.*\(// /etc/redhat-release | sed s/\)//`
      DistroRevision=`sed s/.*release\ // /etc/redhat-release | sed s/\ .*//`
    elif [ -f /etc/SuSE-release ]; then
      DistroBasedOn=SuSe
      DistroPkgType=rpm
      DistroCodename=`tr "\n" ' ' < /etc/SuSE-release | sed s/VERSION.*//`
      DistroRevision=`tr "\n" ' ' < /etc/SuSE-release | sed s/.*=\ //`
    elif [ -f /etc/mandrake-release ]; then
      DistroBasedOn=Mandrake
      DistroPkgType=rpm
      DistroCodename=`sed s/.*\(// /etc/mandrake-release | sed s/\)//`
      DistroRevision=`sed s/.*release\ // /etc/mandrake-release | sed s/\ .*//`
    elif [ -f /etc/debian_version ]; then
      DistroBasedOn=Debian
      DistroPkgType=deb
      DistroFullName=`grep '^DISTRIB_DESCRIPTION' /etc/lsb-release | awk -F=  '{ print $2 }'`
      DistroCodename=`grep '^DISTRIB_CODENAME' /etc/lsb-release | awk -F=  '{ print $2 }'`
      DistroRevision=`grep '^DISTRIB_RELEASE' /etc/lsb-release | awk -F=  '{ print $2 }'`
    elif [ -f /etc/slackware-version ]; then
      DistroBasedOn=Slackware
      DistroPkgType=pkgtools
      DistroFullName=
      DistroCodename=
      DistroRevision=
    fi
    export DistroBasedOn DistroPkgType DistroFullName DistroCodename DistroRevision
    ;;
  "SunOS" | "solaris")
    if [ -z "${OSTYPE}" ]; then OSTYPE=solaris; export OSTYPE; fi
    ARCH=`uname -p`
    OSSTR=`uname -a`
    export ARCH OSSTR
    ;;
  "AIX")
    if [ -z "${OSTYPE}" ]; then OSTYPE=aix; export OSTYPE; fi
    OSSTR="${OS} )oslevel) ()oslevel -r))"
    export OSSTR
    ;;
  "HPUX")
    if [ -z "${OSTYPE}" ]; then OSTYPE=hpux; export OSTYPE; fi
    ;;
  *"BSD" | "DragonFly" | "Bitrig")
    if [ -z "${OSTYPE}" ]; then OSTYPE=bsd; export OSTYPE; fi
    ;;
  "Darwin")
    if [ -z "${OSTYPE}" ]; then OSTYPE=mac; export OSTYPE; fi
    # For osx, we use 'sw_vers' which has output like this:
    # ProductName: Mac OS X
    # ProductVersion: 10.2.3
    # BuildVersion: 6G30
    OIFS="$IFS"; IFS=$'\n'
    set `sw_vers` > /dev/null
    DIST=`echo $1 | tr "\n" ' ' | sed 's/ProductName:[ ]*//'`
    VERSION=`echo $2 | tr "\n" ' ' | sed 's/ProductVersion:[ ]*//'`
    BUILD=`echo $3 | tr "\n" ' ' | sed 's/BuildVersion:[ ]*//'`
    IFS="$OIFS"
    # We may need this one day, I'll just hide it here for now
    #Serial Number: $(system_profiler SPHardwareDataType | awk '/Serial/ {print $4}')
    ;;
  "CYGWIN"* | "MSYS"* | "MINGW"*)
    if [ -z "${OSTYPE}" ]; then OSTYPE=Windows; export OSTYPE; fi
    ;;
  "Haiku")
    if [ -z "${OSTYPE}" ]; then OSTYPE=Haiku; export OSTYPE; fi
    ;;
  "MINIX")
    if [ -z "${OSTYPE}" ]; then OSTYPE=MINIX; export OSTYPE; fi
    ;;
  "IRIX64")
    if [ -z "${OSTYPE}" ]; then OSTYPE=IRIX; export OSTYPE; fi
    ;;
  *)
    printf '%s\n' "[configGenie ERROR]: Unrecognised Operating System."
    exit 1
    ;;
esac

OSSTR="${OS} ${DistroBasedOn} ${RELEASE} (${DistroCodename} ${KERNEL} ${MACH})"
