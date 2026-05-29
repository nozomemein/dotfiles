# git worktree picker: fzf で選択 → そのワークツリーへ cd
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
