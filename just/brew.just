# Add a package to Brewfile (e.g. just brew-add minio, just brew-add cask firefox)
add type="brew" name="":
    #!/usr/bin/env zsh
    if [[ -z "{{ name }}" ]]; then
        entry='brew "{{ type }}"'
    else
        entry='{{ type }} "{{ name }}"'
    fi
    if grep -qxF "$entry" ~/.Brewfile; then
        echo "Already in Brewfile: $entry"
    else
        echo "$entry" >> ~/.Brewfile
        chezmoi add ~/.Brewfile
        echo "Added: $entry"
    fi

# Remove a package from Brewfile (e.g. just brew-remove minio, just brew-remove cask firefox)
remove type="brew" name="":
    #!/usr/bin/env zsh
    if [[ -z "{{ name }}" ]]; then
        entry='brew "{{ type }}"'
    else
        entry='{{ type }} "{{ name }}"'
    fi
    if grep -qxF "$entry" ~/.Brewfile; then
        grep -vxF "$entry" ~/.Brewfile > ~/.Brewfile.tmp && mv ~/.Brewfile.tmp ~/.Brewfile
        chezmoi add ~/.Brewfile
        echo "Removed: $entry"
    else
        echo "Not found in Brewfile: $entry"
    fi

# Show diff between installed packages and Brewfile
diff:
    #!/usr/bin/env zsh
    echo "=== Missing (in Brewfile but not installed) ==="
    brew bundle check --global --verbose 2>&1 || true
    echo ""
    echo "=== Extra (installed but not in Brewfile) ==="
    brew bundle cleanup --global 2>&1 || true

# Install packages from Brewfile and remove extras
apply:
    brew bundle --global --cleanup

# Clean up extra packages
clean:
    brew bundle cleanup --global --force
