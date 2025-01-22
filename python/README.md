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
```
python -m venv .venv
.venv\Scripts\activate
```

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
  -dac1, --dac1-file PATH         Path to the DAC1 file (Downloaded manually).
  -crs, --crs-file PATH           Path to the CRS file (Downloaded manually).
  -im, --imputed-multilateral-file PATH
                                  Path to the Imputed Multilateral data from
                                  the ONE Campaign (Retrieved manually).
  -ly, --latest-year TEXT         Latest year to use in the analysis
  -country, --group-by-country TEXT
                                  Group by country? (Each country gets a
                                  separate chart output)
  -o, --output TEXT               Output CSV file if not grouped by country.
  --help                          Show this message and exit.
```

# Package Usage

## Files Required:
To successfully use this package, you will need: 
* DAC1 dataset (link here)
* CRS dataset (link here)
* ONE Campaign imputed multilateral data (Can be generated in python/analysis.py)
