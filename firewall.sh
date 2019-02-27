#!/usr/bin/env bash

ip="^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$"
port="^[0-9]{1,5}$"
num=$port
s="sudo"
consoleChar="$"

#---------------------HTML Formatting-------------------------#
printhtml() {
  echo -e "<!DOCTYPE html>\n" \
  "<html>\n" \
  "<body style=background-color:#63CCCA>\n" \
  "<p>\n" > report.html
#--------------Take the iptables command given by arguments
#--------------In this case, all the arguments given to the function
#--------------is the whole command (hence $*) and use awk to parse the
#--------------output and format it into HTML
#--------------(I attempted to keep the long line below column 65, but awk
#--------------doesn't like breaks, tabs, or \ escape characters)
  $* | awk '/Chain/ {
    print "<div style=display:block;text-align:center;width:auto;margin:auto;max-width:800px;background-color:#00A3BB;border-radius:4px>";
    print "<h1 style=color:#000033>";
    print;
    print "</h1>"; next }
    /target/ {
    print "<h2 style=color:#black>";
    print;
    print "</h2>"; next }
    // {
    print "<p style=color:#EEEEFF align=center>";
    print;
    print "</p>";
    print "</div>" }' >> report.html
  echo -e "\n" \
  "</p>\n" \
  "</body>\n" \
  "</html>" >> report.html
}

#--------------If user is root, change the $ to #
if [[ $UID == "0" ]]; then
  consoleChar="#"
fi

#--------------Fancy prefix for interactive mode
pre="[Firewall]$consoleChar$command"

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
    echo "#############################################"
    echo "#        Welcome to the Firewall!           #"
    echo "#       Created by:  Robert Dunski          #"
    echo "#############################################"
    echo "-----type 'help' for a list of commands------"
    interact="yes"
fi

while(true); do

###############################################################
#                                                             #
#-------------------------FIREWALL----------------------------#
#                                                             #
###############################################################

#--------------------------List-------------------------------#
  if [[ $1 == "list" ]]; then
    if [[ -z $2 ]]; then
      $s iptables -L

    elif [[ ! $2 == "input" ]] && [[ ! $2 == "output" ]] \
      && [[ ! $2 == "forward" ]]; then
      if [[ $2 == "specs" ]]; then
        $s iptables -S
      elif [[ $2 == "nums" ]]; then
        $s iptables -L --line-numbers
      else
        echo "$pre list option not valid"
      fi
    else
      if [[ $3 == "specs" ]]; then
        $s iptables -S ${2^^}
      elif [[ $3 == "nums" ]]; then
        $s iptables -L ${2^^} --line-numbers
      else
        echo "$pre list option not valid"
      fi
    fi
  fi
  if [[ $arg == "list" ]]; then
    echo "$pre please select an option"
    echo -e "\t1. List All"
    echo -e "\t2. List All (Including Rule #s)"
    echo -e "\t3. List All (Specifications)"
    echo -e "\t4. List Chain"
    echo -e "\t5. List Chain (Including Rule #s)"
    echo -e "\t6. List Chain (Specifications)"
    echo -n $pre" " && read arg
    if [[ $arg == "1" ]]; then
      $s iptables -L
    elif [[ $arg == "2" ]]; then
      $s iptables -L --line-numbers
    elif [[ $arg == "3" ]]; then
      $s iptables -S
    elif [[ $arg == "4" ]] || [[ $arg == "5" ]] || [[ $arg == "6" ]]; then
      echo "$pre please specify a chain"
      echo -n $pre" " && read chain
      if [[ $chain == "input" ]] || [[ $chain == "output" ]]; then
        if [[ $arg == "4" ]]; then
          $s iptables -L ${chain^^}
        elif [[ $arg == "5" ]]; then
          $s iptables -L ${chain^^} --line-numbers
        elif [[ $arg == "6" ]]; then
          $s iptables -S ${chain^^}
        fi
      else
        echo "$pre not a valid chain, please try again"
      fi
    else
      echo "$pre not a valid option, please try again"
    fi
  fi

