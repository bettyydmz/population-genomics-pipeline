#!/bin/bash
# =============================================================================
# 01_quality_control.sh
# Quality control and adapter trimming using fastp
# Processes paired-end FASTQ files for multiple samples in batch
#
# Tools required: fastp
# Author: Beatriz Domínguez — UNAM Agrogenomics
# =============================================================================

# --- CONFIG: Edit these paths before running ---
RAW_DIR="path/to/raw_fastq"         # Directory with raw FASTQ files
OUTPUT_DIR="results/fastp_trimmed"  # Output directory for trimmed reads
REPORT_DIR="results/fastp_reports"  # Output directory for QC reports
PREFIX="SAMPLE"                     # Sample name prefix
START=1                             # First sample number
END=59                              # Last sample number
# -----------------------------------------------

mkdir -p "$OUTPUT_DIR" "$REPORT_DIR"

# Loop through samples
for i in $(seq -w $START $END); do
    SAMPLE="${PREFIX}-${i}"

    echo "Processing sample: $SAMPLE"

    fastp \
        -i "${RAW_DIR}/${SAMPLE}_R1_001.fastq.gz" \
        -I "${RAW_DIR}/${SAMPLE}_R2_001.fastq.gz" \
        -o "${OUTPUT_DIR}/${SAMPLE}_R1_clean.fastq.gz" \
        -O "${OUTPUT_DIR}/${SAMPLE}_R2_clean.fastq.gz" \
        --html "${REPORT_DIR}/fastp_report_${SAMPLE}.html" \
        --json "${REPORT_DIR}/fastp_report_${SAMPLE}.json" \
        -l 40 \
        -q 25 \
        -z 9 \
        --cut_mean_quality 25 \
        --cut_tail \
        --cut_front \
        --cut_right \
        --trim_front1 5 \
        --trim_front2 3 \
        --detect_adapter_for_pe \
        --trim_poly_g

    echo "Done: $SAMPLE"
done

echo "Quality control complete. Results in: $OUTPUT_DIR"
