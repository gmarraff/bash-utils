alias gitrsync="rsync -av --filter=':- .gitignore' --exclude='.git/'"

function localgitdiff() {
    colordiff -burN $@
}
