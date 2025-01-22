from pathlib import Path
import pandas as pd

# Define the path to the Parquet file
crs_file = Path("~/Downloads") / "CRS.parquet"
dac1_file = Path("~/Downloads") / "Table1_Data.csv"

static_dir = Path(__file__).parent / "static" 

projection_file = static_dir / "DT_ODA_Projections_2025.csv"
deflator_file_wide = static_dir / "deflators.csv"
deflator_file_long = static_dir / "deflator_file_long.csv"


DAC_COUNTRIES = tuple([
  "Australia", "Austria", "Belgium", "Canada", "Czechia", "Denmark", "Finland", "France", "Germany", "Greece", "Hungary",
  "Iceland", "Ireland", "Italy", "Japan", "Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Poland",
  "Portugal", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States", "Estonia", "Lithuania", 
  "EU Institutions"
])

if __name__ == "__main__":
  deflator_table = pd.read_csv(deflator_file_wide, na_values='- ')

  deflator_file_long = pd.melt(deflator_table,
                              id_vars=['country'],
                              var_name='year',
                              value_name='deflator'
                              ).reset_index(drop=True)
  deflator_file_long.to_csv(static_dir / 'deflator_file_long.csv', index=False)