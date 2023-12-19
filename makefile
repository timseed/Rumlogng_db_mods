PYENV:=source ~/pe310/bin/activate
DB:=Qso.db
DB_SRC:=~/Documents/DV3A.rlog

.PHONY : $(DB)
$(DB): 
	$(info Copy $(DB))
	$(shell cp $(DB_SRC) $(DB))

.PHONY: setup
setup:
	$(shell sqlite3 $(DB)  < my_upgrade.sql > my_update.log)
	$(info DB stage finished)
	($(PYENV);\
		python3 python_load.py;\
	  echo  Python Load finished;\
		)


.PHONY: clean 
clean:
		rm -f $(DB)
		rm -f *.log
