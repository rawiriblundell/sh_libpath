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
        get_uptime() {
            if var_is_unset "${MK_IS_DOCKERIZED}"; then
                cat /proc/uptime
            else
                write "$(($(get_epoch) - $(stat -c %Z /dev/pts)))"
            fi    
        }
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
