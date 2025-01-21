import click
from pathlib import Path
from jinja2 import Template
import duckdb
from config import DAC_COUNTRIES
SQL_DIR = Path(__file__).parent / "sql"

@click.command()
@click.argument("query-name")
@click.option("--dac1-file", "-dac1", type=click.Path(exists=True), required=False, help="Path to the DAC1 file (Downloaded manually).")
@click.option("--crs-file", "-crs", type=click.Path(exists=True), required=False, help="Path to the CRS file (Downloaded manually).")
@click.option("--imputed-multilateral-file", "-im", type=click.Path(exists=True), required=False, help="Path to the Imputed Multilateral data from the ONE Campaign (Retrieved manually).")
@click.option("--group-by-country", "-country", help="Group by country? (Each country gets a separate chart output)")
@click.option("--output", "-o", default="output.csv", help="Output CSV file if not grouped by country.")
def main(query_name, dac1_file, crs_file, imputed_multilateral_file, group_by_country, output):
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
                                dac_countries=DAC_COUNTRIES)

    # Run query
    click.echo(f"Running query '{query_name}'...")
    click.echo(query)
    conn = duckdb.connect()
    result = conn.execute(query).fetchdf()

    click.echo(f"First few rows...")
    click.echo(result.head(10))
    # Save output
    # result.to_csv(output, index=False)
    # click.echo(f"Result saved to {output}")

if __name__ == '__main__':
    main()
