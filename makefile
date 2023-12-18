PYENV:=source ~/pe310/bin/activate
DB:=Qso.db
DB_SRC:=~/Documents/DV3A.rlog
COPY:=$(shell cp $(DB_SRC) $(DB))
DB_UPD:=$(shell sqlite3 $(DB)  < my_upgrade.sql > my_update.log)
LOAD_DATA:=$(shell )
.DEFAULT_GOAL := $(DB) 

.PHONY: $(DB)
$(DB): $(DB_SRC)
	$(info Copy $(DB))
	$(COPY)
	$(DB_UPD)
	$(info DB stage finished)
	($(PYENV);\
		python3 python_load.py;\
	  echo  Python Load finished;\
		)

clean:
		rm $(DB)
