# DB 

RumLog's data stores is sqlite3.... 
Copy the Db before you 'play' with it....

This code is my **TEST** code - to try and add some extra functionality to the Db. You will not be able to see anything
inside the most excellent **RUMlogNG**, but I was thinking of a simple Web page to assist the overlay.

Specifically these DB changes are to help me try and Track DXCC status, as I find the RUMlogNG codes rather confusing. 
## Requirements

Some back/zsh shell, plus the following software tools.

  - Python3
  - sqlite3 

Python requires SqlAlchemy to be installed 

    pip install Sqlalchemy 


# These are the steps if done Manually

This is how you can *step* through the process. However it may be advisable to use the **make** solution show lower if you want to try out. 
## Copy Db 

    cp ~/Documents/DV3A.rlog log.db


## Connect to Db 

    sqlite3 log.db


## Main Table 


The main table is called logbook.

    schema logbook

This will show you the columns

## Simple queries


### Show the Calls 

    select distinct callsign from logbook where name ="";


### Show Calls and Name

    select callsign,name from logbook where name != "";


### Show calls where we have a name for 1 or more records

```sql
select l1.callsign,l1.name,l2.name from logbook l1, logbook l2  where l1.name ="" and l2.callsign=l1.callsign and l2.name !="";
```

I see something like 

```
KU1CW||Alex
KL7SB||Steve
KH6AQ||Dave
```

Showing 1 missing name, and 1 Name.

### Show records where we have some names 

```sql
   select l.callsign,l.name,l2.name,count(*) from 
   			logbook as l, logbook as l2 where
        l.callsign=l2.callsign and
        l.name="" and
        l2.name!="" group by l.callsign, l.name, l2.name;
```

### Update missing names


```sql
UPDATE logbook
SET name = L2.name
FROM (select callsign,name from logbook where name !="") as L2
WHERE logbook .callsign = l2.callsign and
      logbook.name="" and
      L2.name!="";
```

### IOTA 


Same callsign with missing IOTA Records.


```sql
 select l.callsign,l.iota,l2.iota,count(*) from 
   			logbook as l, logbook as l2 where
        l.callsign=l2.callsign and
        l.iota="" and
        l2.iota!="" group by l.callsign, l.name, l2.name;
```

```sql
UPDATE logbook
SET iota = L2.iota
FROM (select callsign,iota from logbook where iota !="") as L2
WHERE logbook .callsign = l2.callsign and
      logbook.iota="" and
      L2.iota!="";
```

### locator


Same callsign with missing locator Records.


```sql
 select l.callsign,l.locator,l2.locator,count(*) from 
   			logbook as l, logbook as l2 where
        l.callsign=l2.callsign and
        l.locator="" and
        l2.locator!="" group by l.callsign, l.locator, l2.locator;
```

```sql
UPDATE logbook
SET locator = L2.locator
FROM (select callsign,locator from logbook where locator !="") as L2
WHERE logbook .callsign = l2.callsign and
      logbook.locator="" and
      L2.locator!="";
```


## Python to do this en-masse

This is accomplished by using the makefile with the command

    make fill_in_missing 

This has done the following steps 

   - Copied the Source Log file  locally a DateTime stamp name
     - This file is not used or modified in ANY way
  - Copied the Source Log file, locally as  Qso.db
  - In the Qso.db - and fields from previous QSO's with a Station are updated.

This means if you have worked M0FGC, 5 times - but for some reason (maybe importing Contest files ?) you only have their name written in 1 QSO log ... then all QSO's with M0FGC will not be updated. 
This process is repeated for IOTA and State.


### How much DX On 1 day ?

Date format is Month/Day/Year

```sql
select dxcc,count(*) from logbook where date='2/5/23' group by dxcc order by dxcc asc;
```



# Confirmed and Unconfirmed Contacts 

## Quick way 
You need to edit the Makefile - to point to your Database.... a Copy will be taken and called **Qso.db**.


     make clean 
     make 
     make setup 

You now have done all the Db Changes, and you have a copy of your Data in a file called Qso.db 

You can look at this  using sqlite3 

    sqlite3 Qso.db 

The table you are most interested in will be called *DX_STATUS*;

## Manually 

We start with copying the database 

    cp ~/Documents/DV3A.rlog log.db
    
We now need to add some Tables/Views 

	sqlite3 log.db < my_upgrade.sql 
	
At this point we need to generate some Data. we will do this in Python.

This code - deleted everything in BMS table. Then for each DXCC, each Band, and Each Mode. Creates a record. Which has   a value of status = 0 (i.e. Not contacted).  The number of records is aprox 15,756. 


```python
from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine,MetaData
from sqlalchemy import select,Table          #Needed for selecting data not mapping the Db
from sqlalchemy.sql import text        #Needed for clearing BMS

metadata = MetaData()
Base = automap_base(metadata=metadata)

# point the connection string to the database
CONN_STR = 'sqlite:///log.db'
engine = create_engine(CONN_STR)
session = Session(engine)
# reflect the tables
Base.prepare(autoload_with=engine)
# Now create an Alias to make the code look a little cleaner
# We want to have a look at 2 tables. Logbook and dxlist
Logbook = Base.classes.logbook
Dxlist  = Base.classes.dxlist
Band    = Base.classes.Band
Mode    = Base.classes.Mode
Status  = Base.classes.Status
BMS     = Base.classes.BMS
# 
# As a View does not have a Primary key - SqlAlchemy is unable to reflect("Auto Add")
# But we can pretend the View is a table 
# These tables will not appear in Metadata
#
dxcc_status      = Table("DX_STATUS", metadata, autoload_with=engine)
bs = session.execute(select(Band.bid)).all()

ms = session.execute(select(Mode.mid)).all()
ms=list(set(list(ms))) # This makes the mid values UNIQUE

ss = session.execute(select(Status.sid).where(Status.name == "NOT WORKED")).all()
# We now need the DXCC ID's 
dxi = session.execute(select(Dxlist.dxccadif,Dxlist.dxcc)).all()
# We will create a List of BMS objects - then add using the Session build add.

session.execute(text('DELETE FROM BMS'))
session.commit()
print("BMS was truncated")
ToAdd=[]
for b in bs:
    for m in ms:
        for s in ss:
            for d in dxi:
              ToAdd.append(BMS(bid=b[0],mid=m[0],sid=s[0],dxccadif=d[0]))
print(f"We have {len(ToAdd)} objects to Add.")
session.add_all(ToAdd)
session.commit()
```

At this point you are in the same position as the 'automated' install.


# Makefile 

Just type **make** and the following steps happen.
You can look inside the makefile for specific steps.

  - all 
    - Backups original
    - Uses Qso.db locally
      - fills in missing fields 
      - Creates my QSL tracking structure
      - Updates locally
    - does not modify Original Log file at all 


