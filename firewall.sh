#!/usr/bin/env bash

ip=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$
s="sudo"
acceptArgs[0]="input"
acceptArgs[1]="output"
acceptArgs[2]="forward"
if [[ -z $1 ]]
  then
    echo "no args given"
    exit
fi

if [[ $1 == "flush" ]] && [[ -z $2 ]]
 then
  echo "did you mean 'flush all'? (y/n): "
  read decision
  if [[ $decision == "y" ]] || [[ $decision == "yes" ]]
    then
      $s iptables -F
      exit
  else
    echo "please specify a chain or press enter to exit: "
    read decision
    if [[ $decision == "input" ]]
     then
      $s iptables -F INPUT
    fi

    if [[ $decision == "output" ]]
     then
      $s iptables -F OUTPUT
    fi

    if [[ $decision == "forward" ]]
     then
      $s iptables -F FORWARD
    fi

    if [[ -z $decision ]]
     then
      exit
    fi
  fi

elif [[ $1 == "flush" ]] && [[ $2 == "all" ]]
 then
  $s iptables -F && echo "tables flushed"
  exit
fi

if [[ $1 == "drop" ]]
 then
  if [[ $2 =~ $ip ]]
   then
    for i in acceptArgs; do
      if [[ $3 == $i ]]
       then
        $s iptables -A ${3^^} -s $2 -j ${1^^}
        exit
      fi
    done
  fi
  if [[ $2 == "all" ]]
   then
    for i in acceptArgs; do
      if [[ $3 == $i ]]
       then
        $s iptables -P ${3^^} ${1^^}
        exit
      fi
    done
  fi
fi

if [[ $1 == "accept" ]]
 then
  if [[ $2 =~ $ip ]]
   then
    for i in acceptArgs; do
      if [[ $3 == $i ]]
       then
        $s iptables -A ${3^^} -s $2 -j ${1^^}
        exit
      fi
    done
  fi
  if [[ $2 == "all" ]]
   then
    for i in acceptArgs; do
      if [[ $3 == $i ]]
       then
        $s iptables -P ${3^^} ${1^^}
      fi
    done
  fi
fi
