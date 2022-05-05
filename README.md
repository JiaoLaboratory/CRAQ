# CRAQ:
### Clipping information for Revealing Assembly Quality

## Summary
CRAQ (Clipping information for Revealing Assembly Quality), a reference-free tool that precisely pinpoints genome assembly errors. CRAQ can identify small-scale local error (SER) and large-scale structural error (LER) using a combinative alignment evidence of short NGS and long SMS reads, and then intergrate SER/LER calling into a comprehensive assembly quality indicator-AQI. Moreover, CRAQ could identify underlying chimeric contigs and break them at conflict breakpoints prior to pseudomolecule construction if user needed. This document has the information on how to run CRAQ.

## Installation

### Requirements:
CRAQ should install on most standard flavors of Linux (OSX and Windows are currently under development). Before running CRAQ, you need to make sure that several pieces of software and/or modules are installed on the system:

1. SAMtools((1.3.1+)) library for accessing SAM/BAM files, available from SourceForge:
    SAMtools: http://sourceforge.net/projects/samtools/files/
2. Minimap2 (2.1.7+) for reads mapping, available from SourceForge:
    Minimap2: https://github.com/lh3/minimap2
3. Perl (version >= 5)](https://www.perl.org/)
Both SAMtools and Minimap2 are straightforward to install following the instructions on its website.
Place the SAMtools and minimap2 executable in your path.

### Install

```
$ git clone https://github.com/JiaoLaboratory/CRAQ.git
```
## Quick Start
```
$ cd CRAQ/example && bash run_example.sh
```

### CRAQ running
#### "craq" is implemented for assembly validation
CRAQ intergrates the reads-mapping status (including reads coverage, clipping signals) of NGS short-reads and SMS long-reads to identify SER and LER breakpoint. The process is simple to run, requiring as input an assembly in FASTA(.fa) format, a sequence size file(.size) and two fastq(.fq)/fasta(.fa) files representing NGS and SMS sequencing data. Alternatively, the user can map the reads to the assembly in advance and provide two BAM files as input. By default, Minimap2 ‘–ax sr’ and  ‘–ax map-hifi’(‘map-ont’ for ONT and ‘map-pb’ for PacBio CLR library) options were selected for genomic short-read and long-read mapping, respectively.

#### Usage
So easy! When mapping alignment file (.bam) are provided: (recommended). Important: sorting (samtools sort) and indexing (samtools index) all bam files before running the pipeline is required.
```
$ craq  -g  genome.fa -z genome.fa.size -lr SMS_sort.bam -sr NGS_sort.bam
```     
If only sequencing reads are available, By default, read mapping is implemented using Minimap2.   
```
$ craq  -g  genome.fa -z genome.fa.size -lr SMS_query.fq.gz -sr NGS_pair1.fq.gz,NGS_pair2.fq.gz
```
Note:
Read mapping is currently the most resource intensive step of CRAQ, especially for long reads mapping. Alternatively, splitting query sequences into multiple pieces for multitasking alignments will benefit time cost. SeqKit (https://bioinf.shenwei.me/seqkit/) could be implemented to split SMS sequences into number of parts for user.
```
$ conda install seqkit   
```
i.e. split long-read sequences into 4 parts
```
$ seqkit split SMS_query.fa  -p 4 -f
```
Which will output: SMS_query.part_001.fa, SMS_query.part_002.fa, SMS_query.part_003.fa, SMS_query.part_004.fa, then performing the following running will reduce the time for sequence alignment
```
$ craq  -g  genome.fa -z genome.size -lr SMS_query.part_001.fa,SMS_query.part_002.fa,SMS_query.part_003.fa,SMS_query.part_004.fa -sr  NGS_pair1.fq.gz,NGS_pair2.fq.gz
```
In addition, if only one of SMS or NGS alignment (.bam) file is available, the following operations are also optional:
```
$ craq -g genome.fa -z genome.fa.size -lr SMS_query.fa -sr NGS_sort.bam
```
or 
```
$ craq -g genome.fa -z genome.fa.size -lr SMS_sort.bam -sr NGS_pair1.fq.gz,NGS_pair2.fq.gz
```
#### step-by-step also supported
     
1. SMS read mapping, filtering and putative LER calling.
```
$ bash src/runLR.sh -g  genome.fa -z  genome.fa.size -1 lr_sorted.bam 
```
or 
```     
$ bash src/runLR.sh -g  genome.fa -z genome.fa.size -1 Pac/ONT.fa.gz -x map-pb -t 10
```
LRout:  
LR_sort.bam	: Filtered SMS alignment file, for view inspection in genome browser.  
LR_sort.bam.bai	: Index of alignment file. 
LR_sort.depth	: SMS mapping coverage.  
LR_clip.coverRate: All output of SMS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at the position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
LR_putative.ER  : Coordinates of putative LER breakages. Filtered (by the -ln and -lf options) from LR_clip.coverRate file.  

2. NGS read mapping, filtering and putative SER calling.
```
$ bash src/runSR.sh -g  genome.fa  -z genome.fa.size  -1 sr_sorted.bam
```
or
```
$ bash src/runSR.sh -g  genome.fa  -z genome.fa.size  -1 NGS_pair1.fq.gz -2 NGS_pair2.fq.gz -t 10
```
SRout:  
SR_sort.bam     : Filtered NGS alignment file, for view inspection in genome browser.  
SR_sort.bam.bai : Index of alignment file.  
SR_sort.depth   : NGS mapping coverage.	 
SR_clip.coverRate: All output of NGS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at that position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
SR_putative.ER	: Coordinates of putative SER breakages. Filtered (by the -sn and -sf options) from SR_clip.coverRate file.  

Note:  
If user used 'bowtie2' generate shortRead alignment in advance, the '--local'(local alignment) option should be performed for generating clipping signal.  

3. Benchmark genomic quality using AQI.       
```
$ bash src/runAQI.sh -g  Genome.fasta -z  Genome.fasta.size -e SRout/SR_eff.size  -c SRout/SR_putative.ER -C LRout/LR_putative.ER  -d SRout/SR_sort.depth  -D LRout/LR_sort.depth
``` 
Main output(runAQI):  
locER_out/final.SER.out	: Exact coordinates of SER breakage, supported by SMS.  
strER_out/final.LER.out	: Exact coordinates of LER breakage, supported by NGS.  
regional.Report : Statistics for regional metrics.  
final.Report : Summary quality metrics for single segment and whole-assembly.  
out_correct.fa	: A CRAQ-corrected FASTA fragments generated (if --break|-b T)

Note:       
Step1 and step2 can be performed simultaneously to accelerate the process 

#### Usage
For more details about the usage and parameter settings, please see the help pages by running:
```
$ craq -h
```
