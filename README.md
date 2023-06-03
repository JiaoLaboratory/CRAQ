# CRAQ:
### Pinpoint assembly errors for genomic assessing and correcting
![image](https://github.com/JiaoLaboratory/CRAQ/blob/main/Fig.png) 
## Summary
CRAQ (Clipping Reveals Assembly Quality), a reference-free genome assembly evaluator could assess assembly accuracy and provide detailed assembly error information. This information includes precise locations of small-scale local errors (SERs), large-scale structural errors (LERs), and regional and overall classified AQI metrics (S-AQI & L-AQI) for assembly validation. CRAQ considers the haplotype features, and provide precise locus of heterozygous regions (SHRs & LHRs) based on the ratio of clipped alignments and mapping coverage. Moreover, CRAQ could identify underlying chimeric contigs and break them at conflict breakpoints prior to pseudomolecule construction. This document has the information on how to run CRAQ.

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
4. pycircos (python 3.7later) (https://github.com/ponnhide/pyCircos) 
Only required for plotting (pip install python-circos)  
### Install

```
$ git clone https://github.com/JiaoLaboratory/CRAQ.git
```

### CRAQ running
#### "craq" is implemented for assembly validation
CRAQ intergrates the reads-mapping status (including reads coverage, clipping signals) of NGS short-reads and SMS long-reads to identify types of assembly errors and heterozygous variants. The process is simple to run, requiring as input an assembly in FASTA(.fa) format, and two fastq(.fq)/fasta(.fa) files representing NGS and SMS sequencing data. Alternatively, the user can map the reads to the assembly in advance and provide two BAM files as input. By default, Minimap2 ‘–ax sr’ and  ‘–ax map-hifi’(‘map-hifi’ for PacBio HiFi,‘map-pb’ for PacBio CLR, ‘map-ont’ for ONT library) options were selected for genomic short illumina and long HiFi mapping, respectively.

When mapping alignment file (.bam) are provided: (recommended). Important: sorting (samtools sort) and indexing (samtools index) all bam files before running the pipeline is required.
```
$ craq  -g your_assembly.fa -lr SMS_sort.bam -sr NGS_sort.bam 
```     
If only sequencing reads are available, By default, read mapping is implemented using Minimap2.   
```
$ craq  -g  your_assembly.fa -lr SMS.fa.gz -sr NGS_R1.fa.gz,NGS_R2.fa.gz
```

### Main output (runAQI_out):  

locER_out/out_final.SER.bed	: Exact coordinates of small regional errors.  
locER_out/out_final.SHR.bed     : Exact coordinates of small heterozygous indels.  
strER_out/out_final.LER.bed	: Exact coordinates of large structral error breakage.  
strER_out/out_final.LHR.bed	: Exact coordinates of structral heterozygous variants.  
out_regional.Report : Statistics for regional genomic metrics.  
out_final.Report : Summary reports inclinding classfied quality metrics(S-AQI, L-AQI) for single scaffold and whole-assembly.  
out_circos.pdf : Drawing genomic metrics.  
out_correct.fa	: A CRAQ-corrected FASTA fragments generated (if --break|-b T)  

Genome Browsers as Integrative Genomics Viewer (IGV) can be used for visually inspecting, details here: https://github.com/JiaoLaboratory/CRAQ/blob/main/src/stepREADME.md


##  Parameter settings
For more details about the usage and parameter settings, please see the help pages by running:
```
$ craq -h
```
Usage:
      craq [options] -g genome.fa -lr SMS_sort.bam -sr NGS_sort.bam

     Options:

      ***Help
            --help|-h                       Print the help message and exit.

      ***Required parameters
            --genome|-g                     Assembly sequence file (.fa)
            --sms_input|-lr                 SMS long-read alignment(.bam) or sequences(.fq.gz)
            --ngs_input|-sr                 NGS short-read alignment(.bam) or sequences(.fq.gz), separated with comma if paired
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
            --gapmodel|-gm                  Gap[N] is treated as 1:SER 2:LER. Default: 1
            --regional_window|-rw           Regional quality score. Default: 50000
            --break|-b                      Break chimera fragment. Default: F
            --map|-x                        Mapping use map-pb/map-hifi/map-ont for PacBio CLR/HiFi or Nanopore vs reference [ignored if .bam provided]. Default: map-hifi
            --mapq|-q                       Minimum reads mapping quality. Default: 20
            --plot|-pl                      Plotting CRAQ metrics. Default: F;  pycircos (python 3.7later) is required if "T"
            --plot_ids|-ids                 An file including selected assembly IDs for plotting. Default use all IDs.                       
            --thread|-t                     The number of thread used in alignment. Default: 10



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
$ craq  -g  Genome.fa -lr SMS.part_001.fa,SMS.part_002.fa,SMS.part_003.fa,SMS.part_004.fa -sr  NGS_R1.fa.gz,NGS_R2.fa.gz
```
