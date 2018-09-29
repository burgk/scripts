#!/bin/env bash
VIMDIR=/home/burgk/.vim/pack/burgk/start
for DIR in $(ls ${VIMDIR}) ; do cd $VIMDIR/${DIR} && git pull; cd .. ; done
