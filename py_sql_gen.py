SHO=""" select l.callsign,l.COLUMN,l2.COLUMN,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.COLUMN="" and
l2.COLUMN!="" group by l.callsign, l.COLUMN, l2.COLUMN;
"""



UPD="""UPDATE logbook
SET COLUMN = L2.COLUMN
FROM (select callsign,COLUMN from logbook where COLUMN !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.COLUMN="" and
      L2.COLUMN!="";
"""


fields=['state','iota','name','qth','locator']

for f in fields:
    SQLSHOW=SHO.replace("COLUMN",f)
    SQLUPDATE=UPD.replace("COLUMN",f)
    print(f"{SQLSHOW}\n\n")
    print(f"{SQLUPDATE}\n\n")

