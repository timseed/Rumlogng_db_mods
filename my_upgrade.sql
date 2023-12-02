DROP TABLE IF EXISTS Band;
DROP TABLE IF EXISTS Mode;
DROP TABLE IF EXISTS Status;
DROP TABLE IF EXISTS BMS;
DROP VIEW  IF EXISTS UNCONFIRMED_VIEW;
DROP VIEW  IF EXISTS CONFIRMED_VIEW;
DROP VIEW  IF EXISTS NEED_TO_CONFIRM;
DROP VIEW  IF EXISTS DXCC_STATUS;
DROP VIEW  IF EXISTS MISSING_MODES;


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

CREATE VIEW CONFIRMED_VIEW as select  distinct l.dxcc, l.dxccadif, m.mid,l.mode,s.sid,s.name , l.lotwqsl, l.band  from logbook l ,Mode m, Status s, Band b  where m.name=l.mode and b.name=l.band and s.code = l.lotwqsl and s.name="CONFIRMED" ORDER BY 1,2,3,4,5,6,7,8
/* COFN_VIEW(dxccadif,mid,mode,sid,name,lotwqsl,band) */;


CREATE VIEW UNCONFIRMED_VIEW as select  distinct l.dxcc, l.dxccadif, m.mid,l.mode,s.sid,s.name , l.lotwqsl, l.band  from logbook l ,Mode m, Status s, Band b  where m.name=l.mode and b.name=l.band and s.code = l.lotwqsl and s.name="NOT CONFIRMED" ORDER BY 1,2,3,4,5,6,7,8
/* UNCOFN_VIEW(dxccadif,mid,mode,sid,name,lotwqsl,band) */;

create view dxcc_status as
select * from (select * from CONFIRMED_VIEW cv  UNION ALL
 select * from UNCONFIRMED_VIEW uv where not exists (select * from CONFIRMED_VIEW cv where cv.dxccadif==uv.dxccadif and cv.mid == uv.mid and cv.     band = uv.band))
  order by dxcc, mode,band,name;

CREATE VIEW NEED_TO_CONFIRM AS  select * from UNCONFIRMED_VIEW uv where not exists (select * from CONFIRMED_VIEW cv where uv.dxcc == cv.dxcc and uv.mid == cv.mid and uv.band == cv.band);

CREATE VIEW MISSING_MODES as      
    SELECT MODE FROM logbook l WHERE NOT EXISTS (SELECT * from Mode m where m.logname=l.mode);

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
