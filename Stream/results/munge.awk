BEGIN {
	expts[0] = "Copy"
	expts[1] = "Scale"
	expts[2] = "Add"
	expts[3] = "Triad"
}


{
	num[$1] += 1
	t[$1,num[$1]] = $2
}

END {
	for (i = 0; i < 4; i++) {
		curr = expts[i]
# 		min[curr] = t[curr,1]
# 		max[curr] = t[curr,num[curr]]
# 		nhalf = sprintf ("%d", num[curr]/2) 
# 		med[curr] = t[curr,nhalf]

		tot = 0
		for (j = 1; j <= num[curr]; j++) {
			tot = tot + t[curr,j]
		}
		avg[curr] = tot / num[curr]

		tot = 0
		for (j = 1; j <= num[curr]; j++) {
			tot = tot + ((t[curr,j] - avg[curr]) * (t[curr,j] - avg[curr]))
		}
		sd[curr] = sqrt (tot/num[curr])


		if (caption) {
			printf "%s\t%s\n", curr, avg[curr]
		}
		else {
			printf "\t%s\n", avg[curr]
		}
	}

	for (i = 0; i < 4; i++) {
		curr = expts[i]
		errmin = sd[curr]	# med[curr] - min[curr]
		errmax = sd[curr]	# max[curr] - med[curr]
		if (caption) {
			printf "%s\t%s\n", curr "ErrMax", errmax
		}
		else {
			printf "\t%s\n", errmax
		}
	}

	for (i = 0; i < 4; i++) {
		curr = expts[i]
		errmin = sd[curr]	# med[curr] - min[curr]
		errmax = sd[curr]	# max[curr] - med[curr]
		if (caption) {
			printf "%s\t%s\n", curr "ErrMin", errmin
		}
		else {
			printf "\t%s\n", errmin
		}
	}

}
