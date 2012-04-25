#!/bin/sh

chr() {
  [ ${1} -lt 256 ] || return 1
  printf \\$(printf '%03o' $1)
}

MIN_RATE=20000000
MAX_RATE=40000000

user="readleaf"
pw=`cat ramp_rate_pw`
date=`date -v -1d +"%Y-%m-%d"`

if [ -e ramp_rate_err ]
  then
  rm ramp_rate_err
fi

ssh -N -L9306:rldb:3306 rapmaster &
pid=$!
sleep 2
rate=`echo "use rapleaf_production; select ramp_rate from ramp_rates order by inclusive_end_date desc limit 1;" | mysql -u$user -p$pw -h 127.0.0.1 -P9306 2>ramp_rate_err | tail -n 1`
kill $pid

if [ -z "$rate" ]
  then
  cat ramp_rate_err | mail -s "Error updating the Ramp Rate Indicatinator" nicole@rapleaf.com
  rm ramp_rate_err
  exit
fi

percent=$((($rate-$MIN_RATE)*100/($MAX_RATE-$MIN_RATE)))
byte=`chr $percent`
ruby indicatinator_writer.rb $byte