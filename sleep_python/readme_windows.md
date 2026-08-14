# Sleep Analysis Pipeline (Python) — Windows

This pipeline turns raw DAM (Drosophila Activity Monitor) data — or, starting from Step 0, raw multi-channel Monitor dumps straight off the hardware — into activity/sleep plots, a GraphPad-ready spreadsheet, and Prism-ready summary plots.

The pipeline consists of five optional steps and guides you through the process with prompts.

* `run_sleep_analysis_pipeline.py` — the main pipeline
* `sleep_pipeline.py` — the plotting/Prism-export engine used by Step 4

**Important:** `sleep_pipeline.py` must remain in the same folder as `run_sleep_analysis_pipeline.py`.

You do not need to edit the Python scripts. Run the pipeline and answer the prompts in the terminal.

---

## 1. Install Python

You need **Python 3** installed on your Windows computer.

To check whether Python is already installed, open **Windows Terminal** and run:

```powershell
py --version
```

If this returns something such as:

```text
Python 3.12.4
```

Python is installed and you can continue.

If Windows says that `py` is not recognized, install Python from:

https://www.python.org/downloads/windows/

During installation, make sure to select:

**Add python.exe to PATH**

---

## 2. Install the required Python packages

In Windows Terminal, run:

```powershell
py -m pip install numpy matplotlib openpyxl python-dateutil
```

This installs the four packages required by the pipeline.

You can verify that they were installed with:

```powershell
py -m pip show numpy matplotlib openpyxl python-dateutil
```

### About tkinter

`tkinter`, which is used for the pop-up dialogs, normally comes bundled with Python on Windows.

You do **not** normally need to install it separately.

If tkinter is unavailable, the pipeline will fall back to typed text prompts in the terminal.

---

## 3. Get the Python scripts

You need these two files in the same folder:

```text
run_sleep_analysis_pipeline.py
sleep_pipeline.py
```

For example, you could create a folder on your Desktop:

```text
C:\Users\YourName\Desktop\sleep_python
```

and place both Python files there.

---

## 4. Open the pipeline folder in Windows Terminal

In Windows Terminal, use `cd` to move into the folder containing the Python scripts.

For example:

```powershell
cd "C:\Users\YourName\Desktop\sleep_python"
```

Replace `YourName` with your Windows username and change the path if you stored the scripts somewhere else.

You can check that you are in the correct folder by running:

```powershell
dir
```

You should see:

```text
run_sleep_analysis_pipeline.py
sleep_pipeline.py
```

---

## 5. Run the pipeline

Once you are in the folder containing the scripts, run:

```powershell
py run_sleep_analysis_pipeline.py
```

The pipeline will ask which step(s) you want to run.

For example:

```text
1 2 3 4
```

runs Steps 1–4.

To run all five steps, including Step 0:

```text
0 1 2 3 4
```

You can also run individual steps. For example:

```text
2 3
```

runs only Steps 2 and 3.

Press **Enter** without typing anything to run the default sequence, Steps 1–4.

---

## 6. What each step does

### Step 0 — Import raw Monitor data (optional)

Use Step 0 if your starting data consists of raw multi-channel files such as:

```text
Monitor38.txt
Monitor39.txt
```

Step 0 extracts the requested measurement type and date/time range and converts the data into the per-channel format required by Step 1.

It asks for:

* The folder containing the raw `Monitor*.txt` files
* The destination experiment folder
* The date/time range to analyze
* The measurement type (`CT`, `MT`, or `Pn`)

For example:

```text
2026-07-28 10:10:00
```

to

```text
2026-07-30 10:10:00
```

Step 0 creates:

```text
Raw Data\
channelList.txt
mat2read.txt
```

inside the experiment folder.

---

### Step 1 — Process one experiment

Step 1 reads the raw `.txt` files for each channel and calculates sleep/wake in 30-minute bins.

A fly is considered asleep during a stretch of at least 5 minutes with zero activity, following the standard DAM sleep definition.

It asks for:

* The experiment folder
* The number of recording days

It produces:

```text
<name>_channelList.pkl
<name>_channelList.pdf
```

Run Step 1 once for each experiment.

---

### Step 2 — Aggregate experiments

Step 2 combines one or more experiments into a GraphPad-ready Excel workbook.

It asks for:

* The `mat2read` file
* The number of recording days
* The ZT range(s) to analyze

Examples:

```text
0-24
```

for the entire day, or:

```text
0-12,12-24
```

for day and night separately.

The output is an `.xlsx` file containing sleep, activity, bout statistics, and 30-minute sleep traces.

---

### Step 3 — Remove dead animals

Step 3 scans the Step 2 spreadsheet for flies with missing data.

It produces:

```text
<name>_edited.xlsx
```

and adds a `Dead Flies` sheet identifying removed animals.

---

### Step 4 — Generate Prism-ready plots and tables

Step 4 takes the cleaned Step 3 spreadsheet and generates:

```text
<name>_prism_export\
```

containing:

```text
combined\
by_sex\
Prism_ready_data.xlsx
```

The `Prism_ready_data.xlsx` workbook contains data formatted for easy transfer into GraphPad Prism.

---

## 7. Example Windows workflow

If your scripts are on your Desktop in:

```text
C:\Users\Camilo\Desktop\sleep_python
```

open Windows Terminal and run:

```powershell
cd "C:\Users\Camilo\Desktop\sleep_python"
py -m pip install numpy matplotlib openpyxl python-dateutil
py run_sleep_analysis_pipeline.py
```

You only need to install the packages **once**. After that, you can normally just use:

```powershell
cd "C:\Users\Camilo\Desktop\sleep_python"
py run_sleep_analysis_pipeline.py
```

---

## 8. Windows path format

Windows paths normally look like:

```text
C:\Users\Camilo\Desktop\sleep_python
```

rather than the macOS format:

```text
/Users/camilog/Desktop/MAC_sleep_codes
```

When a path contains spaces, put the entire path inside quotation marks:

```powershell
cd "C:\Users\Camilo\Desktop\My Sleep Analysis"
```

---

## Tips

* You can run individual steps later. For example, type `4` to regenerate the Step 4 plots without re-processing the raw data.
* If a step cannot find a required file, it will ask you to select one rather than silently using the wrong file.
* Step 0 creates the destination experiment folder if it does not already exist. Double-check the selected path before confirming.
* Keep `run_sleep_analysis_pipeline.py` and `sleep_pipeline.py` together in the same folder.
