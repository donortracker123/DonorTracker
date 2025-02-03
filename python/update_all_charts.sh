#!/bin/bash

export DAC1="data/Table1_Data.csv"
export CRS="data/CRS.parquet"
export IM="data/imputed_spending_purpose.csv"

python chart_update.py all_donor_oda_ranking_2a -ly 2023 -dac1 $DAC1;
# python chart_update.py all_donor_gni_ranking_2b -ly 2023 -dr -dac1 $DAC1;
