#!/bin/bash

# au dump
mysqldump -c -u root bikeexchange option_types option_values > ~/options.sql

# rename tables
sed 's/`option_types`/`au_option_types`/g' < ~/options.sql > tmp
mv tmp ~/options.sql
sed 's/`option_values`/`au_option_values`/g' < ~/options.sql > tmp
mv tmp ~/options.sql

# rename index, constraint
sed 's/index_option_values_on_option_type_id/index_au_option_values_on_option_type_id/g' < ~/options.sql > tmp
mv tmp ~/options.sql
sed 's/`option_values_option_type_id_fk`/`au_option_values_option_type_id_fk`/g' < ~/options.sql > tmp
mv tmp ~/options.sql

# import in to us db
mysql bikeexchange_us < ~/options.sql
