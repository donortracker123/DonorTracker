#!/bin/bash

export DAC1="data/Table1_Data.csv"
export CRS="data/CRS.parquet"
export IM="data/imputed_spending_purpose.csv"
export LY=2023

# python chart_update.py all_donor_oda_ranking_2a -ly $LY -dac1 $DAC1 -o "alldonor_2A_ODATrend";
# python chart_update.py all_donor_gni_ranking_2b -ly $LY -dac1 $DAC1 -o "alldonor_2B_ODAGNIranking";
# python chart_update.py refugee_3b -ly $LY -country -dac1 $DAC1 -o "3B_refugee";
# python chart_update.py bimulti_4 -ly $LY -country -dac1 $DAC1 -o "4_bimulti";
# python chart_update.py bimulti_percentage_4a  -ly $LY -dac1 $DAC1 -country -o "EMEAA_4A_bi-multi"

# python chart_update.py bilateral_oda_by_channel_10a -ly $LY -country -crs $CRS -o "EMEEA_10A_channel";
# python chart_update.py sector_breakdown_5a -ly $LY -country -crs $CRS -o "5A_sector";
# python chart_update.py income_group_5b -ly $LY -country -crs $CRS -o "5B_income";
# python chart_update.py regions_5c -ly $LY -country -crs $CRS -o "5C_region";
# python chart_update.py top_recipients_5d -ly $LY -country -crs $CRS -o "5d_recipient";
# python chart_update.py bilateral_oda_by_flow_type_10b -ly $LY -country -crs $CRS -o "EMEAA_10b_flow";

# python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s ag -country -o "AG3_sector" -f "Agriculture";
# python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -f "Agriculture" -o "alldonor_AG1a_agricultureODAranking";
# python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -f "Agriculture" -o "alldonor_AG1b_agricultureODAranking";
# python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -country  -f "Agriculture" -o "AG2_trend";
# python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -country  -f "Agriculture" -o "AG4a_multi";

# python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s ed -country -o "EDUC3_sector" -f "Education";
# python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -f "Education" -o "alldonor_EDUC1a_educationODAranking";
# python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -f "Education" -o "alldonor_EDUC1b_educationODAranking";
# python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -country  -f "Education" -o "EDUC2_trend";
# python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -country  -f "Education" -o "EDUC4a_multi";

# python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s gh -country -o "GH3_sector" -f "Global_Health";
# python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -f "Global_Health" -o "alldonor_GH1a_healthODAranking";
# python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -f "Global_Health" -o "alldonor_GH1b_healthODAranking";
# python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -country  -f "Global_Health" -o "GH2_trend";
# python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -country  -f "Global_Health" -o "GHa_multi";

