#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Apr  7 20:37:04 2021

@author: Von P. Walden 
         Washington State University
"""
#%% Imports
import pandas as pd

#%% Read in sample data
df_UTC = pd.read_csv('/Users/vonw/work/software/airpact/IDEQ/pm25.dat', sep='|', parse_dates={'Time': ['_MM/DD/YY_UTZ', '_HH:MM_UTZ']}, index_col='Time')

#%% Convert Pandas dataframe index to UTC
df_UTC = df_UTC.tz_localize('UTC')
print(df_UTC)

#%% Create a new dataframe with index in MST.
df_MST = df_UTC.tz_convert('MST')
print(df_MST)
