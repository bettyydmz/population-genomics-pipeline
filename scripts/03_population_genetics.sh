#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# 03_population_genetics.sh
# Population genetics analysis using Stacks (gstacks + populations)
# Performs reference-based SNP calling and population-level filtering
#
# Tools required: gstacks, populations (Stacks v2+)
# Input: sorted BAM files from 02_alignment.sh
# Author: Beatriz Domínguez — UNAM Agrogenomics
# =============================================================================

# --- CONFIG: Edit these paths before running ---
BAM_DIR="results/bams"              # BAM files from 02_alignment.sh
POP_MAP="popmap.tsv"                # Population map: SAMPLE<TAB>POPULATION
GSTACKS_OUT="results/gstacks"      # gstacks output directory
POP_OUT="results/populations"      # populations output directory
THREADS=12

# populations filters (adjust to your study design)
MIN_SAMPLES_POP=0.75                # Min proportion of samples per population (-r)
MAX_OBS_HET=0.80                    # Max observed heterozygosity
MIN_MAF=0.05                        # Minimum minor allele frequency
# -----------------------------------------------

# 1) Check population map
if [ ! -f "$POP_MAP" ]; then
    echo "ERROR: Population map not found at $POP_MAP"
    echo "Create a tab-separated file with format: SAMPLE<TAB>POPULATION"
    echo "Example:"
    echo "  sample_01    PopA"
    echo "  sample_02    PopB"
    exit 1
fi

echo "Population map: $(wc -l < $POP_MAP) samples found"

mkdir -p "$GSTACKS_OUT" "$POP_OUT"

# 2) Run gstacks — reference-aligned SNP catalog
echo "Running gstacks..."
gstacks \
    -I "$BAM_DIR" \
    -M "$POP_MAP" \
    -O "$GSTACKS_OUT" \
    -t "$THREADS" \
    --rm-pcr-duplicates

echo "gstacks complete."

# 3) Run populations — filtering and output formats
echo "Running populations..."
populations \
    -P "$GSTACKS_OUT" \
    -M "$POP_MAP" \
    -O "$POP_OUT" \
    -r "$MIN_SAMPLES_POP" \
    --max-obs-het "$MAX_OBS_HET" \
    --min-maf "$MIN_MAF" \
    -t "$THREADS" \
    --vcf \
    --structure \
    --plink

echo "Pipeline complete. Final SNP output in: $POP_OUT"
