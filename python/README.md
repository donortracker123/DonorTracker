# Donor Tracker Chart Update CLI

This project provides a command-line interface (CLI) for generating Donor Tracker charts and reports from custom SQL templates for SEEK GmbH. The queries are executed using DuckDB, and the results can be saved as CSV files that are automatically connected to Flourish. 

# Getting started

## 1) Python

1. Download and install Python 3.10 or later from the official [Python website](https://www.python.org/downloads/).
2. Make sure to check the box "Add Python to PATH" during installation.

**Verify that python is installed:** 

* macOS / Linux:
```
python3 --version
```

* Windows:
```
python --version
```

## 2) git

1. Download and install Git from the official [git website](https://git-scm.com/)

**Verify installation (Same for macOS and Windows):**
```
git --version
```

## 3) Clone the Repository
Open a terminal or command prompt
Change directories to wherever you want your code/files to live
Clone this repository:
```
cd PATH/TO/FOLDER
git clone https://github.com/donortracker123/DonorTracker.git
```

## 4) Create a Virtual Environment
A virtual environment is a completely blank slate in Python. It allows you to install ONLY the packages you need for a project. It's good practice to have one virtual environment per project so that there is no dependency confusion. 

**Navigate to the project directory**
```
cd PATH/TO/FOLDER
```

* macOS/Linux: 
```
python3 -m venv .venv
source .venv/bin/activate
```

* Windows:

NOTE: On Windows Powershell, you may need to allow your shell to execute scripts as this is disabled by default. Check your settings with: 
```
Get-ExecutionPolicy
```

If this returns `Restricted`, you will need to authorize scripts to run with: 

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then you should be able to activate the environment with:

```
python -m venv .venv
.venv\Scripts\activate
```

From your terminal, you should now see `(.venv)` at the front of every prompt. 

## 5) Install the Package Dependencies

```
pip install --upgrade pip
pip install -r requirements.txt
```

## 6) Verify Setup

If everything is installed, you should be able to run the following: 

Change to the python directory: 
```
cd python
```

* macOS/Linux
```
python3 chart_update.py --help
```

* Windows
```
python chart_update.py --help
```

And see the following output (or extremely similar):
```
Usage: chart_update.py [OPTIONS] QUERY_NAME

  Run a query using the provided files and save the result.

Options:
  -dac1, --dac1-file PATH         Path to the DAC1 file (Downloaded from the
                                  OECD). This can be a path to a SharePoint
                                  file. If not set, defaults to the 'data'
                                  directory.
  -crs, --crs-file PATH           Path to the CRS file (Downloaded from the
                                  OECD). This can be a path to a SharePoint
                                  file. If not set, defaults to the 'data'
                                  directory.
  -im, --imputed-multilateral-file PATH
                                  Path to the Imputed Multilateral data from
                                  the ONE Campaign (Retrieved manually). This
                                  can be a path to a SharePoint file. If not
                                  set, defaults to the 'data' directory.
  -ly, --latest-year INTEGER      Latest year to use in the analysis
                                  [required]
  -country, --group-by-country    Group by country? (Each country gets a
                                  separate chart output)
  -s, --sector TEXT               Sector for which to perform the analysis
  -f, --folder TEXT               Folder to use inside the project. Defaults
                                  to 'DT_update'
  -o, --output-file TEXT          Name to use for the output CSV file(s).
  -dr, --dry-run                  Only show the results of the query for
                                  testing purposes.
  --help                          Show this message and exit.
```

# Package Usage

## Files Required:
To successfully use this package, you will need: 
* DAC1 dataset (link here)
* CRS dataset (link here)
* ONE Campaign imputed multilateral data (Can be generated in python/one_campaign_imputed_multilateral.py)

## Git usage
It's a good idea to create a `branch` in git so that the changes you make to the charts aren't immediately live. 
To make sure that you're up to date with what is live on Github: 
```
git checkout main
git pull
```

Then execute: 

```
git checkout -b feature/chart-update-{DATE}
```

Now all of your changes exist on the `feature/chart-update-{DATE}` branch and you can confirm that the changes made are appropriate. 

When you make changes to the charts by using the package, your changes will show up in the version control panel of VS-Code. Here, you will need to 
click the `+` button to `stage` your changes. This will tell git that you really mean to update these files. 

Then, add a message in the text box of what you are changing, and hit `push`. This will sync your changes that you just made to Github (on the `feature/chart-update-{DATE}` branch).

Navigate to Github, and under `branches`, you should see the changes you just made and an option to create a `Pull Request (PR)`. This is the last line of defense to make sure that the charts look correct.

When you create the PR, you will need to merge them (you'll see an option for this in green). Once you do, congrats! Your changes are now live. The only step 
left to show the changes on the Donor Tracker website is to sync them on Flourish. 

## Chart updating
To get started, run the same `help` command that you ran above: 
```
python chart_update.py --help
```

This will show you all of the options that you have for choosing charts to update. 

A particularly useful option is `-dr` which stands for "Dry Run". This will show you the output of the query before saving to a file as another layer of checks.

The `QUERY_NAME` parameter to use is the file name (excluding .sql) of the SQL queries found in the `python/sql/` directory. These are templated SQL queries
that expect some files from you. For example: 
```
python3 chart_update.py all_donor_gni_ranking_2b -ly 2023 -dr -dac1 "PATH/TO/SHARED/FOLDER"
```
This will show you the output of running the "2B All Donor GNI Ranking" analysis. To save this to a file, remove `-dr`