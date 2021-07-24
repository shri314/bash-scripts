#!/bin/bash

set -euo pipefail

if [ $# -ne 2 ]
then
   echo "Usage: $0 <key-seq1> <key-seq2>"
   echo "Example:"
   echo "   $0 'top' 'top'"
   echo "   $0 'q' 'q'"
   echo "   $0 'pwd;make' 'pwd;gradle build'"
   exit 1
fi

CMD_1="$1"; shift
CMD_2="$1"; shift

C=$(tmux list-pane | wc -l)
if [ "$C" -eq 1 ]
then
   tmux split-window -h -t :.0 -p 30 -d
   tmux split-window -v -t :.1 -p 30 -d
fi

if [ "$C" -ne 3 ]
then
   echo "Refusing to start panes..."
fi

tmux select-pane -t :0
#tmux display-pane

tmux send-keys -t :.2 "$CMD_2"
tmux send-keys -t :.1 "$CMD_1"
