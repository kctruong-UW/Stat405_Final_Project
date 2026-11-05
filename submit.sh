#!/bin/bash
jobA=$(sbatch --parsable --partition short --array=1-72 getDay.sh)
sbatch --partition short --dependency=afterok:$jobA combine.sh
