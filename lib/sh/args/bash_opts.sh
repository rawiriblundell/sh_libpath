#!/bin/bash

# set -x

declare -a __OPTS__=() __VARS__=()

function opts() {
  function opt_name() {
    local opt=$1
    local type name
    type=$(opt_type "$opt")
    name=$(echo "${opt/--no-/}" | tr -d '\-=[]')

    if [[ $type == array && ${name: -1} == s ]]; then
      name=${name%?}
    fi
    echo "$name"
  }

  function var_name() {
    local opt=$1
    echo "${opt/--no-/}" | tr -d '\-=[]'
  }

  function short_name() {
    local opt=$1
    local name=${opt/[]//}
    if [[ $name =~ (\[(.)\]) ]]; then
      echo "${BASH_REMATCH[2]}"
    fi
  }

  function opt_type() {
    local opt=$1
    local type=flag
    [[ ! $opt =~ =$   ]] || type=var
    [[ ! $opt =~ \[\] ]] || type=array
    echo $type
  }

  function negated() {
    local opt=$1
    [[ $opt =~ ^--no- ]] && echo true || echo false
  }

  local opts=("$@")

  for opt in "${opts[@]}"; do
    __OPTS__[${#__OPTS__[@]}]="
      opt=$(opt_name "$opt")
      name=$(var_name "$opt")
      type=$(opt_type "$opt")
      short=$(short_name "$opt")
      negated=$(negated "$opt")
    "
  done
}
export -f opts

function opts_eval() {
  function puts() {
    echo "$@" >&2
  }

  function opts_declare() {
    for opt in "${__OPTS__[@]}"; do
      local type= name= short= negated=
      eval "$opt"
      [[ $type != var ]]   || store_var "$name="
      [[ $type != array ]] || store_var "$name=()"
      [[ $type != flag ]]  || store_var "$name=$([[ $negated == true ]] && echo true || echo false)"
    done
  }

  function store_var() {
    __VARS__[${#__VARS__[@]}]="$1"
  }

  function opt_value() {
    local arg=$1 opt=$2 name=$3 short=$4
    [[ $arg =~ --$opt=(.*)$ || $arg =~ -$short=(.*)$ ]] || return 1
    echo "${BASH_REMATCH[1]}"
  }

  function set_var() {
    local name=$3 value=
    value=$(opt_value "$@") && store_var "$name=\"$value\""
  }

  function set_array() {
    local name=$3 value=
    value=$(opt_value "$@") && store_var "$name[\${#""$name""[@]}]=\"$value\""
  }

  function set_flag() {
    local arg=$1 opt=$2 name=$3 short=$4 value=

    if [[ $arg == -$short ]]; then
      value=true
    elif [[ $arg =~ --(no-)?$opt$ ]]; then
      value=$([[ -n ${BASH_REMATCH[1]} ]] && echo false || echo true)
    fi

    [[ -n $value ]] && store_var "$name=$value"
  }

  function opts_parse() {
    local arg=$1

    for opt in "${__OPTS__[@]}"; do
      local type= name= short= negated= value=
      eval "$opt"
      if set_$type "$arg" "$opt" "$name" "$short"; then
        return 0
      fi
    done

    return 1
  }

  function opts_join_assignment() {
    local arg=$1 type= name= short= negated= value=

    for opt in "${__OPTS__[@]}"; do
      eval "$opt"
      if [[ $type != flag && ($arg == --$opt || $arg == -$short) ]]; then #  && (( $# > 0 ))
        return 0
      fi
    done

    return 1
  }

  opts_declare

  local arg var
  args=(0)

  while (( $# > 0 )); do
    if opts_join_assignment "$1"; then
      arg="$1=$2"
      shift || true
    else
      arg=$1
    fi
    shift || true

    if [[ $arg == '--' ]]; then
      args=( ${args[@]} $@ )
      break
    elif opts_parse "$arg"; then
      true
    elif [[ $arg =~ ^- ]]; then
      echo "Unknown option: ${arg}" >&2 && exit 1
    else
      args[${#args[@]}]="$arg"
    fi
  done

  for var in "${__VARS__[@]}"; do
    eval "$var"
  done

  args=(${args[@]:1})
}
export -f opts_eval

function opt() {
  function opt_type() {
    local opt line
    line=$(echo "${__OPTS__[@]}" | grep -A 1 "name=$1" | tail -n 1)
    echo "${line#*=}"
  }

  function opt_var() {
    echo "--$1=\"$(eval "echo \$$1")\""
  }

  function opt_array() {
    local _length
    _length=$(eval "echo \${#$1[@]}")
    (( _length == 0 )) || echo $(
      for ((_i=0; _i < _length ; _i++)); do
        echo "--${1%s}=\"$(eval "echo \${$1[$_i]}")\""
      done
    ) | tr "\n" ' ' | sed 's/ *$//'
  }

  function opt_flag() {
    [[ $(eval "echo \$$1") == false ]] || echo "--$1"
  }

  opt_$(opt_type "$1") "$1"
}
export -f opt

# if [[ $0 == "$BASH_SOURCE" ]]; then
#   args=("--foo=FOO" "--fuu" "FUU" "arg-1" "--bar=1" "--bar=2" "--baz" "--no-buz" "arg-2 --bum=3") # "--boz")
#   # args=("--foo=FOO" "--fuu=FUU")
#   # args=("--foo" "FOO")
#   # args=("--foo", "FOO BAR")
#
#   echo args: "${args[@]}"
#   echo opts: --[f]oo= --bars[]= --[b]az --no-buz
#   opts --[f]oo= --fuu= --bars[]= --[b]az --no-buz
#   opts_eval "${args[@]}"
#
#   echo
#   echo foo: ${foo:=}
#   echo fuu: ${fuu:=}
#   [[ ${#bars[@]} == 0 ]] || for bar in ${bars[@]}; do echo bar: $bar; done
#   echo baz: ${baz:=}
#   echo buz: ${buz:=}
#
#   echo
#   echo args: ${#args[@]}
#   [[ ${#args[@]} == 0 ]] || for arg in "${args[@]}"; do echo arg: "$arg"; done
# fi
