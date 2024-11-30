#!/bin/sh
# shellcheck shell=dash

[ -z "$1" ] && {
  cat <<EOF
Usage: $0 <binary> <arg1> <argN>

 e.g.: $0 /usr/bin/ls -l
EOF
	exit 1
}

command -v 'ls'      >/dev/null || { echo "[ERROR] please install 'ls'"     ; exit 1; }
command -v 'ldd'     >/dev/null || { echo "[ERROR] please install 'ldd'"    ; exit 1; }
command -v 'awk'     >/dev/null || { echo "[ERROR] please install 'awk'"    ; exit 1; }
command -v 'cut'     >/dev/null || { echo "[ERROR] please install 'cut'"    ; exit 1; }
command -v 'grep'    >/dev/null || { echo "[ERROR] please install 'grep'"   ; exit 1; }
command -v 'sort'    >/dev/null || { echo "[ERROR] please install 'sort'"   ; exit 1; }
command -v 'tail'    >/dev/null || { echo "[ERROR] please install 'tail'"   ; exit 1; }
command -v 'head'    >/dev/null || { echo "[ERROR] please install 'head'"   ; exit 1; }
command -v 'strace'  >/dev/null || { echo "[ERROR] please install 'strace'" ; exit 1; }
command -v 'timeout' >/dev/null || { echo "[ERROR] please install 'timeout'"; exit 1; }

log()
{
  >&2 printf '%s\n' "$1"
}

# root@openwrt:~ ls -l /bin/true
# lrwxrwxrwx    1 root     root             7 Oct 14 19:57 /bin/true -> busybox
#
# bastian@ryzen:~/software/show-full-binary-dependencies$ ls -l /bin/true
# -rwxr-xr-x 1 root root 35664  9. Mär 2024  /bin/true
#
# bastian@ryzen:~/software/show-full-binary-dependencies$ ls -l /bin/true --time-style=long-iso
# -rwxr-xr-x 1 root root 35664 2024-03-09 18:42 /bin/true

showdeps()              # helper: list all dependencies for a binary (shared libs)
{
  local binary="$1"     # e.g. './foo.exe arg1 arg2' - maybe apply: export LC_ALL=C
  local line base i

  log "# running: strace --follow-forks -e trace=file $*"
  log "#     and: LC_ALL=C ldd '$binary'"
  log

  list_file() {
    local bytes file="$1"
    test -h "$file" || file="$( readlink -f "$file" )"
    bytes="$( wc -c 2>/dev/null <"$file" )" || return 1

    # shellcheck disable=SC2012
    ls -l "$file" --time-style=long-iso | awk "{print \$1,sprintf(\"%10s\", \"$bytes\"),\$6,\$7,\$8,\$9,\$10}"
  }

  binary="$( command -v "$binary" )"    # e.g. 'busybox' => /usr/bin/busybox OR './busybox' => './busybox'
  base="$( basename -- "$binary" )"

  x()
  {
   local firstline shebang word
   list_file "$binary"		# stays always on top

   {
    # https://stackoverflow.com/questions/41660574/strace-a-shebang-script
    firstline="$( head -n1 "$binary" | cut -b1-256 )"
    case "$firstline" in '#!/'*)
      shebang="$( echo "$firstline" | cut -b3- )"
      for word in $shebang; do {
        list_file "$word"
      } done
      # shellcheck disable=SC2086
      timeout 3 strace -f -e trace=file $shebang 2>&1 | \
      while read -r line; do {
        test -f "$line" && list_file "$line"
      } done
    esac

    strace -f -e trace=file "$@" 2>&1 | \
      cut -d'"' -f2 | \
      while read -r line; do {
        test -f "$line" && list_file "$line"
      } done

    LC_ALL=C ldd "$binary" 2>&1 | while read -r line; do {
      # shellcheck disable=SC2086
      set -- $line

      case "$line" in
        *'not a dynamic executable'*) ;;
        *' => '*) test -f "$3" && list_file "$3" ;;
        *) test -f "$1" && list_file "$1" ;;
      esac
    } done
   } | grep -v "$base " | grep -v ' /etc/ld.so.cache' | grep -v ' /sys/' | grep -v ' /proc/' | grep -v ' /etc/' | sort -k5,5 | uniq
  }

  i="$( x "$@" | awk '{print $5}' | while read -r line; do md5sum <"$line" | cut -d' ' -f1; done | sort -u | wc -l )"
  x "$@" ; echo && echo "list()       # all $i deps for '$base' - generated with showdeps()" && echo "{"
  echo "    echo \"$( x "$@" | grep "$binary" | awk '{print $5}' )\""
  x "$@" | tail -n +2 | awk '{print $5}' | while read -r line; do {
    echo "|$( md5sum <"$line" | cut -d' ' -f1 )|    echo \"$line\""
  } done | sort -u -k1,1 | cut -d'|' -f3 | sort -k2,2
  echo "}"
}

showdeps "$@"
