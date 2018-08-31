# CPO_Prediction
Scripts for the characterization and visualization of genomics data for carbapenemase producing organisms or bacteria in general.

Module 1: QC and Assembly: See wrapper script pipeline_sequdas.py
usage: $>python M1_pipeline_sequdas.py -i $ID -f $ForwardRead -r $ReverseRead -o $OutDir -e "$Species"

Module 2: Prediction and visualization: See wrapper script pipeline_prediction.py and pipeline_tree.py
Usage: this module is implemented in galaxy. For details see https://github.com/imasianxd/CPO_Prediction_Galaxy
