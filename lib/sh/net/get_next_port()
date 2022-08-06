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

# Get the next available local port for portforwarding
# Usage: get_next_port [start port (9000)] [number of ports to scan (100)]
get_next_port() {
    local test_port
    # Default to port 9000
    test_port="${1:-9000}"
    # Set an upper bound.  100 cycles should be plenty.
    max_port="$(( test_port + "${2:-100}" ))"
    while true; do
        # Obviously, if we hit our upper bound, then stop processing
        if (( test_port == max_port )); then
            printf -- '%s\n' "Could not find an available port" >&2
            return 1
        fi
        # bash builtins weren't working in WSL2 for me, so I'm using 'ss' here
        # TODO: figure out a more portable way to do this, or multiple methods failing over to one another?
        if ! ss 2>&1 | grep -q "127.0.0.1:${test_port}"; then
            printf -- '%d\n' "${test_port}"
            break   
        fi
        # If we get to this point, iterate the port number up and try again
        (( test_port++ ))
    done  
}
