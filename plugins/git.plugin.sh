cite about-plugin
about-plugin 'git helper functions'

#function commiter() {
#    about 'Add file, commit and push'
#    group 'git'

#    git add -f "$1";
#    if [ "$2" == "" ]; then
#        git commit -m"Updated $1";
#    else
#        git commit -m"$2";
#    fi;
#    $(git push -q >> /dev/null 2>&1) &
#    }

createpr() {
    # Push changes and create Pull Request on GitHub
    REMOTE="devel";
    if ! git show-ref --quiet refs/heads/devel; then REMOTE="master"; fi
    BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    git push -u origin "${BRANCH}" || true;
    if [ -f /usr/local/bin/hub ]; then
        /usr/local/bin/hub pull-request -b "${REMOTE}" -h "${BRANCH}" --no-edit || true
    else
        echo "Failed to create PR, create it Manually"
        echo "If you would like to continue install hub: https://github.com/github/hub/"
    fi
}

function committer() {
    about 'Add file, commit and push'
    group 'git'
    # Add file(s), commit and push
    FILE=$(git status | $(which grep) "modified:" | cut -f2 -d ":" | xargs)
    for file in $FILE; do git add -f "$file"; done
    if [ "$1" == "" ]; then
        # SignOff by username & email, SignOff with PGP and ignore hooks
        git commit -m"Updated $FILE";
    else
        git commit -m"$2";
    fi;
   # read -t 5 -p "Hit ENTER if you want to push else wait 5 seconds"
   # [ $? -eq 0 ] &&
     bash -c "git push --no-verify -q &"
}

function git_remote {
  about 'adds remote $GIT_HOSTING:$1 to current repo'
  group 'git'

  echo "Running: git remote add origin ${GIT_HOSTING}:$1.git"
  git remote add origin $GIT_HOSTING:$1.git
}

function git_first_push {
  about 'push into origin refs/heads/master'
  group 'git'

  echo "Running: git push origin master:refs/heads/master"
  git push origin master:refs/heads/master
}

function git_pub() {
  about 'publishes current branch to remote origin'
  group 'git'
  BRANCH=$(git rev-parse --abbrev-ref HEAD)

  echo "Publishing ${BRANCH} to remote origin"
  git push -u origin $BRANCH
}

function git_revert() {
  about 'applies changes to HEAD that revert all changes after this commit'
  group 'git'

  git reset $1
  git reset --soft HEAD@{1}
  git commit -m "Revert to ${1}"
  git reset --hard
}

function git_rollback() {
  about 'resets the current HEAD to this commit'
  group 'git'

  function is_clean() {
    if [[ $(git diff --shortstat 2> /dev/null | tail -n1) != "" ]]; then
      echo "Your branch is dirty, please commit your changes"
      kill -INT $$
    fi
  }

  function commit_exists() {
    git rev-list --quiet $1
    status=$?
    if [ $status -ne 0 ]; then
      echo "Commit ${1} does not exist"
      kill -INT $$
    fi
  }

  function keep_changes() {
    while true
    do
      read -p "Do you want to keep all changes from rolled back revisions in your working tree? [Y/N]" RESP
      case $RESP
      in
      [yY])
        echo "Rolling back to commit ${1} with unstaged changes"
        git reset $1
        break
        ;;
      [nN])
        echo "Rolling back to commit ${1} with a clean working tree"
        git reset --hard $1
        break
        ;;
      *)
        echo "Please enter Y or N"
      esac
    done
  }

  if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
    is_clean
    commit_exists $1

    while true
    do
      read -p "WARNING: This will change your history and move the current HEAD back to commit ${1}, continue? [Y/N]" RESP
      case $RESP
        in
        [yY])
          keep_changes $1
          break
          ;;
        [nN])
          break
          ;;
        *)
          echo "Please enter Y or N"
      esac
    done
  else
    echo "you're currently not in a git repository"
  fi
}

function git_remove_missing_files() {
  about "git rm's missing files"
  group 'git'

  git ls-files -d -z | xargs -0 git update-index --remove
}

