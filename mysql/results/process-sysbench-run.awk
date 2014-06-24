BEGIN {
	oltpStat = 0;
	testSummary = 0;
	perReq = 0;
	resultsFound = 0;
}

/Number of threads:/ {
	x=match($0,"[0-9]");
	if (x > 0) {
		numTthreads=substr($0,x);
	}
	else {
		numTthreads = "0";
	}
	oltpStat = 0;
	testSummary = 0;
}


/OLTP test statistics:/ {
	oltpStat = 1;
}

/read:/ && oltpStat {
	x=match($0,"[0-9]");
	if (x > 0) {
		readOltp=substr($0,x);
	}
	else {
		readOltp = "0";
	}
}
/write:/ && oltpStat {
	x=match($0,"[0-9]");
	if (x > 0) {
		writeOltp=substr($0,x);
	}
	else {
		writeOltp = "0";
	}
}
/other:/ && oltpStat {
	x=match($0,"[0-9]");
	if (x > 0) {
		otherOltp=substr($0,x);
	}
	else {
		otherOltp = "0";
	}
}
/total:/ && oltpStat {
	x=match($0,"[0-9]");
	if (x > 0) {
		totalOltp=substr($0,x);
	}
	else {
		totalOltp = "0";
	}
}
/transactions:/ && oltpStat {
	x=match($0,"[0-9]");
	if (x > 0) {
		transOltp=substr($0,x);
		x=index(transOltp," ");
		transOltp=substr(transOltp,1,x-1);
	}
	else {
		transOltp = "0";
	}
}
	
/Test execution summary:/ {
	oltpStat = 0;
	testSummary = 1;
	perReq = 0;
}

/total time:/ && testSummary {
	x=match($0,"[0-9]");
	if (x > 0) {
		timeOltp=substr($0,x);
		x=index(timeOltp,"s");
		timeOltp=substr(timeOltp,1,x-1);
	}
	else {
		timeOltp = "0";
	}
}
/per-request statistics:/ && testSummary {
	perReq = 1;
}

/min/ && perReq {
	x=match($0,"[0-9]");
	if (x > 0) {
		minLatOltp=substr($0,x);
		x=index(minLatOltp,"ms");
		minLatOltp=substr(minLatOltp,1,x-1);
	}
	else {
		minLatOltp = "0";
	}
}

/max/ && perReq {
	x=match($0,"[0-9]");
	if (x > 0) {
		maxLatOltp=substr($0,x);
		x=index(maxLatOltp,"ms");
		maxLatOltp=substr(maxLatOltp,1,x-1);
	}
	else {
		maxLatOltp = "0";
	}
}


/avg/ && perReq {
	x=match($0,"[0-9]");
	if (x > 0) {
		avgLatOltp=substr($0,x);
		x=index(avgLatOltp,"ms");
		avgLatOltp=substr(avgLatOltp,1,x-1);
	}
	else {
		avgLatOltp = "0";
	}
}

/95 percentile:/ && perReq {
	x=match($0,":");
	if (x > 0) {
		per95LatOltp=substr($0,x);
		x=match(per95LatOltp,"[0-9]");
		per95LatOltp=substr(per95LatOltp,x);
		x=index(per95LatOltp,"ms");
		per95LatOltp=substr(per95LatOltp,1,x-1);
	}
	else {
		per95LatOltp = "0";
	}
	perReq = 0;
}

/multi-threaded system evaluation benchmark/ {
	if (resultsFound) {
		printf "%d,%f,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f\n", numTthreads, transOltp/timeOltp,readOltp, writeOltp, otherOltp, totalOltp, transOltp, timeOltp, minLatOltp, avgLatOltp, maxLatOltp, per95LatOltp
	}
	resultsFound = 1;
}

END {
	if (resultsFound) {
		printf "%d,%f,%d,%d,%d,%d,%d,%f,%f,%f,%f,%f\n", numTthreads, transOltp/timeOltp,readOltp, writeOltp, otherOltp, totalOltp, transOltp, timeOltp, minLatOltp, avgLatOltp, maxLatOltp, per95LatOltp
	}
}

