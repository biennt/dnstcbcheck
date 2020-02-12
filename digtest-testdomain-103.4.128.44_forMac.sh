#!/bin/bash

# TCB DNS
dns1='103.4.128.44'
#dns2='103.4.130.44'
dns5='203.113.131.1'
dns6='203.113.131.2'
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

END=1000
for ((i=1;i<=END;i++)); do
    lookup "$dns1" "ib.testtcb02.com.vn" "a"
    #lookup "$dns2" "ib.testtcb02.com.vn" "a"
    #lookup "$dns3" "ib.testtcb02.com.vn" "a"
    #lookup "$dns4" "ib.testtcb02.com.vn" "a"
    lookup "$dns5" "ib.testtcb02.com.vn" "a"
    lookup "$dns6" "ib.testtcb02.com.vn" "a"

done

echo "End test"
echo "Number of error = $errornum"

