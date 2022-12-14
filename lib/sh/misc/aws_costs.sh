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

# Requires GNU date, aws-cli and jq

get_month_end() {
    local date_int
    date_int=$(date +%Y%m27)
    for (( i=0; i<4; i++ )); do
        date_int=$(( date_int + 1 ))
        date -d "${date_int}" "+%Y-%m-%d" 2>/dev/null
    done | tail -n 1
}

last_month_start="$(date -d "last month" '+%Y-%m-01')"
# Could be "$(printf '%(%Y-%m-01)T\n' -1)" to spare a fork
current_month_start="$(date '+%Y-%m-01')"
last_month_end="$(date -d "${current_month_start} -1 day" '+%Y-%m-%d')" 
current_month_end="$(get_month_end)"
current_month_end_minus1="$(date -d "${current_month_end} -1 day" '+%Y-%m-%d')"

aws_get_cost_last_month() {
    aws ce get-cost-and-usage \
        --time-period Start="${last_month_start}",End="${last_month_end}" \
        --granularity MONTHLY \
        --metrics USAGE_QUANTITY BLENDED_COST \
        --group-by Type=DIMENSION,Key=SERVICE | 
            jq '[ .ResultsByTime[].Groups[] | 
                select(.Metrics.BlendedCost.Amount > "0") | 
                { (.Keys[0]): .Metrics.BlendedCost } ] 
                | sort_by(.Amount) 
                | add
            '
}

aws_get_cost_this_month() {
    aws ce get-cost-and-usage \
        --time-period Start="${current_month_start}",End="${current_month_end}" \
        --granularity MONTHLY \
        --metrics USAGE_QUANTITY BLENDED_COST \
        --group-by Type=DIMENSION,Key=SERVICE | 
            jq '[ .ResultsByTime[].Groups[] | 
                select(.Metrics.BlendedCost.Amount > "0") | 
                { (.Keys[0]): .Metrics.BlendedCost } ] 
                | sort_by(.Amount) 
                | add
            '
}

aws_get_cost_forecast() {
    aws ce get-cost-forecast \
        --time-period Start="${current_month_end_minus1}",End="${current_month_end}" \
        --granularity MONTHLY \
        --metric AMORTIZED_COST |
            jq '.'
}
