####
rm -rf SRout LRout  #
#Assessing  
perl ../bin/craq -g Genome.fa -lr SMS_sort.bam  -sr NGS_sort.bam -rw 50000 -x map-ont  
