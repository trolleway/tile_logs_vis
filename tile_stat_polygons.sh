#!/bin/bash

HOST=localhost
DBNAME=gis
USER=trolleway
PASSWORD=16208

ZOOM=3

#reset tables and temporary files
rm data.csv

psql -d $DBNAME -U $USER -c "DROP TABLE IF EXISTS tile_logs;"
psql -d $DBNAME -U $USER -c "DROP TABLE IF EXISTS tile_logs_merged;"
psql -d $DBNAME -U $USER -c "CREATE TABLE tile_logs
(
  ogc_fid serial NOT NULL,
  wkb_geometry geometry,
  date character varying,
  x character varying,
  y character varying,
  z character varying,
  count integer,
  CONSTRAINT tile_logs_pkey PRIMARY KEY (ogc_fid)
)"


for file in `find  dumps/tile_logs/ -maxdepth 1 -type f -name "*.csv"|sort` 
do
   DATETEXT=${file%.csv*}
   DATETEXT=${DATETEXT##*tiles-}
   echo $DATETEXT "filtering"
   cat $file | awk  -v var="$ZOOM" '$1 == var' | ./calc_coords.py | ./filter_area.py | sed -e "s/^/$DATETEXT /" | ./delimiter2comma.py > temp.csv
   
   cat temp.csv | sed '1i date,z,x,y,wkt,count,latitude,longitude' > data.csv

   echo $DATETEXT "importing"
   ogr2ogr  -overwrite -f "PostgreSQL" PG:"host=$HOST user=$USER dbname=$DBNAME password=$PASSWORD" data.csv -select "date, x, y, z, count" -nln tile_logs_import


   psql -d $DBNAME -U $USER -c "CREATE TABLE tile_logs_merged AS (
SELECT wkb_geometry, x, y, z, SUM(count) AS count from (SELECT wkb_geometry, x, y, z, count FROM tile_logs UNION ALL SELECT wkb_geometry, x, y, z, count::integer FROM tile_logs_import) AS tile_logs_merged GROUP BY wkb_geometry, x, y, z ORDER BY z,x,y);
"

   psql -d $DBNAME -U $USER -c "DROP TABLE IF EXISTS tile_logs;"
   psql -d $DBNAME -U $USER -c "CREATE TABLE tile_logs AS (SELECT * FROM tile_logs_merged);"
   psql -d $DBNAME -U $USER -c "DROP TABLE IF EXISTS tile_logs_merged;"

done


ogr2ogr -overwrite -progress -f "ESRI Shapefile" tile_logs_summary_2015-05_zoom$ZOOM.shp  PG:"host=$HOST user=$USER dbname=$DBNAME password=$PASSWORD" -sql "SELECT wkb_geometry, sum(count::integer) AS summary FROM tile_logs GROUP BY wkb_geometry;" -s_srs EPSG:4326 -t_srs EPSG:4326 #-clipdst 31 40 189 89

rm temp.csv
