#!/bin/bash

if [[  $# -eq 1 ]]
then
if [[ -d $1 ]]
then
ct1=0	#initialize count variables to count errors
ct2=0
ct3=0
ct4=0
ct5=0
t=0
		for i in $(find $1  -name 'sensordata-*.log');	#iterate through files found
	do

	echo "Processing sensor data set for $i
Year,Month,Day,Hour,Sensor1,Sensor2,Sensor3,Sensor4,Sensor5"

	grep readouts $i | sed -e 's/-/ /1'  -e 's/-/ /1' -e 's/:/ /g' -e 's/  / /g' |
 awk '{if($9!="ERROR"){tmp1=$9}; if($10!="ERROR") {tmp2=$10}; if($11!="ERROR") {tmp3=$11}; if($12!="ERROR") {tmp4=$12}; if($13!="ERROR") {tmp5=$13};
 OFS=","; print $1,$2,$3,$4,tmp1,tmp2,tmp3,tmp4,tmp5}'	#select the lines that have readouts, change any punctuation to " " catch errors, and replace them by the previous value, print while seperating arguments with a ","

echo "====================================
Readout statistics
Year,Month,Hour,MaxTemp,MaxSensor,MinTemp,MinSensor"

minSensor=""
maxSensor=""


max=1000	#set to arbitrary value
min=1000

 #select the lines that have readouts, change any punctuation to " " catch errors, don't take them into consideration while computing max and min, print max and min
#grep readouts $i | sed -e 's/-/ /1' -e 's/-/ /1' -e 's/:/ /g' -e 's/  / /g'  | awk '{
#for(l=13;l>8;l--){
#m=l-8
#if($l!="ERROR") { max=$l;min=$l;minSensor="Sensor"m;maxSensor="Sensor"m}
#}
#for(l=9;l<14;l++){
#m=l-8
#if($l!="ERROR") {
#if($l<min) { min=$l; minSensor="Sensor"m};
#if($l>max) { max=$l; maxSensor="Sensor"m};
#}
#} OFS=",";print $1,$2,$3,$4,max,maxSensor,min,minSensor}'

grep 'readouts' $i | sed -e 's/:/ /g' -e's/-/ /;s/-/ /' |
                awk ' {


                        for (current=9; current<=NF; current++) {
                                number=current-8
                                if( maxVal!=-2000 && minVal!=2000 && current!="ERROR"){

                                        if (current >= maxVal) {maxVal=current ; maxsens="Sensor"number}
                                        if (current <= minVal) {minVal=current ; minsens="Sensor"number}

                                        }
                                }

                        {OFS="," ;  print $1,$2, $3, $4,maxVal, maxsens, minVal, minsens}

                }'



echo "===================================="

	done	#done iterationg on files

echo "Sensor error statistics
Year,Month,Day,Sensor1,Sensor2,Sensor3,Sensor4,Sensor5,Total"

for i in $(find $1 -name 'sensordata-*.log'); #iterate on files
do

#for i in $(find $1 -name 'sensordata-*.log'); #iterate on files
#do

#catch error, count them by incrementing, compute total t, if no error, set to 0, pipe to awk, that finds the last occurence of each date: last incrementation of errors and total, then sort by total number of errors, then by date, then print seperating with ","
grep  readouts $i | sed -e 's/-/ /1' -e 's/-/ /1' -e 's/:/ /g' -e 's/  / /g' | awk '{
for(l=9;l<14;l++){

if($l=="ERROR"){ if(l==9) ct1++;else if(l==13) ct5++; else if(l==10) ct2++; else if(l==11) ct3++;else if(l==12) ct4++}
}
ct1=ct1+0
ct2=ct2+0
ct3=ct3+0
ct4=ct4+0
ct5=ct5+0


t=ct1+ct2+ct3+ct4+ct5

OFS=",";print $1,$2,$3,ct1,ct2,ct3,ct4,ct5,t

}'
done | sed -e 's/,/ /g' | awk '{a[$1 FS $2 FS $3 ] = $4" "$5" "$6" "$7" "$8" "$9 ; c[$1 FS $2 FS $3 ]++}; END{ for(i in a) {if (c[i]>1) print i,a[i]}}' | sort  -k9nr -k2,3n| sed -e 's/ /,/g'
#awk '{a[$1 FS $2 FS $3 ] = $4" "$5" "$6" "$7" "$8" "$9 ; c[$1 FS $2 FS $3 ]++}; END{ fo    r(i in a) {if (c[i]>1) print i,a[i]}}'
else 
	>&2 echo "Error! $1 is not a valid directory name"	#send to standard error and standard output
	exit 1
fi

else
 echo "Usage ./dataformatter.sh <sensorlogdir>" #wrong input
exit 1
fi

