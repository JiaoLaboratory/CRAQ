#Get genome size file
rm -rf SRout LRout runAQI_out #
perl ../src/fetch_size.pl Genome.fa >Genome.fa.size #
#Assessing  
perl ../bin/craq -g Genome.fa -z Genome.fa.size -lr SMS_sort.bam  -sr NGS_sort.bam -rw 50000 -x map-ont  
