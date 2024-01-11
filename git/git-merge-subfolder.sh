#!/bin/bash

git-merge-repo-in-subfolder() {
    SOURCE_REPO_PATH=$1
    SOURCE_BRANCH=$2
    DEST_REPO_PATH=$3
    DEST_DIR=$4
    DEST_BRANCH=$5

    if [[ "$SOURCE_REPO_PATH" == "" || "$SOURCE_BRANCH" == "" || "$DEST_REPO_PATH" == "" || "$DEST_DIR" == "" || "$DEST_BRANCH" == "" ]]; then
        echo -e "ERROR"
        echo "Missing Parameters."
        echo -e "\n\nDESCRIPTION"
        echo "Merge a SOURCE repository and its history in a subfolder of DEST repository at the specified source branch"
        echo -e "\n\nUSAGE"
        echo "git-merge-repo-in-subfolder <SOURCE_REPO_PATH> <SOURCE_BRANCH> <DEST_REPO_PATH> <DEST_DIR> <DEST_BRANCH>"
        echo ""
        echo -e "SOURCE_REPO_PATH\t Pippo"
        return 1
    fi

    cd $SOURCE_REPO_PATH
    git pull
    git checkout $SOURCE_BRANCH

    cd $DEST_REPO_PATH
    git checkout main
    git pull
    git checkout -b $DEST_BRANCH
    git remote add -f tmpremote $SOURCE_REPO_PATH
    git merge -s ours --no-commit tmpremote/$SOURCE_BRANCH --allow-unrelated-histories
    git read-tree --prefix=$DEST_DIR -u tmpremote/$SOURCE_BRANCH:
    git remote remove tmpremote
    git commit
}

git-merge-subfolder-in-subfolder(){
    SOURCE_REPO_PATH=$1
    SOURCE_DIR=$2
    SOURCE_BRANCH=$3
    DEST_REPO_PATH=$4
    DEST_DIR=$5
    DEST_BRANCH=$6

    cwd=$PWD

    if [[ "$SOURCE_REPO_PATH" == "" || "$SOURCE_DIR" == "" || "$SOURCE_BRANCH" == "" || "$DEST_REPO_PATH" == "" || "$DEST_DIR" == "" || "$DEST_BRANCH" == "" ]]; then
        echo -e "ERROR"
        echo "Missing Parameters."
        echo -e "\n\nDESCRIPTION"
        echo "Merge a folder of SOURCE repository and its history in a subfolder of DEST repository at the specified source branch"
        echo -e "\n\nUSAGE"
        echo "git-merge-subfolder-in-subfolder <SOURCE_REPO_PATH> <SOURCE_DIR> <SOURCE_BRANCH> <DEST_REPO_PATH> <DEST_DIR> <DEST_BRANCH>"
        echo ""
        echo -e "SOURCE_REPO_PATH\t Pippo"
        return 1
    fi

    cd $SOURCE_REPO_PATH
    git pull
    git checkout $SOURCE_BRANCH
    git subtree split --prefix=$SOURCE_DIR -b tmpbranch

    git-merge-repo-in-subfolder $SOURCE_REPO_PATH tmpbranch $DEST_REPO_PATH $DEST_DIR $DEST_BRANCH

    cd $SOURCE_REPO_PATH
    git branch -D tmpbranch

    cd $DEST_REPO_PATH
}
