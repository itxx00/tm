#!/bin/bash
bindir=/usr/local/bin
tmdir=$HOME/.tm
tmconf=$tmdir/tmux.conf
cmd=/usr/bin/tmux
session=${1:-itxx}
cwd=$(cd $(dirname $0) && pwd)

install_tm() {
    [ -d $bindir ] || mkdir -p $bindir
    [ -d $tmdir ] || mkdir -p $tmdir
    source /etc/os-release 2>/dev/null
    if [[ ${VERSION_ID:0:1} -le 7 ]]; then
        osver=el7
        [ -f $cmd ] || /bin/cp -f $cwd/pkgs/tmux.${osver}.$(uname -i) $cmd
    else
        [ -f $cmd ] || yum -y install tmux
    fi
    echo "Installing tm to $bindir"
    /bin/cp -f $cwd/tm $bindir/tm
    [ -f $tmconf ] && mv $tmconf{,.bk-$(date '+%Y%m%d%H%M%S')}
    /bin/cp -f $cwd/conf/tmux.conf $tmconf
    [ -f $HOME/.vimrc ] || {
        echo "Updateing $HOME/.vimrc"
        /bin/cp -f $cwd/conf/vimrc $HOME/.vimrc
    }
    [ -f $HOME/.bashrc ] || {
        echo "Updateing $HOME/.bashrc"
        /bin/cp -f $cwd/conf/bashrc $HOME/.bashrc
    }
    [[ -n "$(tail -c1 $HOME/.bashrc)" ]] && echo >>$HOME/.bashrc
    grep -q 'vim' $HOME/.bashrc || echo "alias vi='vim'" >>$HOME/.bashrc
}

cpustat() {
    local i=0
    local j
    local d
    for j in $(grep -w cpu /proc/stat); do
        d[$i]=$j
        i=$[$i+1]
    done
    # current idle and total cpu time
    cidle=${d[4]}
    ctotal=$(awk "BEGIN {print ${d[1]}+${d[2]}+${d[3]}+${d[4]}+${d[5]}+${d[6]}+${d[7]}+${d[8]}}")
    [ -f /tmp/cputime ] && read pidle ptotal < /tmp/cputime
    echo "$cidle $ctotal" > /tmp/cputime
    if [ -n "$pidle" ]; then
        stat=$(awk "BEGIN {printf \"%.2f\"\"%\", (100-(100*(($cidle-$pidle)/($ctotal-$ptotal)))) }")
    else
        stat=0
    fi
    echo $stat
}

memstat() {
    total=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
    free=$(awk '/MemFree/ {print $2}' /proc/meminfo)
    awk "BEGIN {printf \"%.2f\"\"%\", 100*($total-$free)/$total}"
}

sysinfo() {
    cpuPercent=$(cpustat)
    memPercent=$(memstat)
    uptime=$(uptime|awk '{print $1" "$2"_"$3"_"$4}')
    loadAvg=$(awk '{print $1","$2","$3}' /proc/loadavg)
    echo "$uptime cpu:$cpuPercent, mem:$memPercent loadAvg:$loadAvg"
}

if [[ $1 = install ]]; then
    [ -x $cmd ] || {
        echo "install tmux ..."
        install_tm
    }
    [ -x $bindir/tm ] || {
        echo "install tm ..."
        install_tm
    }

    [ -x $cmd ] || {
        echo "install tmux failed."
        exit 1
    }
    echo "installed"
    exit
fi
if [[ $1 = sysinfo ]]; then
    sysinfo
    exit
fi
$cmd -f $tmconf has -t $session || {
    $cmd -f $tmconf new -d -n bash1 -s $session "bash"
    $cmd -f $tmconf neww -n bash2 -t $session "bash"
    $cmd -f $tmconf selectw -t $session:1
}

$cmd -f $tmconf att -t $session

exit 0
