# CRAQ
### Pinpoint assembly errors for genomic assessing and correcting
![image](https://github.com/JiaoLaboratory/CRAQ/blob/main/Doc/Fig.png)

## Summary
CRAQ (Clipping Reveals Assembly Quality) is a reference-free genome assembly evaluator that can assess the accuracy of assembled genomic sequences and provide detailed assembly quality assessment from multiple perspectives. It can report precise locations of small-scale Clip-based Regional Errors (CREs), large-scale Clip-based Structural Errors (CSEs), as well as regional and overall AQI metrics (S-AQI & L-AQI) for assembly evaluation. Through evaluating a large set of genome assemblies with different qualities, we classified genomes as following: AQI > 90, reference quality; AQI from 80-90, high quality; AQI from 60-80, draft quality; and AQI < 60, low quality CRAQ also considered haplotype features which is important for identifying true misassembly. It can output coordinates of regional heterozygous variants (CRHs) and coordinates of structural heterozygous variants (CSHs) based on the ratio of clipped alignments and mapping coverage. Moreover, CRAQ detects potential chimeric contigs and break them at conflict breakpoints for assembly correction. This document has the information on how to run CRAQ.

## Installation

### Requirements
Note that CRAQ is temporarily supported on Linux, and will be developed on OSX and Windows in the future.

1. SAMtools((1.3.1+)) library for accessing SAM/BAM files, available from SourceForge:
    SAMtools: http://sourceforge.net/projects/samtools/files/
2. Minimap2 (2.1.7+) for reads mapping, available from SourceForge:
    Minimap2: https://github.com/lh3/minimap2
3. Perl (version >= 5)](https://www.perl.org/)
Both SAMtools and Minimap2 are straightforward to install following the instructions on its website.
Place the SAMtools and minimap2 executable in your path.
4. pycircos (python 3.7later) (https://github.com/ponnhide/pyCircos) 
Only required for plotting (pip install python-circos)  
### Install and test

```
$ git clone https://github.com/JiaoLaboratory/CRAQ.git  
$ cd CRAQ/Example/ && bash run_example.sh
```

## CRAQ running
### "craq" is implemented for assembly validation
CRAQ integrates the reads-mapping status (reads coverage & clipping signals) of NGS short-reads and SMS long-reads to detect types of assembly errors and heterozygous variants. The program requires an assembly in FASTA(.fa) format, and two fastq(.fq)/fasta(.fa) files representing NGS and SMS sequencing data as input. By default, Minimap2 ‘–ax sr’ and  ‘–ax map-hifi’(‘map-hifi’ for PacBio HiFi,‘map-pb’ for PacBio CLR, ‘map-ont’ for ONT library) options were used for genomic short illumina and long HiFi mapping, respectively. 
```
$ craq  -g  assembly.fa -sms SMS.fa.gz -ngs NGS_R1.fa.gz,NGS_R2.fa.gz -x map-hifi
```
Alternatively, users can map the reads to the assembly in advance and provide two sorted and indexed alignment files (sort.bam & sort.bam.bai) instead, which are highly recommended.
```
$ craq  -g assembly.fa -sms SMS_sort.bam -ngs NGS_sort.bam 
```     
 

###  Parameter settings
For more details about the usage and parameter settings, please see the help pages by running:
```
$ craq -h
```   Options:

      ***Help
            --help|-h                       Print the help message and exit.

      ***Required parameters
            --genome|-g                     Assembly sequence file (.fa)
            --sms_input|-sms                SMS long-read alignment(.bam) or sequences(.fq.gz)
            --ngs_input|-ngs                NGS short-read alignment(.bam) or sequences(.fq.gz), separated with comma if paired
      ***Filter parameters
            --min_ngs_clip_num|-sn          Minimum number of NGS clipped-reads. Default: 2
            --ngs_clip_coverRate|-sf        Minimum proportion of NGS clipped-reads. Default: 0.75
            --min_sms_clip_num|-ln          Minimum number of SMS clipped-reads. Default: 2
            --sms_clip_coverRate|-lf        Minimum proportion of SMS clipped-reads. Default: 0.75
            --he_min|-hmin                  Lower clipping rate for heterozygous allele. Default: 0.4
            --he_max|-hmax                  Upper clipping rate for heterozygous allele. Default: 0.6
            --min_gap_size|-mgs             Gap[N] length greater than the threshold will be treated as breakage. Default: 10
            --sms_coverage|-avgl            Average SMS coverage. Default: 100
            --ngs_coverage|-avgs            Average NGS coverage. Default: 100
      ***Other parameters
            --search_error|-ser             Search noisy error region nearby an CRE|CSE breakpoint. Default: "T" (time consuming)
            --gapmodel|-gm                  Gap[N] is treated as 1:CRE 2:CSE Default: 1
            --regional_window|-rw           Regional quality benchmarking. Default: 50000
            --break|-b                      Break chimera fragment. Default: F
            --map|-x                        Mapping use map-pb/map-hifi/map-ont for PacBio CLR/HiFi or Nanopore vs reference [ignored if .bam provided]. Default: map-hifi
            --mapq|-q                       Minimum reads mapping quality. Default: 20
            --norm_window|-nw               Window size for normalizing error count. Default: 0.0001*(total size)
            --plot|-pl                      Plotting CRAQ metrics. Default: F;  pycircos (python 3.7later) is required if "T"
            --plot_ids|-ids                 An file including selected assembly IDs for plotting. Default use all IDs.                       
            --thread|-t                     The number of thread used in alignment. Default: 10
            --output_dir|-D                 User-specified output directory. Default: ./Output

### Output files  
./runAQI_out/  
out_final.Report : Summary reports including classified  quality metrics(S-AQI, L-AQI) for single and whole assembly.  
out_regional.Report : Statistics for regional genomic metrics.  
out_circos.pdf : Drawing genomic metrics.  
out_correct.fa : A CRAQ-corrected FASTA fragments generated (if --break|-b T).  
locER_out/out_final.CRE.bed	: Exact coordinates of regional errors (CREs).  
locER_out/out_final.CRH.bed     : Exact coordinates of regional heterozygous indels (CRHs).  
locER/ambiguous.RE.RH : Coordinates of some ambiguous regions-maybe small-regional error or heterozygous indels (CRE|CRHs).  
strER_out/out_final.CSE.bed	: Exact coordinates of large structural breakage (CSEs).  
strER_out/out_final.CSH.bed	: Exact coordinates of structral heterozygous variants (CSHs).  
strER_out/ambiguous.SE.SH : Coordinates of some ambiguous regions-maybe structural error or heterozygous variants (CSE|CSHs).  
low_confidence.bed : low confident genomic regions at current parameter settings.  

./LRout/  
LR_sort.bam	: Filtered SMS alignment file, for view inspection in genome browser.  
LR_sort.bam.bai	: Index of alignment file.  
LR_sort.depth	: SMS mapping coverage.  
LR_clip.coverRate: All output of SMS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at the position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
LR_putative.SE.SH  : Coordinates of putative large structural errors or variant breakages (putative CSE|CSHs). Filtered from LR_clip.coverRate file.  

./SRout/  
SR_sort.bam     : Filtered NGS alignment file, could for view inspection in Genome Browsers.  
SR_sort.bam.bai : Index of alignment file.  
SR_sort.depth   : NGS mapping coverage.  
SR_clip.coverRate: All output of NGS clipping positions, with columns:chr, position, strand, number of clipped-reads, and total coverage at that position. The strand is just left-clipped(+) or right-clipped(-) to help identify the clipping orientation.  
SR_putative.RE.RH	: Coordinates of putative small-scale regional errors or heterozygous indel breakages (putative CRE|CRHs). Filtered from SR_clip.coverRate file.  

### Visually inspecting
Genome Browsers as Integrative Genomics Viewer (IGV) can be used for visually inspecting, details here: https://github.com/JiaoLaboratory/CRAQ/blob/main/Doc/loadIGVREADME.md

### Parallel running to speed up
Reads mapping is currently the most time-consuming step of CRAQ, especially for long reads mapping. Users can run the core CRAQ programs separately to increase speed. Details here: https://github.com/JiaoLaboratory/CRAQ/blob/main/Doc/steprunREADME.md  
### Running with NGS or long SMS data only
If the users only have NGS data or SMS long read dta, CRAQ could just take one of these datasets at the expense of some reliability or informativity.
Run CRAQ with SMS long read data only:  
```
$ craq  -g assembly.fa -sms SMS_sort.bam
```     
Run CRAQ with NGS data only:
```
$ craq  -g assembly.fa -ngs NGS_sort.bam
```     
