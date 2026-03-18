#!/bin/bash
#SBATCH --partition=buyin
#SBATCH --account=b1164
#SBATCH --ntasks=1
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --time=12:00:00
#SBATCH -a [0-99%24]
#SBATCH --mem=1G

# usage: $ sbatch sub.sh restart[scratch|restart] epsilon efielddir efield_strength length


# -----------------------------------------------------------------------------|
# inputs
# -----------------------------------------------------------------------------|

seedlist=('146576' '79209384' '12345' '333555' '44556677' '654321')
lengthlist=('15')
seed='146576'
# ${seedlist[$SLURM_ARRAY_TASK_ID]}
# length=${lengthlist[$SLURM_ARRAY_TASK_ID]}

restart=$1
run_file=in.viscous
eps=$2
efielddir=$3
efield_strength=$4
length=$5

a1=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a1=$(printf "%.4f" "$a1")
a2=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a2=$(printf "%.4f" "$a2")
a3=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a3=$(printf "%.4f" "$a3")
a4=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a4=$(printf "%.4f" "$a4")
a5=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a5=$(printf "%.4f" "$a5")
a6=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a6=$(printf "%.4f" "$a6")
a7=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a7=$(printf "%.4f" "$a7")
a8=$(echo "scale=4 ; ${RANDOM}/32767" | bc -l)
a8=$(printf "%.4f" "$a8")

echo "$a1"

# -----------------------------------------------------------------------------|
# processing information and run preparation
# -----------------------------------------------------------------------------|

# make output directory
outputdir=0.25_e${eps}_L${length}_E${efield_strength}_faster_As_${a1}_${a2}_${a3}_${a4}_${a5}_${a6}_${a7}_${a8}
mkdir -p $outputdir

# start from a restart file if restarting, otherwise get data file from input-data
if [ "$restart" == "restart"  ]; then
    restartfile=${outputdir}/end.restart
else
    restartfile=NA
fi

# cleanup on exit
cleanup() { 
    mv slurm-${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID}.out $outputdir
}
trap cleanup EXIT

# count how many gpus we have
IFS=',' read -ra gpus <<< "$SLURM_JOB_GPUS"
ngpu=${#gpus[@]}


# -----------------------------------------------------------------------------|
# process walltime left for passing into lammps timer command
# -----------------------------------------------------------------------------|

# calculate time left from slurm walltime
WALLTIME=$(squeue -j ${SLURM_ARRAY_JOB_ID}_${SLURM_ARRAY_TASK_ID} -h --Format TimeLimit)

# parse string
if [[ $WALLTIME == *"-"* ]]; then
    IFS="-:" read -r d h m s <<< "$WALLTIME"
    h=$(( d*24 + h ))
elif [[ $WALLTIME =~ [0-9]+:[0-9]+:[0-9]+ ]]; then
    IFS=":" read -r h m s <<< "$WALLTIME"
elif [[ $WALLTIME =~ [0-9]+:[0-9]+ ]]; then
    IFS=":" read -r m s <<< "$WALLTIME"
fi

# subtract 30 minutes
if [[ $m > 30 ]]; then
    m=$(( m-30 ))
else
    h=$(( h-1 ))
    m=$(( m+30 ))
fi

TIMELEFT="$h:$m:$s"
echo running lammps for: $TIMELEFT


# -----------------------------------------------------------------------------|
# actually run lammps
# -----------------------------------------------------------------------------|

# run lammps

build=build_19feb2025_efield2
LMP=/projects/b1021/Isaac/lammps
module purge
module load git
module load ffmpeg/4.2
module load blas-lapack/3.11.0_gcc
module load FitSNAP/3.1.0
module load fsl/6.0.7.6
module load intel-oneapi-mkl/2021.4.0-gcc-10.4.0
module load cuda/cuda-12.1.0-openmpi-4.1.4
echo "$a1"
mpirun -np $SLURM_NTASKS $LMP/$build/lmp_mpi -in $run_file -sf gpu -pk gpu ${ngpu} \
                        -v restartfile $restartfile \
                        -v seed $seed \
                        -v timeleft $TIMELEFT \
                        -v restart $restart \
                        -v outdir $outputdir \
			-v eps $eps \
			-v efielddir $efielddir \
			-v efield_strength $efield_strength \
			-v a1 ${a1} \
                        -v a2 ${a2} \
                        -v a3 ${a3} \
                        -v a4 ${a4} \
                        -v a5 ${a5} \
                        -v a6 ${a6} \
                        -v a7 ${a7} \
                        -v a8 ${a8} \
			-v datafile 0.25_z${length}.data \
                        -v logfile $outputdir/log.lammps -log $outputdir/log.delete
