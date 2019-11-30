cite about-plugin
about-plugin 'git helper functions'

function commiter() {
    about 'Add file, commit and push'
    group 'git'

    git add -f "$1";
    if [ "$2" == "" ]; then
        git commit -m"Updated $1";
    else
        git commit -m"$2";
    fi;
    $(git push -q >> /dev/null 2>&1) &
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
# are we in a git repo?
git rev-parse --is-inside-work-tree &>/dev/null

if [[ $? != 0 ]]; then
  echo "Not a git repository." 1>&2
  return 1
fi


# assume origin if not provided
# fallback to upstream if neither is present.
remote="origin"
if [ -n "$1" ]; then
  if [ "$1" == "issue" ]; then
    currentBranch=$(git symbolic-ref -q --short HEAD)
    regex='^issue'
    if [[ $currentBranch =~ $regex ]]; then
      issue=${currentBranch#*#}
    else
      echo "'git open issue' expect branch naming to be issues/#123" 1>&2
      return 1
    fi
  else
    remote="$1"
  fi
fi

remote_url="remote.${remote}.url"

giturl=$(git config --get "$remote_url")
if [ -z "$giturl" ]; then
  echo "$remote_url not set." 1>&2
  return 1
fi

# get current branch
if [ -z "$2" ]; then
  branch=$(git symbolic-ref -q --short HEAD)
else
  branch="$2"
fi

# Make # and % characters url friendly
#   github.com/paulirish/git-open/pull/24
branch=${branch//%/%25} && branch=${branch//#/%23}

# URL normalization
# GitHub gists
if grep -q gist.github <<<$giturl; then
  giturl=${giturl/git\@gist.github\.com\:/https://gist.github.com/}
  providerUrlDifference=tree

# GitHub
elif grep -q github <<<$giturl; then
  giturl=${giturl/git\@github\.com\:/https://github.com/}

  # handle SSH protocol (links like ssh://git@github.com/user/repo)
  giturl=${giturl/#ssh\:\/\/git\@github\.com\//https://github.com/}

  providerUrlDifference=tree

# Bitbucket
elif grep -q bitbucket <<<$giturl; then
  giturl=${giturl/git\@bitbucket\.org\:/https://bitbucket.org/}
  # handle SSH protocol (change ssh://https://bitbucket.org/user/repo to https://bitbucket.org/user/repo)
  giturl=${giturl/#ssh\:\/\/git\@/https://}

  rev="$(git rev-parse HEAD)"
  git_pwd="$(git rev-parse --show-prefix)"
  providerUrlDifference="src/${rev}/${git_pwd}"
  branch="?at=${branch}"

# Atlassian Bitbucket Server
elif grep -q "/scm/" <<<$giturl; then
  re='(.*)/scm/(.*)/(.*)\.git'
  if [[ $giturl =~ $re ]]; then
    giturl=${BASH_REMATCH[1]}/projects/${BASH_REMATCH[2]}/repos/${BASH_REMATCH[3]}
    providerUrlDifference=browse
    branch="?at=refs%2Fheads%2F${branch}"
  fi

# GitLab
else
  # custom GitLab
  gitlab_domain=$(git config --get gitopen.gitlab.domain)
  gitlab_port=$(git config --get gitopen.gitlab.port)
  if [ -n "$gitlab_domain" ]; then
    if grep -q "$gitlab_domain" <<<$giturl; then

      # Handle GitLab's default SSH notation (like git@gitlab.domain.com:user/repo)
      giturl=${giturl/git\@${gitlab_domain}\:/https://${gitlab_domain}/}

      # handle SSH protocol (links like ssh://git@gitlab.domain.com/user/repo)
      giturl=${giturl/#ssh\:\/\//https://}

      # remove git@ from the domain
      giturl=${giturl/git\@${gitlab_domain}/${gitlab_domain}/}

      # remove SSH port
      if [ -n "$gitlab_port" ]; then
        giturl=${giturl/\/:${gitlab_port}\///}
      fi
      providerUrlDifference=tree
    fi
    # hosted GitLab
  elif grep -q gitlab <<<$giturl; then
    giturl=${giturl/git\@gitlab\.com\:/https://gitlab.com/}
    providerUrlDifference=tree
  fi
fi
giturl=${giturl%\.git}

if [ -n "$issue" ]; then
  giturl="${giturl}/issues/${issue}"
elif [ -n "$branch" ]; then
  giturl="${giturl}/${providerUrlDifference}/${branch}"
fi

# simplify URL for master
giturl=${giturl/tree\/master/}

# get current open browser command
case $( uname -s ) in
  Darwin)  open=open;;
  MINGW*)  open=start;;
  CYGWIN*) open=cygstart;;
  MSYS*)   open="powershell.exe –NoProfile Start";;
  *)       open=${BROWSER:-xdg-open};;
esac

# open it in a browser
$open "$giturl" &> /dev/null
return $?
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
