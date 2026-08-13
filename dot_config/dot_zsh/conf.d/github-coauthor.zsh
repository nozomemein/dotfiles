# Generate a Co-authored-by trailer from GitHub logins.
gh-coauthor() {
  emulate -L zsh

  local copy=0
  local usage="usage: gh-coauthor [-c|--copy] <github-login-or-profile-url> [...]"

  while (( $# > 0 )); do
    case "$1" in
      -c|--copy)
        copy=1
        shift
        ;;
      -h|--help)
        print -r -- "$usage"
        print -r -- "example: gh-coauthor octocat"
        return 0
        ;;
      --)
        shift
        break
        ;;
      -*)
        print -u2 -r -- "gh-coauthor: unknown option: $1"
        print -u2 -r -- "$usage"
        return 2
        ;;
      *)
        break
        ;;
    esac
  done

  if (( $# == 0 )); then
    print -u2 -r -- "$usage"
    return 2
  fi

  if ! command -v gh >/dev/null 2>&1; then
    print -u2 -r -- "gh-coauthor: gh command is required"
    return 127
  fi

  local raw login trailer
  local -a trailers
  trailers=()

  for raw in "$@"; do
    login="${raw#https://github.com/}"
    login="${login#http://github.com/}"
    login="${login#github.com/}"
    login="${login#@}"
    login="${login%%\?*}"
    login="${login%%#*}"
    login="${login%%/*}"
    login="${login%/}"

    if [[ -z "$login" ]]; then
      print -u2 -r -- "gh-coauthor: empty GitHub login: $raw"
      return 2
    fi

    trailer=$(
      gh api "users/${login}" --jq '
        def display_name:
          if (.name // "") == "" then .login else .name end;
        "Co-authored-by: \(display_name) <\(.id)+\(.login)@users.noreply.github.com>"
      '
    ) || {
      print -u2 -r -- "gh-coauthor: failed to fetch GitHub user: $login"
      return 1
    }

    trailers+=("$trailer")
  done

  print -r -- ${(F)trailers}

  if (( copy )); then
    if ! command -v pbcopy >/dev/null 2>&1; then
      print -u2 -r -- "gh-coauthor: pbcopy command is required for --copy"
      return 127
    fi
    print -r -- ${(F)trailers} | pbcopy
  fi
}
