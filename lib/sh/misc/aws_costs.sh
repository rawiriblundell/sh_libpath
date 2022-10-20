#!/bin/bash
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