# Adds files to git's exclude file (same as .gitignore)
function local-ignore() {
  about 'adds file or path to git exclude file'
  param '1: file or path fragment to ignore'
  group 'git'
  echo "$1" >> .git/info/exclude
}

# get a quick overview for your git repo
function git_info() {
    about 'overview for your git repo'
    group 'git'

    if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
        # print informations
        echo "git repo overview"
        echo "-----------------"
        echo

        # print all remotes and thier details
        for remote in $(git remote show); do
            echo $remote:
            git remote show $remote
            echo
        done

        # print status of working repo
        echo "status:"
        if [ -n "$(git status -s 2> /dev/null)" ]; then
            git status -s
        else
            echo "working directory is clean"
        fi

        # print at least 5 last log entries
        echo
        echo "log:"
        git log -5 --oneline
        echo

    else
        echo "you're currently not in a git repository"

    fi
}

function git_stats {
    about 'display stats per author'
    group 'git'

# awesome work from https://github.com/esc/git-stats
# including some modifications

if [ -n "$(git symbolic-ref HEAD 2> /dev/null)" ]; then
    echo "Number of commits per author:"
    git --no-pager shortlog -sn --all
    AUTHORS=$( git shortlog -sn --all | cut -f2 | cut -f1 -d' ')
    LOGOPTS=""
    if [ "$1" == '-w' ]; then
        LOGOPTS="$LOGOPTS -w"
        shift
    fi
    if [ "$1" == '-M' ]; then
        LOGOPTS="$LOGOPTS -M"
        shift
    fi
    if [ "$1" == '-C' ]; then
        LOGOPTS="$LOGOPTS -C --find-copies-harder"
        shift
    fi
    for a in $AUTHORS
    do
        echo '-------------------'
        echo "Statistics for: $a"
        echo -n "Number of files changed: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f3 | sort -iu | wc -l
        echo -n "Number of lines added: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f1 | awk '{s+=$1} END {print s}'
        echo -n "Number of lines deleted: "
        git log $LOGOPTS --all --numstat --format="%n" --author=$a | cut -f2 | awk '{s+=$1} END {print s}'
        echo -n "Number of merges: "
        git log $LOGOPTS --all --merges --author=$a | grep -c '^commit'
    done
else
    echo "you're currently not in a git repository"
fi
}

function gittowork() {
  about 'Places the latest .gitignore file for a given project type in the current directory, or concatenates onto an existing .gitignore'
  group 'git'
  param '1: the language/type of the project, used for determining the contents of the .gitignore file'
  example '$ gittowork java'

  result=$(curl -L "https://www.gitignore.io/api/$1" 2>/dev/null)

  if [[ $result =~ ERROR ]]; then
    echo "Query '$1' has no match. See a list of possible queries with 'gittowork list'"
  elif [[ $1 = list ]]; then
    echo "$result"
  else
    if [[ -f .gitignore ]]; then
      result=`echo "$result" | grep -v "# Created by http://www.gitignore.io"`
      echo ".gitignore already exists, appending..."
      echo "$result" >> .gitignore
    else
      echo "$result" > .gitignore
    fi
  fi
}

function gitignore-reload() {
  about 'Empties the git cache, and readds all files not blacklisted by .gitignore'
  group 'git'
  example '$ gitignore-reload'

    # The .gitignore file should not be reloaded if there are uncommited changes.
  # Firstly, require a clean work tree. The function require_clean_work_tree() 
  # was stolen with love from https://www.spinics.net/lists/git/msg142043.html

  # Begin require_clean_work_tree()

  # Update the index
  git update-index -q --ignore-submodules --refresh
  err=0

  # Disallow unstaged changes in the working tree
  if ! git diff-files --quiet --ignore-submodules --
  then
    echo >&2 "ERROR: Cannot reload .gitignore: Your index contains unstaged changes."
    git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
    err=1
  fi

  # Disallow uncommited changes in the index
  if ! git diff-index --cached --quiet HEAD --ignore-submodules
  then
    echo >&2 "ERROR: Cannot reload .gitignore: Your index contains uncommited changes."
    git diff-index --cached --name-status -r --ignore-submodules HEAD -- >&2
    err=1
  fi

  # Prompt user to commit or stash changes and exit
  if [ $err = 1 ]
  then
    echo >&2 "Please commit or stash them."
  fi

  # End require_clean_work_tree()

  # If we're here, then there are no uncommited or unstaged changes dangling around.
  # Proceed to reload .gitignore
  if [ $err = 0 ]; then
    # Remove all cached files
    git rm -r --cached .

    # Re-add everything. The changed .gitignore will be picked up here and will exclude the files
    # now blacklisted by .gitignore
    echo >&2 "Running git add ."
    git add .
    echo >&2 "Files readded. Commit your new changes now."
  fi
}



