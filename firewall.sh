#!/usr/bin/env bash

ip=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$
s="sudo"
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

if [$1 == "drop"]; then
  if [$2 =~ $ip]; then
    if [$3 == "input"]; then
      $s iptables -A INPUT -s $2 -j DROP
    fi

    if [$3 == "output"]; then
      $s iptables -A OUTPUT -s $2 -j DROP
    fi

    if [$3 == "forward"]; then
      $s iptables -A FORWARD -s $2 -j DROP
    fi

  if [$2 == "all"]; then
    if [$3 == "input"]; then
      $s iptables -P INPUT DROP
    fi

    if [$3 == "output"]; then
      $s iptables -P OUTPUT DROP
    fi

    if [$3 == "forward"]; then
      $s iptables -P FORWARD DROP
    fi
  fi
fi

if [$1 == "accept"]; then
  if [$2 =~ $ip]; then
    if [$3 == "input"]; then
      $s iptables -A INPUT -s $2 -j ACCEPT
    fi

    if [$3 == "output"]; then
      $s iptables -A OUTPUT -s $2 -j ACCEPT
    fi

    if [$3 == "forward"]; then
      $s iptables -A FORWARD -s $2 -j ACCEPT
    fi

  if [$2 == "all"]; then
    if [$3 == "input"]; then
      $s iptables -P INPUT ACCEPT
    fi

    if [$3 == "output"]; then
      $s iptables -P OUTPUT ACCEPT
    fi

    if [$3 == "forward"]; then
      $s iptables -P FORWARD ACCEPT
    fi

  fi
fi
