from pathlib import Path

# Define the path to the Parquet file
crs_file = Path("~/Downloads") / "CRS.parquet"
dac1_file = Path("~/Downloads") / "Table1_Data.csv"

DAC_COUNTRIES = tuple([
  "Australia", "Austria", "Belgium", "Canada", "Czechia", "Denmark", "Finland", "France", "Germany", "Greece", "Hungary",
  "Iceland", "Ireland", "Italy", "Japan", "Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Poland",
  "Portugal", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States", "Estonia", "Lithuania"
])