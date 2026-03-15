# shellcheck shell=ksh

# BSD 3-Clause License

# Copyright (c) 2014-2015, Miëtek Bak
# All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:

# * Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.

# * Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.

# * Neither the name of the copyright holder nor the names of its
#   contributors may be used to endorse or promote products derived from
#   this software without specific prior written permission.

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Provenance: https://raw.githubusercontent.com/mietek/bashmenot/master/src/platform.sh

[ -n "${_SH_LOADED_sys_platform+x}" ] && return 0
_SH_LOADED_sys_platform=1

# @description Convert a platform identifier string to a human-readable label.
#
# @arg $1 string Platform identifier, e.g. "linux-ubuntu-14.04-x86_64"
#
# @stdout Human-readable platform name, e.g. "Ubuntu 14.04 LTS (x86_64)", or "unknown"
# @exitcode 0 Always
format_platform_description () {
	case "$1" in
	'freebsd-10.0-x86_64')		printf -- '%s\n' 'FreeBSD 10.0 (x86_64)';;
	'freebsd-10.1-x86_64')		printf -- '%s\n' 'FreeBSD 10.1 (x86_64)';;
	'linux-amzn-2014.09-x86_64')	printf -- '%s\n' 'Amazon Linux 2014.09 (x86_64)';;
	'linux-arch-x86_64')		printf -- '%s\n' 'Arch Linux (x86_64)';;
	'linux-centos-6-i386')		printf -- '%s\n' 'CentOS 6 (i386)';;
	'linux-centos-6-x86_64')	printf -- '%s\n' 'CentOS 6 (x86_64)';;
	'linux-centos-7-i386')		printf -- '%s\n' 'CentOS 7 (i386)';;
	'linux-centos-7-x86_64')	printf -- '%s\n' 'CentOS 7 (x86_64)';;
	'linux-debian-6-i386')		printf -- '%s\n' 'Debian 6 (i386)';;
	'linux-debian-6-x86_64')	printf -- '%s\n' 'Debian 6 (x86_64)';;
	'linux-debian-7-i386')		printf -- '%s\n' 'Debian 7 (i386)';;
	'linux-debian-7-x86_64')	printf -- '%s\n' 'Debian 7 (x86_64)';;
	'linux-debian-8-i386')		printf -- '%s\n' 'Debian 8 (i386)';;
	'linux-debian-8-x86_64')	printf -- '%s\n' 'Debian 8 (x86_64)';;
	'linux-exherbo-x86_64')		printf -- '%s\n' 'Exherbo Linux (x86_64)';;
	'linux-fedora-19-i386')		printf -- '%s\n' 'Fedora 19 (i386)';;
	'linux-fedora-19-x86_64')	printf -- '%s\n' 'Fedora 19 (x86_64)';;
	'linux-fedora-20-i386')		printf -- '%s\n' 'Fedora 20 (i386)';;
	'linux-fedora-20-x86_64')	printf -- '%s\n' 'Fedora 20 (x86_64)';;
	'linux-fedora-21-x86_64')	printf -- '%s\n' 'Fedora 21 (x86_64)';;
	'linux-gentoo-x86_64')		printf -- '%s\n' 'Gentoo Linux (x86_64)';;
	'linux-opensuse-13.2-x86_64')	printf -- '%s\n' 'openSUSE 13.2 (x86_64)';;
	'linux-rhel-6-i386')		printf -- '%s\n' 'Red Hat Enterprise Linux 6 (i386)';;
	'linux-rhel-6-x86_64')		printf -- '%s\n' 'Red Hat Enterprise Linux 6 (x86_64)';;
	'linux-rhel-7-x86_64')		printf -- '%s\n' 'Red Hat Enterprise Linux 7 (x86_64)';;
	'linux-slackware-14.1-x86_64')	printf -- '%s\n' 'Slackware 14.1 (x86_64)';;
	'linux-sles-11-i386')		printf -- '%s\n' 'SUSE Linux Enterprise Server 11 (i386)';;
	'linux-sles-11-x86_64')		printf -- '%s\n' 'SUSE Linux Enterprise Server 11 (x86_64)';;
	'linux-sles-12-x86_64')		printf -- '%s\n' 'SUSE Linux Enterprise Server 12 (x86_64)';;
	'linux-ubuntu-10.04-i386')	printf -- '%s\n' 'Ubuntu 10.04 LTS (i386)';;
	'linux-ubuntu-10.04-x86_64')	printf -- '%s\n' 'Ubuntu 10.04 LTS (x86_64)';;
	'linux-ubuntu-12.04-i386')	printf -- '%s\n' 'Ubuntu 12.04 LTS (i386)';;
	'linux-ubuntu-12.04-x86_64')	printf -- '%s\n' 'Ubuntu 12.04 LTS (x86_64)';;
	'linux-ubuntu-14.04-i386')	printf -- '%s\n' 'Ubuntu 14.04 LTS (i386)';;
	'linux-ubuntu-14.04-x86_64')	printf -- '%s\n' 'Ubuntu 14.04 LTS (x86_64)';;
	'linux-ubuntu-14.10-i386')	printf -- '%s\n' 'Ubuntu 14.10 (i386)';;
	'linux-ubuntu-14.10-x86_64')	printf -- '%s\n' 'Ubuntu 14.10 (x86_64)';;
	'linux-ubuntu-15.04-i386')	printf -- '%s\n' 'Ubuntu 15.04 (i386)';;
	'linux-ubuntu-15.04-x86_64')	printf -- '%s\n' 'Ubuntu 15.04 (x86_64)';;
	'osx-10.6-x86_64')		printf -- '%s\n' 'OS X 10.6 (x86_64)';;
	'osx-10.7-x86_64')		printf -- '%s\n' 'OS X 10.7 (x86_64)';;
	'osx-10.8-x86_64')		printf -- '%s\n' 'OS X 10.8 (x86_64)';;
	'osx-10.9-x86_64')		printf -- '%s\n' 'OS X 10.9 (x86_64)';;
	'osx-10.10-x86_64')		printf -- '%s\n' 'OS X 10.10 (x86_64)';;
	*)				printf -- '%s\n' 'unknown'
	esac
}


