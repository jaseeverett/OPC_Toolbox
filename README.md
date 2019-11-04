# OPC_Toolbox

This repository contains the software required to process OPC and LOPC data in MATLAB, and output size-spectra information.

There is test data and code in the TestData/ directory. Use this directory as your 'working' or 'project directory. Add the remaining 3 directories (Common/ OPC/ and LOPC/) to your MATLAB path. Basic Instructions for running the code can be found in the LOPC_Process.m file in the TestData folder.

The folders:
OPC/ contains files relevent to the processing of the LED OPC 1T/L and 2T/L manufactured by Focal Technologies.
LOPC/ contains files relevent to the processing of the in-situ and lab-based LOPC manufactured by ODIM/Rolls Royce.
Common/ contains files common to both systems such as routines for calculating the Normalised Biomass Size Spectra (NBSS).

It is still a work in progress and many bugs may exist. Please drop me a line via GitHub if you start using it so we can stay in touch.
