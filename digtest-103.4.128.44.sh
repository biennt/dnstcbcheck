#!/bin/bash

# TCB DNS
dns1='103.4.128.44'
dns2='103.4.130.44'
errornum=0

lookup() {
start=`date +%s`
 #dig @$1 $2 $3 > tmpresult_$1_$2_$3.txt

 # for ISP DNS
 dig $2 $3 > tmpresult_$1_$2_$3.txt
end=`date +%s`
runtime=$(echo "$end - $start" | bc -l)
#echo "#### dig @$1 $2 $3 ( exec time: $runtime ) ####"

# for ISP DNS
echo "#### dig $2 $3 ( exec time: $runtime ) ####"
 if [ $? -ne 0 ]
  then
    errornum=$(expr $errornum + 1)
    echo "## ERROR while run dig @$1 $2 $3"
    sleep 3
  fi
 if cat tmpresult_$1_$2_$3.txt | grep -q 'NXDOMAIN'; then
   errornum=$(expr $errornum + 1) 
   echo "## NXDOMAIN returned"
   sleep 3
 fi
 cat tmpresult_$1_$2_$3.txt | grep -A1 'ANSWER SECTION'
 rm tmpresult_$1_$2_$3.txt
 echo "########"
 echo " "
}

echo "Begin test"
for recordtype in A CNAME NS PTR SRV TXT MX; do
  echo "################ $recordtype ################"
  filen="query$recordtype.txt"
  while IFS= read -r line
    do
      lookup "$dns1" "$line" "$recordtype"
      lookup "$dns2" "$line" "$recordtype"
      if [ $recordtype == "A" ]
      then
        lookup "$dns1" "$line" "AAAA"
        lookup "$dns2" "$line" "AAAA"      
      fi
    done < $filen
done
echo "End test"
echo "Number of error = $errornum"