function git-open(){
  about 'Open the GitHub page or website for a repository in your browser.'
  group 'git'
  example '$ git-open'

# Figure out github repo base URL
base_url=$(git config --get remote.origin.url)
base_url=${base_url%\.git} # remove .git from end of string

# Fix git@github.com: URLs
base_url=${base_url//git@github\.com:/https:\/\/github\.com\/}

# Fix git://github.com URLS
base_url=${base_url//git:\/\/github\.com/https:\/\/github\.com\/}

# Fix git@bitbucket.org: URLs
base_url=${base_url//git@bitbucket.org:/https:\/\/bitbucket\.org\/}

# Fix git@gitlab.com: URLs
base_url=${base_url//git@gitlab\.com:/https:\/\/gitlab\.com\/}

# Validate that this folder is a git folder
git branch 2>/dev/null 1>&2
if [ $? -ne 0 ]; then
  echo Not a git repo!
  return $?
fi

# Find current directory relative to .git parent
full_path=$(pwd)
git_base_path=$(cd ./$(git rev-parse --show-cdup); pwd)
relative_path=${full_path#$git_base_path} # remove leading git_base_path from working directory

# If filename argument is present, append it
if [ "$1" ]; then
  relative_path="$relative_path/$1"
fi

# Figure out current git branch
# git_where=$(command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
git_where=$(command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null

# Remove cruft from branchname
branch="${git_where#refs\/heads\/}"
branch="${branch#tags\/}"
branch="${branch%^0}"

[[ $base_url == *bitbucket* ]] && tree="src" || tree="tree"
url="$base_url/$tree/$branch$relative_path"

echo "$url"

# Check for various OS openers. Quit as soon as we find one that works.
# Don't assume this will work, provide a helpful diagnostic if it fails.
for opener in xdg-open open cygstart "start"; {
  if command -v $opener; then
    open=$opener;
    break;
  fi
}

$open "$url" || (echo "Unrecognized OS: Expected to find one of the following launch commands: xdg-open, open, cygstart, start" && return 1);
}




function git-switch(){
  about 'Switch between branches in the current repository'
  group 'git'
  example '$ git-switch'

colorize_remotes() {
    perl -pe 's|^(remotes/.*)$|\033[36m$1\033[m|g'
}

remove_color() {
    perl -pe 's/\e\[?.*?[\@-~]//g'
}

unique() {
    if [[ -n $1 ]] && [[ -f $1 ]]; then
        cat "$1"
    else
        cat <&0
    fi | awk '!a[$0]++' 2>/dev/null
}

reverse() {
    if [[ -n $1 ]] && [[ -f $1 ]]; then
        cat "$1"
    else
        cat <&0
    fi | awk '
        {
            line[NR] = $0
        }
        
        END {
            for (i = NR; i > 0; i--) {
                print line[i]
            }
        }' 2>/dev/null
}

get_filter() {
    local x candidates

    if [[ -z $1 ]]; then
        return 1
    fi

    # candidates should be list like "a:b:c" concatenated by a colon
    candidates="$1:"

    while [[ -n $candidates ]]
    do
        # the first remaining entry
        x=${candidates%%:*}
        # reset candidates
        candidates=${candidates#*:}

        if type "${x%% *}" &>/dev/null; then
            echo "$x"
            return 0
        else
            continue
        fi
    done

    return 1
}

# If you are not in a git repository, the script ends here
git_root_dir="$(git rev-parse --show-toplevel)"
current_branch="$(git rev-parse --abbrev-ref HEAD)"

GIT_FILTER=${GIT_FILTER:-fzy:fzf-tmux:fzf:peco}

filter="$(get_filter "$GIT_FILTER")"
if [[ -z $filter ]]; then
    echo "No available filter in \$GIT_FILTER" >&2
    return 1
fi

logfile="$git_root_dir/.git/logs/switch.log"
post_script="$git_root_dir/.git/hooks/post-checkout"

if [[ ! -x $post_script ]]; then
    cat <<HOOK >|"$post_script"
git rev-parse --abbrev-ref HEAD >>$logfile
HOOK
    chmod 755 "$post_script"
fi

if [[ ! -f $logfile ]]; then
    touch "$logfile"
fi

candidates="$(
{
    cat "$logfile" \
        | reverse \
        | unique
    git branch -a --no-color \
        | cut -c3-
} \
    | unique \
    | colorize_remotes \
    | grep -v "HEAD" \
    | grep -v "$current_branch" || true
    # ^ if the candidates is empty, grep return false
)"

if [[ -z $candidates ]]; then
    echo "No available branches to be checkouted" >&2
    return 1
fi

selected_branch="$(echo "$candidates" | $filter | remove_color)"
if [[ -z $selected_branch ]]; then
    return 0
fi

git checkout "$selected_branch"
return $?
}



function git-ls(){
  about 'List File status in the current git'
  group 'git'
  example '$ git-ls'
# Colors
green='\e[0;32m%-3s\e[0m'
red='\e[0;31m%-3s\e[0m'
blue='\e[0;34m%-3s\e[0m'
purple='\e[0;35m%-3s\e[0m'
nc='\e[0m%-3s' # no color

# Make sure this is a git repo
git status --porcelain &> /dev/null
if [ $? -ne 0 ]
then
	echo "Not a Git repository!"
	return 
fi

if [[ `which exa` ]]
	then
		lsout=`exa -lh --git`
	else
		lsout=`ls -lh`
	fi
IFS=$'\n' lslines=($lsout)

# ls -ls every file, shimming a git status for the working tree in front
i=1
for file in *
do
	gitstatus=`git status --porcelain $file`
	if [ -z "$gitstatus" ]
	then
		stat="-"
	else
		stat=${gitstatus:1:1} # grab the second char, which is the working tree status
	fi

	case "$stat" in
		"?")
			printf $nc $stat
			;;
		"M")
			printf $red $stat
			;;
		"A")
			printf $blue $stat
			;;
		"D")
			printf $purple $stat
			;;
		"-")
			printf $green "OK"
			;;
	esac

	echo ${lslines[i]}
	((i++))

done
}


git-pull-all() {
    # Pull all remote refs from repos in the current dir
    CUR_DIR=$(pwd)
    find -type d -execdir test -d {}/.git \; -print -prune | sort | while read -r DIR;
        do builtin cd $DIR &>/dev/null;
        (git fetch -pa && git pull --allow-unrelated-histories \
            origin $(git symbolic-ref --short HEAD)) &>/dev/null &disown;

        STATUS=$(git status 2>/dev/null |
        awk -v r=${RED} -v y=${YELLOW} -v g=${GREEN} -v b=${BLUE} -v n=${NC} '
        /^On branch / {printf(y$3n)}
        /^Changes not staged / {printf(g"|?Changes unstaged!"n)}
        /^Changes to be committed/ {printf(b"|*Uncommitted changes!"n)}
        /^Your branch is ahead of/ {printf(r"|^Push changes!"n)}
        ')
        LAST_UPDATE="${STATUS} | ${LIGHTCYAN}[$(git show -1 --stat | grep ^Date | cut -f4- -d' ')]${NC}"

        printf "Repo: \t${DIR} \t| ${LAST_UPDATE}\n";
        builtin cd - &>/dev/null;
    done
    builtin cd ${CUR_DIR} &>/dev/null;
}
