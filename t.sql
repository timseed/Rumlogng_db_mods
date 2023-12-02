drop table BMS;
create table BMS (bid Integer NOT NULL, mid Integer NOT NULL, sid Integer NOT NULL,
    PRIMARY KEY (bid, mid, sid),
    FOREIGN KEY (bid)REFERENCES Band (bid)  
    FOREIGN KEY (mid)REFERENCES Mode (mid)  
    FOREIGN KEY (sid)REFERENCES Status (sid)  
    ); 

.schema BMS
