**Data Generation**

This folder contains materials related to the data generation process for this project by molecular dynamics

`MolecularDynamics.md` explains the data generation process

`viscous.sh` and `in.viscous` are, respectively, the bash script for running the MD simulations, and the LAMMPS input script for the simulation

`RawDiodeDataProcessing.ipynb` is the notebook that was used to process the raw molecular dynamics data

`current.csv`, `efield.csv`, and `current_splied.csv` are the files containing the processed data, which the ML model is trained on
