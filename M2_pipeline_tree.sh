#!/bin/bash -e

#$ -V             # Pass environment variables to the job
#$ -N CPO_pipeline    # Replace with a more specific job name
#$ -cwd           # Use the current working dir
#$ -pe smp 8      # Parallel Environment (how many cores)
#$ -l h_vmem=11G  # Memory (RAM) allocation *per core*
#$ -e ./logs/$JOB_ID.err
#$ -o ./logs/$JOB_ID.log

#input parameters: 1 = id, 2= outputdir

#step 1, mash QC
source activate snippy

threads=8
ram=80
outputDir="$1"
reference="$2"
contigs="$3"

echo "parameters: "
echo "outputDir: $outputDir"
echo "outputDir: $reference"
echo "outputDir: $contigs"
echo "outputDir: $threads"
echo "outputDir: $ram"

#treeDir="$outputDir"/trees
treeFileDir="$outputDir"/trees
#mkdir -p "$treeDir"
mkdir -p "$treeFileDir"

contigArray=()

#find snps within each genome
IFS=',' read -ra ADDR <<< "$contigs" #hax to read in a csv
for i in "${ADDR[@]}"; do
	refG=`basename $i`
	echo $refG
	snippy --cpus "$threads" --outdir "$treeFileDir"/"$refG" --reference $reference --ctgs $i
	contigArray+=($refG)
done

cd $treeFileDir

#create an alignment from the snps
snippy-core --prefix core *

#create a distance matrix from alignment
snp-dists core.full.aln > distance.tab

#make a nj tree from the matrix
clustalw2 -tree -infile=core.full.aln -outputtree=nj

source deactivate
echo "done step 4"




