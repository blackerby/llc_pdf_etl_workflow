#!/usr/bin/env zsh

file=$1

mlr --c2p --from $file cut -f congress,bill_type,bill_number,sponsor,committee,action,action_date
