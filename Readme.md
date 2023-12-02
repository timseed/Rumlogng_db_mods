# DB 

RumLog's data stores is sqlite3.... 
Copy the Db before you 'play' with it....

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




### How much DX On 1 day ?

Date format is Month/Day/Year

```sql
select dxcc,count(*) from logbook where date='2/5/23' group by dxcc order by dxcc asc;
```
