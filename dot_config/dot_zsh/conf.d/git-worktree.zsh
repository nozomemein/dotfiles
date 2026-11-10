# git worktree picker: pick with fzf, then cd into the worktree
gwcd() {
  local sel
  sel=$(git worktree list --porcelain 2>/dev/null | awk '
    /^worktree / { path = substr($0, 10); next }
    /^branch refs\/heads\// { branch = substr($0, 19); printf "%s\t%s\n", branch, path; next }
    /^detached$/ { printf "(detached)\t%s\n", path }
  ' | fzf --with-nth=1 --delimiter='\t' --preview='echo {}' --preview-window=down:1:wrap)
  [[ -z "$sel" ]] && return
  cd "${sel#*$'\t'}"
}

# Pick another worktree's branch and open it in the main worktree.
gwco() {
  emulate -L zsh

  local entry main_worktree worktree_path branch sel
  local -a records candidates
  records=("${(@0)$(git worktree list --porcelain -z)}") || return

  for entry in "${records[@]}"; do
    case "$entry" in
      'worktree '*)
        worktree_path=${entry#worktree }
        [[ -n "$main_worktree" ]] || main_worktree=$worktree_path
        ;;
      'branch refs/heads/'*)
        [[ "$worktree_path" == "$main_worktree" ]] && continue
        branch=${entry#branch refs/heads/}
        candidates+=("$branch"$'\t'"$worktree_path")
        ;;
    esac
  done

  if (( ${#candidates} == 0 )); then
    print -u2 -r -- 'gwco: no branches in other worktrees'
    return 1
  fi

  sel=$(printf '%s\0' "${candidates[@]}" | fzf --read0 --print0 \
    --with-nth=1 --delimiter='\t' --query="$*" \
    --preview='echo {}' --preview-window=down:1:wrap) || return
  [[ -n "$sel" ]] || return
  branch=${sel%%$'\t'*}

  # Keep the source worktree attached so ongoing work there can continue.
  git -C "$main_worktree" switch --ignore-other-worktrees -- "$branch" || return
  cd -- "$main_worktree"
}
