from sqlalchemy.ext.automap import automap_base
from sqlalchemy.orm import Session
from sqlalchemy import create_engine,MetaData
from sqlalchemy import select,Table          #Needed for selecting data not mapping the Db
from sqlalchemy.sql import text        #Needed for clearing BMS

metadata = MetaData()
Base = automap_base(metadata=metadata)

# point the connection string to the database
CONN_STR = 'sqlite:///Qso.db'
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
for mdtable in metadata.tables:
    print("Metadata", mdtable)

for mappedclass in Base.classes:
    print ("Mapped",mappedclass)

# Lets just check we see all the fields in a View
print("Checking View DXCC_STATUS columns")
list(dxcc_status.columns)

'''
Populate BMS
We need to create a Record for each Band/Mode/DX
By default we will assume that all BMS are not worked.
'''
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

# We will now get all the Sent but not Confirmed (Ignoring for the moment) 
# For Band/Mode/DXCC 
# The SQL is this 
#     select  distinct l.dxccadif, m.mid,l.mode,s.sid,s.name , l.lotwqsl, l.band  from logbook l ,Mode m, Status s, Band b  where m.name=l.mode and b.name=l.band and s.code = l.lotwqsl and s.name="NOT CONFIRMED";
stmt = select(Logbook.dxccadif, Logbook.band, Logbook.mode,Status.name,Logbook.lotwqsl, Status.sid, Mode.mid).where(Mode.name == Logbook.mode and Band.name == Logbook.band and Status.code == Logbook.lotqsql and Status.name =="NOT CONFIRMED" )
non_confirmed_result = session.execute(stmt).all()
print(f"We have {len(non_confirmed_result)} Non Confirmed in Total")

#Sqlalchemy does not appear to like the .distinct(fld,fld) clause.... so we 
#will make these records unique using python
#Cast data to a set and then back to a list

unique_non_confirmed = list(set(non_confirmed_result))
print(f"We have {len(unique_non_confirmed)} Unique Non Confirmed records")