# @description Return whether a platform identifier is Debian-based (debian or ubuntu).
#
# @arg $1 string Platform identifier string
#
# @exitcode 0 Platform is Debian-like
# @exitcode 1 Platform is not Debian-like
is_debian_like () {
	case "$1" in
	'linux-debian-'*)	return 0;;
	'linux-ubuntu-'*)	return 0;;
	*)			return 1
	esac
}


# @description Return whether a platform identifier is Red Hat-based (amzn, centos, fedora, rhel).
#
# @arg $1 string Platform identifier string
#
# @exitcode 0 Platform is Red Hat-like
# @exitcode 1 Platform is not Red Hat-like
is_redhat_like () {
	case "$1" in
	'linux-amzn-'*)		return 0;;
	'linux-centos-'*)	return 0;;
	'linux-fedora-'*)	return 0;;
	'linux-rhel-'*)		return 0;;
	*)			return 1
	esac
}


# @description Detect the current operating system family using uname.
#
# @stdout "freebsd", "linux", "osx", or "unknown"
# @exitcode 0 Always
detect_os () {
	local raw_os
	raw_os=$( uname -s ) || true

	case "${raw_os}" in
	'FreeBSD')	printf -- '%s\n' 'freebsd';;
	'Linux')	printf -- '%s\n' 'linux';;
	'Darwin')	printf -- '%s\n' 'osx';;
	*)		printf -- '%s\n' 'unknown'
	esac
}


# @description Detect the current CPU architecture using uname, normalising
#   common aliases to a canonical form.
#
# @stdout "x86_64", "i386", or "unknown"
# @exitcode 0 Always
detect_arch () {
	local raw_arch
	raw_arch=$( uname -m | tr '[:upper:]' '[:lower:]' ) || true

	case "${raw_arch}" in
	'amd64')	printf -- '%s\n' 'x86_64';;
	'i686')		printf -- '%s\n' 'i386';;
	'x64')		printf -- '%s\n' 'x86_64';;
	'x86-64')	printf -- '%s\n' 'x86_64';;
	'x86_64')	printf -- '%s\n' 'x86_64';;
	*)		printf -- '%s\n' 'unknown'
	esac
}


