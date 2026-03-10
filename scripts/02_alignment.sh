#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# 02_alignment.sh
# Reference-based alignment pipeline for RADseq data (Vitis vinifera)
# Maps trimmed paired-end reads to reference genome using BWA MEM
# Outputs sorted, indexed BAM files ready for variant calling
#
# Tools required: bwa, samtools
# Author: Beatriz Domínguez — UNAM Agrogenomics
# =============================================================================

# --- CONFIG: Edit these paths before running ---
REF="path/to/reference.fasta"       # Reference genome (soft-masked recommended)
FASTQ_DIR="results/fastp_trimmed"   # Trimmed FASTQ files from 01_quality_control.sh
BAM_DIR="results/bams"              # Output directory for BAM files
THREADS=12                          # Number of threads
SAMPLES_LIST="sample_names.txt"     # Auto-generated from FASTQ files
# -----------------------------------------------

# 1) Index reference genome
if [ ! -f "${REF}.bwt" ]; then
    echo "Indexing reference with BWA..."
    bwa index "$REF"
fi

if [ ! -f "${REF}.fai" ]; then
    echo "Indexing reference with samtools..."
    samtools faidx "$REF"
fi

mkdir -p "$BAM_DIR"

# 2) Build sample list from FASTQ directory
if [ ! -f "$SAMPLES_LIST" ]; then
    echo "Building sample list..."
    ls ${FASTQ_DIR}/*_R1*.fastq.gz \
        | xargs -n1 basename \
        | sed -E 's/_R1.*//' \
        | sort -u > "$SAMPLES_LIST"
    echo "Found $(wc -l < $SAMPLES_LIST) samples"
fi

# 3) Align each sample with BWA MEM, sort and index
echo "Aligning samples..."
while read -r SAMPLE; do
    R1="${FASTQ_DIR}/${SAMPLE}_R1_001.fastq.gz"
    R2="${FASTQ_DIR}/${SAMPLE}_R2_001.fastq.gz"
    OUT_BAM="${BAM_DIR}/${SAMPLE}.sorted.bam"

    if [ -f "$OUT_BAM" ]; then
        echo "  $SAMPLE: BAM already exists, skipping..."
        continue
    fi

    echo "  Aligning $SAMPLE ..."
    bwa mem -t "$THREADS" -M \
        -R "@RG\tID:${SAMPLE}\tLB:lib1\tPL:ILLUMINA\tPU:${SAMPLE}.01\tSM:${SAMPLE}" \
        "$REF" "$R1" "$R2" \
        | samtools view -b -F 4 - \
        | samtools sort -@ "$THREADS" -o "${OUT_BAM}"

    samtools index "${OUT_BAM}"
    echo "  Done: $SAMPLE"

done < "$SAMPLES_LIST"

# 4) Generate alignment statistics for all samples
echo "Generating alignment statistics..."
STATS_FILE="results/alignment_stats.txt"
> "$STATS_FILE"

for BAM in ${BAM_DIR}/*.sorted.bam; do
    SAMPLE=$(basename "$BAM" .sorted.bam)
    echo "===== $SAMPLE =====" >> "$STATS_FILE"
    samtools flagstat "$BAM" >> "$STATS_FILE"
    echo "" >> "$STATS_FILE"
done

echo "Alignment complete. Statistics saved to: $STATS_FILE"
