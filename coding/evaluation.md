# Evaluating the Program

## Data

1. go through all the subsequences of the ECG
    - count them by type and annotation combination (alphabetical order)
2. annotate which things cardiologists found
3. then annotate which ones were found by SAX and MSAX
    - make sure to sort out double identifications in the SAX case

- store all of the things that SAX or MSAX identify
    - method parameters
    - distance
    - index? necessary?
    - which ecg
    - which database
    - which things were detected (types of heart beats)
    - all the indices of the ECG that were annotated 

## Evaluation

- use the standard statistical methods
    - accuracy
    - recall
    - precision
    - F1
    - roc curve

# TODO

- return the symbols in alphabetical order as a single string
- store this string in an array to compare if this thing has happened
- count both how often it occurred and how often either SAX or MSAX found it
- do this individually for each ecg
- make a master list of what the annotations mean

- Use either julia or R for analysis
