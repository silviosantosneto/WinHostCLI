# ================================================================================================
# Windows Hosts Manager via WSL
# Manage Windows 'hosts' file entries directly from WSL
# ================================================================================================

setopt shwordsplit

# Constants
[[ -z "$HOSTS_FILE" ]] && readonly HOSTS_FILE="/mnt/c/Windows/System32/drivers/etc/hosts"
[[ -z "$CLEAN_HOST_FILE" ]] && readonly CLEAN_HOST_FILE=$(create_temp_file)
[[ -z "$MARKER_START" ]] && readonly MARKER_START="# Valet generated Hosts. Do not change"
[[ -z "$MARKER_END" ]] && readonly MARKER_END="# End Valet generated Hosts"

create_temp_file() {
  local temp_file
  temp_file=$(mktemp) || {
    echo "❌ Failed to create temp file." >&2
    return 1
  }
  trap 'rm -f "$temp_file"' EXIT
  echo "$temp_file"
}

copy_and_clean_host_file() {
  local input="$1"
  local output="$2"

  awk '
    /^[[:space:]]*$/ { empty_line_count++ ; next }
    { lines[NR] = $0; last = NR; empty_line_count = 0 }
    END {
      for (i = 1; i <= last; i++) print lines[i]
    }
  ' "$input" > "$output"
}
# Flushes Windows DNS cache
flushdnswin() {
  if ! powershell.exe -Command "ipconfig /flushdns" >/dev/null 2>&1; then
    echo "❌ Failed to flush DNS cache. Try running WSL as administrator." >&2
    return 1
  fi
}

# Validate IPv4
function is_valid_ip() {
  local ip="$1"
  IFS='.' read -r o1 o2 o3 o4 extra <<<"$ip"

  if [[ -n "$extra" || -z "$o1" || -z "$o2" || -z "$o3" || -z "$o4" ]]; then
    return 1
  fi

  for octet in "$o1" "$o2" "$o3" "$o4"; do
    if ! [[ "$octet" =~ ^[0-9]+$ ]] || ((octet < 1 || octet > 254)); then
      return 1
    fi
  done

  return 0
}

# Validate domain
function is_valid_domain() {
  local domain="$1"
  if [[ "$domain" == *.* && "$domain" =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]]; then
    return 0
  else
    return 1
  fi
}

# Insert domain
insert_host_between_markers() {
  local ip="$1" domain="$2" infile="$3" outfile="$4"
  local in_section=0 inserted=0 found=0

  while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ "$line" == "$MARKER_START" ]]; then
      echo "$line" >>"$outfile"
      in_section=1
      found=1
      continue
    elif [[ "$line" == "$MARKER_END" ]]; then
      ((inserted == 0)) && echo "$ip    $domain" >>"$outfile"
      echo "$line" >>"$outfile"
      in_section=0
      continue
    fi
    [[ $in_section -eq 1 && "$line" =~ [[:space:]]$domain$ ]] && continue
    echo "$line" >>"$outfile"
  done <"$infile"

  if ((found == 0)); then
    {
      echo ""
      echo "$MARKER_START"
      echo "$ip    $domain"
      echo "$MARKER_END"
    } >>"$outfile"
  fi
}

# Add entry(ies) to hosts file
addhostwin() {

  local ip="127.0.0.1"
  if is_valid_ip "$1"; then
    ip="$1"
    shift
  fi

  local domain temp_file
  temp_file=$(mktemp) || {
    echo "❌ Failed to create temp file." >&2
    return 1
  }
  trap 'rm -f "$temp_file"' EXIT

  for domain in "$@"; do
    is_valid_domain "$domain" || {
      echo "❌Invalid domain: $domain" >&2
      continue
    }

    copy_and_clean_host_file "$HOSTS_FILE" "$CLEAN_HOST_FILE" || {
      echo "❌ Failed to copy and clean hosts file." >&2
      continue
    }

    if ! insert_host_between_markers "$ip" "$domain" "$CLEAN_HOST_FILE" "$temp_file"; then
      echo "❌ Failed to process domain" >&2
      continue
    fi

    if ! sudo cp "$temp_file" "$HOSTS_FILE"; then
      echo "❌ Permission denied updating hosts." >&2
      continue
    fi

    flushdnswin

    if [[ $ip == "127.0.0.1" ]]; then
      echo "✔️ Domain $domain successfully added."
    else
      echo "✔️ Domain $domain pointing to $ip successfully added."
    fi
  done
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