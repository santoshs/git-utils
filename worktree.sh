# bash function to switch to a worktree of a git repository. Multiple
# repositories specified in `repolist` associative array.
#
# usage:
#   wt [pattern]
#
# If only one match found then directly move to that directory, else
# show all the matching repositories. If no pattern, everything is
# shown and can be searched using the fzf frontend.

function wt ()
{
    output=""
    filter=""
    declare -A repolist

    if [ $# -eq 1 ]; then
        filter="$1"
    fi

    repolist=([kernel]=$HOME/dev/repos/kernels/linux
              [ndctl]=$HOME/dev/repos/ndctl
              [skiboot]=$HOME/dev/repos/skiboot
              [bugalert]=$HOME/dev/gws/src/github.com/fossix/bugalert
              [kbuild]=$HOME/dev/gws/src/github.com/santoshs/kbuild)

    i=1
    for r in "${!repolist[@]}"; do
        pushd ${repolist[$r]} > /dev/null
        areas=(`git worktree list | cut -d' ' -f1`)
        for a in ${areas[@]}; do
            d=`basename $a`
            o=`/usr/bin/echo -e $i. $d [$r] $a`

            if [ -n "$filter" ]; then
                echo $d $r | grep "$filter" > /dev/null
                [ $? -ne 0 ] && continue
            fi

            output="$output""$o\n"
            ((i++))
        done
        popd > /dev/null
    done

    output=`echo $output | head -c -3` # remove the last newline
    dir=`echo -e $output | fzf --color=dark -1 -0 --with-nth=1..3 --reverse | tr -d '\n' | cut -f4 -d' '`
    [ -n "$dir" ] && pushd $dir > /dev/null
}
