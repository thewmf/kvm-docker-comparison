BEGIN {
	clat = 0;
}
/random-read-16: \(groupid/ {
	#print "Found beginning",$0
	clat=1;
}
/^ *\|/ && clat {
	nr=split($0,per,",");
	for(i=1;i<=nr;i++) {
		x=match(per[i],"[0-9]+\.[0-9][0-9]th=");
		if (x == 0) {
			continue;
		}
		val=substr(per[i],x);
		x=match(val,"th=");
		valPer=substr(val,1,x-1);
		y=index(val,"\]");
		valVal=substr(val,x+5,y-(x+5));
		print valPer,valVal;

	}
}
/^ *bw/ && clat {
	clat=0;
}
