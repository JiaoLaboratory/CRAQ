
#Get size file
rm -rf SRout LRout runAQI_out
perl ../src/fetch_size.pl Genome.fa >Genome.fa.size
##
#Assessing
perl ../bin/craq -g Genome.fa -z Genome.fa.size -lr SMS.bam  -sr NGS.bam -x map-ont 


