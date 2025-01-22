import click
from pathlib import Path
from jinja2 import Template
import duckdb
from config import DAC_COUNTRIES, projection_file, deflator_file_long
SQL_DIR = Path(__file__).parent / "sql"
SAVE_PATH = Path(__file__).parent.parent

@click.command()
@click.argument("query-name")
@click.option("--dac1-file", "-dac1", type=click.Path(exists=True), required=False, help="Path to the DAC1 file (Downloaded manually).")
@click.option("--crs-file", "-crs", type=click.Path(exists=True), required=False, help="Path to the CRS file (Downloaded manually).")
@click.option("--imputed-multilateral-file", "-im", type=click.Path(exists=True), required=False, help="Path to the Imputed Multilateral data from the ONE Campaign (Retrieved manually).")
@click.option("--latest-year", "-ly", required=False, help="Latest year to use in the analysis")
@click.option("--group-by-country", "-country", help="Group by country? (Each country gets a separate chart output)")
@click.option("--output", "-o", default="output.csv", help="Output CSV file if not grouped by country.")
def main(query_name, dac1_file, crs_file, imputed_multilateral_file, latest_year, group_by_country, output):
    """Run a query using the provided files and save the result."""
    # Validate query
    sql_file = SQL_DIR / f"{query_name}.sql"
    if not sql_file.exists():
        click.echo(f"Error: Query '{query_name}' not found.")
        click.echo("Available charts:")
        for file in SQL_DIR.glob("*.sql"):
            click.echo(f"  - {file.stem}")
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
                                deflator_file_long=deflator_file_long)

    # Run query
    click.echo(f"Running query '{query_name}'...")
    click.echo(query)
    conn = duckdb.connect()
    result = conn.execute(query).fetchdf()

    click.echo(f"First few rows...")
    click.echo(result.head())

    # Save output
    if group_by_country: 
        for donor in DAC_COUNTRIES:
            if donor in ['Austria', 'Belgium', 'Denmark', 'Finland', 'Ireland', 'Luxembourg', 'Switzerland']:
                save_path = SAVE_PATH / "OP" / f"{donor}{query_name}.csv"
            else: 
                save_path = SAVE_PATH / "DT_update" / f"{donor}_{output}.csv"

            click.echo(f"Saving result to: {save_path}")

            data = result[result["donor"] == donor]
            data.drop("donor", axis=1)
            data.to_csv(output, index=False)

if __name__ == '__main__':
    main()
