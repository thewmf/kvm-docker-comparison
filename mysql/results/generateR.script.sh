echo "procData=c(1:(9*2*17))"
echo "dim(procData)=c(9,2,17)"
j=0;
while [ $j -lt 17 ]
do
	i=0;
	while [ $i -lt 9 ]
	do
		echo "decode_${j}_${i} <- read.csv(header=0,sep=\",\",file=\"decoded-${j}-${i}.csv\")"
		echo "procData["$(($i+1))",1,"$(($j+1))"]=mean(decode_${j}_${i}[,4])" 
		echo "procData["$(($i+1))",2,"$(($j+1))"]=sd(decode_${j}_${i}[,4])"
		i=$(($i+1))
	done
	j=$(($j+1))
done
echo "procStat=c(1:51)"
echo "dim(procStat)=c(17,3)"
echo "for(i in 1:17) {"
echo "procStat[i,1] <- min(100-procData[,1,i])" 
echo "procStat[i,2] <- mean(100-procData[,1,i])" 
echo "procStat[i,3] <- max(100-procData[,1,i])" 
echo "}"
echo "print(procStat)"
