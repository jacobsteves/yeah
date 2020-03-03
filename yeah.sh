#!/bin/sh
# shellcheck disable=1001,1012,2039,1090
# 1001,1012 stop complaints about '\awk' syntax to bypass aliases.
# 2039 stops complaints about array references not being POSIX.
# 1090 stops complaints about sourcing non-constant paths.

# This shell script was inspired by https://github.com/Shopify/shopify-app-cli

# This must be outside of the function context for $0 to work properly
__shell="$(\ps -p $$ | \awk 'NR > 1 { sub(/^-/, "", $4); print $4 }')"
__shellname="$(basename "${__shell}")"

case "${__shellname}" in
  zsh)  __yeah_source_dir="$(\dirname "$0:A")" ;;
  bash) __yeah_source_dir="$(builtin cd "$(\dirname "${BASH_SOURCE[0]}")" && \pwd)" ;;
  *)
    >&2 \echo "yeah is not compatible with your shell (${__shell})"
    \return 1
    ;;
esac

#### Handlers for bin/shell-support environment manipulation
#### See bin/shell-support for documentation.
yeah__source() { source "$1"; }
yeah__setenv() { export "$1=$2"; }
yeah__append_path() { export "PATH=${PATH}:$1"; }
yeah__lazyload() { type "$1" >/dev/null 2>&1 || eval "$1() { source $2 ; $1 \"\$@\"; }"; }
yeah__prepend_path() {
  PATH="$(
    /usr/bin/awk -v RS=: -v ORS= -v "prepend=$1" '
      BEGIN         { print prepend }
                    { gsub(/\n$/,"", $0) }
      $0 != prepend { print ":" $0 }
    ' <<< "${PATH}"
  )"
  export PATH
}

while read -r line; do
  eval "${line}"
done < <("${__yeah_source_dir}/bin/shell-support" env "${__shellname}")

unset -f yeah__source
unset -f yeah__setenv
unset -f yeah__append_path
unset -f yeah__prepend_path
unset -f yeah__lazyload

## End changing environment variables

__mtime_of_yeah_script="$(\date -r "${__yeah_source_dir}/yeah.sh" +%s)"

yeah() {
  # reload __yeah__ function
  local current_mtime
  current_mtime="$(\date -r "${__yeah_source_dir}/yeah.sh" +%s)"

  if [[ "${current_mtime}" != "${__mtime_of_yeah_script}" ]]; then
    . "${__yeah_source_dir}/yeah.sh"
  fi
  __yeah__ "$@"
}

__yeah__() {
  for cmd in chruby_auto rvm rbenv iterm2_preexec; do
    if command -v "${cmd}" >/dev/null 2>&1 ; then
      export "yeah_CONFLICTING_TOOL_${cmd}=1"
    fi
  done

  export LANG="${LANG-en_US.UTF-8}"
  export LANGUAGE="${LANGUAGE-en_US.UTF-8}"
  export LC_ALL="${LC_ALL-en_US.UTF-8}"

  local bin_path
  bin_path="${__yeah_source_dir}/bin/yeah"

  local tmpfile
  tmpfile="$(\mktemp -u)" # Create a new tempfile

  exec 9>"${tmpfile}" # Open the tempfile for writing on FD 9.
  exec 8<"${tmpfile}" # Open the tempfile for reading on FD 8.
  \rm -f "${tmpfile}" # Unlink the tempfile. (we've already opened it).

  local return_from_yeah
  local with_gems
  local install_dir="$HOME/.yeah"
  if [[ "${__yeah_source_dir}" == "${install_dir}" ]] || [ ! -t 0 ]; then
    with_gems="FALSE"
  else
    with_gems="TRUE"
  fi
  if [[ "$1" == "--with-gems" ]]; then
    shift
    with_gems="TRUE"
  elif [[ "$1" == "--without-gems" ]]; then
    shift
    with_gems="FALSE"
  fi

  if [[ ${with_gems} == "TRUE" ]]; then
    /usr/bin/env ruby "${bin_path}" "$@"
  else
    "${bin_path}" "$@"
  fi
  return_from_yeah=$?

  local finalizers
  finalizers=()

  local fin
  while \read -r fin; do
    finalizers+=("${fin}")
  done <&8

  exec 8<&- # close FD 8.
  exec 9<&- # close FD 9.

  for fin in "${finalizers[@]}"; do
    case "${fin}" in
      cd:*)
        # shellcheck disable=SC2164
        cd "${fin//cd:/}"
        ;;
      setenv:*)
        # shellcheck disable=SC2163
        export "${fin//setenv:/}"
        ;;
      *)
        ;;
    esac
  done

  \return ${return_from_yeah}
}

# . "${__yeah_source_dir}/sh/hooks/hooks.${__shellname}"
