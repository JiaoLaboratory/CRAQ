# CRAQ:
### Pinpoint assembly errors for genomic assessing and correcting

## Summary
CRAQ (Clipping Reveals Assembly Quality), a reference-free genome assembly evaluator could assess assembly accuracy and provide detailed assembly error information. This information includes precise locations of small-scale local errors (SERs), large-scale structural errors (LERs), and regional and overall classified AQI metrics (S-AQI & L-AQI) for assembly validation. CRAQ considers the haplotype features in diploid or polyploid genomes, and provide precise locus of heterozygous regions (SHRs & LHRs) based on the ratio of clipped alignments and mapping coverage. Moreover, CRAQ could identify underlying chimeric contigs and break them at conflict breakpoints prior to pseudomolecule construction. This document has the information on how to run CRAQ.

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
$ cd CRAQ/Example && bash run_example.sh
```

### CRAQ running
#### "craq" is implemented for assembly validation
CRAQ intergrates the reads-mapping status (including reads coverage, clipping signals) of NGS short-reads and SMS long-reads to identify types of assembly errors and heterozygous variants. The process is simple to run, requiring as input an assembly in FASTA(.fa) format, a sequence size file(.size) and two fastq(.fq)/fasta(.fa) files representing NGS and SMS sequencing data. Alternatively, the user can map the reads to the assembly in advance and provide two BAM files as input. By default, Minimap2 ‘–ax sr’ and  ‘–ax map-hifi’(‘map-hifi’ for PacBio HiFi,‘map-pb’ for PacBio CLR, ‘map-ont’ for ONT library) options were selected for genomic short illumina and long HiFi mapping, respectively.

#### Usage
When mapping alignment file (.bam) are provided: (recommended). Important: sorting (samtools sort) and indexing (samtools index) all bam files before running the pipeline is required.
```
$ craq  -g  Genome.fa -z Genome.fa.size -lr SMS_sort.bam -sr NGS_sort.bam
```     
If only sequencing reads are available, By default, read mapping is implemented using Minimap2.   
```
$ craq  -g  Genome.fa -z Genome.fa.size -lr SMS.fa.gz -sr NGS_R1.fa.gz,NGS_R2.fa.gz
```
Note:
Read mapping is currently the most resource intensive step of CRAQ, especially for long reads mapping. Alternatively, splitting query sequences into multiple pieces for multitasking alignments will benefit time cost. SeqKit (https://bioinf.shenwei.me/seqkit/) could be implemented to split SMS sequences into number of parts for user.
```
$ conda install seqkit   
```
i.e. split long-read sequences into 4 parts
```
$ seqkit split SMS.fa  -p 4 -f
```
Which will output: SMS.part_001.fa, SMS.part_002.fa, SMS.part_003.fa, SMS.part_004.fa, then performing the following running will reduce the time for sequence alignment
```
$ craq  -g  Genome.fa -z Genome.size -lr SMS.part_001.fa,SMS.part_002.fa,SMS.part_003.fa,SMS.part_004.fa -sr  NGS_R1.fa.gz,NGS_R2.fa.gz
```
In addition, if only one of SMS or NGS alignment (.bam) file is available, the following operations are also optional:
```
$ craq -g Genome.fa -z Genome.fa.size -lr SMS.fa.gz -sr NGS_sort.bam
```
or 
```
$ craq -g Genome.fa -z Genome.fa.size -lr SMS_sort.bam -sr NGS_R1.fa.gz,NGS_R2.fa.gz
```
#### step-by-step also supported
     
1. SMS read mapping, filtering and putative LER calling.
```
$ bash src/runLR.sh -g  Genome.fa -z  Genome.fa.size -1 SMS_sort.bam 
```
or 
```     
$ bash src/runLR.sh -g  Genome.fa -z Genome.fa.size -1 Pac/ONT.fa.gz -x map-pb -t 10
```
LRout:  
LR_sort.bam	: Filtered SMS alignment file, for view inspection in genome browser.  
LR_sort.bam.bai	: Index of alignment file.  
LR_sort.depth	: SMS mapping coverage.  
LR_clip.coverRate: All output of SMS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at the position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
LR_putative.ER.HR  : Coordinates of putative structral errors or variant breakages. Filtered from LR_clip.coverRate file.  

2. NGS read mapping, filtering and putative SER calling.
```
$ bash src/runSR.sh -g  Genome.fa  -z Genome.fa.size  -1 NGS_sort.bam
```
or
```
$ bash src/runSR.sh -g  Genome.fa  -z Genome.fa.size  -1 NGS_R1.fq.gz -2 NGS_R2.fq.gz -t 10
```
SRout:  
SR_sort.bam     : Filtered NGS alignment file, for view inspection in genome browser.  
SR_sort.bam.bai : Index of alignment file.  
SR_sort.depth   : NGS mapping coverage.  
SR_clip.coverRate: All output of NGS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at that position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
SR_putative.ER	: Coordinates of putative small-scale errors or heterozygous indel breakages. Filtered from SR_clip.coverRate file.

Note:  
If user used 'bowtie2' generate shortRead alignment in advance, the '--local'(local alignment) option should be performed for generating clipping signal.  

3. Benchmark genomic quality using AQI.       
```
$ bash src/runAQI.sh -g  Genome.fasta -z  Genome.fasta.size -e SRout/SR_eff.size  -c SRout/SR_putative.ER.HR -C LRout/LR_putative.ER.HR  -d SRout/SR_sort.depth  -D LRout/LR_sort.depth
``` 
Main output(runAQI_out):  

locER_out/out_final.SER.out	: Exact coordinates of small regional errors.  
locER_out/out_final.SHR.out     : Exact coordinates of small heterozygous indels.  
strER_out/out_final.LER.out	: Exact coordinates of large structral error breakage.  
strER_out/out_final.LHR.out	: Exact coordinates of structral heterozygous variants.  
out_regional.Report : Statistics for regional genomic metrics.  
out_final.Report : Summary reports inclinding classfied quality metrics(S-AQI, L-AQI) for single scaffold and whole-assembly.  
out_correct.fa	: A CRAQ-corrected FASTA fragments generated (if --break|-b T)

Note:       
Step1 and step2 can be performed simultaneously to accelerate the process 

#### Usage
For more details about the usage and parameter settings, please see the help pages by running:
```
$ craq -h
```