# @internal
bashmenot_internal_detect_linux_label () {
	local label raw_label
	label=''

	if [[ -f '/etc/os-release' ]]; then
		label=$( awk -F= '/^ID=/ { print $2 }' <'/etc/os-release' ) || true
	fi
	if [[ -z "${label}" && -f '/etc/lsb-release' ]]; then
		label=$( awk -F= '/^DISTRIB_ID=/ { print $2 }' <'/etc/lsb-release' ) || true
	fi
	if [[ -z "${label}" && -f '/etc/centos-release' ]]; then
		label='centos'
	fi
	if [[ -z "${label}" && -f '/etc/debian_version' ]]; then
		label='debian'
	fi
	if [[ -z "${label}" && -f '/etc/redhat-release' ]]; then
		raw_label=$( <'/etc/redhat-release' ) || true
		case "${raw_label}" in
		('CentOS'*)
			label='centos';;
		('Red Hat Enterprise Linux Server'*)
			label='rhel';;
		(*)
			true
		esac
	fi
	if [[ -z "${label}" && -f '/etc/SuSE-release' ]]; then
		raw_label=$( <'/etc/SuSE-release' ) || true
		case "${raw_label}" in
		('SUSE Linux Enterprise Server'*)
			label='sles';;
		(*)
			true
		esac
	fi

	printf -- '%s\n' "${label}"
}


# @internal
bashmenot_internal_detect_linux_version () {
	local version raw_version
	version=''

	if [[ -f '/etc/os-release' ]]; then
		version=$( awk -F= '/^VERSION_ID=/ { print $2 }' <'/etc/os-release' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/lsb-release' ]]; then
		version=$( awk -F= '/^DISTRIB_RELEASE=/ { print $2 }' <'/etc/lsb-release' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/centos-release' ]]; then
		raw_version=$( <'/etc/centos-release' ) || true
		case "${raw_version}" in
		('CentOS release 6'*)
			version='6';;
		('CentOS Linux release 7'*)
			version='7';;
		(*)
			true
		esac
	fi
	if [[ -z "${version}" && -f '/etc/debian_version' ]]; then
		version=$( sed 's/^\([0-9]*\).*$/\1/' <'/etc/debian_version' ) || true
	fi
	if [[ -z "${version}" && -f '/etc/redhat-release' ]]; then
		raw_version=$( <'/etc/redhat-release' ) || true
		case "${raw_version}" in
		('Red Hat Enterprise Linux Server release 5'*)
			version='5';;
		('Red Hat Enterprise Linux Server release 6'*)
			version='6';;
		(*)
			true
		esac
	fi
	if [[ -z "${version}" && -f '/etc/SuSE-release' ]]; then
		raw_version=$( <'/etc/SuSE-release' ) || true
		case "${raw_version}" in
		('SUSE Linux Enterprise Server 11'*)
			version='11';;
		(*)
			true
		esac
	fi

	printf -- '%s\n' "${version}"
}


# @description Detect the full platform identifier string for the current host,
#   combining OS, distro label, version, and architecture.
#
# @example
#   detect_platform   # => "linux-ubuntu-14.04-x86_64"
#
# @stdout Platform identifier string, e.g. "linux-centos-7-x86_64" or "osx-10.10-x86_64"
# @exitcode 0 Always
detect_platform () {
	local os arch
	os=$( detect_os )
	arch=$( detect_arch )

	local raw_label raw_version
	raw_label=''
	raw_version=''
	case "${os}" in
	('freebsd')
		raw_version=$( uname -r | awk -F- '{ print $1 }' ) || true
		;;
	('linux')
		raw_label=$( bashmenot_internal_detect_linux_label ) || true
		raw_version=$( bashmenot_internal_detect_linux_version ) || true
		;;
	('osx')
		raw_version=$( sw_vers -productVersion ) || true
		;;
	(*)
		true
	esac

	local label version
	label=$( tr -dc '[:alpha:]' <<<"${raw_label}" | tr '[:upper:]' '[:lower:]' ) || true
	version=$( tr -dc '[:digit:]\.' <<<"${raw_version}" | sed 's/^\([0-9]*\.[0-9]*\).*$/\1/' ) || true
	if [[ "${label}" == 'rhel' ]]; then
		version="${version%%.*}"
	fi

	printf -- '%s\n' "${os}${label:+-${label}}${version:+-${version}}${arch:+-${arch}}"
}
