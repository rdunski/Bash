#!/usr/bin/env bash

ip="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
port="^[0-9]{1,5}$"
s="sudo"

acceptedOption[0]="delete"
acceptedOption[1]="insert"
acceptedOption[2]="list"
acceptedOption[3]="add"

acceptedPolicy[0]="drop"
acceptedPolicy[1]="accept"

acceptedChain[0]="input"
acceptedChain[1]="output"
acceptedChain[2]="forward"

if [[ -z $1 ]]
  then
    echo "no args given"
    exit
fi

if [[ $1 == ${acceptedOption[2]} ]]
  then
    $s iptables -L
    exit
fi
if [[ $1 == "help" ]]
  then
    echo -e "Usage: \t firewall help"
    echo -e "\t firewall [policy] [ip] [chain]"
    echo -e "\t firewall [policy] all [chain]"
    echo -e "\t firewall flush [chain]"
    echo -e "\t firewall flush all"
    echo -e "\t firewall list\n"
    echo -e "Policies:accept"
    echo -e "\t drop\n"
    echo -e "Chains:\t input"
    echo -e "\t output"
    echo -e "\t forward\n"
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

if [[ $1 == ${acceptedOption[3]} ]]
  then
    if [[ $2 == "ping" ]]
      then
        for i in ${acceptedChain[*]}; do
          if [[ $3 == $i ]]
            then
              $s iptables -p icmp --icmp-type any -A {$3^^}
              exit
          fi
        done
        echo "no valid chain specified"
        exit
    fi
    if [[ -z $2 ]]
      then
        echo "please specify a port number"
        read pNum
        echo "please specify a chain"
        read chain
        if [[ $pNum =~ $port ]]
          then
            if [[ $chain == "output" ]]
              then
                $s iptables -A ${chain^^} -p tcp --sport $pNum
                exit
            elif [[ $chain == "input" ]]
              then
                $s iptables -A ${chain^^} -p tcp --dport $pNum
                exit
            else
              echo "not a valid chain"
              exit
            fi
        else
          echo "not a valid port"
          exit
        fi
    fi
fi

for a in ${acceptedPolicy[*]}; do
  if [[ $1 == "drop" ]] || [[ $1 == "accept" ]]
   then
    if [[ $2 =~ $ip ]]
     then
      for i in ${acceptedChain[*]}; do
        if [[ $3 == $i ]]
         then
          $s iptables -A ${3^^} -s $2 -j ${1^^}
          exit
        fi
      done
    fi
    if [[ $2 == "all" ]]
     then
      for i in ${acceptedChain[*]}; do
        if [[ $3 == $i ]]
         then
          $s iptables -P ${3^^} ${1^^}
          exit
        fi
      done
    fi
  fi
done

echo "not a valid option"
