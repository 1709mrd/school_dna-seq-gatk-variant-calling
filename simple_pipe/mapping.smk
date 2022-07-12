rule map_reads:
    input:
        genome="resources/genome.fasta",
        reads="input/{sample}.fastq"
    output:
        "results/mapped/{sample}.sam"
    log:
        "logs/bwa_mem/{sample}.log"
    shell:
        "bwa-mem2 mem {input.genome} {input.reads} > {output} 2> {log}"


rule sort_sam:
    input:
        input_bam="results/mapped/{sample}.sam"
    output:
        "results/mapped/{sample}.sorted.bam"
    log:
        "logs/samtools/{sample}.sort.log"
    shell:
        "samtools sort {input.input_bam} -o {output}"

rule index_bam:
    input:
        rules.sort_sam.output
    output:
        "results/mapped/{sample}.sorted.bam.bai"
    log:
        "logs/samtools/{sample}.index.log"
    shell:
        "samtools index {input}"


rule create_pileup_call:
    input:
        index=rules.index_bam.output,
        bam=rules.sort_sam.output,
        genome="resources/genome.fasta"
    output:
        "results/calls/{sample}.vcf"
    log:
        "logs/samtools/{sample}.mpileup.log"
    shell:
        """
        samtools mpileup -g -f {input.genome} {input.bam} | bcftools call -mv - > {output}
        """

