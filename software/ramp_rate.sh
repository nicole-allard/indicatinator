#!/bin/sh

chr() {
  [ ${1} -lt 256 ] || return 1
  printf \\$(printf '%03o' $1)
}

MIN_RATE=39500000
MAX_RATE=60000000

user="readleaf"
pw=`cat ramp_rate_pw`

#ssh -N -L9306:rldb:3306 rapmaster &
#pid=$!
#sleep 2
rate=`echo "select ramp_rate from ramp_rates order by inclusive_end_date desc limit 1;" | mysql -u$user -p$pw -h rapmaster -P9306 rapleaf_production 2>ramp_rate_err | tail -n 1`
echo $rate
#kill $pid

if [ -z "$rate" ]
  then
#  cat ramp_rate_err | mail -s "Error updating the Ramp Rate Indicatinator" nicole@rapleaf.com
#  rm ramp_rate_err
  exit
fi

percent=$((($rate-$MIN_RATE)*100/($MAX_RATE-$MIN_RATE)))
echo "$percent %"
if [ $percent -lt 0 ]
then
  percent=0
fi
#echo $percent
#byte=`chr $percent`
#echo "$byte"
ruby indicatinator_writer.rb $percent
