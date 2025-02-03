import click
import duckdb
import pandas as pd
from pathlib import Path
from jinja2 import Template
from config import DAC_COUNTRIES, SECTOR_MAPPING, projection_file, deflator_file, dt_sector_file, dt_regions_file, dt_channels_file

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
@click.option("--latest-year", "-ly", 
              type=int, 
              required=True, 
              help="Latest year to use in the analysis")
@click.option("--group-by-country", "-country", 
              is_flag=True, 
              help="Group by country? (Each country gets a separate chart output)")
@click.option("--sector", "-s", 
              help="Sector for which to perform the analysis")
@click.option("--output", "-o", 
              default="output.csv", 
              help="Name to use for the output CSV file(s).")
@click.option("--dry-run", "-dr", 
              is_flag=True, 
              help="Only show the results of the query for testing purposes.")
def main(query_name, dac1_file, crs_file, imputed_multilateral_file, latest_year, group_by_country, sector, output, dry_run):
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
                                latest_year=latest_year,
                                dac_countries=DAC_COUNTRIES,
                                projection_file=projection_file,
                                deflator_file=deflator_file, 
                                dt_sector_file=dt_sector_file, 
                                dt_regions_file=dt_regions_file,
                                dt_channels_file=dt_channels_file,
                                sector=SECTOR_MAPPING.get(sector))

    # Run query
    click.echo(f"Running query '{query_name}'...")
    click.echo(query)
    with duckdb.connect() as conn:
        result = conn.execute(query).fetchdf()

    if dry_run:
        click.echo(f"First few rows...")
        click.echo(result.head(10))
        return

    # Save output
    if group_by_country: 
        for donor in DAC_COUNTRIES:

            csv_path = (
                SAVE_PATH / "OP" / f"{donor}_{output}.csv" 
                if donor in ['Austria', 'Belgium', 'Denmark', 'Finland', 'Ireland', 'Luxembourg', 'Switzerland']
                else 
                SAVE_PATH / "DT_update" / f"{donor}_{output}.csv"
            )

            click.echo(f"Saving result to: {csv_path}")

            data = result[(result["donor"] == donor) | (result["donor"] == 'DAC Average')]

            data.to_csv(csv_path, index=False, columns=[col for col in data.columns if col != "donor"])
        return #Stop execution
    
    if output:
        result.to_csv(SAVE_PATH / "DT_update" / f"{output}.csv", index=False)



if __name__ == '__main__':
    main()
