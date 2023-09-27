git_push_new_empty_file() {
    filename=$1

    if [[ -z "$filename" ]]; then
        echo "Please specify a filename to create and push."
        return 1
    fi

    touch $filename
    git add $filename
    git commit -m "Add $filename"
    git push
}
