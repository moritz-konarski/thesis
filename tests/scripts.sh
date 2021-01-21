# requires Physio Net's WFDB Software Package

# to download an ecg record, save with header as csv

rdsamp -r mitdb/100 -p -v -c > 100.txt

# to download the annotations

rdann -r mitdb/100 -a atr -v -x > ann_100.mitbih
