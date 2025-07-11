# Set environment variables
# !!Change these to point to relevant paths
$env:DAC1 = "data/Table1_Data.csv";
$env:CRS = "data/CRS.parquet";
$env:IM = "data/seek_sectors_revised_with_channel.parquet";
$env:CRF = "data/climate_riomarkers.txt";
$env:MF = "data/multisystem.txt";
$env:AGF = "data/allocable_gender.csv";
$env:LY = 2023;
$env:DEFLATE = true;


# Run Python scripts
python chart_update.py multilateral_recipients_6a -ly $env:LY -mf $env:MF -country -o "6A_region" -d $env:DEFLATE;


# DAC1 Queries
python chart_update.py all_donor_oda_ranking_2a -ly $env:LY -dac1 $env:DAC1 -o "alldonor_2A_ODATrend" -d $env:DEFLATE;
python chart_update.py all_donor_gni_ranking_2b -ly $env:LY -dac1 $env:DAC1 -o "alldonor_2B_ODAGNIranking" -d $env:DEFLATE;
python chart_update.py refugee_3b -ly $env:LY -country -dac1 $env:DAC1 -o "3B_refugee" -d $env:DEFLATE;
python chart_update.py bimulti_4 -ly $env:LY -country -dac1 $env:DAC1 -o "4_bimulti" -d $env:DEFLATE;
python chart_update.py bimulti_percentage_4a  -ly $env:LY -dac1 $env:DAC1 -country -o "EMEAA_4A_bi-multi" -d $env:DEFLATE;
python chart_update.py total_oda_over_time_3a -ly $env:LY -dac1 $env:DAC1 -country -o "3A_Total ODA over time" -d $env:DEFLATE;


# CRS Queries
python chart_update.py bilateral_oda_by_channel_10a -ly $env:LY -country -crs $env:CRS -o "EMEEA_10A_channel" -d $env:DEFLATE;
python chart_update.py sector_breakdown_5a -ly $env:LY -country -crs $env:CRS -o "5A_sector" -d $env:DEFLATE;
python chart_update.py income_group_5b -ly $env:LY -country -crs $env:CRS -o "5B_income" -d $env:DEFLATE;
python chart_update.py regions_5c -ly $env:LY -country -crs $env:CRS -o "5C_region" -d $env:DEFLATE;
python chart_update.py top_recipients_5d -ly $env:LY -country -crs $env:CRS -o "5d_recipient" -d $env:DEFLATE;
python chart_update.py bilateral_oda_by_flow_type_10b -ly $env:LY -country -crs $env:CRS -o "EMEAA_10b_flow" -d $env:DEFLATE;


# Agriculture Queries
python chart_update.py subsector_split_3_sector -ly $env:LY -crs $env:CRS -s ag -country -o "AG3_sector" -f "Agriculture" -d $env:DEFLATE;
python chart_update.py ranking_absolute_1a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ag -f "Agriculture" -o "alldonor_AG1a_agricultureODAranking" -d $env:DEFLATE;
python chart_update.py ranking_relative_1b_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ag -f "Agriculture" -o "alldonor_AG1b_agricultureODAranking" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ag -country  -f "Agriculture" -o "AG2_trend" -d $env:DEFLATE;
python chart_update.py top_multilateral_recipients_4a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ag -country  -f "Agriculture" -o "AG4a_multi" -d $env:DEFLATE;
#Agriculture Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $env:LY -crs $env:CRS -s ag -o "AG_sector_aggregate" -f "Agriculture" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector_overall -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ag  -f "Agriculture" -o "AG_trend_aggregate" -d $env:DEFLATE;


# Education Queries
python chart_update.py subsector_split_3_sector -ly $env:LY -crs $env:CRS -s ed -country -o "EDUC3_sector" -f "Education" -d $env:DEFLATE;
python chart_update.py ranking_absolute_1a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ed -f "Education" -o "alldonor_EDUC1a_educationODAranking" -d $env:DEFLATE;
python chart_update.py ranking_relative_1b_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ed -f "Education" -o "alldonor_EDUC1b_educationODAranking" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ed -country  -f "Education" -o "EDUC2_trend" -d $env:DEFLATE;
python chart_update.py top_multilateral_recipients_4a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ed -country  -f "Education" -o "EDUC4a_multi" -d $env:DEFLATE;
#Education Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $env:LY -crs $env:CRS -s ed -o "EDUC_sector_aggregate" -f "Education" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector_overall -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s ed  -f "Education" -o "EDUC_trend_aggregate" -d $env:DEFLATE;


