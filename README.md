# Bachelor's Thesis Repository

This repository contains the results of my Bachelor's thesis at the [American
University of Central Asia][1]. I graduated on the 5th of June 2021 with
a Bachelor of Arts from the Applied Mathematics and Informatics Program.

The final documents can be found in the "Final Documents" folder. The "Programming" folder contains the code for this project,
"Resources" the papers I read, "Syllabus" the requirements of my department,
and "Writing" the Latex sources for the thesis and presentations.

## General Information

__Title__: Multivariate Symbolic Aggregate Approximation for ECG Analysis

__Author__: Moritz M. Konarski

__Department__: Applied Mathematics and Informatics Program

__Supervisor__: Professor Taalaibek M. Imanaliev

__Keywords__: Symbolic Aggregate Approximation, ECG Discord Discovery, HOT SAX, 
MSAX, Time Series Analysis

__Submission Date__: 25.05.2021

__Defense Date__: 31.05.2021

__DSpace Link__ (requires account): <https://dspace.auca.kg/handle/123456789/2653>

__Accepted__: Yes

__Abstract__: The electrocardiogram (ECG) is the most common diagnostic tool
used for heart diseases. Because heart diseases claim more lives each year than
any other disease, proper analysis of ECGs is very important. For humans,
learning how to read an ECG is very difficult and even with a lot of training,
mistakes are common. One proposed solution to this problem is computerized ECG
analysis which aims to use the power of computers to improve and speed up the
analysis of ECGs and to save lives. But even computers have their limits, and
working with large ECG recordings can take a prohibitively long time. One
approach to speeding up the analysis process is to transform the ECG into
a more compact form–a representation. These representations can be used to more
efficiently store and compare two ECGs. The Symbolic Aggregate Approximation
(SAX) is a prominent representation method that has been modified to properly
represent time series that record more than one value for each moment in time,
e.g. ECGs. This modification is known as Multivariate SAX (MSAX). Besides
representing ECGs, SAX can also be used as part of an algorithm called HOT SAX,
which can find discords in ECGs. ECG discords are segments of the ECG that are
very different from the other segments. Because they are so different, they are
likely to be indicators of disease and thus their discovery can help
a cardiologist save lives.

This research compares the use of MSAX with the HOT SAX algorithm (HOT MSAX) to
the use of standard HOT SAX. The novel contributions of this research are to
use MSAX as the representation for HOT SAX, and the application of MSAX to ECG
discord discovery. Because MSAX is meant to represent time series like ECGs and
SAX is not, the recall value for HOT MSAX-based ECG discord discovery should be
greater than the recall value for the HOT SAX-based method. Through
experimental testing using the MIT-BIH Arrhythmia Database it is shown that,
when each method is used with its optimal parameters, there is no significant
difference between HOT SAX and HOT MSAX. Nonetheless, HOT MSAX performs as well
as HOT SAX and could thus find applications in ECG discord discovery by
pre-selecting potentially relevant ECG segments for the cardiologist to analyze
and thus speeding up and simplifying the diagnosis process.


[1]: https://www.auca.kg/
