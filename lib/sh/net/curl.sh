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

# Provenance: https://raw.githubusercontent.com/mietek/bashmenot/master/src/curl.sh

[ -n "${_SHELLAC_LOADED_net_curl+x}" ] && return 0
_SHELLAC_LOADED_net_curl=1

# @description Convert an HTTP response code integer to a short human-readable label.
#
# @arg $1 string HTTP status code (via expect_args)
#
# @stdout Short label, e.g. 'done', '404 (not found)'
# @exitcode 0 Always
format_http_code_description () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'100')	printf -- '%s\n' '100 (continue)';;
	'101')	printf -- '%s\n' '101 (switching protocols)';;
	'200')	printf -- '%s\n' 'done';;
	'201')	printf -- '%s\n' '201 (created)';;
	'202')	printf -- '%s\n' '202 (accepted)';;
	'203')	printf -- '%s\n' '203 (non-authoritative information)';;
	'204')	printf -- '%s\n' '204 (no content)';;
	'205')	printf -- '%s\n' '205 (reset content)';;
	'206')	printf -- '%s\n' '206 (partial content)';;
	'300')	printf -- '%s\n' '300 (multiple choices)';;
	'301')	printf -- '%s\n' '301 (moved permanently)';;
	'302')	printf -- '%s\n' '302 (found)';;
	'303')	printf -- '%s\n' '303 (see other)';;
	'304')	printf -- '%s\n' '304 (not modified)';;
	'305')	printf -- '%s\n' '305 (use proxy)';;
	'306')	printf -- '%s\n' '306 (switch proxy)';;
	'307')	printf -- '%s\n' '307 (temporary redirect)';;
	'400')	printf -- '%s\n' '400 (bad request)';;
	'401')	printf -- '%s\n' '401 (unauthorized)';;
	'402')	printf -- '%s\n' '402 (payment required)';;
	'403')	printf -- '%s\n' '403 (forbidden)';;
	'404')	printf -- '%s\n' '404 (not found)';;
	'405')	printf -- '%s\n' '405 (method not allowed)';;
	'406')	printf -- '%s\n' '406 (not acceptable)';;
	'407')	printf -- '%s\n' '407 (proxy authentication required)';;
	'408')	printf -- '%s\n' '408 (request timeout)';;
	'409')	printf -- '%s\n' '409 (conflict)';;
	'410')	printf -- '%s\n' '410 (gone)';;
	'411')	printf -- '%s\n' '411 (length required)';;
	'412')	printf -- '%s\n' '412 (precondition failed)';;
	'413')	printf -- '%s\n' '413 (request entity too large)';;
	'414')	printf -- '%s\n' '414 (request URI too long)';;
	'415')	printf -- '%s\n' '415 (unsupported media type)';;
	'416')	printf -- '%s\n' '416 (requested range)';;
	'417')	printf -- '%s\n' '417 (expectation failed)';;
	'418')	printf -- '%s\n' "418 (I'm a teapot)";;
	'419')	printf -- '%s\n' '419 (authentication timeout)';;
	'420')	printf -- '%s\n' '420 (enhance your calm)';;
	'426')	printf -- '%s\n' '426 (upgrade required)';;
	'428')	printf -- '%s\n' '428 (precondition required)';;
	'429')	printf -- '%s\n' '429 (too many requests)';;
	'431')	printf -- '%s\n' '431 (request header fields too large)';;
	'451')	printf -- '%s\n' '451 (unavailable for legal reasons)';;
	'500')	printf -- '%s\n' '500 (internal server error)';;
	'501')	printf -- '%s\n' '501 (not implemented)';;
	'502')	printf -- '%s\n' '502 (bad gateway)';;
	'503')	printf -- '%s\n' '503 (service unavailable)';;
	'504')	printf -- '%s\n' '504 (gateway timeout)';;
	'505')	printf -- '%s\n' '505 (HTTP version not supported)';;
	'506')	printf -- '%s\n' '506 (variant also negotiates)';;
	'510')	printf -- '%s\n' '510 (not extended)';;
	'511')	printf -- '%s\n' '511 (network authentication required)';;
	*)	printf -- '%s\n' "${code} (unknown)"
	esac
}


