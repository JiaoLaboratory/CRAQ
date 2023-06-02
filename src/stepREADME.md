# Step-by-step instructions  
## Quick start using the test data
```
$ cd CRAQ/Example && bash run_example.sh
```
![image](https://github.com/JiaoLaboratory/CRAQ/assets/65637958/0412a038-8268-4186-9530-554aac0fb52d)


## CRAQ would output following 

### Main output (runAQI_out):  

locER_out/out_final.SER.bed	: Exact coordinates of small regional errors.  
locER_out/out_final.SHR.bed     : Exact coordinates of small heterozygous indels.  
strER_out/out_final.LER.bed	: Exact coordinates of large structral error breakage.  
strER_out/out_final.LHR.bed	: Exact coordinates of structral heterozygous variants.  
out_regional.Report : Statistics for regional genomic metrics.  
out_final.Report : Summary reports inclinding classfied quality metrics(S-AQI, L-AQI) for single scaffold and whole-assembly.  
out_circos.pdf : Drawing genomic metrics.  
out_correct.fa	: A CRAQ-corrected FASTA fragments generated (if --break|-b T)  

Load output to IGV: 
![image](https://github.com/JiaoLaboratory/CRAQ/blob/main/Example/Example.png)
Note:       
Step1 and step2 can be performed simultaneously to accelerate the process 
Load CRAQ output to IGV:
## Usage
For more details about the usage and parameter settings, please see the help pages by running:
```
$ craq -h
```
