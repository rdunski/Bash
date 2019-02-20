#!/usr/bin/env bash

ip="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
port="^[0-9]{1,5}$"

s="sudo"
consoleChar="$"

if [[ $UID == "0" ]]
  then consoleChar="#"
fi
pre="[KomodoWall]$consoleChar"

acceptedOption[0]="delete"
acceptedOption[1]="insert"
acceptedOption[2]="list"
acceptedOption[3]="add"

acceptedPolicy[0]="drop"
acceptedPolicy[1]="accept"

acceptedChain[0]="input"
acceptedChain[1]="output"
acceptedChain[2]="forward"

interact="no"

if [[ -z $1 ]]
  then
    echo "$pre Welcome to KomodoWall, type 'help' for a list of commands"
    interact="yes"
fi

while(true); do
  decision=null

  if [[ $1 == ${acceptedOption[2]} ]] || [[ $arg == ${acceptedOption[2]} ]]
    then
      arg=null
      $s iptables -L
      if [[ $interact == "no" ]]
        then
          break;
      fi
  fi

  if [[ $1 == "help" ]] || [[ $arg == "help" ]]
    then
      echo -e "$pre $arg $1"
      arg=null
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

  fi
  if ([[ $1 == "flush" ]] && [[ -z $2 ]]) || [[ $arg == "flush" ]]
   then
    echo -n "$pre did you mean 'flush all'? (y/n): " && read decision
    if [[ $decision == "y" ]] || [[ $decision == "yes" ]]
      then
        arg=null
        $s iptables -F
    else
      arg=null
      echo -n "$pre please specify a chain or press enter to cancel: " && read decision
      if [[ $decision == "input" ]]
       then
        $s iptables -F INPUT

      elif [[ $decision == "output" ]]
       then
        $s iptables -F OUTPUT

      elif [[ $decision == "forward" ]]
       then
        $s iptables -F FORWARD

      elif [[ $decision != "" ]]
        then
          echo "$pre not a valid chain, please retry"
      fi
    fi

  elif ([[ $1 == "flush" ]] && [[ $2 == "all" ]]) || [[ $arg == "flush all" ]]
   then
    arg=null
    $s iptables -F && echo "tables flushed"
  fi

  if [[ $arg == ${acceptedOption[3]} ]]
    then
      echo -n "$pre what rule would you like to add?" && read arg
      if [[ $arg == "icmp" ]]
        then
          #------------------------------------------------------__WORKING HERE
      fi
  fi

  if [[ $1 == ${acceptedOption[3]} ]]
    then
      if [[ $2 == "ping" ]]
        then
          for i in ${acceptedChain[*]}; do
            if [[ $3 == $i ]]
              then
                arg=null
                $s iptables -p icmp --icmp-type any -A {$3^^}

            fi
          done
          arg=null
          echo "no valid chain specified"

      fi
      if [[ -z $2 ]]
        then
          arg=null
          pnum=null
          chain=null
          echo "please specify a port number"
          read pNum
          echo "please specify a chain"
          read chain
          if [[ $pNum =~ $port ]]
            then
              if [[ $chain == "output" ]]
                then
                  $s iptables -A ${chain^^} -p tcp --sport $pNum

              elif [[ $chain == "input" ]]
                then
                  $s iptables -A ${chain^^} -p tcp --dport $pNum
              else
                echo "not a valid chain"
              fi
          else
            echo "not a valid port"
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
            arg=null
            $s iptables -A ${3^^} -s $2 -j ${1^^}

          fi
        done
      fi
      if [[ $2 == "all" ]]
       then
        for i in ${acceptedChain[*]}; do
          if [[ $3 == $i ]]
           then
            arg=null
            $s iptables -P ${3^^} ${1^^}


          fi
        done
      fi
    fi
  done

  if [[ $interact == "no" ]]
    then
      break;
  fi

echo -n $pre" "
read arg
done
