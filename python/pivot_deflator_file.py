from pathlib import Path
import pandas as pd

static_dir = Path(__file__).parent / "static"
data_dir = Path(__file__).parent /  "data"

deflator_file_wide = static_dir / "deflators.csv"

def main():
    deflator_df = pd.read_csv(deflator_file_wide, na_values='- ')

    deflator_file = pd.melt(deflator_df,
                              id_vars=['country'],
                              var_name='year',
                              value_name='deflator'
                              ).reset_index(drop=True)
    deflator_file.rename(columns={'country': 'donor'}, inplace=True)

    deflator_file.to_csv(static_dir / 'deflator_file.csv', index=False)

if __name__ == "__main__":
    main()