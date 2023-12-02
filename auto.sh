echo "Taking a copy of DV3A"
cp ~/Documents/DV3A.rlog dv3a.db
cp ~/Documents/DV3A.rlog dv3a_orig.db
echo "Generating SQL scripts"
python py_sql_gen.py > auto.sql
echo "Executing SQL Update"
sqlite3 dv3a.db < auto.sql > auto_results.txt
echo "SQL Update done"
cat auto_results.txt
echo "run this to update the Source Db"
echo "  cp dv3a.db ~/Documents/DV3A.rlog"
