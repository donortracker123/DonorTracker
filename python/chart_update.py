import click
import duckdb
import pandas as pd
from pathlib import Path
from jinja2 import Template
from config import DAC_COUNTRIES, SECTOR_MAPPING, projection_file, deflator_file, dt_sector_file, dt_regions_file, dt_channels_file, dt_multilaterals_file, dt_world_bank_income_file


pd.options.display.max_colwidth=100

SQL_DIR = Path(__file__).parent / "sql"
SAVE_PATH = Path(__file__).parent.parent

@click.command()
@click.argument("query-name")
@click.option("--dac1-file", "-dac1", 
              type=click.Path(exists=True), 
              required=False, 
              help="""Path to the DAC1 file (Downloaded from the OECD). This can be a path to a SharePoint file.
              If not set, defaults to the 'data' directory.""")
@click.option("--crs-file", "-crs", 
              type=click.Path(exists=True), 
              required=False, 
              help="""Path to the CRS file (Downloaded from the OECD). This can be a path to a SharePoint file.
              If not set, defaults to the 'data' directory.""")
@click.option("--imputed-multilateral-file", "-im", 
              type=click.Path(exists=True), 
              required=False, 
              help="""Path to the Imputed Multilateral data from the ONE Campaign (Retrieved manually). This can be a path to a SharePoint file.
              If not set, defaults to the 'data' directory.""")
@click.option("--riomarkers-file", "-rf",
              type=click.Path(exists=True),
              required=False,
              help="""Path to the Allocable ODA file. This can be a path to a SharePoint file.
              If not set, defaults to the 'data' directory.""")
@click.option("--climate-riomarkers-file", "-crf",
              type=click.Path(exists=True),
              required=False,
              help="""Path to the Climate RioMarkers file. This can be a path to a SharePoint file.
              If not set, defaults to the 'data' directory.""")
@click.option("--latest-year", "-ly", 
              type=int, 
              required=True, 
              help="Latest year to use in the analysis")
@click.option("--group-by-country", "-country", 
              is_flag=True, 
              help="Group by country? (Each country gets a separate chart output)")
@click.option("--sector", "-s", 
              help="Sector for which to perform the analysis")
@click.option("--folder", "-f", 
              default="DT_update", 
              help="Folder to use inside the project. Defaults to 'DT_update'")
@click.option("--output-file", "-o", 
              default="output.csv", 
              help="Name to use for the output CSV file(s).")
@click.option("--dry-run", "-dr", 
              is_flag=True, 
              help="Only show the results of the query for testing purposes.")
def main(query_name, dac1_file, crs_file, imputed_multilateral_file, riomarkers_file, climate_riomarkers_file, latest_year, group_by_country, sector, folder, output_file, dry_run):
    """Run a query using the provided files and save the result."""
    # Validate query
    sql_file = SQL_DIR / f"{query_name}.sql"
    if not sql_file.exists():
        click.echo(f"Error: Query '{query_name}' not found.")
        click.echo("Available charts:")
        for file in SQL_DIR.glob("*.sql"):
            click.echo(f"  - {file.stem}")
        return
    
    if sector: 
        if not SECTOR_MAPPING.get(sector):
            click.echo(f"Error: Sector '{sector}' not found in the available options")
            click.echo("Available sectors:")
            for abbreviation, full in SECTOR_MAPPING.items():
                click.echo(f"Abbreviation: {abbreviation} || OECD name: {full}")
            return

    # Load SQL template
    with open(sql_file) as f:
        template = Template(f.read())
        query = template.render(dac1_file=dac1_file, 
                                crs_file=crs_file, 
                                imputed_multilateral_file=imputed_multilateral_file,
                                riomarkers_file=riomarkers_file,
                                climate_riomarkers_file=climate_riomarkers_file,
                                latest_year=latest_year,
                                dac_countries=DAC_COUNTRIES,
                                projection_file=projection_file,
                                deflator_file=deflator_file, 
                                dt_sector_file=dt_sector_file, 
                                dt_regions_file=dt_regions_file,
                                dt_channels_file=dt_channels_file,
                                dt_multilaterals_file=dt_multilaterals_file,
                                dt_world_bank_income_file=dt_world_bank_income_file,
                                sector=SECTOR_MAPPING.get(sector))

    # Run query
    click.echo(f"Running query '{query_name}'...")
    click.echo(query)
    with duckdb.connect() as conn:
        result = conn.execute(query).fetchdf()

    if dry_run:
        click.echo(f"First few rows...")
        click.echo(result.head(70))
        return

    # Save output
    if group_by_country: 
        for donor in DAC_COUNTRIES:

            csv_path = (
                SAVE_PATH / 
                folder / 
                f"{donor}_{output_file}.csv"
            )

            click.echo(f"Saving result to: {csv_path}")

            # Force capital 'Donor'
            if 'donor' in result.columns:
                result.rename(columns={'donor': 'Donor'}, inplace=True)

            data = result[(result["Donor"] == donor) | (result["Donor"] == 'DAC Average')]

            data.to_csv(csv_path, index=False)
        return #Stop execution
    
    if output_file:
        result.to_csv(SAVE_PATH / folder / f"{output_file}.csv", index=False)



if __name__ == '__main__':
    main()
