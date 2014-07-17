BEGIN {
	nLines = 0;
	zeroLow = 0;
	numStops = -1;
	numFile = 0;
	FS=",";
	OUTFILE="decoded-"numStops".csv";
}

$1 ~ /^\"/ {
	header=$0;
	print header;
}

$1 ~ /^[0-9][.0-9]*$/ && $1 < 2.0 {
	if (zeroLow == 0) {
	#	print numStops","oldData > OUTFILE;
		# first zero so count as # zeros
		if (numStops >= 0) {
			#print numStops,nSum,sumIdle/nSum,(sumSqIdle-((sumIdle*sumIdle)/nSum))/(nSum-1);
			#print numStops,nSum,sumIdle,sumSqIdle;
			nSum = 0;
			sumIdle = 0;
			sumSqIdle = 0;
			close(OUTFILE);
		}
		numStops++;
		OUTFILE="decoded-"numStops".csv";
		zeroLow = 1;
		printHeader = 1;
	}
	else {
	#	if (numStops > 0) {
	#		print numStops","oldData > OUTFILE;
	#	}
	}
	oldData = $0;
}

$1 >= 2.0 {
	if (zeroLow == 1) {
		zeroLow = 0;
		skipFirst = 0;
	}
	else
	{
		if (skipFirst > 0) {
			nSum += 1;
			if (printHeader) {
				print header > OUTFILE;
				printHeader = 0;
			}
			print oldData > OUTFILE;
		}
		skipFirst = 1;
	}
	oldData = $0;
}

