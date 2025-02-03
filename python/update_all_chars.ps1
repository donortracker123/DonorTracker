# Set environment variables
$env:DAC1 = "data/Table1_Data.csv"
$env:CRS = "data/CRS.parquet"
$env:IM = "data/imputed_spending_purpose.csv"

# Run Python scripts
python chart_update.py all_donor_oda_ranking_2a -ly 2023 -dr -dac1 $env:DAC1
python chart_update.py all_donor_gni_ranking_2b -ly 2023 -dr -dac1 $env:DAC1
