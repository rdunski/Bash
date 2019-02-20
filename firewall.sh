#!/usr/bin/env bash

ip="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
port="^[0-9]{1,5}$"
s="sudo"
consoleChar="$"

if [[ $UID == "0" ]]; then
  consoleChar="#"
fi

pre="[Firewall]$consoleChar"

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

if [[ -z $1 ]]; then
    echo "$pre Welcome to KomodoWall, type 'help' for a list of commands"
    interact="yes"
fi

while(true); do

###############################################################
#                                                             #
#-------------------------FIREWALL----------------------------#
#                                                             #
###############################################################

#--------------------------Add--------------------------------#
  if [[ $arg == ${acceptedOption[3]} ]]; then
      echo "$pre what rule would you like to add?"
      echo "accepted options are:"
      echo -e "\t icmp (ping)"
      echo -e "\t tcp"
      echo -e -n "\t ip\n$pre " && read arg
      if [[ $arg == "icmp" ]]; then
        echo -n "$pre please specify a chain (Default=input): " && read arg

          if [[ $arg == "input" ]] || [[ $arg == "" ]]; then
            $s iptables -p icmp --icmp-type any -A INPUT

          elif [[ $arg == "output" ]] || [[ $arg == "forward" ]]; then
              $s iptables -p icmp --icmp-type any -A ${arg^^}
              echo "$pre rule added successfully"

          else
            echo -n "$pre invalid chain, please try again"
          fi

      elif [[ $arg == "tcp" ]]; then
          pnum=null
          chain=null
          echo "$pre please specify a port number" && echo -n "$pre " \
            && read pNum
          echo "$pre please specify a chain" && echo -n "$pre " \
            && read chain

          if [[ $pNum =~ $port ]]; then
            if [[ $chain == "output" ]]; then
              $s iptables -A ${chain^^} -p tcp --sport $pNum \
                && echo "$pre rule added successfully"

            elif [[ $chain == "input" ]]; then
              $s iptables -A ${chain^^} -p tcp --dport $pNum \
                && echo "$pre rule added successfully"

            else
              echo "$pre not a valid chain, please try again"
            fi

          else
            echo "$pre not a valid port, please try again"
          fi

      elif [[ $arg == "ip" ]]; then
        echo -n "$pre please enter an ip address (0.0.0.0-255.255.255.255): " \
          && read address

          if [[ $address =~ $ip ]]; then
            echo -n "$pre drop or accept this ip? (drop/accept): " \
              && read policy

              if [[ $policy != "drop" ]] && [[ $policy != "accept" ]]; then
                echo "$pre not a valid policy, please try again"
                continue
              fi

            echo -n "$pre please specify a chain: " && read chain
            found="false"

              for i in ${acceptedChain[*]}; do
                if [[ $chain == $i ]]; then
                  $s iptables -A ${chain^^} -s $address -j ${policy^^} && echo "$pre rule added successfully"
                  found="true"
                fi
              done

              if [[ $found == "false" ]]; then
                echo "$pre not a valid chain, please try again"
              fi

          else
            echo "$pre not a valid ip address, please try again"
          fi

      else
        echo "$pre not a valid option, please try agin"
      fi
  fi
#--------------------------List-------------------------------#
  if [[ $1 == "list" ]] || [[ $arg == "list" ]]; then
    $s iptables -L
  fi

#--------------------------Help-------------------------------#
  if [[ $1 == "help" ]] || [[ $arg == "help" ]]; then
    echo "Usage (from CLI):"
    echo -e "\t firewall help"
    echo -e "\t firewall [policy] [ip] [chain]"
    echo -e "\t firewall [policy] all [chain]"
    echo -e "\t firewall flush [chain]"
    echo -e "\t firewall flush all"
    echo -e "\t firewall list\n"

    echo "Usage (running firewall.sh standalone):"
    echo -e "\t help"
    echo -e "\t add"
    echo -e "\t list\n"

    echo "Policies:"
    echo -e "\t accept"
    echo -e "\t drop\n"

    echo -e "Chains:"
    echo -e "\t input"
    echo -e "\t output"
    echo -e "\t forward\n"
  fi

#-------------------------Flush-------------------------------#
  if ([[ $1 == "flush" ]] && [[ -z $2 ]]) || [[ $arg == "flush" ]]; then
    decision=null
    echo -n "$pre did you mean 'flush all'? (y/n): " && read decision
    if [[ $decision == "y" ]] || [[ $decision == "yes" ]]; then
      $s iptables -F && echo "$pre all tables flushed"

    else
      echo -n "$pre please specify a chain or press enter to cancel: "
      read decision
      if [[ $decision == "input" ]]; then
        $s iptables -F INPUT
        echo "$pre $decision flushed"

      elif [[ $decision == "output" ]]; then
        $s iptables -F OUTPUT
        echo "$pre $decision flushed"

      elif [[ $decision == "forward" ]]; then
        $s iptables -F FORWARD
        echo "$pre $decision flushed"

      elif [[ $decision != "" ]]; then
        echo "$pre not a valid chain, please try again"
      fi
    fi

  elif ([[ $1 == "flush" ]] && \
          [[ $2 == "all" ]]) || \
          [[ $arg == "flush all" ]]; then
    $s iptables -F && echo "$pre all tables flushed"
  fi

#-----------------------Begin CLI-----------------------------#
#-----------------Add->Ping/TCP->Chain------------------------#
  if [[ $1 == ${acceptedOption[3]} ]]; then
    if [[ $2 == "ping" ]]; then

      for i in ${acceptedChain[*]}; do

        if [[ $3 == $i ]]; then
            $s iptables -p icmp --icmp-type any -A ${3^^}
        fi

      done
        echo "$pre no valid chain specified"
    fi

    if [[ $2 =~ $port ]]; then
      if [[ $3 == "output" ]]; then
        $s iptables -A ${3^^} -p tcp --sport $2

      elif [[ $3 == "input" ]]; then
        $s iptables -A ${3^^} -p tcp --dport $2

      else
        echo "$pre not a valid chain"
      fi

      else
        echo "$pre not a valid port"
    fi
  fi

#-----------------Policy->IP/All->Chain-----------------------#
  if [[ $1 == "drop" ]] || [[ $1 == "accept" ]]; then
    if [[ $2 =~ $ip ]]; then

      for i in ${acceptedChain[*]}; do

        if [[ $3 == $i ]]
         then
          $s iptables -A ${3^^} -s $2 -j ${1^^}
        fi

      done
    fi
      if [[ $2 == "all" ]]; then

        for i in ${acceptedChain[*]}; do

          if [[ $3 == $i ]]; then
            $s iptables -P ${3^^} ${1^^}
          fi

        done
      fi
    fi

#--------------------If not interactive-----------------------#
  if [[ $interact == "no" ]]; then
    break;
  fi

#---------------------Rinse and repeat------------------------#
echo -n $pre" "
read arg

done
