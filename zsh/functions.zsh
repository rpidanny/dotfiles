#!/usr/bin/env zsh

# Change brightness of Apple Cinema Display
function bright() {
  acdcontrol /dev/usb/hiddev$1 $2;
}

# Create a directory and cd into it.
function mcd {
  if [ ! -n "$1" ]; then
    echo "Usage: mcd directory"
    echo "FATAL: Did not pass directory"
    return 1
  elif [ -n "$2" ]; then
    echo "Usage: mcd directory"
    echo "FATAL: Too many arguments"
    return 1
  elif [ -d $1 ]; then
    echo "'$1' already exists"
    return 1
  else
    mkdir -p $1 && cd $1
  fi
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@" | sort -h;
	else
		du $arg .[^.]* ./* | sort -h;
	fi;
}

# Create a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
function targz() {
	local tmpFile="${@%/}.tar";
	tar -cvf "${tmpFile}" --exclude=".DS_Store" "${@}" || return 1;

	size=$(
		stat -f"%z" "${tmpFile}" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}" 2> /dev/null;  # GNU `stat`
	);

	local cmd="";
	if (( size < 52428800 )) && hash zopfli 2> /dev/null; then
		# the .tar file is smaller than 50 MB and Zopfli is available; use it
		cmd="zopfli";
	else
		if hash pigz 2> /dev/null; then
			cmd="pigz";
		else
			cmd="gzip";
		fi;
	fi;

	echo "Compressing .tar ($((size / 1000)) kB) using \`${cmd}\`…";
	"${cmd}" -v "${tmpFile}" || return 1;
	[ -f "${tmpFile}" ] && rm "${tmpFile}";

	zippedSize=$(
		stat -f"%z" "${tmpFile}.gz" 2> /dev/null; # macOS `stat`
		stat -c"%s" "${tmpFile}.gz" 2> /dev/null; # GNU `stat`
	);

	echo "${tmpFile}.gz ($((zippedSize / 1000)) kB) created successfully.";
}

# Compare original and gzipped file size
function gz() {
	local origsize=$(wc -c < "$1");
	local gzipsize=$(gzip -c "$1" | wc -c);
	local ratio=$(echo "$gzipsize * 100 / $origsize" | bc -l);
	printf "orig: %d bytes\n" "$origsize";
	printf "gzip: %d bytes (%2.2f%%)\n" "$gzipsize" "$ratio";
}

# Syntax-highlight JSON strings or files
# Usage: `json '{"foo":42}'` or `echo '{"foo":42}' | json`
function json() {
	if [ -t 0 ]; then # argument
		python -mjson.tool <<< "$*" | pygmentize -l javascript;
	else # pipe
		python -mjson.tool | pygmentize -l javascript;
	fi;
}

# Show all the names (CNs and SANs) listed in the SSL certificate
# for a given domain
function getcertnames() {
	if [ -z "${1}" ]; then
		echo "ERROR: No domain specified.";
		return 1;
	fi;

	local domain="${1}";
	echo "Testing ${domain}…";
	echo ""; # newline

	local tmp=$(echo -e "GET / HTTP/1.0\nEOT" \
		| openssl s_client -connect "${domain}:443" -servername "${domain}" 2>&1);

	if [[ "${tmp}" = *"-----BEGIN CERTIFICATE-----"* ]]; then
		local certText=$(echo "${tmp}" \
			| openssl x509 -text -certopt "no_aux, no_header, no_issuer, no_pubkey, \
			no_serial, no_sigdump, no_signame, no_validity, no_version");
		echo "Common Name:";
		echo ""; # newline
		echo "${certText}" | grep "Subject:" | sed -e "s/^.*CN=//" | sed -e "s/\/emailAddress=.*//";
		echo ""; # newline
		echo "Subject Alternative Name(s):";
		echo ""; # newline
		echo "${certText}" | grep -A 1 "Subject Alternative Name:" \
			| sed -e "2s/DNS://g" -e "s/ //g" | tr "," "\n" | tail -n +2;
		return 0;
	else
		echo "ERROR: Certificate not found.";
		return 1;
	fi;
}

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		xdg-open .;
	else
		xdg-open "$@";
	fi;
}

