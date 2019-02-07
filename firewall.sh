#!/usr/bin/env bash

ip=^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$

if [[ -z $1 ]]
  then
    echo "no args given"
    exit
fi

if [[ -z $2 ]] && [[ $1 != "flush" ]]
  then
    echo "chain must be specified"
    exit
fi

if [[ $1 == "flush" ]] && [[ -z $2 ]]
 then
  echo "did you mean 'flush all'? (y/n): "
  read decision
  if [[ $decision == "y" ]] || [[ $decision == "yes" ]]
    then
      sudo iptables -F
      exit
  else
    echo "please specify a chain or press enter to exit: "
    read decision
    if [$decision == "input"]; then
      iptables -F INPUT
    fi

    if [$decision == "output"]; then
      iptables -F OUTPUT
    fi

    if [$decision == "forward"]; then
      iptables -F FORWARD
    fi

    if [-z $decision]; then
      exit
    fi
  fi

elif [$1 == "flush"] && [$2 == "all"]; then
  iptables -F
fi

if [$1 == "drop"]; then
  if [$2 =~ $ip]; then
    if [$3 == "input"]; then
      iptables -A INPUT -s $2 -j DROP
    fi

    if [$3 == "output"]; then
      iptables -A OUTPUT -s $2 -j DROP
    fi

    if [$3 == "forward"]; then
      iptables -A FORWARD -s $2 -j DROP
    fi

  if [$2 == "all"]; then
    if [$3 == "input"]; then
      iptables -P INPUT DROP
    fi

    if [$3 == "output"]; then
      iptables -P OUTPUT DROP
    fi

    if [$3 == "forward"]; then
      iptables -P FORWARD DROP
    fi
  fi
fi

if [$1 == "accept"]; then
  if [$2 =~ $ip]; then
    if [$3 == "input"]; then
      iptables -A INPUT -s $2 -j ACCEPT
    fi

    if [$3 == "output"]; then
      iptables -A OUTPUT -s $2 -j ACCEPT
    fi

    if [$3 == "forward"]; then
      iptables -A FORWARD -s $2 -j ACCEPT
    fi

  if [$2 == "all"]; then
    if [$3 == "input"]; then
      iptables -P INPUT ACCEPT
    fi

    if [$3 == "output"]; then
      iptables -P OUTPUT ACCEPT
    fi

    if [$3 == "forward"]; then
      iptables -P FORWARD ACCEPT
    fi

  fi
fi
