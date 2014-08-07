#!/bin/bash
 
SACHIN_PRD='publish.oomphhq.com'
SACHIN_INT='publish-integration.oomphhq.com'

AD_PRD='ec2-174-129-102-12.compute-1.amazonaws.com'
AD_STG='ec2-54-253-63-216.ap-southeast-2.compute.amazonaws.com'

SSO_PRD='ec2-75-101-146-213.compute-1.amazonaws.com'
SSO_INT='my-integration.oomphhq.com'
 
if [[ $1 == 'PRD' ]]; then
	SACHIN=$SACHIN_PRD
	AD=$AD_PRD
	SSO=$SSO_PRD
	RAILS_ENV=production
elif [[ $1 == 'INT' ]]; then
	SACHIN=$SACHIN_INT
	AD=$AD_STG
	SSO=$SSO_INT
	RAILS_ENV=integration
else
	echo "Error: environment not specified."
	echo "Usage: "$0" PRD|INT"
	exit 1
fi
 
SACHIN_ROOT='/data/sachin/current'
SACHIN_DUMP='sachin_dump.sql'

AD_ROOT='/data/adomatic/current'
AD_DUMP='adomatic_dump.sql'
 
SSO_ROOT='/data/oomphsso/current'
 
CAS_MIGRATION=20140512041721
OOMPH_MIGRATION=20140805061138
AD_MIGRATION=20140807034035
 
# sachin export
ssh deploy@$SACHIN 'mysqldump -c -u deploy sachin sections docs > ~/'$SACHIN_DUMP''
scp deploy@$SACHIN:~/$SACHIN_DUMP ~/

# adomatic export
ssh deploy@$AD 'mysqldump -c --skip-add-drop-table --no-create-info -u deploy adomatic users > ~/'$AD_DUMP''
# ssh deploy@$AD 'mysqldump -c -u deploy -p'$AD_PWD' adomatic users > ~/'$AD_DUMP''
scp deploy@$AD:~/$AD_DUMP ~/

# if you want to rename the table
# sed 's/`users`/`adomatic_users`/g' < ~/$AD_DUMP > tmp
# mv tmp ~/$AD_DUMP
 


 
# # CASino migrations
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:drop RAILS_ENV='$RAILS_ENV''
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:create RAILS_ENV='$RAILS_ENV''
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:migrate VERSION='$CAS_MIGRATION' RAILS_ENV='$RAILS_ENV''

# create Oomph tables and organizations data
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:migrate VERSION='$OOMPH_MIGRATION' RAILS_ENV='$RAILS_ENV''
 
# sachin import to sso
scp ~/$SACHIN_DUMP deploy@$SSO:~
ssh deploy@$SSO 'mysql -u deploy oomphsso < ~/'$SACHIN_DUMP''

# adomatic import to sso
scp ~/$AD_DUMP deploy@$SSO:~
ssh deploy@$SSO 'mysql -u deploy oomphsso < ~/'$AD_DUMP''

# adomatic migration
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:migrate VERSION='$AD_MIGRATION' RAILS_ENV='$RAILS_ENV''

# remaining migrations
ssh deploy@$SSO 'cd '$SSO_ROOT'; bin/rake db:migrate RAILS_ENV='$RAILS_ENV''
