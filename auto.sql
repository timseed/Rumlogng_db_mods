 select l.callsign,l.state,l2.state,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.state="" and
l2.state!="" group by l.callsign, l.state, l2.state;



UPDATE logbook
SET state = L2.state
FROM (select callsign,state from logbook where state !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.state="" and
      L2.state!="";



 select l.callsign,l.iota,l2.iota,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.iota="" and
l2.iota!="" group by l.callsign, l.iota, l2.iota;



UPDATE logbook
SET iota = L2.iota
FROM (select callsign,iota from logbook where iota !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.iota="" and
      L2.iota!="";



 select l.callsign,l.name,l2.name,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.name="" and
l2.name!="" group by l.callsign, l.name, l2.name;



UPDATE logbook
SET name = L2.name
FROM (select callsign,name from logbook where name !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.name="" and
      L2.name!="";



 select l.callsign,l.qth,l2.qth,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.qth="" and
l2.qth!="" group by l.callsign, l.qth, l2.qth;



UPDATE logbook
SET qth = L2.qth
FROM (select callsign,qth from logbook where qth !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.qth="" and
      L2.qth!="";



 select l.callsign,l.locator,l2.locator,count(*) from 
logbook as l, logbook as l2 where
l.callsign=l2.callsign and
l.locator="" and
l2.locator!="" group by l.callsign, l.locator, l2.locator;



UPDATE logbook
SET locator = L2.locator
FROM (select callsign,locator from logbook where locator !="") as L2
WHERE logbook.callsign = l2.callsign and
      logbook.locator="" and
      L2.locator!="";



