PYENV:=source ~/pe310/bin/activate
DB:=Qso.db
DB_SRC:=~/Documents/DV3A.rlog
NOW := $(shell date +"%Y%m%d" )

all: 
	$(MAKE) backup
	$(MAKE) $(DB) 
	$(MAKE) fill_in_missing
	$(MAKE) qsl_track_setup

.PHONY: backup
backup:
	$(shell cp $(DB_SRC) $(NOW).db)
	$(info DV3A backed up to $(NOW).db)

.PHONY : $(DB)
$(DB): backup
	$(info Copy $(DB))
	$(shell cp $(DB_SRC) $(DB))
	$(info Copy of Db made locally as $(DB))

.PHONY: qsl_track_setup
qsl_track_setup:
	$(shell sqlite3 $(DB)  < my_upgrade.sql > my_update.log)
	$(info DB stage finished)
	($(PYENV);\
		python3 python_load.py;\
	  echo  Python Load finished;\
		)

.PHONY: fill_in_missing
fill_in_missing:
	sqlite3 $(DB) < auto.sql > auto_results.txt
	$(info Db Updated)


.PHONY: clean 
clean:
		rm -f $(DB)
		rm -f *.log
