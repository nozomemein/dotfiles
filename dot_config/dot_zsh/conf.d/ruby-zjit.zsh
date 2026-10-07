# Build Ruby benchmark binaries with ZJIT stats. Run ruby-zjit-install --help for usage.
# A subshell isolates directory changes, helper functions, and cleanup traps.
ruby-zjit-install() (
  emulate -L zsh
  setopt NO_UNSET PIPE_FAIL

  local source_dir="$HOME/dev/ruby"
  local prefix=""
  local master_prefix="$HOME/.rubies/ruby-zjit-master"
  local jobs=""
  local dry_run=false
  local current_only=false
  local branch revision master_revision brew_bin openssl_prefix readline_prefix libyaml_prefix opt_dir
  local master_source temp_root temp_dir=""

  usage() {
    command cat <<'EOF'
Usage: ruby-zjit-install [options]

Configure, build, and install local master and the current checkout with ZJIT stats.
When the current branch is master, build it only once.
Branches are not fetched, updated, or switched. The current checkout includes uncommitted changes.
Master uses a temporary worktree and is rebuilt from scratch each time.
Install directories are reused; slashes in branch names become hyphens.

Options:
  --source DIR    Ruby source directory (default: ~/dev/ruby)
  --prefix DIR    Current checkout's install directory (default: ~/.rubies/ruby-<branch>)
                 On master, default to ~/.rubies/ruby-zjit-master
  --master-prefix DIR
                 Master's install directory (default: ~/.rubies/ruby-zjit-master)
  --current-only Build only the current checkout
  -j, --jobs N    Parallel build jobs (default: number of CPUs)
  --dry-run       Print commands without building or installing
  -h, --help      Show this help

Examples:
  ruby-zjit-install
  ruby-zjit-install --prefix "$HOME/.rubies/ruby-zjit-basicobject-neq-hook"
  ruby-zjit-install --master-prefix "$HOME/.rubies/ruby-zjit-master-comparison"
  ruby-zjit-install --source "$HOME/dev/ruby-master" --jobs 4
  ruby-zjit-install --current-only
  ruby-zjit-install --dry-run
EOF
  }

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --source|--prefix|--master-prefix|-j|--jobs)
        if [[ $# -lt 2 || -z "$2" ]]; then
          printf 'Missing value for %s\n' "$1" >&2
          exit 1
        fi
        case "$1" in
          --source) source_dir="$2" ;;
          --prefix) prefix="$2" ;;
          --master-prefix) master_prefix="$2" ;;
          -j|--jobs) jobs="$2" ;;
        esac
        shift 2
        ;;
      --dry-run)
        dry_run=true
        shift
        ;;
      --current-only)
        current_only=true
        shift
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        printf 'Unknown option: %s\n' "$1" >&2
        usage >&2
        exit 1
        ;;
    esac
  done

  if [[ ! -f "$source_dir/ruby.c" || ! -f "$source_dir/configure.ac" || ! -x "$source_dir/autogen.sh" ]]; then
    printf 'Not a Ruby source directory: %s\n' "$source_dir" >&2
    exit 1
  fi
  source_dir="$(cd "$source_dir" && pwd -P)" || exit
  branch="$(git -C "$source_dir" symbolic-ref --quiet --short HEAD || git -C "$source_dir" rev-parse --short HEAD)" || exit
  revision="$(git -C "$source_dir" describe --always --dirty)" || exit
  if [[ -z "$prefix" ]]; then
    if [[ "$branch" == master ]]; then
      prefix="$HOME/.rubies/ruby-zjit-master"
    else
      prefix="$HOME/.rubies/ruby-${branch//\//-}"
    fi
  fi
  case "$prefix" in
    /*) ;;
    *) prefix="$PWD/$prefix" ;;
  esac
  case "$master_prefix" in
    /*) ;;
    *) master_prefix="$PWD/$master_prefix" ;;
  esac
  if [[ "$branch" == master ]]; then
    current_only=true
  fi
  if [[ "$current_only" == false ]]; then
    master_revision="$(git -C "$source_dir" rev-parse --verify 'refs/heads/master^{commit}')" || exit
    if [[ "${prefix%/}" == "${master_prefix%/}" ]]; then
      printf 'Master and current checkout need separate install directories.\n' >&2
      exit 1
    fi
  fi

  if [[ -z "$jobs" ]]; then
    jobs="$(sysctl -n hw.ncpu)" || exit
  fi
  case "$jobs" in
    ''|*[!0-9]*) printf 'Jobs must be a positive integer: %s\n' "$jobs" >&2; exit 1 ;;
  esac
  if [[ "$jobs" != *[1-9]* ]]; then
    printf 'Jobs must be a positive integer: %s\n' "$jobs" >&2
    exit 1
  fi

  brew_bin=brew
  # Prefer native libraries when both Intel and Apple Silicon Homebrew are installed.
  if [[ "$(uname -m)" == arm64 && -x /opt/homebrew/bin/brew ]]; then
    brew_bin=/opt/homebrew/bin/brew
  fi
  openssl_prefix="$("$brew_bin" --prefix openssl@3)" || exit
  readline_prefix="$("$brew_bin" --prefix readline)" || exit
  libyaml_prefix="$("$brew_bin" --prefix libyaml)" || exit
  opt_dir="$openssl_prefix:$readline_prefix:$libyaml_prefix"

  run() {
    printf '+'
    printf ' %q' "$@"
    printf '\n'
    if [[ "$dry_run" == false ]]; then
      "$@"
    fi
  }

  build_ruby() {
    local ruby_source="$1"
    local ruby_prefix="$2"
    local ruby_revision="$3"
    local build_dir="$ruby_source/build"
    printf '\nSource: %s (%s)\nBuild: %s\nInstall: %s\n' "$ruby_source" "$ruby_revision" "$build_dir" "$ruby_prefix"
    printf '+ cd %q\n' "$ruby_source"
    if [[ "$dry_run" == false ]]; then
      cd "$ruby_source" || return
    fi
    # Branch switches can leave a configure generated from older configure.ac.
    run ./autogen.sh || return
    run mkdir -p "$build_dir" || return
    printf '+ cd %q\n' "$build_dir"
    if [[ "$dry_run" == false ]]; then
      cd "$build_dir" || return
    fi
    run "$ruby_source/configure" \
      --enable-zjit=stats \
      "--prefix=$ruby_prefix" \
      --disable-install-doc \
      "--with-opt-dir=$opt_dir" || return
    run make -j "$jobs" all || return
    run make install || return
    run "$ruby_prefix/bin/ruby" --zjit --version
  }

  cleanup() {
    local exit_code="$1"
    trap - EXIT INT TERM
    if [[ -n "$temp_dir" ]]; then
      # This worktree contains only this invocation's sources and build artifacts.
      if [[ -e "$temp_dir/master/.git" ]]; then
        if ! git -C "$source_dir" worktree remove --force "$temp_dir/master"; then
          printf 'Could not remove temporary worktree: %s\n' "$temp_dir/master" >&2
          exit 1
        fi
      fi
      rmdir "$temp_dir" || exit 1
      temp_dir=""
    fi
    exit "$exit_code"
  }

  if [[ "$current_only" == false ]]; then
    if [[ "$dry_run" == true ]]; then
      master_source="${TMPDIR:-/tmp}"
      master_source="${master_source%/}/ruby-zjit-install.<temporary>/master"
    else
      temp_root="${TMPDIR:-/tmp}"
      temp_dir="$(mktemp -d "${temp_root%/}/ruby-zjit-install.XXXXXX")" || exit
      trap 'cleanup $?' EXIT
      trap 'cleanup 130' INT
      trap 'cleanup 143' TERM
      master_source="$temp_dir/master"
    fi
    # A separate worktree keeps the current checkout and its uncommitted changes intact.
    run git -C "$source_dir" worktree add --detach "$master_source" "$master_revision" || exit
    build_ruby "$master_source" "$master_prefix" "$master_revision" || exit
  fi
  build_ruby "$source_dir" "$prefix" "$revision" || exit
)
