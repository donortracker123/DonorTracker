#!/bin/bash

export DAC1="data/Table1_Data.csv"
# export DAC1="/Users/robertwest/Downloads/Table1_Data.csv" #Added to use old DAC1 data
export CRS="data/CRS.parquet"
export IM="data/seek_sectors_revised_with_channel.parquet"
export CRF="data/climate_riomarkers.txt"
export MF="data/multisystem.txt"
export AGF="data/allocable_gender.csv"
export LY=2023
export DEFLATE=true

set -e #Exit upon any failures


python chart_update.py multilateral_recipients_6a -ly $LY -mf $MF -country -o "6A_region" -d $DEFLATE


#DAC1 queries
python chart_update.py all_donor_oda_ranking_2a -ly $LY -dac1 $DAC1 -o "alldonor_2A_ODATrend" -d $DEFLATE
python chart_update.py all_donor_gni_ranking_2b -ly $LY -dac1 $DAC1 -o "alldonor_2B_ODAGNIranking" -d $DEFLATE
python chart_update.py refugee_3b -ly $LY -country -dac1 $DAC1 -o "3B_refugee" -d $DEFLATE
python chart_update.py bimulti_4 -ly $LY -country -dac1 $DAC1 -o "4_bimulti" -d $DEFLATE
python chart_update.py bimulti_percentage_4a  -ly $LY -dac1 $DAC1 -country -o "EMEAA_4A_bi-multi" -d $DEFLATE
python chart_update.py total_oda_over_time_3a -ly $LY -dac1 $DAC1 -country -o "3A_Total ODA over time" -d $DEFLATE


#CRS queries
python chart_update.py bilateral_oda_by_channel_10a -ly $LY -country -crs $CRS -o "EMEEA_10A_channel" -d $DEFLATE
python chart_update.py sector_breakdown_5a -ly $LY -country -crs $CRS -o "5A_sector" -d $DEFLATE
python chart_update.py income_group_5b -ly $LY -country -crs $CRS -o "5B_income" -d $DEFLATE
python chart_update.py regions_5c -ly $LY -country -crs $CRS -o "5C_region" -d $DEFLATE
python chart_update.py top_recipients_5d -ly $LY -country -crs $CRS -o "5d_recipient" -d $DEFLATE
python chart_update.py bilateral_oda_by_flow_type_10b -ly $LY -country -crs $CRS -o "EMEAA_10b_flow" -d $DEFLATE


#Agriculture
python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s ag -country -o "AG3_sector" -f "Agriculture" -d $DEFLATE
python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -f "Agriculture" -o "alldonor_AG1a_agricultureODAranking" -d $DEFLATE
python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -f "Agriculture" -o "alldonor_AG1b_agricultureODAranking" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -country  -f "Agriculture" -o "AG2_trend" -d $DEFLATE
python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag -country  -f "Agriculture" -o "AG4a_multi" -d $DEFLATE
#Agriculture Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $LY -crs $CRS -s ag -o "AG_sector_aggregate" -f "Agriculture" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector_overall -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ag  -f "Agriculture" -o "AG_trend_aggregate" -d $DEFLATE


#Education
python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s ed -country -o "EDUC3_sector" -f "Education" -d $DEFLATE
python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -f "Education" -o "alldonor_EDUC1a_educationODAranking" -d $DEFLATE
python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -f "Education" -o "alldonor_EDUC1b_educationODAranking" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -country  -f "Education" -o "EDUC2_trend" -d $DEFLATE
python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed -country  -f "Education" -o "EDUC4a_multi" -d $DEFLATE
#Education Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $LY -crs $CRS -s ed -o "EDUC_sector_aggregate" -f "Education" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector_overall -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s ed  -f "Education" -o "EDUC_trend_aggregate" -d $DEFLATE


#Global Health
python chart_update.py subsector_split_3_sector -ly $LY -crs $CRS -s gh -country -o "GH3_sector" -f "Global_Health" -d $DEFLATE
python chart_update.py ranking_absolute_1a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -f "Global_Health" -o "alldonor_GH1a_healthODAranking" -d $DEFLATE
python chart_update.py ranking_relative_1b_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -f "Global_Health" -o "alldonor_GH1b_healthODAranking" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -country  -f "Global_Health" -o "GH2_trend" -d $DEFLATE
python chart_update.py top_multilateral_recipients_4a_sector -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh -country  -f "Global_Health" -o "GH4a_multi" -d $DEFLATE
#Global Health Aggregates
python chart_update.py subsector_split_3_sector_overall -ly $LY -crs $CRS -s gh -o "GH_sector_aggregate" -f "Global_Health" -d $DEFLATE
python chart_update.py time_trend_channels_2_sector_overall -ly $LY -dac1 $DAC1 -crs $CRS -im $IM -s gh  -f "Global_Health" -o "GH_trend_aggregate" -d $DEFLATE


#Gender
python chart_update.py gender_ranking_absolute_1a -ly $LY -crs $CRS -f "Gender" -o "alldonor_GE1a_genderODAranking" -d $DEFLATE
python chart_update.py gender_ranking_relative_1b -ly $LY -agf $AGF -crs $CRS -f "Gender" -o "alldonor_GE1b_genderODArelative" -d $DEFLATE
python chart_update.py gender_time_trend_2 -ly $LY -agf $AGF -crs $CRS -country -f "Gender" -o "GE2_trend" -d $DEFLATE
python chart_update.py gender_sector_3 -ly $LY -crs $CRS -country -f "Gender" -o "GE3_sector" -d $DEFLATE
#Gender Aggregates
python chart_update.py gender_sector_overall -ly $LY -crs $CRS -f "Gender" -o "GE_sector_aggregate" -d $DEFLATE
python chart_update.py gender_time_trend_overall -ly $LY -agf $AGF -crs $CRS -f "Gender" -o "GE_trend_aggregate" -d $DEFLATE


#Climate
python chart_update.py climate_ranking_absolute_1a -ly $LY -crf $CRF -crs $CRS -f "Climate" -o "alldonor_CL1A_climateODARanking" -d $DEFLATE
python chart_update.py climate_ranking_relative_1b -ly $LY -crf $CRF -crs $CRS -f "Climate" -o "alldonor_CL1B_climateODArankingrelative" -d $DEFLATE
python chart_update.py climate_time_trend_2 -ly $LY -crf $CRF -crs $CRS -country -f "Climate" -o "CL2_trend" -d $DEFLATE
python chart_update.py climate_sector_3b -ly $LY -crf $CRF -crs $CRS -country -f "Climate" -o "CL3B_sector" -d $DEFLATE
python chart_update.py climate_intervention_type_split_3a -ly $LY -crf $CRF -crs $CRS -country -f "Climate" -o "CL3A_type" -d $DEFLATE
#Climate aggregates
python chart_update.py climate_sector_overall -ly $LY -crf $CRF -crs $CRS -f "Climate" -o "CL_sector_aggregate" -d $DEFLATE
python chart_update.py climate_time_trend_overall -ly $LY -crf $CRF -crs $CRS -f "Climate" -o "CL2_trend_aggregate" -d $DEFLATE
