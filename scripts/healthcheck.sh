#!/bin/bash
#

tmux ls | grep "${SESSION_NAME}:" > /dev/null || exit 1
