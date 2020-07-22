#!/bin/bash

# Based on https://gist.github.com/douglas/1287372
# But with a couple of changes

# store the current dir
CUR_DIR=$(pwd)

# Let the person running the script know what's going on.
echo "Pulling in latest changes for all repositories..."

# Find all git repositories and update it to the master latest revision
for i in $(find . -name ".git" | cut -c 3-); do
    echo "";
    echo $i;

    # We have to go to the .git parent directory to call the pull command
    cd "$i";
    cd ..;

    # finally pull
    # This is the only thing I changed
    # I have repos where I don't edit in the master branch
    #git pull origin master;
    git pull;

    # lets get back to the CUR_DIR
    cd $CUR_DIR
done

echo "Complete!"