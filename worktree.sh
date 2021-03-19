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
              [BSD]=$HOME/dev/repos/kernels/freebsd-src
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
                if [ $? -ne 0 ]; then
                    continue
                fi
            fi

            output="$output""$o\n"
            ((i++))
        done
        popd > /dev/null
    done

    [ -z "$output" ] && return
    [ $i -eq 2 ] && pushd `echo -e $output | tr -d '\n' | cut -f4 -d' '` > /dev/null && return

    dir=`echo -e $output | fzf --with-nth=1..3 --reverse | cut -f4 -d' '`
    pushd $dir > /dev/null
}
