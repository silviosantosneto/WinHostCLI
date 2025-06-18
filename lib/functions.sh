MSG_FILE="$WINHOSTCTL_DIR/msg/messages.json"

copy_and_clean_host_file() {
  local input="$1" output="$2"

  awk '
    /^[[:space:]]*$/ { empty_line_count++ ; next }
    { lines[NR] = $0; last = NR; empty_line_count = 0 }
    END {
      for (i = 1; i <= last; i++) print lines[i]
      print ""
    }
  ' "$input" >"$output"
}

flushdnswin() {
  if ! powershell.exe -Command "ipconfig /flushdns" >/dev/null 2>&1; then
    msg error FLUSH_DNS_FAILED >&2
    return 1
  fi
}

is_valid_ip() {
  local ip="$1"
  IFS='.' read -r o1 o2 o3 o4 extra <<< "$ip"

  if [[ -n "$extra" || -z "$o1" || -z "$o2" || -z "$o3" || -z "$o4" ]]; then
    msg error INVALID_IP "$ip">&2
    return 1
  fi

  for octet in "$o1" "$o2" "$o3" "$o4"; do
    if ! [[ "$octet" =~ ^[0-9]+$ ]] || ((octet < 0 || octet > 254)); then
      msg error INVALID_IP "$ip">&2
      return 1
    fi
  done
  return 0
}

is_valid_domain() {
  if [[ $1 == *.* && $1 =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]]; then
    return 0
  else
    msg error INVALID_DOMAIN "$domain" >&2
    return 1
  fi
}

insert_host() {
  local domain="$1" ip="$2" infile="$3" outfile="$4"
  local in_section=false success=false line host_line

  host_line="$(printf "%s\t\t%s" "$ip" "$domain")"

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "# $SECTION_START" ]]; then
      printf '%s\n' "$line" >> "$outfile" &&  in_section=true
      printf '%s\n' "$host_line" >> "$outfile" && success=true
      continue
    fi

    if [[ "$in_section" == true ]]; then
      if [[ "$line" == "# $SECTION_END" ]]; then
        in_section=false
      elif [[ "$success" == true && "$line" =~ ^[[:space:]]*$ ]]; then
        printf '%s\n' "# $SECTION_END" >>"$outfile"
        in_section=false
        continue
      elif [[ "$line" == "$host_line" ]]; then
        continue
      elif [[ "$line" != \#* && "$line" =~ (^|[[:space:]])$domain($|[[:space:]#]) ]]; then
        continue
      fi
    fi

    printf '%s\n' "$line" >> "$outfile"
  done < "$infile"

  if [[ "$success" == false && "$in_section" == false ]]; then
    printf '%s\n%s\n%s\n' "# $SECTION_START" "$host_line" "# $SECTION_END" >> "$outfile"
  fi
}

delete_host() {
  local domain="$1" infile="$2" outfile="$3"
  local in_section=false success=false line

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "# $SECTION_START" ]]; then
      printf '%s\n' "$line" >> "$outfile" &&  in_section=true
      continue
    fi

    if [[ "$in_section" == true ]]; then
      if [[ "$line" == "# $SECTION_END" ]]; then
        in_section=false
      elif [[ "$success" == true && "$line" =~ ^[[:space:]]*$ ]]; then
        printf '%s\n' "# $SECTION_END" >> "$outfile"
        in_section=false
        continue
      elif [[ "$line" != \#* && "$line" =~ (^|[[:space:]])$domain($|[[:space:]#]) ]]; then
        success=true
        continue
      fi
    fi

    printf '%s\n' "$line" >> "$outfile"
  done < "$infile"

  if grep -q "# $SECTION_START" "$outfile"; then
    tmpfile=$(mktemp)
    awk -v start="# $SECTION_START" -v end="# $SECTION_END" '
      {
        if ($0 == start) {
          getline next_line
          if (next_line == end) {
            next
          } else {
            print $0
            print next_line
          }
        } else {
          print $0
        }
      }
    ' "$outfile" > "$tmpfile"
    mv "$tmpfile" "$outfile"
  fi

  if [[ "$success" == false && "$in_section" == false ]]; then
    msg error DOMAIN_NOT_FOUND "$domain">&2
    return 1
  fi
}

addhost() {
  local ip domain
  local clear_host_file=$(mktemp) new_host_file=$(mktemp)
  trap 'rm -f "$clear_host_file" "$new_host_file"' EXIT

  copy_and_clean_host_file "$HOSTS_FILE" "$clear_host_file"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --domain|-d)
        shift
        domain="$1"
        [[ -z "$1" ]] && {
          msg error MISSING_ARGUMENT >&2
          return 1
        }
        ;;
      --ip|-i)
        shift
        ip="$1"
        ;;
    esac
    shift
  done

  if ! is_valid_ip "$ip"; then
    return 1
  fi

  if ! is_valid_domain "$domain"; then
    return 1
  fi

  insert_host "$domain" "$ip" "$clear_host_file" "$new_host_file"

  if ! sudo cp "$new_host_file" "$HOSTS_FILE"; then
    msg error PERMISSION_DENIED >&2
    return 1
  fi

  flushdnswin

  if [[ "$ip" == "$DEFAULT_IP_ADDRESS" ]]; then
    msg success HOST_ADDED_DEFAULT "$domain"
  else
    msg success HOST_ADDED_CUSTOM "$domain" "$ip"
  fi
}

removehost() {
  local domain
  local clear_host_file=$(mktemp) new_host_file=$(mktemp)
  trap 'rm -f "$clear_host_file" "$new_host_file"' EXIT

  copy_and_clean_host_file "$HOSTS_FILE" "$clear_host_file"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --domain|-d)
        shift
        [[ -z "$1" ]] && {
          msg error MISSING_ARGUMENT >&2
          return 1
        }
        domain="$1"
        ;;
    esac
    shift
  done

  if ! is_valid_domain "$domain"; then
    return 1
  fi

  if ! delete_host "$domain" "$clear_host_file" "$new_host_file"; then
    return 1
  fi


  if ! sudo cp "$new_host_file" "$HOSTS_FILE"; then
    msg error PERMISSION_DENIED >&2
    return 1
  fi

  flushdnswin

  msg success HOST_REMOVED "$domain"
}

msg() {
  local level="$1"
  local key="$2"
  shift 2

  _msg=$(jq -r ".\"${level}\"[\"${key}\"]" "$MSG_FILE")
  if [[ "$_msg" == *"%s"* ]]; then
    printf "$_msg\n" "$@"
  else
    echo -e "$_msg"
  fi
}