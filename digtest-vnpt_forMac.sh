#!/bin/bash

# VNPT Local DNS
dns1='123.23.23.23'
dns2='123.26.26.26'
errornum=0

lookup() {
start=`date +%s`
 dig @$1 $2 $3 > tmpresult_$1_$2_$3.txt
end=`date +%s`
runtime=$(echo "$end - $start" | bc -l)
echo "dig @$1 $2 $3 $runtime"

 if [ $? -ne 0 ]
  then
    errornum=$(expr $errornum + 1)
    echo "## ERROR while run dig @$1 $2 $3"
  fi
 if cat tmpresult_$1_$2_$3.txt | grep -q 'NXDOMAIN'; then
   errornum=$(expr $errornum + 1)
   echo "## NXDOMAIN returned"
   cat tmpresult_$1_$2_$3.txt
   echo "####################"
 fi
 rm tmpresult_$1_$2_$3.txt
}

echo "Begin test"
for recordtype in NS A CNAME PTR SRV TXT MX; do
  echo "################ $recordtype ################"
  filen="query$recordtype.txt"
  while IFS= read -r line
    do
      lookup "$dns1" "$line" "$recordtype"
      lookup "$dns2" "$line" "$recordtype"
    done < $filen
done
echo "End test"
echo "Number of error = $errornum"

