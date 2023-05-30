####
rm -rf SRout LRout  #
#Assessing  
perl ../bin/craq -g Genome.fa -lr SMS_sort.bam  -sr NGS_sort.bam -rw 1300 -x map-ont -pl T 
