#!/bin/bash

# --- Configuration ---

# Extensions to Categories
declare -A extensions_to_categories
extensions_to_categories[Documents]='pdf docx doc txt rtf odt xls xlsx ppt pptx'
extensions_to_categories[Images]='jpg jpeg png svg webp bmp gif'
extensions_to_categories[Videos]='mp4 mkv mov avi flv'
extensions_to_categories[Audio]='mp3 wav flac aac m4a'
extensions_to_categories[Archives]='zip gz tar rar 7z iso'
extensions_to_categories[Scripts]='sh py js rb pl'
extensions_to_categories[Executables]='deb pkg dmg exe msi'

others_dir='Others'

# --- Variables ---
target_dir=""
verbose=false
excluded_dirs=()
ignored_exts=()

#  --- Functions ---

# Print Usage Helper
usage() {
  echo "Usage: $0 <directory_path> [OPTIONS]"
  echo "Options:"
  echo "  -v, --verbose         Show detailed output"
  echo "  -ed, --exclude-dirs   Comma-separated list of directories NOT to create (e.g., 'Images,Videos')."
  echo "  -ie, --ignore-exts    Comma-separated list of extensions to ignore (e.g., 'txt,log')."
  echo "  -h, --help            Show this help message"
}

# Logger
log() {
  if $verbose; then
    echo "$1"
  fi
}

is_ext_contained_in_excluded_dirs() {
  for category in ${excluded_dirs[@]}; do
    for extension in ${extensions_to_categories[$category]}; do
      if [[ $extension == "$1" ]]; then
        return 0
      fi
    done
  done

  return 1
}

# --- Argument Parsing ---
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -v|--verbose)
      verbose=true
      shift
      ;;
    -ed|--exclude-dirs)
      IFS=',' read -ra excluded_dirs <<< "$2"
      shift 2
      ;;
    -ie|--ignore-exts)
      IFS=',' read -ra ignored_exts <<< "$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      # Assume it's the directory path if it's not a flag
      if [[ -z "$target_dir" && ! "$key" =~ ^- ]]; then
        target_dir="$key"
        shift
      else
        echo "Error: Unknown option or multiple directories provided: $1"
        usage
        exit 1
      fi
  esac
done

# --- Validation ---

if [[ -z "$target_dir" ]]; then
  echo "Error: Directory path is mandatory."
  usage
fi

if [[ ! -d "$target_dir" ]]; then
  echo "Error: Directory '$target_dir' doesn't exist."
  exit 1
fi

# Remove trailing slash from tagret_dir if present
target_dir="${target_dir%/}"

# --- Main Logic ---

for category in "${!extensions_to_categories[@]}"; do
  if [[ " ${excluded_dirs[*]} " =~ " ${category} " ]]; then
    log "Skipping the $category category"
    continue
  fi

  category_path="${target_dir}/${category}"

  if [[ ! -d "$category_path" ]]; then
    log "Creating directory: $category_path"
    mkdir -p "$category_path"
  fi

  for extension in ${extensions_to_categories[$category]}; do
    if [[ " ${ignored_exts[*]} " =~ " ${extension} " ]]; then
      log "Ignoring $extension extension"
      continue
    fi

    mv "$target_dir"/*."$extension" "$category_path" -u 2>/dev/null
  done
  log
done

if [[ ! " ${excluded_dirs[*]} " =~ " ${others_dir} " ]]; then
  others_path="${target_dir}/${others_dir}"

  if [[ ! -d "$others_path" ]]; then
    log "Creating directory: $others_path"
    mkdir -p "$others_path"
  fi

  for file in "${target_dir}"/*.*; do
    extension="${file##*.}"

    if [[ " ${ignored_exts[*]} " =~ " $extension " ]]; then
      log "Ignoring $extension extension"
      continue
    fi

    if is_ext_contained_in_excluded_dirs "$extension"; then
      log "Ignoring $extension extension"
      continue
    fi

    mv "$file" "$others_path" -u
  done
else
  log "Skipping the Others category and ignoring the rest of the files"
fi
log

# Summary
echo '=== Organization complete ==='
