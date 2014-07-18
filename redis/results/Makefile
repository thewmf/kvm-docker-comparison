
GRAPHS=Redis-latency.pdf Redis-throughput.pdf

DATAFILES = $(wildcard *.txt)

all : $(DATAFILES:.txt=.csv) $(GRAPHS)

%.csv : %.txt
	@echo '"Experiment","Run","Connections","Test","Throughput"' > $@
	@./parseDataToCsv.py $< >> $@

%.lf: %.csv
	tr "\r" "\n" < $< | grep "^[0-9]" > $@

Redis-latency.pdf: Redis-latency.lf gnuplotLatency-pdf.script
	gnuplot gnuplotLatency-pdf.script


Redis-throughput.pdf: Redis-throughput.lf gnuplotThroughput-pdf.script
	gnuplot gnuplotThroughput-pdf.script


