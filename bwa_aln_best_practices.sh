#!/bin/bash

usage(){ echo "                                             
Usage: quick.sh [-m|--memory] [-t|--time] [-n|--threads] [-i|--jobid] "command.here"
        
        -m: job memory
        -t: job time
        -n: threads
        -i: sample id
	-b: input bam file
	-r: reference genome                                                           
"                                                           
1>&2;exit 1;}

die() {
    printf '%s\n' "$1" >&2
    exit 1
}

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
###Defaults###
memory=80000
time=72:00:00
threads=16
##############


while :; do
        case $1 in
                -h|-\?|--help)
                        usage    # Display a usage synopsis.
                        exit1
                        ;;
                -m|--memory)
                        if [ "$2" ];then
                                memory=$2
                                shift
                        fi
                        ;;
                -t|--time)
                        if [ "$2" ];then
                                time=$2
                                shift
                        fi
                        ;;
                -n|--threads)
                        if [ "$2" ];then
                                threads=$2
                                shift
                        fi
                        ;;
                -i|--sampleid)
                        if [ "$2" ];then
                                outid=$2
                                shift
                        else
				echo "output ID needed";exit1
			fi
                        ;;
		-b|--bam)
			if [ "$2" ];then
				ubamfile=$2
				shift
			else
				echo "ubamfile needed";exit1
			fi
			;;
		-r|--ref)
                        if [ "$2" ];then
                                refgenome=$2
				shift
                        else
                                echo "reference genome needed";exit1
                        fi
                        ;; 
                --)
                        shift
                        break
                        ;;
                -?*)
                        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
                        ;;
                *)
                        break
                        ;;
        esac
        shift
done




cat <<EOF > ${outid}.aln.slurm
#!/bin/bash
#SBATCH -p hoekstra,commons,shared
#SBATCH -t ${time} 
#SBATCH --mem=${memory}
#SBATCH -n ${threads}
#SBATCH -e ./logs/${outid}.aln.e
#SBATCH -o ./logs/${outid}.aln.o
#SBATCH -c 1
#SBATCH -N 1
#SBATCH -J ${outid}.aln

module load centos6/0.0.1-fasrc01; module load java;module load samtools

if [ -f ${outid}.sorted.ubam.md5 ]; then echo "${outid}.sorted.ubam succesfully created previously,skipping" ; else java -Xmx8G -XX:ParallelGCThreads=1 -Djava.io.tmpdir=`pwd`/tmp -jar ~/Software/picard/2.18.4/picard.jar SortSam CREATE_MD5_FILE=true SORT_ORDER=queryname I=${ubamfile} O=${outid}.sorted.ubam;fi

if [ -f ${outid}.markedadapters.ubam.md5 ]; then echo "${outid}.markedadapters.ubam succesfully created previously,skipping" ; else java -Xmx8G -XX:ParallelGCThreads=1 -Djava.io.tmpdir=`pwd`/tmp -jar ~/Software/picard/2.18.4/picard.jar MarkIlluminaAdapters CREATE_MD5_FILE=true I=${outid}.sorted.ubam O=${outid}.markedadapters.ubam M=${outid}.metrics.txt;fi

if [ -f ${outid}.samtofastq_interleaved.fq.md5 ]; then echo "${outid}.samtofastq_interleaved.fq succesfully created previously,skipping" ; else java -XX:ParallelGCThreads=1 -Djava.io.tmpdir=`pwd`/tmp -Dsamjdk.buffer_size=131072 -Dsamjdk.compression_level=1 -Xmx4G -jar ~/Software/picard/2.18.4/picard.jar SamToFastq CREATE_INDEX=true CREATE_MD5_FILE=true I=${outid}.markedadapters.ubam FASTQ=${outid}.samtofastq_interleaved.fq CLIPPING_ATTRIBUTE=XT CLIPPING_ACTION=2 INTERLEAVE=true;fi

if [ -f ${outid}.bwa_mem.sam ]; then echo "${outid}.bwa_mem.sam created previously, skipping mapping"; else module load bwa;bwa mem -M -t ${threads} -p ${refgenome} ${outid}.samtofastq_interleaved.fq > ${outid}.bwa_mem.sam;fi

samtools quickcheck ${outid}.bwa_mem.sam && ( echo "nothing wrong with ${outid}.bwa_mem.sam"; ) || ( echo "${outid}.bwa_mem.sam corrupted, exiting"; rm ${outid}.bwa_mem.sam; exit 1; )

if [ -f ${outid}.mergebamalignment.sorted.bam.md5 ]; then echo "${outid}.mergebamalignment.sorted.bam.md5 succesfully created previously,skipping"; else java -Dsamjdk.buffer_size=131072 -Dsamjdk.use_async_io=true -Dsamjdk.compression_level=1 -XX:+UseStringCache -XX:ParallelGCThreads=1 -Xmx5000m -jar ~/Software/picard/2.18.4/picard.jar MergeBamAlignment CREATE_MD5_FILE=true R=${refgenome} UNMAPPED_BAM=${ubamfile} ALIGNED_BAM=${outid}.bwa_mem.sam O=${outid}.mergebamalignment.sorted.bam SORT_ORDER=coordinate CREATE_INDEX=true ADD_MATE_CIGAR=true CLIP_ADAPTERS=false CLIP_OVERLAPPING_READS=true INCLUDE_SECONDARY_ALIGNMENTS=true MAX_INSERTIONS_OR_DELETIONS=-1 PRIMARY_ALIGNMENT_STRATEGY=MostDistant ATTRIBUTES_TO_RETAIN=XS TMP_DIR=`pwd`/tmp;fi

if [ -f ${outid}.mdup2500.bam.md5 ]; then echo "${outid}.mdup2500.bam.md5 succesfully created previously,skipping"; else java -Dsamjdk.buffer_size=131072 -Dsamjdk.use_async_io=true -Dsamjdk.compression_level=1 -XX:+UseStringCache -XX:ParallelGCThreads=1 -Djava.io.tmpdir=`pwd`/tmp -Xmx5G -jar ~/Software/picard/2.18.4/picard.jar MarkDuplicates INPUT=${outid}.mergebamalignment.sorted.bam OUTPUT=${outid}.mdup2500.bam METRICS_FILE=${outid}_markduplicates_metrics.txt OPTICAL_DUPLICATE_PIXEL_DISTANCE=2500 CREATE_INDEX=true CREATE_MD5_FILE=true TMP_DIR=`pwd`/tmp;fi

EOF

mkdir -p logs
sbatch ${outid}.aln.slurm