# Convert video file to GIF
function video2gif() {
	if [ ! -n "$1" ]; then
    echo "Usage: video2gif inputfile outputfile"
    echo "FATAL: Did not pass directory"
    return 1
	elif [ -n "$3" ]; then
    echo "Usage: video2gif inputfile outputfile"
    echo "FATAL: Too many arguments"
    return 1
  elif [ -z "$2" ]; then
		ffmpeg -v warning -ss 2 -t 5 -i $1 -vf scale=320:-1 -gifflags -transdiff -y $1.gif
		echo "${1}.gif created."
  else
		ffmpeg -v warning -ss 2 -t 5 -i $1 -vf scale=320:-1 -gifflags -transdiff -y $2
		echo "${2} created."
  fi
}

# rotate video 90 clockwise
function rvc() {
	if [ ! -n "$1" ]; then
    echo "Usage: rvc inputfile outputfile"
    echo "FATAL: Did not pass directory"
    return 1
	elif [ -n "$3" ]; then
    echo "Usage: rvc inputfile outputfile"
    echo "FATAL: Too many arguments"
    return 1
  elif [ -z "$2" ]; then
		filename="${1%%.*}"
		ext="${1##*.}"
		ffmpeg -i $1 -vf "transpose=1" ${filename}_90c.${ext}
		echo "${1} rotated."
  else
		ffmpeg -i $1 -vf "transpose=1" $2
		echo "${1} saved as ${2} ."
  fi
}

# Nuke Node Modules
function nnm() {
	if [ ! -n "$1" ]; then
    echo "Usage: nnm path"
    echo "FATAL: Did not pass directory"
    return 1
	elif [ -n "$2" ]; then
    echo "Usage: nnm path"
    echo "FATAL: Too many arguments"
    return 1
  else
		echo "🔍 Scanning for node_modules directories in: $1"
		local count=$(find $1 -type d -name "node_modules" 2>/dev/null | wc -l | tr -d ' ')
		if [ "$count" -eq 0 ]; then
			echo "✅ No node_modules directories found in $1"
			return 0
		fi
		echo "📦 Found $count node_modules directory(ies)"
		echo "🗑️  Removing node_modules directories..."
		find $1 -type d -name "node_modules" -exec rm -rf {} + 2>/dev/null
		echo "✅ Successfully nuked $count node_modules directory(ies) from $1"
  fi
}

# Get pylintrc from google's yapf project
function getpylintrc() {
	echo "Fetching pylintrc.."
	wget -c https://raw.githubusercontent.com/google/yapf/master/pylintrc -O .pylintrc
	echo "Saved to .pylintrc"
}

# Function to count file extensions with more detailed output
count_file_extensions_detailed() {
    local target_dir="${1:-.}"
    
    if [[ ! -d "$target_dir" ]]; then
        echo "Error: Directory '$target_dir' does not exist." >&2
        return 1
    fi
    
    echo "Detailed file extension analysis for: $target_dir"
    echo "=================================================="
    
    # Count total files
    local total_files=$(find "$target_dir" -type f | wc -l)
    echo "Total files found: $total_files"
    echo ""
    
    # Get extension counts
    find "$target_dir" -type f | \
    sed 's/.*\.//' | \
    sort | \
    uniq -c | \
    sort -nr | \
    while read count extension; do
        if [[ -n "$extension" ]]; then
            local percentage=$((count * 100 / total_files))
            printf "%-20s %4d files (%3d%%)\n" ".$extension" "$count" "$percentage"
        else
            local percentage=$((count * 100 / total_files))
            printf "%-20s %4d files (%3d%%)\n" "(no extension)" "$count" "$percentage"
        fi
    done
    
    echo "=================================================="
}

