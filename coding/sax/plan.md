# Algorithm

1. read in ECG
2. find first couple peaks, determine approximate points per heartbeat
3. do this in a couple places, take the average
4. find first R peak and last R peak
4. determine number of paa segments per heartbeat
    - task to be analyzed for accuracy vs dimensionality reduction
5. determine alphabet size
    - task to be analyzed for accuracy vs dimensionality reduction
6. compute SAX, ESAX, TSAX for whole ECG
7. properly segment whole time series
7. apply least-similarity finder algorithm -> find K most dissimilar ones
8. pass those to kNN algorithm to find out which ones are actual IHD
