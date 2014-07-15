
all:FIO-GNU.pdf

linux.txt:linux.log
	awk -f process-log.awk $< > $@

vm.txt:vm.log
	awk -f process-log.awk $< > $@

docker.txt:docker.log
	awk -f process-log.awk $< > $@


FIO-GNU.pdf:linux.txt vm.txt docker.txt gnuplot-pdf.script
	gnuplot gnuplot-pdf.script