#--------------------------Help-------------------------------#
  if [[ $1 == "help" ]] || [[ $arg == "help" ]]; then
    echo "{} means optional, [] means required"
    echo "Usage (from CLI):"
    echo -e "\t firewall help"
    echo -e "\t firewall list {chain} {specs/nums}"
    echo -e "\t firewall report {specs/nums}"
    echo -e "\t firewall add [ping/tcp port #] [chain]"
    echo -e "\t firewall delete [chain] [rule #]"
    echo -e "\t firewall delete [chain] [specification]"
    echo -e "\t firewall [policy] [ip] [chain]"
    echo -e "\t firewall [policy] all [chain]"
    echo -e "\t firewall flush [chain]"
    echo -e "\t firewall flush all\n"

    echo "Usage (running firewall.sh standalone):"
    echo -e "\t help"
    echo -e "\t list"
    echo -e "\t report"
    echo -e "\t add"
    echo -e "\t delete\n"

    echo "Policies:"
    echo -e "\t accept"
    echo -e "\t drop\n"

    echo "Chains:"
    echo -e "\t input"
    echo -e "\t output"
    echo -e "\t forward\n"
  fi

#-------------------------Report------------------------------#
if [[ $arg == "report" ]]; then
  echo "$pre please select an option"
  echo -e "\t1. Report"
  echo -e "\t2. Report w/ Rule Numbers"
  echo -e "\t3. Report Specificiations" && echo -n "$pre " && read arg
  if [[ $arg == "1" ]]; then
    command="$s iptables -L"
    printhtml $command && echo "$pre report created at report.html"
  elif [[ $arg == "2" ]]; then
    command="$s iptables -L --line-numbers" && \
      echo "$pre report created at report.html"
    printhtml $command
  elif [[ $arg == "3" ]]; then
    command="$s iptables -S" && echo "$pre report created at report.html"
    printhtml $command
  else
    echo "$pre not a valid option, please try again"
  fi
fi
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

#-------------------------Delete------------------------------#
  if [[ $arg == "delete" ]]; then
    echo "$pre please choose an option"
    echo -e "\t1. Rule Number"
    echo -e "\t2. Rule Specification"
    echo -n $pre" " && read arg

    if [[ $arg == "1" ]]; then
      echo "$pre please specify a chain"
      echo -n $pre" " && read arg

      if [[ $arg == "input" ]] || [[ $arg == "output" ]]; then
        $s iptables -L ${arg^^} --line-numbers
        echo "$pre please specify a rule number"
        echo -n $pre" " && read rule

        if [[ $rule =~ $num ]]; then
          $s iptables -D ${arg^^} $rule && echo "$pre rule deleted" \
            || echo "$pre rule not deleted, please try again"
        fi

      fi

    elif [[ $arg == "2" ]]; then
      echo "$pre please specify a chain"
      echo -n $pre" " && read arg

      if [[ $arg == "input" ]] || [[ $arg == "output" ]]; then
        $s iptables -S ${arg^^}

        echo -e "$pre please type in the specification to delete without the -A\n
          (rules that don't have -A at the beginning are not valid for deletion)\n
          ex. specification: -A INPUT -p tcp --sport 80 \n
          \tinput: INPUT -p tcp --sport 80"
        echo -n $pre" " && read rule

        $s iptables -D ${arg^^} $rule && echo "$pre rule deleted" \
          || echo "$pre rule not deleted, please make sure the specification \
            exists and is typed in correctly"
      fi

    else
      echo "$pre not a valid option, please try again"
    fi

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

#-----------Delete->Chain->Rule Num/Specification-------------#
  if [[ $1 == "delete" ]]; then
    if [[ $2 == "input" ]] || [[ $2 == "output" ]]; then
      if [[ -z $3 ]]; then
        echo "$pre no rule number or specification given"
      else
        $s iptables -D ${2^^} ${3^^} && echo "$pre rule deleted" || \
          echo "rule not deleted, make sure the rule exists"
      fi
    else
      echo "$pre not a valid chain"
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

#---------------------Report->Specs/Nums----------------------#
if [[ $1 == "report" ]]; then
  if [[ -z $2 ]]; then
    command="$s iptables -L"
    printhtml $command
  elif [[ $2 == "nums" ]]; then
    command="$s iptables -L --line-numbers"
    printhtml $command
  elif [[ $2 == "specs" ]]; then
    command="$s iptables -S"
    printhtml $command
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
