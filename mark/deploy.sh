function mark_deploy_file_print_usage {
    echo "
USAGE
mark_deploy_file <RELATIVE PATH TO YOUR FILE>

Environment variables that must be set set:
    CONFLUENCE_USER     -> Username of your conflunce user
    CONFLUENCE_TOKEN    -> API Token of your confluence user
    CONFLUENCE_HOME     -> URL of the confluence entrypoint
"
}

function mark_deploy_file {
    RELPATH=$1
    if [[ -z "$RELPATH" ]]; then
        echo "Please provide the file you want to process with mark."
        mark_deploy_file_print_usage
        return 1
    fi

    if [[ -z "$CONFLUENCE_USER" || -z "$CONFLUENCE_TOKEN" || -z "$CONFLUENCE_HOME" ]]; then
        echo "Please check that all the required environment variables are set."
        mark_deploy_file_print_usage
        return 1
    fi

    docker run --rm \
        --pull always \
        -v $PWD:/docs \
        kovetskiy/mark:latest \
            mark \
            -u $CONFLUENCE_USER  \
            -p $CONFLUENCE_TOKEN \
            -b $CONFLUENCE_HOME \
            -f $RELPATH

}
