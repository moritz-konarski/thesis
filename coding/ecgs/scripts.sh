# requires Physio Net's WFDB Software Package

# to download an ecg record, save with header as csv

rdsamp -r mitdb/100 -p -v -c > 100.mit

# to download the annotations

rdann -r mitdb/100 -a atr -v > ann_100.mit
