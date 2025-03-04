from pathlib import Path
import pandas as pd

static_dir = Path(__file__).parent / "static"
data_dir = Path(__file__).parent /  "data"

projection_file = static_dir / "DT_ODA_Projections_2025.csv"
deflator_file = static_dir / "deflator_file.csv"
dt_sector_file = static_dir / "DT_sector_map.csv"
dt_regions_file = static_dir / "DT_region.csv"
dt_channels_file = static_dir / "DT_channel_map.csv"

# Define the path to the Parquet file
CRS_FILE = data_dir / "CRS.parquet"
DAC1_FILE = data_dir / "Table1_Data.csv"

DAC_COUNTRIES = tuple([
  "Australia", "Austria", "Belgium", "Canada", "Czechia", "Denmark", "Finland", "France", "Germany", "Greece", "Hungary",
  "Iceland", "Ireland", "Italy", "Japan", "Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Poland",
  "Portugal", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States", "Estonia", "Lithuania", 
  "EU Institutions"
])

SECTOR_MAPPING = {
  "ag": "Agriculture (incl. forestry, fishing, rural development)",
  "ed": "Education",
  "gh": "Health & populations"
}