To link with pycharm for local development, for client’s requests or typically in projects larger than demos)

Get zsh
Get Java SDK
Get Anaconda (command line installation) + Pycharm
After installation of conda, don’t let conda alter the shell starter script, instead, activate base env first by source xx/bin/activate -> then conda init zsh, this will let your shell auto enable conda base env every time the zsh terminal is run. 

Make sure that databricks runtime is compatible with db-connect client library (7.3 LTS would be fine). Follow the instructions in the tutorial by Matt.

DBR 9.1 LTS example:

Make sure the conda env python version, matches python version of databricks cluster runtime.
E.g. DBR 9.1 LTS is using python 3.

Note that databricks-connect only supports certain versions of DBR runtime. 



![alt text](../_media/dbconnect_dbr.png?raw=true)


Using DBR 9.1 LTS for example, this runtime is using python 3.8, so we need a python 3.8 conda environment by:

conda env create py38 python=3.8
conda activate py38 

Then install the latest version of databricks-connect, choose the version corresponding to your DBR version, by:

pip install -U "databricks-connect==9.1.*"  # or X.Y.* to match your cluster version.

-U is to download the latest minor version.

Then to do databricks-connect configure, and databricks-connect test, should pass.

