# Notes about thesis

0. Acknowledgement of the grant, and the other participants?
    - talk to Imanaliev about that?
1. Introduction
    - mention time series and that ECGs are just time series
    - difficulties in time series analysis
    - many ECG papers don't focus on them being just time series
    - mention how efficient SAX is (iSAX 2.0 terra byte series and so on)
    - define time series
    - mention SAX, why it was used, what it does
    - mention the data bases
2. Literature review
    - mention SAX and some of the other papers that cover it
    - make clear what my contribution here is => I use it with two concurrent
    time series and not just 1 like all those other papers
    - is there any sense to it? because it takes twice the computational time
    and power, but how much more accurate can we get? or rather, can we relax
    some of the other parameters if we use 2 time series at the same time?
    - cardiologists would usually look at all available leads and thus
    a program should too
    - having machines diagnose diseases is trickier, but if an algorithm can
    point a doctor in the right direction for examining certain spots of an
    hour long ECG, that would be nice
    - look at cutting the ECG into smaller strips such that it can be more
    efficiently searched
    - most ECG are mostly normal
3. Methods
    - explain PAA
    - explain SAX
    - explain the brute force algorithm
    - explain the optimization to that algorithm
    - explain how to use 2 concurrent time series with these algorithms
        - first find all discords in each lead
        - if they match up, they get a higher score
        - maybe weighted average between the two distances?
4. Results
    - can we find discords more easily when we use both time series
    - can one implement some type of lower bound for distance to classify
    anomalies?
5. Conclusion
    - was it worth it?
    - 

6. 
