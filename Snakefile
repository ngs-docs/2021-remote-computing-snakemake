SAMPLES=["ERR458493", "ERR458501", "ERR458494", "ERR458500"]
print('samples are:', SAMPLES)
rule all:
    input:
        expand("{sample}_fastqc.html", sample=SAMPLES),
        "orf_coding.fasta.gz",
        "yeast_orfs",
        expand("{sample}.quant", sample=SAMPLES),

rule make_fastqc:
    input:
        "{sample}.fastq.gz",
    output:
        "{sample}_fastqc.html",
        "{sample}_fastqc.zip"  
    shell:
        "fastqc {input}"
        
rule download_reference:
    output:
        "orf_coding.fasta.gz"
    shell:
        "curl -L -O https://downloads.yeastgenome.org/sequence/S288C_reference/orf_dna/orf_coding.fasta.gz"

rule index_reference:
    input:
        "orf_coding.fasta.gz"
    output:
        directory("yeast_orfs")
    shell:
        "salmon index --index yeast_orfs --transcripts {input}"

rule salmon_quant:
    input: 
        fastq = "{sample}.fastq.gz",
        index = "yeast_orfs"
    output: 
        directory("{sample}.quant")
    shell:
        "salmon quant -i {input.index} --libType U -r {input.fastq} -o {output} --seqBias --gcBias"
