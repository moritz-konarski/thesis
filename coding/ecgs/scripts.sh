# requires Physio Net's WFDB Software Package

# to download an ecg record, save with header as csv

rdsamp -r mitdb/100 -c -v > 100.csv

# to download the annotations

rdann -r mitdb/100 -a atr -v > a100.dat
