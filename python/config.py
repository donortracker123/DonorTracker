from pathlib import Path

static_dir = Path(__file__).parent / "static"
data_dir = Path(__file__).parent /  "data"

projection_file = static_dir / "DT_ODA_Projections_2025.csv"
deflator_file = static_dir / "deflator_file.csv"
dt_sector_file = static_dir / "DT_sector_map.csv"
dt_regions_file = static_dir / "DT_region.csv"
dt_channels_file = static_dir / "DT_channel_map.csv"
dt_multilaterals_file = static_dir / "DT_multilaterals.csv"
dt_world_bank_income_file = static_dir / "DT_world_bank_income_groups.csv"

# Define the path to the Parquet file
CRS_FILE = data_dir / "CRS.parquet"
DAC1_FILE = data_dir / "Table1_Data.csv"

DAC_COUNTRIES = tuple([
  "Australia", "Austria", "Belgium", "Canada", "Czechia", "Denmark", "Finland", "France", "Germany", "Greece", "Hungary",
  "Iceland", "Ireland", "Italy", "Japan", "Korea", "Luxembourg", "Netherlands", "New Zealand", "Norway", "Poland",
  "Portugal", "Slovak Republic", "Slovenia", "Spain", "Sweden", "Switzerland", "United Kingdom", "United States", "Estonia", "Lithuania", 
  "EU Institutions", "Latvia"
])

ALLOCABLE_AID_CATEGORIES = tuple([
  'A02', 'B01', 'B03', 'B031', 'B032', 'B033', 'B04', 'C01', 'D01', 'D02', 'E01'
])

SECTOR_MAPPING = {
  "ag": "Agriculture (incl. forestry, fishing, rural development)",
  "ed": "Education",
  "gh": "Health & populations"
}