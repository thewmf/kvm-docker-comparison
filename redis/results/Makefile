
DATAFILES = $(wildcard *.txt)

all : $(DATAFILES:.txt=.csv)

%.csv : %.txt
	@echo '"Experiment","Run","Connections","Test","Throughput"' > $@
	@./parseDataToCsv.py $< >> $@
