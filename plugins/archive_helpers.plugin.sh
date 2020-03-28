if [ ! "$(which pigz)" -o ! "$(which pbzip2)" -o ! "$(which pv)" -o ! "$(which xz)" ]
then
  echo "Missing dependency for $BASH_SOURCE" >&2
  return 1
fi


# workaround a bug with pv -c which breaks Bash keyboard echo
fix_shell_echo() {
  if [ -t 2 ]  # if stderr is connected to a terminal
  then
    stty echo
  fi
}


#
# Universal untar
#

UnTar() {
  local -r in=${1:?}
  shift
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  else
    local -r ext=${in##*.}
    local -r size=$(du -sb "$in" 2> /dev/null | cut -f 1)
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    if [ "$ext" = "gz" -o "$ext" = "tgz" ]
    then
      pv -cpterab -N 'pigz' -i 0.2 -s $size "$in" | pigz -d | pv -Wctrab -N 'tar' -i 0.2 | tar -x $@ 2> /dev/null
    elif [ "$ext" = "bz2" -o "$ext" = "tbz2" ]
    then
      pv -cpterab -N 'pbzip2' -i 0.2 -s $size "$in" | pbzip2 -d | pv -Wctrab -N 'tar' -i 0.2 | tar -x $@ 2> /dev/null
    elif [ "$ext" = "xz" -o "$ext" = "txz" ]
    then
      pv -cpterab -N 'xz' -i 0.2 -s $size "$in" | xz -d | pv -Wctrab -N 'tar' -i 0.2 | tar -x $@ 2> /dev/null
    else
      pv -pterab -N 'tar' -i 0.2 -s $size "$in" | tar -x $@ 2> /dev/null
    fi
    fix_shell_echo
  fi
}


#
# No compression
#

Tar() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $@ "$in" 2> /dev/null | pv -Wpterab -N 'tar' -i 0.2 -s $size > "$out"
}

TarNpb() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  tar -cP $@ "$in" 2> /dev/null | pv -Wtrab -N 'tar' -i 0.2 > "$out"
}

TarExclude() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  local -r exclude=$(for p in $@; do echo -n "--exclude="$p" "; done)
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb $exclude "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh $exclude "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $exclude --exclude-caches-under "$in" 2> /dev/null | pv -Wpterab -N 'tar' -i 0.2 -s $size > "$out"
}


#
# Gzip
#

Gz() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'pigz' -i 0.2 "$in" | pigz > "$out"
  fi
}

UnGz() {
  local -r in=${1:?}
  local -r out=${2:-${in%.gz}}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  elif [ "$out" = "$in" ]
  then
    echo "Please specify output file" >&2
    return 1
  elif [ -f "$out" ]
  then
    echo "Output file already exists" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'pigz' -i 0.2 "$in" | pigz -d > "$out"
  fi
}

TarGz() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $@ "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | pigz | pv -Wctrab -N 'pigz' -i 0.2 > "$out"
  fix_shell_echo
}

TarGzNpb() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  tar -cP $@ "$in" 2> /dev/null | pv -Wctrab -N 'tar' -i 0.2 | pigz | pv -Wctrab -N 'pigz' -i 0.2 > "$out"
  fix_shell_echo
}

TarGzExclude() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  local -r exclude=$(for p in $@; do echo -n "--exclude="$p" "; done)
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb $exclude "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh $exclude "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $exclude --exclude-caches-under "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | pigz | pv -Wctrab -N 'pigz' -i 0.2 > "$out"
  fix_shell_echo
}


#
# Bzip2
#

Bz2() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'pbzip2' -i 0.2 "$in" | pbzip2 > "$out"
  fi
}

UnBz2() {
  local -r in=${1:?}
  local -r out=${2:-${in%.bz2}}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  elif [ "$out" = "$in" ]
  then
    echo "Please specify output file" >&2
    return 1
  elif [ -f "$out" ]
  then
    echo "Output file already exists" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'pbzip2' -i 0.2 "$in" | pbzip2 -d > "$out"
  fi
}

TarBz2() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $@ "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | pbzip2 | pv -Wctrab -N 'pbzip2' -i 0.2 > "$out"
  fix_shell_echo
}

TarBz2Npb() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  tar -cP $@ "$in" 2> /dev/null | pv -Wctrab -N 'tar' -i 0.2 | pbzip2 | pv -Wctrab -N 'pbzip2' -i 0.2 > "$out"
  fix_shell_echo
}

TarBz2Exclude() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  local -r exclude=$(for p in $@; do echo -n "--exclude="$p" "; done)
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb $exclude "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh $exclude "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $exclude --exclude-caches-under "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | pbzip2 | pv -Wctrab -N 'pbzip2' -i 0.2 > "$out"
  fix_shell_echo
}


#
# Xz
#

Xz() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'xz' -i 0.2 "$in" | xz > "$out"
  fi
}

UnXz() {
  local -r in=${1:?}
  local -r out=${2:-${in%.xz}}
  if [ ! -f "$in" ]
  then
    echo "Input is not a file" >&2
    return 1
  elif [ "$out" = "$in" ]
  then
    echo "Please specify output file" >&2
    return 1
  elif [ -f "$out" ]
  then
    echo "Output file already exists" >&2
    return 1
  else
    local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
    echo "File size: $pretty_size" >&2
    pv -pterab -N 'xz' -i 0.2 "$in" | xz -d > "$out"
  fi
}

TarXz() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $@ "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | xz | pv -Wctrab -N 'xz' -i 0.2 > "$out"
  fix_shell_echo
}

TarXzNpb() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  tar -cP $@ "$in" 2> /dev/null | pv -Wctrab -N 'tar' -i 0.2 | xz | pv -Wctrab -N 'xz' -i 0.2 > "$out"
  fix_shell_echo
}

TarXzExclude() {
  local -r in=${1:?}
  local -r out=${2:-/dev/stdout}
  shift 2
  local -r exclude=$(for p in $@; do echo -n "--exclude="$p" "; done)
  echo -n 'Calculating size...' >&2
  local -r size=$(du -sb $exclude "$in" 2> /dev/null | cut -f 1)
  local -r pretty_size=$(du -sbh $exclude "$in" 2> /dev/null | cut -f 1)
  echo -en '\r\e[K' >&2
  echo "Total size: $pretty_size" >&2
  tar -cP $exclude --exclude-caches-under "$in" 2> /dev/null | pv -Wcpterab -N 'tar' -i 0.2 -s $size | xz | pv -Wctrab -N 'xz' -i 0.2 > "$out"
  fix_shell_echo
}
