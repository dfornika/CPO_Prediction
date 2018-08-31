#!/bin/bash -e

#$ -V             # Pass environment variables to the job
#$ -N CPO_pipeline    # Replace with a more specific job name
#$ -cwd           # Use the current working dir
#$ -pe smp 8      # Parallel Environment (how many cores)
#$ -l h_vmem=11G  # Memory (RAM) allocation *per core*
#$ -e ./logs/$JOB_ID.err
#$ -o ./logs/$JOB_ID.log

#input parameters: 1=ID 2 = assemblyPath, 3= outputdir, 4=card.json

#step 1, mash QC
source activate cpo_qc

ID="$1"
assemblyPath="$2"
outputDir="$3"
cardPath="$4"
threads=8 #"$5"


echo "parameters: "
echo "ID: $ID"
echo "outputDir: $outputDir"
echo "card.json Path: $cardPath"
echo "threads: $threads"

predictionsDir="$outputDir"/predictions
mkdir -p "$predictionsDir"
mkdir -p "$outputDir"/summary

source activate cpo_predictions


echo "step3: mlst"

#step3: run mlst
mlst "$assemblyPath" > "$predictionsDir/$ID.mlst"

#step4: plasmid+amr
echo "step4: plasmid+amr prediction"

#find origin of replications using plasmidfinder, >>defunct replaced with mobsuite
#abricate --db plasmidfinder "$assemblyPath" > "$predictionsDir/$ID.origins"

#find carbapenemases using custom cpo database. 
abricate --db cpo "$assemblyPath" > "$predictionsDir/$ID.cp"

#run rgi
cd $predictionsDir

rgi load -i "$cardPath" --local #--debug
rgi main -i "$assemblyPath" -o "$ID.rgi" -t contig -a BLAST -n "$threads" --local --clean #--debug
rm -rf localDB

source deactivate

#source activate plasflow

#find contigs that are likely to be plasmids >>defunct replaced with mobsuite
#PlasFlow.py --input "$ID" --output "$predictionsDir/$ID.plasflow" --threshold 0.85
#rm -rf "$contigsDir"/*.fa_kmer*
#rm -rf "$predictionsDir"/*.fasta

#source deactivate

source activate mob_suite #requires sudo

#run mob typer
mob_recon --infile "$assemblyPath" --outdir "$predictionsDir/$ID.recon" --run_typer

source deactivate

echo "done step 4"




