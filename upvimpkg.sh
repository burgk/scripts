#!/bin/env bash
VIMDIR=/home/burgk/.vim/pack/burgk/start
for dir in $(ls /home/burgk/.vim/pack/burgk/start) ; do cd $VIMDIR/${dir} && git pull; cd .. ; done
