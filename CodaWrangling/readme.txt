This was the code to get the heart rate frequencies powers from CODA software that does not do this natively.
All in Matlab; Windows
(1) Run runripcoda.m This calls ripcoda.m
It allows you to copy CODA raw data to the Windows clipboard.
(2) These data saved to a temporary file so can re-open with ControlBeats.m
(3) ControlBeatsm then calls FindingBeats2.m  That outputs the HRV powers; gather in the main folder.


