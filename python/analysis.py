"""Replicate ONE's multilateral sectors analysis using the oda-data package"""

import pandas as pd
from oda_data import set_data_path, ODAData, add_sectors, add_broad_sectors
from oda_data.clean_data.channels import add_channel_names


# Set the path to the raw data folder. Using the config module, we can access the "raw_data" folder
# inside this project's root folder.
set_data_path("python/data")


def groupby_purpose(
    data: pd.DataFrame, value_column: str, group_by: str, by_recipient: bool = False
) -> pd.DataFrame:
    """Group the data by purpose codes and recipient, if requested.

    Args:
        data (pd.DataFrame): The data to group.
        value_column (str): The name of the column with the values to sum.
        group_by (str): The level of aggregation for the data. Options are "purpose", "sector",
        or "broad_sector".
        by_recipient (bool): Whether to group the data by recipient. The default is False.

    Returns:
        pd.DataFrame: The grouped data.
    """
    # Drop the existing purpose names, unless the data is requested at that level
    if group_by != "purpose" and "purpose_name" in data.columns:
        data = data.drop(columns="purpose_name")

    # Group the data by the requested level of aggregation, if "sector" or "broad_sector"
    # are requested.
    if group_by == "sector":
        data = add_sectors(data)
    elif group_by == "broad_sector":
        data = add_broad_sectors(data)
    elif group_by != "purpose":
        raise ValueError(
            "Invalid value for group_by. Must be 'purpose', 'sector', or 'broad_sector'"
        )

    # For that we need to exclude the value columns and, if needed, the recipient
    exclude = (
        ["share", "value"]
        if by_recipient
        else ["share", "value", "recipient_code", "recipient_name"]
    )
    # Get the columns to group by
    grouper = [c for c in data.columns if c not in exclude]

    # Group the data
    data = (
        data.groupby(grouper, observed=True, dropna=False)[value_column]
        .sum()
        .reset_index()
    )

    return data


def get_multilateral_spending_shares(
    start_year: int,
    end_year: int,
    group_by: str = "purpose",
    by_recipient: bool = False,
) -> pd.DataFrame:
    """Get sector spending shares for multilateral agencies.

    The data can be grouped by purpose codes (very detailed), by sector (less detailed), or
    by broad sector (least detailed). The default is to group by purpose codes.

    Args:
        start_year (int): The start year for the data.
        end_year (int): The end year for the data.
        group_by (str): The level of aggregation for the data. Options are "purpose", "sector",
        or "broad_sector". The default is "purpose".
        by_recipient (bool): Whether to show the data by recipient country. The default is False,
        which means the data will be shown for all recipients, total.

    Returns:
        pd.DataFrame: A DataFrame with the spending shares for each sector.

    """

    # Create an instance of the ODAData class. For the sectors analysis, the starting
    # year must be 2 years before the requested start_year in order to create the 3-year
    # spending totals
    oda = ODAData(years=range(start_year - 2, end_year + 1))

    # Load the shares indicator
    oda.load_indicator(indicators=["multilateral_purpose_spending_shares"])

    # Get the spending shares for the multilateral agencies
    shares = oda.get_data()

    # Group the data by the requested level of aggregation, if "sector" or "broad_sector"
    # are requested.
    shares = groupby_purpose(
        shares, value_column="share", group_by=group_by, by_recipient=by_recipient
    )

    # Add channel names
    shares = add_channel_names(shares)

    # Clean the output columns
    shares = shares.filter(
        ["year", "indicator", "channel_code", "mapped_name", "purpose_name", "share"]
    )

    return shares


def get_imputed_multilateral_disbursements_by_sector(
    start_year: int,
    end_year: int,
    currency: str = "USD",
    prices: str = "current",
    base_year: int | None = None,
    group_by: str = "purpose",
    by_recipient: bool = False,
) -> pd.DataFrame:
    """Get the imputed multilateral disbursements by sector.

    The data can be grouped by purpose codes (very detailed), by sector (less detailed), or
    by broad sector (least detailed). The default is to group by purpose codes.

    Args:
        start_year (int): The start year for the data.
        end_year (int): The end year for the data.
        currency (str): The currency for the data. The default is "USD".
        prices (str): The price type for the data. The default is "current".
        base_year (int): The base year for the prices. The default is None.
        group_by (str): The level of aggregation for the data. Options are "purpose", "sector",
        or "broad_sector". The default is "purpose".
        by_recipient (bool): Whether to show the data by recipient country. The default is False,
        which means the data will be shown for all recipients, total.

    Returns:
        pd.DataFrame: A DataFrame with the imputed multilateral disbursements by sector.

    """

    # Create an instance of the ODAData class. For the sectors analysis, the starting
    # year must be 2 years before the requested start_year.
    oda = ODAData(
        years=range(start_year - 2, end_year + 1),
        currency=currency,
        prices=prices,
        base_year=base_year,
        include_names=True,
    )

    # Load the  indicator
    oda.load_indicator(indicators=["imputed_multi_flow_disbursement_gross"])

    # Get the spending data
    spending = oda.get_data()

    # Group the data by the requested level of aggregation, if "sector" or "broad_sector"
    # are requested.
    spending = groupby_purpose(
        spending, value_column="value", group_by=group_by, by_recipient=by_recipient
    )

    # Add channel names
    spending = add_channel_names(spending)

    return spending


def get_bilateral_disbursements_by_sector(
    start_year: int,
    end_year: int,
    currency: str = "USD",
    prices: str = "current",
    base_year: int | None = None,
    group_by: str = "purpose",
    by_recipient: bool = False,
) -> pd.DataFrame:
    """Get the bilateral disbursements by sector.

    The data can be grouped by purpose codes (very detailed), by sector (less detailed), or
    by broad sector (least detailed). The default is to group by purpose codes.

    Args:
        start_year (int): The start year for the data.
        end_year (int): The end year for the data.
        currency (str): The currency for the data. The default is "USD".
        prices (str): The price type for the data. The default is "current".
        base_year (int): The base year for the prices. The default is None.
        group_by (str): The level of aggregation for the data. Options are "purpose", "sector",
        or "broad_sector". The default is "purpose".
        by_recipient (bool): Whether to show the data by recipient country. The default is False,
        which means the data will be shown for all recipients, total.

    Returns:
        pd.DataFrame: A DataFrame with the bilateral disbursements by sector.
    """

    # Create an instance of the ODAData class. For the sectors analysis, the starting
    # year must be 2 years before the requested start_year.
    oda = ODAData(
        years=range(start_year, end_year + 1),
        currency=currency,
        prices=prices,
        base_year=base_year,
        include_names=True,
    )

    # Load the indicator
    oda.load_indicator(indicators=["crs_bilateral_flow_disbursement_gross"])

    # Get the spending data
    spending = oda.get_data().filter(
        [
            "year",
            "indicator",
            "donor_code",
            "donor_name",
            "recipient_code",
            "recipient_name",
            "purpose_code",
            "prices",
            "currency",
            "value",
        ]
    )

    # Group the data by the requested level of aggregation, if "sector" or "broad_sector"
    # are requested.
    spending = groupby_purpose(
        spending, value_column="value", group_by=group_by, by_recipient=by_recipient
    )

    return spending


if __name__ == "__main__":

    imputed_spending_purpose = get_imputed_multilateral_disbursements_by_sector(
        start_year=2015,
        end_year=2023,
        prices="constant",
        base_year=2021,
        group_by="purpose",
    )

    imputed_spending_purpose.to_csv(r'~/Documents/dev/DonorTracker/python/data/imputed_spending_purpose.csv', index=False)
