#!/bin/bash

SACHIN='publish.oomphhq.com'
DASHBOARD='ec2-54-82-222-73.compute-1.amazonaws.com'
ADOMATIC='ec2-174-129-102-12.compute-1.amazonaws.com'

function db_restore
{
  DB_HOST=$2
  APP_NAME=$1
  ssh deploy@$DB_HOST '<<-_eof_
i="9"
while [ $i -ge 0 ]; do
  sudo -i eybackup -e mysql --download $i:$APP_NAME
  if [ $? -eq 0 ]; then
    break;
  fi
  i=$[$i-1]
done
_eof_
  '
  BACKUP=`ssh deploy@$DB_HOST 'ls /mnt/tmp'`
  scp deploy@$DB_HOST:/mnt/tmp/$BACKUP ~/db
  gunzip ~/db/$BACKUP
  mysql -u root $APP_NAME'_development' < ~/db/`echo $BACKUP | sed 's/\.gz//'`
}

db_restore sachin $SACHIN
db_restore oompfserver $DASHBOARD
db_restore adomatic $ADOMATIC
