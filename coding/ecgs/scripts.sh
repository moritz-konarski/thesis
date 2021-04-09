# requires Physio Net's WFDB Software Package

# to download an ecg record, save with header as csv

rdsamp -r mitdb/100 -c -v -p > 100.csv

# or to use with local file database

rdsamp -r 100 -c -v -p > 100.csv

# to download the annotations

rdann -r mitdb/100 -a atr -v > a100.dat
