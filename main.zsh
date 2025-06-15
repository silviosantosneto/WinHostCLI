# ================================================================================================
# Windows Hosts Manager via WSL
# Manage Windows 'hosts' file entries directly from WSL
# ================================================================================================

setopt shwordsplit

# Constants
[[ -z "$HOSTS_FILE" ]] && readonly HOSTS_FILE="/mnt/c/Windows/System32/drivers/etc/hosts"
[[ -z "$MARKER_START" ]] && readonly MARKER_START="# Valet generated Hosts. Do not change"
[[ -z "$MARKER_END" ]] && readonly MARKER_END="# End Valet generated Hosts"

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
# Flushes Windows DNS cache
flushdnswin() {
  if ! powershell.exe -Command "ipconfig /flushdns" >/dev/null 2>&1; then
    echo "❌ Failed to flush DNS cache. Try running as administrator." >&2
    return 1
  fi
}

# Validate IPv4
is_valid_ip() {
  local ip="$1"
  IFS='.' read -r o1 o2 o3 o4 extra <<<"$ip"

  if [[ -n "$extra" || -z "$o1" || -z "$o2" || -z "$o3" || -z "$o4" ]]; then
    echo "❌ Invalid IP: '$1'"
    return 1
  fi

  for octet in "$o1" "$o2" "$o3" "$o4"; do
    if ! [[ "$octet" =~ ^[0-9]+$ ]] || ((octet < 0 || octet > 254)); then
      echo "❌ Invalid IP: '$1'"
      return 1
    fi
  done
  return 0
}

# Validate domain
is_valid_domain() {
  if [[ $1 == *.* && $1 =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]]; then
    return 0
  else
    echo "❌Invalid domain: $1"
    return 1
  fi
}

# Insert domain
insert_host() {
  local host_line="$1" infile="$2" outfile="$3"
  local in_section=false host_added=false line count

  while IFS= read -r line || [[ -n "$line" ]]; do
    count=$((count + 1))
    if [[ "$line" == "$MARKER_START" ]]; then
      printf '%s\n' "$line" >> "$outfile" &&  in_section=true
      printf '%s\n' "$host_line" >> "$outfile" && host_added=true
      continue
    fi

    if [[ "$in_section" == true ]]; then
      if [[ "$line" == "$MARKER_END" ]]; then
        in_section=false
      elif [[ "$host_added" == true && "$line" =~ ^[[:space:]]*$ ]]; then
        printf '%s\n' "$MARKER_END" >>"$outfile"
        echo "$count"
        in_section=false
        continue
      elif [[ "$line" == "$host_line" ]]; then
        continue
      fi
    fi

    printf '%s\n' "$line" >> "$outfile"
  done < "$infile"

  if [[ "$host_added" == false && "$in_section" == false ]]; then
    printf '%s\n%s\n%s\n' "$MARKER_START" "$host_line" "$MARKER_END" >> "$outfile"
  fi
}

# Add entry(ies) to hosts file
addhostwin() {
  local ip="127.0.0.1" domain=""
  local clear_host_file=$(mktemp) || { echo "❌ Erro clear_host_file"; return 1; }
  local new_host_file=$(mktemp) || { echo "❌ Erro new_host_file"; return 1; }
  trap 'rm -f "$clear_host_file" "$new_host_file"' EXIT

  copy_and_clean_host_file "$HOSTS_FILE" "$clear_host_file"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --ip|-i)
        shift
        [[ -z "$1" ]] && {
          echo "❌ Missing IP address after --ip" >&2
          return 1
        }
        ip="$1"
        ;;
      --domain|-d)
        shift
        [[ -z "$1" ]] && {
          echo "❌ Missing domain after --domain" >&2
          return 1
        }
        domain="$1"
        ;;
      --help|-h)
        echo "Usage: addhostwin [--ip <ip>] --domain <domain>"
        echo "Example: addhostwin --ip 192.168.0.1 --domain test.local"
        echo "         addhostwin --domain test.local"
        return 0
        ;;
      *)
        echo "❌ Unknown option: $1" >&2
        echo "Use --help for usage." >&2
        return 1
        ;;
    esac
    shift
  done

  if [[ -z "$domain" ]]; then
    echo "❌ The --domain option is required." >&2
    return 1
  fi

  if ! is_valid_ip "$ip"; then
    return 1
  fi

  if ! is_valid_domain "$domain"; then
    return 1
  fi

  # Insere no hosts
  if ! insert_host "$(printf "%s\t\t%s" "$ip" "$domain")" "$clear_host_file" "$new_host_file"; then
    echo "❌ Failed to process domain: $domain" >&2
    return 1
  fi

  if ! sudo cp "$new_host_file" "$HOSTS_FILE"; then
    echo "❌ Permission denied updating hosts file." >&2
    return 1
  fi

  flushdnswin

  if [[ "$ip" == "127.0.0.1" ]]; then
    echo "✔️ Domain '$domain' added successfully pointing to localhost."
  else
    echo "✔️ Domain '$domain' added successfully pointing to $ip."
  fi
}


# Remove domain and markers if empty
removehostwin() {

  local domain="$1" temp_file
  temp_file=$(mktemp) || {
    echo "❌ Failed to create temp file." >&2
    return 1
  }
  trap 'rm -f "$temp_file"' EXIT

  is_valid_domain "$domain" || {
    echo "❌ Invalid domain" >&2
    return 1
  }

  local in_section=0 found=0 removed=0 domain_count=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$MARKER_START" ]]; then
      in_section=1
      found=1
      echo "$line" >>"$temp_file"
      continue
    elif [[ "$line" == "$MARKER_END" ]]; then
      in_section=0
      if ((domain_count == 0)); then
        head -n -1 "$temp_file" >"${temp_file}.tmp" && mv "${temp_file}.tmp" "$temp_file"
        continue
      else
        echo "$line" >>"$temp_file"
      fi
      continue
    fi

    if ((in_section)); then
      if [[ "$line" =~ [[:space:]]$domain$ ]]; then
        removed=1
        continue
      fi
      [[ -n "$line" && ! "$line" =~ ^# ]] && ((domain_count++))
    fi

    echo "$line" >>"$temp_file"
  done <"$HOSTS_FILE"

  ((found == 0)) && {
    echo "⚠️ Valet marker block not found." >&2
    return 1
  }

  ((removed == 0)) && {
    echo "⚠️ Domain '$domain' not found." >&2
    return 1
  }

  if ! sudo cp "$temp_file" "$HOSTS_FILE"; then
    echo "❌ Failed to write hosts file." >&2
    return 1
  fi

  flushdnswin

  echo "✔️ Domain '$domain' successfully removed."
}