# @description Return an exit code matching the HTTP status code class:
#   2xx => 0, 3xx => 3, 4xx => 4, 5xx => 5, other => 1.
#
# @arg $1 string HTTP status code (via expect_args)
#
# @exitcode 0 2xx success
# @exitcode 1 Unknown code
# @exitcode 3 3xx redirect
# @exitcode 4 4xx client error
# @exitcode 5 5xx server error
return_http_code_status () {
	local code
	expect_args code -- "$@"

	case "${code}" in
	'2'*)	return 0;;
	'3'*)	return 3;;
	'4'*)	return 4;;
	'5'*)	return 5;;
	*)	return 1
	esac
}


# @description Execute a curl request with retry logic. Retries up to
#   BASHMENOT_CURL_RETRIES (default 5) times with exponential backoff.
#   4xx errors are not retried by default unless BASHMENOT_INTERNAL_CURL_RETRY_ALL is set.
#
# @arg $1 string URL to request (via expect_args)
# @arg $2 string Additional curl arguments (passed through)
#
# @exitcode 0 2xx response received
# @exitcode 1 Non-2xx response after all retries
curl_do () {
	local url
	expect_args url -- "$@"
	shift

	# NOTE: On Debian 6, curl considers HTTP 40* errors to be transient,
	# which makes using the --retry option impractical.  Additionally,
	# in some circumstances, curl writes out 100 and fails instead
	# of automatically continuing.
	# http://curl.haxx.se/mail/lib-2011-03/0161.html
	local max_retries retries code
	max_retries="${BASHMENOT_CURL_RETRIES:-5}"
	retries="${max_retries}"
	code=
	while (( retries )); do
		code=$(
			curl "${url}" \
				--fail \
				--location \
				--silent \
				--show-error \
				--write-out '%{http_code}' \
				"$@" \
				2>'/dev/null'
		) || true

		local code_description
		code_description=$( format_http_code_description "${code}" )
		log_indent_end "${code_description}"

		if [[ "${code}" =~ '2'.* ]]; then
			break
		fi
		if [[ "${code}" =~ '4'.* ]] && ! (( ${BASHMENOT_INTERNAL_CURL_RETRY_ALL:-0} )); then
			break
		fi

		retries=$(( retries - 1 ))
		if (( retries )); then
			local retry delay
			retry=$(( max_retries - retries ))
			delay=$(( 2**retry ))

			log_indent_begin "Retrying in ${delay} seconds (${retry}/${max_retries})..."
			sleep "${delay}" || true
		fi
	done

	return_http_code_status "${code}" || return
}


# @description Download a remote file to a local path, creating parent directories
#   as needed. Uses curl_do for retry behaviour.
#
# @arg $1 string Source URL (via expect_args)
# @arg $2 string Destination file path (via expect_args)
#
# @exitcode 0 Download succeeded
# @exitcode 1 Download failed
curl_download () {
	local src_file_url dst_file
	expect_args src_file_url dst_file -- "$@"

	log_indent_begin "Downloading ${src_file_url}..."

	local dst_dir
	dst_dir=$( dirname "${dst_file}" ) || return 1

	mkdir -p "${dst_dir}" || return 1

	curl_do "${src_file_url}" \
		--output "${dst_file}" || return
}


# @description Perform a HEAD request to check whether a URL is reachable.
#
# @arg $1 string URL to check (via expect_args)
#
# @exitcode 0 URL is reachable (2xx)
# @exitcode 1 URL is not reachable
curl_check () {
	local src_url
	expect_args src_url -- "$@"

	log_indent_begin "Checking ${src_url}..."

	curl_do "${src_url}" \
		--output '/dev/null' \
		--head || return
}


# @description Upload a local file to a remote URL using curl PUT.
#
# @arg $1 string Source file path (via expect_args)
# @arg $2 string Destination URL (via expect_args)
#
# @exitcode 0 Upload succeeded
# @exitcode 1 Upload failed or source file not found
curl_upload () {
	local src_file dst_file_url
	expect_args src_file dst_file_url -- "$@"

	expect_existing "${src_file}" || return 1

	log_indent_begin "Uploading ${dst_file_url}..."

	curl_do "${dst_file_url}" \
		--output '/dev/null' \
		--upload-file "${src_file}" || return
}


# @description Send a DELETE request to a remote URL via curl.
#
# @arg $1 string Target URL (via expect_args)
#
# @exitcode 0 Delete succeeded
# @exitcode 1 Delete failed
curl_delete () {
	local dst_url
	expect_args dst_url -- "$@"

	log_indent_begin "Deleting ${dst_url}..."

	curl_do "${dst_url}" \
		--output '/dev/null' \
		--request DELETE || return
}