# Clean temporary and cache directories
function ntc() {
	if [ ! -n "$1" ]; then
    echo "Usage: ntc path [--dry-run]"
    echo "FATAL: Did not pass directory"
    return 1
	elif [ -n "$3" ]; then
    echo "Usage: ntc path [--dry-run]"
    echo "FATAL: Too many arguments"
    return 1
  else
		local dry_run=false
		local target_dir="$1"
		
		# Check for dry-run flag
		if [ "$2" = "--dry-run" ]; then
			dry_run=true
		fi
		if [ "$dry_run" = true ]; then
			echo "🔍 DRY RUN: Scanning for temporary and cache directories in: $target_dir"
		else
			echo "🧹 Scanning for temporary and cache directories in: $target_dir"
		fi
		
		# Define patterns to search for
		local patterns=(
			".nx"
			".cache"
			".git"
			".pytest_cache"
			"__pycache__"
			".coverage"
			".mypy_cache"
			".tox"
			".venv"
			"venv"
			"env"
			".env"
			"node_modules"
			".next"
			".nuxt"
			".idea"
			"dist"
			"build"
			".build"
			"target"
			".target"
			".cargo"
			".gradle"
			".m2"
			".ivy2"
			".sbt"
			".scala"
			".metals"
			".bloop"
			".bsp"
			".ammonite"
			".mill"
			"tmp"
			"temp"
			".tmp"
			".temp"
			"local_tests"
		)
		
		local total_found=0
		local total_size=0
		
		echo "🔍 Searching for the following patterns:"
		for pattern in "${patterns[@]}"; do
			echo "  - $pattern"
		done
		echo ""
		
		# Count and calculate size for each pattern
		for pattern in "${patterns[@]}"; do
			local count=$(find "$target_dir" -type d -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
			if [ "$count" -gt 0 ]; then
				echo "📦 Found $count '$pattern' directory(ies)"
				
				# List specific directories that would be deleted
				if [ "$dry_run" = true ]; then
					echo "   📋 Directories that would be deleted:"
					find "$target_dir" -type d -name "$pattern" 2>/dev/null | while read -r dir; do
						if [ -d "$dir" ]; then
							local dir_size=$(du -sh "$dir" 2>/dev/null | cut -f1)
							echo "      🗂️  $dir ($dir_size)"
						fi
					done
				fi
				
				# Calculate total size for this pattern
				local size=0
				while IFS= read -r dir; do
					if [ -d "$dir" ]; then
						local dir_size=$(du -sk "$dir" 2>/dev/null | cut -f1)
						if [ -n "$dir_size" ]; then
							size=$((size + dir_size))
						fi
					fi
				done < <(find "$target_dir" -type d -name "$pattern" 2>/dev/null)
				
				if [ "$size" -gt 0 ]; then
					local size_mb=$((size / 1024))
					echo "   💾 Total size: ${size_mb}MB"
					total_size=$((total_size + size))
				fi
				
				total_found=$((total_found + count))
			fi
		done
		
		if [ "$total_found" -eq 0 ]; then
			echo "✅ No temporary/cache directories found in $target_dir"
			return 0
		fi
		
		echo ""
		echo "📊 Summary:"
		echo "   📁 Total directories found: $total_found"
		if [ "$total_size" -gt 0 ]; then
			local total_size_mb=$((total_size / 1024))
			echo "   💾 Total size to be freed: ${total_size_mb}MB"
		fi
		echo ""
		
		# Handle dry-run mode
		if [ "$dry_run" = true ]; then
			echo "🔍 DRY RUN COMPLETE - No files were actually deleted"
			echo "💡 To actually delete these directories, run: ntc $target_dir"
			return 0
		fi
		
		# Ask for confirmation
		echo "⚠️  This will permanently delete all found directories."
		echo -n "🤔 Are you sure you want to continue? (y/N): "
		read -r reply
		echo ""
		
		if [[ ! $reply =~ ^[Yy]$ ]]; then
			echo "❌ Operation cancelled."
			return 0
		fi
		
		echo "🗑️  Removing directories..."
		
		# Remove each pattern
		for pattern in "${patterns[@]}"; do
			local count=$(find "$target_dir" -type d -name "$pattern" 2>/dev/null | wc -l | tr -d ' ')
			if [ "$count" -gt 0 ]; then
				echo "   🧹 Removing $count '$pattern' directory(ies)..."
				find "$target_dir" -type d -name "$pattern" -exec rm -rf {} + 2>/dev/null
			fi
		done
		
		echo ""
		echo "✅ Successfully cleaned $total_found temporary/cache directory(ies) from $target_dir"
		if [ "$total_size" -gt 0 ]; then
			local total_size_mb=$((total_size / 1024))
			echo "💾 Freed approximately ${total_size_mb}MB of disk space"
		fi
  fi
}

# List non-code files with sizes (sorted largest to smallest)
function lfs() {
	if [ ! -n "$1" ]; then
    echo "Usage: lfs path [--include-extensions] [--exclude-patterns] [--delete-above SIZE] [--dry-run]"
    echo "FATAL: Did not pass directory"
    return 1
	elif [ -n "$6" ]; then
    echo "Usage: lfs path [--include-extensions] [--exclude-patterns] [--delete-above SIZE] [--dry-run]"
    echo "FATAL: Too many arguments"
    return 1
  else
		local target_dir="$1"
		local include_extensions=""
		local exclude_patterns=""
		local delete_above=""
		local dry_run=false
		local files_to_delete=()
		local total_size_to_delete=0
		
		# Parse optional arguments - simplified approach
		shift  # Remove the first argument (target directory)
		
		while [[ $# -gt 0 ]]; do
			case "$1" in
				"--include-extensions")
					if [[ $# -lt 2 ]]; then
						echo "❌ Error: --include-extensions requires a value"
						return 1
					fi
					include_extensions="$2"
					shift 2
					;;
				"--exclude-patterns")
					if [[ $# -lt 2 ]]; then
						echo "❌ Error: --exclude-patterns requires a value"
						return 1
					fi
					exclude_patterns="$2"
					shift 2
					;;
				"--delete-above")
					if [[ $# -lt 2 ]]; then
						echo "❌ Error: --delete-above requires a value"
						return 1
					fi
					delete_above="$2"
					shift 2
					;;
				"--dry-run")
					dry_run=true
					shift
					;;
				"--deleve-above"|"--delet-above"|"--delet-abov"|"--dele-above")
					echo "❌ Error: Did you mean '--delete-above'?"
					echo "💡 Correct usage: lfs path --delete-above SIZE"
					return 1
					;;
				*)
					if [[ "$1" =~ ^-- ]]; then
						echo "❌ Error: Unknown option '$1'"
						echo "💡 Available options: --include-extensions, --exclude-patterns, --delete-above, --dry-run"
						return 1
					fi
					echo "❌ Error: Unexpected argument '$1'"
					return 1
					;;
			esac
		done
		
		echo "📁 Analyzing non-code files in: $target_dir"
		echo "=================================================="
		
		# Define common code file extensions to exclude
		local code_extensions=(
			"js" "jsx" "ts" "tsx" "mjs" "py" "java" "cpp" "c" "h" "hpp" "cs" "php" "rb" "go" "rs" "swift" "kt" "scala"
			"html" "htm" "css" "scss" "sass" "less" "xml" "json" "yaml" "yml" "toml" "ini" "cfg" "conf"
			"sql" "sh" "bash" "zsh" "fish" "ps1" "bat" "cmd" "dockerfile" "makefile" "cmake"
			"md" "txt" "rst" "tex" "latex" "org" "adoc" "asciidoc" "mdc"
			"vue" "svelte" "astro" "jsx" "tsx" "elm" "clj" "hs" "ml" "fs" "fsx" "ex" "exs"
			"gif" "png" "jpg" "jpeg" "svg" "ico" "webp" "bmp" "tiff" "tif"
			"pem" "crt" "cer" "key" "p12" "pfx" "jks" "keystore" "truststore"
		)
		
		# Build find command with exclusions
		local find_cmd="find \"$target_dir\" -type f"
		
		# Exclude code file extensions
		for ext in "${code_extensions[@]}"; do
			find_cmd="$find_cmd ! -name \"*.$ext\""
		done
		
		# Exclude common non-code directories
		find_cmd="$find_cmd ! -path \"*/node_modules/*\" ! -path \"*/.git/*\" ! -path \"*/.vscode/*\" ! -path \"*/.idea/*\""
		find_cmd="$find_cmd ! -path \"*/dist/*\" ! -path \"*/build/*\" ! -path \"*/target/*\" ! -path \"*/.next/*\""
		find_cmd="$find_cmd ! -path \"*/.nuxt/*\" ! -path \"*/.cache/*\" ! -path \"*/.nx/*\""
		
		# Exclude specific important files
		find_cmd="$find_cmd ! -name \"Dockerfile\" ! -name \"dockerfile\" ! -name \"Dockerfile.*\""
		find_cmd="$find_cmd ! -name \"Makefile\" ! -name \"makefile\" ! -name \"GNUmakefile\""
		find_cmd="$find_cmd ! -name \"Jenkinsfile\" ! -name \"jenkinsfile\""
		find_cmd="$find_cmd ! -name \".env*\" ! -name \".npmrc\" ! -name \".gitignore\" ! -name \".gitattributes\""
		find_cmd="$find_cmd ! -name \"README*\" ! -name \"CHANGELOG*\" ! -name \"LICENSE*\" ! -name \"CONTRIBUTING*\""
		find_cmd="$find_cmd ! -name \"*.example\" ! -name \"*.sample\" ! -name \"*.template\""
		find_cmd="$find_cmd ! -name \"package.json\" ! -name \"package-lock.json\" ! -name \"yarn.lock\""
		find_cmd="$find_cmd ! -name \"tsconfig.json\" ! -name \"jest.config.*\" ! -name \"eslint.config.*\""
		find_cmd="$find_cmd ! -name \"tailwind.config.*\" ! -name \"postcss.config.*\" ! -name \"next.config.*\""
		find_cmd="$find_cmd ! -name \"vercel.json\" ! -name \"netlify.toml\" ! -name \"docker-compose.*\""
		find_cmd="$find_cmd ! -name \"*.lock\" ! -name \"*.lockb\""
		
		# Exclude Git hooks and project management files
		find_cmd="$find_cmd ! -name \".husky\" ! -path \"*/.husky/*\""
		find_cmd="$find_cmd ! -name \"CODEOWNERS\" ! -name \"codeowners\""
		find_cmd="$find_cmd ! -name \".dockerignore\" ! -name \"dockerignore\""
		find_cmd="$find_cmd ! -name \".stignore\" ! -name \"stignore\""
		find_cmd="$find_cmd ! -name \".nvmrc\" ! -name \"nvmrc\""
		find_cmd="$find_cmd ! -name \".nxignore\" ! -name \"nxignore\""
		find_cmd="$find_cmd ! -name \".babelrc\" ! -name \".babelrc.*\" ! -name \"babel.config.*\""
		
		# Exclude additional config files
		find_cmd="$find_cmd ! -name \".prettierrc*\" ! -name \"prettier.config.*\""
		find_cmd="$find_cmd ! -name \".editorconfig\" ! -name \"editorconfig\""
		find_cmd="$find_cmd ! -name \".commitlintrc*\" ! -name \"commitlint.config.*\""
		find_cmd="$find_cmd ! -name \".lintstagedrc*\" ! -name \"lint-staged.config.*\""
		find_cmd="$find_cmd ! -name \".eslintignore\" ! -name \".prettierignore\""
		find_cmd="$find_cmd ! -name \".gitmodules\" ! -name \".gitkeep\""
		find_cmd="$find_cmd ! -name \".dockerignore\" ! -name \"dockerignore\""
		find_cmd="$find_cmd ! -name \".npmignore\" ! -name \"npmignore\""
		find_cmd="$find_cmd ! -name \".yarnrc*\" ! -name \"yarn.config.*\""
		find_cmd="$find_cmd ! -name \".travis.yml\" ! -name \".github\" ! -path \"*/.github/*\""
		find_cmd="$find_cmd ! -name \".gitlab-ci.yml\" ! -name \"gitlab-ci.yml\""
		find_cmd="$find_cmd ! -name \".circleci\" ! -path \"*/.circleci/*\""
		find_cmd="$find_cmd ! -name \".vscode\" ! -path \"*/.vscode/*\""
		find_cmd="$find_cmd ! -name \".idea\" ! -path \"*/.idea/*\""
		
		# Add custom exclude patterns if provided
		if [ -n "$exclude_patterns" ]; then
			IFS=',' read -ra patterns <<< "$exclude_patterns"
			for pattern in "${patterns[@]}"; do
				find_cmd="$find_cmd ! -path \"*$pattern*\""
			done
		fi
		
		# Add custom include extensions if provided
		if [ -n "$include_extensions" ]; then
			find_cmd="$find_cmd \("
			IFS=',' read -ra extensions <<< "$include_extensions"
			for ext in "${extensions[@]}"; do
				find_cmd="$find_cmd -name \"*.$ext\" -o"
			done
			find_cmd="${find_cmd% -o}\)"
		fi
		
		echo "🔍 Search criteria:"
		echo "  📝 Excluding code files, static assets, configs, docs, and certificates"
		echo "  📁 Excluding common build/cache directories and important project files"
		if [ -n "$include_extensions" ]; then
			echo "  ✅ Including only: $include_extensions"
		fi
		if [ -n "$exclude_patterns" ]; then
			echo "  ❌ Excluding patterns: $exclude_patterns"
		fi
		if [ -n "$delete_above" ]; then
			echo "  🗑️  Will delete files larger than: $delete_above"
		fi
		if [ "$dry_run" = true ]; then
			echo "  🔍 DRY RUN MODE - No files will be deleted"
		fi
		echo ""
		
		# Execute find command and get file sizes
		echo "📊 Non-code files (sorted by size, largest first):"
		echo "=================================================="
		
		# Create temporary file to store results
		local temp_file=$(mktemp)
		
		# Use eval to execute the constructed find command
		eval "$find_cmd" 2>/dev/null | while read -r file; do
			if [ -f "$file" ]; then
				local size=$(du -h "$file" 2>/dev/null | cut -f1)
				local size_bytes=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null)
				if [ -n "$size_bytes" ]; then
					printf "%10s %s\n" "$size" "$file"
					
					# Check if file should be deleted
					if [ -n "$delete_above" ]; then
						# Convert delete_above to bytes for comparison
						local delete_threshold_bytes
						case "$delete_above" in
							*K|*k)
								delete_threshold_bytes=$(echo "$delete_above" | sed 's/[Kk]//' | awk '{print $1 * 1024}')
								;;
							*M|*m)
								delete_threshold_bytes=$(echo "$delete_above" | sed 's/[Mm]//' | awk '{print $1 * 1024 * 1024}')
								;;
							*G|*g)
								delete_threshold_bytes=$(echo "$delete_above" | sed 's/[Gg]//' | awk '{print $1 * 1024 * 1024 * 1024}')
								;;
							*)
								# Assume bytes if no unit
								delete_threshold_bytes="$delete_above"
								;;
						esac
						
						if [ "$size_bytes" -gt "$delete_threshold_bytes" ]; then
							echo "$file|$size_bytes" >> "$temp_file"
						fi
					fi
				fi
			fi
		done | sort -hr
		
		# Handle file deletion
		if [ -n "$delete_above" ] && [ -s "$temp_file" ]; then
			echo ""
			echo "🗑️  Files larger than $delete_above:"
			echo "=================================================="
			
			local delete_count=0
			local total_size_mb=0
			
			while IFS='|' read -r file size_bytes; do
				if [ -f "$file" ]; then
					local size_mb=$((size_bytes / 1024 / 1024))
					printf "  🗂️  %10s %s\n" "$(du -h "$file" 2>/dev/null | cut -f1)" "$file"
					delete_count=$((delete_count + 1))
					total_size_mb=$((total_size_mb + size_mb))
				fi
			done < "$temp_file"
			
			echo ""
			echo "📊 Deletion Summary:"
			echo "  📁 Files to delete: $delete_count"
			echo "  💾 Total size: ${total_size_mb}MB"
			echo ""
			
			if [ "$dry_run" = true ]; then
				echo "🔍 DRY RUN - No files were actually deleted"
				echo "💡 To actually delete these files, run without --dry-run"
			else
				echo "⚠️  This will permanently delete $delete_count files (${total_size_mb}MB)"
				echo -n "🤔 Are you sure you want to continue? (y/N): "
				read -r reply
				echo ""
				
				if [[ $reply =~ ^[Yy]$ ]]; then
					echo "🗑️  Deleting files..."
					local deleted_count=0
					local deleted_size=0
					
					while IFS='|' read -r file size_bytes; do
						if [ -f "$file" ]; then
							if rm "$file" 2>/dev/null; then
								deleted_count=$((deleted_count + 1))
								deleted_size=$((deleted_size + size_bytes))
								echo "  ✅ Deleted: $file"
							else
								echo "  ❌ Failed to delete: $file"
							fi
						fi
					done < "$temp_file"
					
					local deleted_size_mb=$((deleted_size / 1024 / 1024))
					echo ""
					echo "✅ Successfully deleted $deleted_count files (${deleted_size_mb}MB freed)"
				else
					echo "❌ Deletion cancelled"
				fi
			fi
		fi
		
		# Clean up temporary file
		rm -f "$temp_file"
		
		echo ""
		echo "💡 Tips:"
		echo "  • Use --include-extensions to focus on specific file types"
		echo "  • Use --exclude-patterns to exclude additional patterns"
		echo "  • Use --delete-above SIZE to delete large files (supports K, M, G units)"
		echo "  • Use --dry-run to preview deletions without actually deleting"
		echo "  • Examples:"
		echo "    - lfs . --include-extensions 'pdf,mp4,zip'"
		echo "    - lfs . --exclude-patterns '*.log,*.tmp'"
		echo "    - lfs . --delete-above 100M --dry-run"
		echo "    - lfs . --delete-above 1G"
  fi
}

# For local functions
[ -f '.functions.local' ] && source '.functions.local'
