DROP TABLE IF EXISTS Band;
DROP TABLE IF EXISTS Mode;
DROP TABLE IF EXISTS Status;
DROP TABLE IF EXISTS BMS;
DROP VIEW  IF EXISTS MISSING_MODES;
DROP VIEW  IF EXISTS BMS_VIEW;
DROP VIEW  IF EXISTS CONFIRMED_VIEW_BMS ;
DROP VIEW  IF EXISTS UNCONFIRMED_VIEW_BMS ;
DROP VIEW  IF EXISTS BMS_STATUS_VIEW;
DROP VIEW  IF EXISTS DX_STATUS;

create table Band (bid Integer, name VarChar, Primary Key (bid DESC));
create table Mode (pid Integer,mid Integer,logname Varchar, name VarChar, Primary Key (pid DESC));
create table Status (sid Integer, code VarChar, name VarChar, Primary Key (sid DESC));
/* Needs a Primary Key, else SqlAlchemy will not pick this up */
CREATE TABLE BMS (bid Integer NOT NULL, mid Integer NOT NULL, sid Integer NOT NULL, dxccadif Integer NOT NULL,
      PRIMARY KEY (bid, mid, sid, dxccadif),
     FOREIGN KEY (bid) REFERENCES Band (bid),
     FOREIGN KEY (sid) REFERENCES Status (sid),
     FOREIGN KEY (dxccadif) REFERENCES dxlist(dxccadif)
      ); 

      -- CONFIRMED_VIEW source

CREATE VIEW MISSING_MODES as      
    SELECT MODE FROM logbook l WHERE NOT EXISTS (SELECT * from Mode m where m.logname=l.mode);

create view BMS_VIEW as select distinct dx.dxcc, bm.dxccadif,bm.mid, m.name, bm.sid, s.name, ' ',  b.name   from BMS bm, Band b, dxlist dx, Mode m, Status s  where 
		b.bid  = bm.bid and 
		dx.dxccadif = bm.dxccadif and 
		s.sid = bm.sid and 
		bm.mid  = m.mid order by b.bid,m.mid;

create view CONFIRMED_VIEW_BMS as  select bid as bid, mid as mid ,max(sid) as sid, dxccadif as dxccadif from (select  b.bid , m.mid ,s.sid, l.dxccadif  from logbook l ,Mode m, Status s, Band b  where 
			m.logname=l.mode and
			b.name=l.band and 
			s.code = l.lotwqsl and s.name="CONFIRMED" 
			union all  select * from BMS bms ) as X
		group by bid,mid, dxccadif 
	order by bid,mid,max(sid),dxccadif;

create view UNCONFIRMED_VIEW_BMS as select bid as bid, mid as mid ,max(sid) as sid, dxccadif as dxccadif from (select  b.bid , m.mid ,s.sid, l.dxccadif  from logbook l ,Mode m, Status s, Band b  where 
			m.logname=l.mode and
			b.name=l.band and 
			s.code = l.lotwqsl and s.name!="CONFIRMED" 
			union all  select * from BMS bms ) as X
		group by bid,mid, dxccadif 
	order by bid,mid,max(sid),dxccadif;


create view BMS_STATUS_VIEW as select bid as bid,mid as mid ,max(sid) as sid,dxccadif as dxccadif  from (select * from UNCONFIRMED_VIEW_BMS uvb union all select * from CONFIRMED_VIEW_BMS cvb union all select * from BMS b)  group by 
	bid,mid,dxccadif order by 4,1,2,3;

create view DX_STATUS as select distinct d.dxcc as DX,b.name as Band,m.name as Mode ,s.name as Status  from BMS_STATUS_VIEW bsv,Mode m, Band b, dxlist d, Status s  where 
	m.mid = bsv.mid and 
	s.sid = bsv.sid and 
	d.dxccadif = bsv.dxccadif AND 
	b.bid = bsv.bid order by 1,2,3,4;

insert into Band values (160,"180m");
insert into Band values (80,"80m");
insert into Band values (60,"60m");
insert into Band values (40,"40m");
insert into Band values (30,"30m");
insert into Band values (20,"20m");
insert into Band values (17,"17m");
insert into Band values (15,"15m");
insert into Band values (12,"12m");
insert into Band values (10,"10m");
insert into Band values (6,"6m");
insert into Band values (2,"2m");
insert into Band values (1,"Sat");

insert into Mode values(1,1,"CW","CW");
insert into Mode values(2,1,"CWR","CW");
insert into Mode values(3,2,"DATA","DATA");
insert into Mode values(4,2,"FT8","DATA");
insert into Mode values(5,2,"FT4","DATA");
insert into Mode values(6,2,"RTTY","DATA");
insert into Mode values(7,3,"PHONE","SSB");
insert into Mode values(8,3,"SSB","SSB");
insert into Mode values(9,3,"USB","SSB");
insert into Mode values(10,3,"LSB","SSB");

insert into Status values (0,'N',"NOT WORKED");
insert into Status values (1,'S',"NOT CONFIRMED");
insert into Status values (2,'X',"CONFIRMED");

select "Band   should be 13 ->",count(*) from Band;
select "Mode   should be 3  ->",count(*) from Mode;
select "Status should be 3  ->",count(*) from Status;
select "BMS    should be 0  ->",count(*) from BMS;

.schema
