# Population Genomics Pipeline — *Vitis vinifera*

A complete bioinformatics pipeline for RADseq population genomics analysis of grapevine (*Vitis vinifera*). Covers the full workflow from raw sequencing reads to annotated variants and population-level statistics.

The tools and methodology used here — quality control, alignment, variant calling, and population filtering — are directly transferable to clinical genomics applications.

---

## Pipeline Overview

```
Raw FASTQ reads
      │
      ▼
01_quality_control.sh     → Adapter trimming & QC (fastp)
      │
      ▼
02_alignment.sh           → Reference alignment & BAM processing (BWA MEM, SAMtools)
      │
      ▼
03_population_genetics.sh → SNP calling & population filtering (Stacks: gstacks + populations)
      │
      ▼
Annotated VCF + population statistics
```

---

## Repository Structure

```
├── scripts/
│   ├── 01_quality_control.sh      # Batch QC with fastp (59 samples)
│   ├── 02_alignment.sh            # BWA MEM alignment + stats
│   └── 03_population_genetics.sh  # Stacks gstacks + populations
├── README.md
└── popmap.tsv                     # Population map (sample → population)
```

---

## Requirements

| Tool | Version | Purpose |
|------|---------|---------|
| fastp | ≥ 0.21 | Quality control & adapter trimming |
| BWA | ≥ 0.7 | Read alignment |
| SAMtools | ≥ 1.13 | BAM processing & statistics |
| Picard | ≥ 2.26 | Duplicate marking (optional) |
| GATK | ≥ 4.2 | Variant calling (HaplotypeCaller) |
| Stacks | ≥ 2.6 | Population genetics (gstacks + populations) |
| snpEff | ≥ 5.0 | Variant annotation |
| conda | — | Environment management |

---

## Usage

### Step 1 — Quality Control
```bash
# Edit paths in script header, then run:
bash scripts/01_quality_control.sh
```
Trims adapters and low-quality bases from 59 paired-end samples. Generates HTML/JSON QC reports per sample.

### Step 2 — Alignment
```bash
# Edit REF and FASTQ_DIR in script header, then run:
bash scripts/02_alignment.sh
```
Aligns trimmed reads to reference genome (T2T soft-masked). Outputs sorted, indexed BAM files and alignment statistics for all samples.

### Step 3 — Population Genetics
```bash
# Prepare your popmap.tsv first, then run:
bash scripts/03_population_genetics.sh
```
Runs gstacks for reference-based SNP catalog, then populations with MAF and heterozygosity filters. Outputs VCF, STRUCTURE, and PLINK formats.

---

## Population Map Format

Create a tab-separated file `popmap.tsv`:
```
sample_01    PopA
sample_02    PopA
sample_03    PopB
```

---

## Key Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| `-q 25` | fastp | Minimum base quality score |
| `-l 40` | fastp | Minimum read length after trimming |
| `--trim_front1 5` | fastp | Trim 5bp from R1 5' end |
| `-r 0.75` | populations | Min 75% samples per population |
| `--min-maf 0.05` | populations | Minimum minor allele frequency |
| `--max-obs-het 0.80` | populations | Maximum observed heterozygosity |

---

## Relevance to Clinical Genomics

The core methodology applied here — paired-end alignment, duplicate removal, variant calling, and functional annotation — is the same foundation used in clinical genomics pipelines for human disease analysis.

Key tools like BWA MEM, SAMtools, GATK HaplotypeCaller, and snpEff are standard in clinical variant analysis pipelines (e.g., ACMG variant interpretation, somatic variant calling in oncology). This project provided hands-on experience with the complete bioinformatics toolkit used in precision medicine and genomic diagnostics.

---

## Author

**Beatriz Domínguez**  
Agrogenomics — UNAM  
Research interests: Clinical genomics · Mental health genomics · Underrepresented Latin American populations  

---
