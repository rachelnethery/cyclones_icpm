Code for ‘Integrated causal-predictive machine learning models for
tropical cyclone epidemiology’ by Nethery et al.
================

The Medicare claims data used in the paper cannot be made public due to
privacy restrictions. In the code provided, we

1.  Generate synthetic data mimicking all of our real data structures,
    but smaller in size to allow for execution of the analyses on a
    laptop (eliminating the need for cluster computing)

2.  Reproduce results analogous to those in the main manuscript,
    including all numbers, tables, and figures, on the synthetic data.

The code allows users to become familiar with the required inputs of the
models, how the data should be structured, and the content and format of
the outputs obtained for a real data analysis. Detailed documentation
for the synthetic data is also provided.

### Software

Software packages and versions used in the development of this code are
as follows.

##### Primary software and version

R version 3.6.3

##### Package dependencies and versions

For model fitting: rstan (version 2.19.3), Hmisc (version 4.4-0)

For visualizations: ggplot2 (version 3.3.0), ggbeeswarm (version 0.6.0),
RColorBrewer (version 1.1-2)

### Instructions

What is to be reproduced: All results shown in the main manuscript (on
the synthetic data). Estimates of the AER and TEE and 95% credible
intervals are printed to the R console and analogues of Figures 2, 3,
and 4 in the main manuscript are saved as .pdf files.

How to reproduce analyses: Open the master script, called ‘master.R’,
and set working directory in R to the directory where the master script
is located. Then run the code in the master script to execute the
following procedures (each step is documented with comments in the
script):

1.  Generate and export synthetic data for the causal model

2.  Generate and export synthetic data for the predictive model

3.  Read in the data for the causal models and fit the models

4.  Estimate the AER and TEE and 95% CIs (printed to console)

5.  Make analogoues of Figures 2 and 3 for synthetic data (output to
    external files ‘figure2.pdf’ and ‘figure\_3.pdf’)

6.  Read in the output from the causal models and the data for the
    predictive model and fit the predictive model

7.  Make analogoues of Figure 4 and Table S.5 for synthetic data (output
    to external files ‘figure\_4.pdf’ and ‘table\_S5.csv’)

To verify that Figures 2, 3, and 4 and Table S.5 are identically
reproduced for the synthetic data, compare them with the corresponding
files with suffix ‘verify’ provided in the folder with the code.

### Run time

The code should run in approximately 10 minutes on an average laptop
computer.