# Global Health Queries
python chart_update.py subsector_split_3_sector -ly $env:LY -crs $env:CRS -s gh -country -o "GH3_sector" -f "Global_Health" -d $env:DEFLATE;
python chart_update.py ranking_absolute_1a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s gh -f "Global_Health" -o "alldonor_GH1a_healthODAranking" -d $env:DEFLATE;
python chart_update.py ranking_relative_1b_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s gh -f "Global_Health" -o "alldonor_GH1b_healthODAranking" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s gh -country  -f "Global_Health" -o "GH2_trend" -d $env:DEFLATE;
python chart_update.py top_multilateral_recipients_4a_sector -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s gh -country  -f "Global_Health" -o "GH4a_multi" -d $env:DEFLATE;
#Global Health Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $env:LY -crs $env:CRS -s gh -o "GH_sector_aggregate" -f "Global_Health" -d $env:DEFLATE;
python chart_update.py time_trend_channels_2_sector_overall -ly $env:LY -dac1 $env:DAC1 -crs $env:CRS -im $env:IM -s gh  -f "Global_Health" -o "GH_trend_aggregate" -d $env:DEFLATE;


# Gender Queries
python chart_update.py gender_ranking_absolute_1a -ly $env:LY -crs $env:CRS -f "Gender" -o "alldonor_GE1a_genderODAranking" -d $env:DEFLATE;
python chart_update.py gender_ranking_relative_1b -ly $env:LY -agf $env:AGF -crs $env:CRS -f "Gender" -o "alldonor_GE1b_genderODArelative" -d $env:DEFLATE;
python chart_update.py gender_time_trend_2 -ly $env:LY -agf $env:AGF -crs $env:CRS -country -f "Gender" -o "GE2_trend" -d $env:DEFLATE;
python chart_update.py gender_sector_3 -ly $env:LY -crs $env:CRS -country -f "Gender" -o "GE3_sector" -d $env:DEFLATE;
#Gender Aggregates
python chart_update.py gender_sector_overall -ly $env:LY -crs $env:CRS -f "Gender" -o "GE_sector_aggregate" -d $env:DEFLATE;
python chart_update.py gender_time_trend_overall -ly $env:LY -agf $env:AGF -crs $env:CRS -f "Gender" -o "GE_trend_aggregate" -d $env:DEFLATE;


# Climate Queries
python chart_update.py climate_ranking_absolute_1a -ly $env:LY -crf $env:CRF -crs $env:CRS -f "Climate" -o "alldonor_CL1A_climateODARanking" -d $env:DEFLATE;
python chart_update.py climate_ranking_relative_1b -ly $env:LY -crf $env:CRF -crs $env:CRS -f "Climate" -o "alldonor_CL1B_climateODArankingrelative" -d $env:DEFLATE;
python chart_update.py climate_time_trend_2 -ly $env:LY -crf $env:CRF -crs $env:CRS -country -f "Climate" -o "CL2_trend" -d $env:DEFLATE;
python chart_update.py climate_sector_3b -ly $env:LY -crf $env:CRF -crs $env:CRS -country -f "Climate" -o "CL3B_sector" -d $env:DEFLATE;
python chart_update.py climate_intervention_type_split_3a -ly $env:LY -crf $env:CRF -crs $env:CRS -country -f "Climate" -o "CL3A_type" -d $env:DEFLATE;
#Climate aggregates
python chart_update.py climate_sector_overall -ly $env:LY -crf $env:CRF -crs $env:CRS -f "Climate" -o "CL_sector_aggregate" -d $env:DEFLATE;
python chart_update.py climate_time_trend_overall -ly $env:LY -crf $env:CRF -crs $env:CRS -f "Climate" -o "CL2_trend_aggregate" -d $env:DEFLATE;
