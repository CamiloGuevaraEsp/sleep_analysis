# Sleep Analysis Pipeline (Python) — Windows

This pipeline turns raw DAM (Drosophila Activity Monitor) data — or, starting from Step 0, raw multi-channel Monitor dumps straight off the hardware — into activity/sleep plots, a GraphPad-ready spreadsheet, and Prism-ready summary plots.

The pipeline consists of five steps, all of which run by default, and guides you through the process with prompts.

* `run_sleep_analysis_pipeline.py` — the main pipeline
* `sleep_pipeline.py` — the plotting/Prism-export engine used by Step 4

**Important:** `sleep_pipeline.py` must remain in the same folder as `run_sleep_analysis_pipeline.py`.

You do not need to edit the Python scripts. Run the pipeline and answer the prompts in the terminal.

> **New to this, or new to the terminal?** Read **[README_START_HERE.md](README_START_HERE.md)** instead — it walks through installing Python, writing your groups file, and answering every prompt, with no assumed coding knowledge. This file is the reference version.

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

Press **Enter** without typing anything to run the default sequence, **all five steps (0–4)**. This is the normal full run, starting from raw `Monitor*.txt` dumps.

If you already have a `Raw Data` folder and want to skip the import step, type:

```text
1 2 3 4
```

which runs Steps 1–4.

You can also run individual steps. For example:

```text
2 3
```

runs only Steps 2 and 3.

---

## 6. What each step does

### Step 0 — Import raw Monitor data

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

It asks for:

* The experiment folder
* The number of recording days
* **The sleep definition** — how many consecutive minutes of zero activity count as a sleep episode

**5 minutes** is the field standard for DAM data and is what you should use unless you have a reason not to. It is a convention rather than a measurement, so the script asks instead of hard-coding it: lowering it to `3` scores more (and shorter) stretches as sleep, raising it to `10` scores fewer. Any value other than 5 is stamped into the Step 2 filenames (for example `..._24hrs_sleepdef3min_multiColumnByFly.xlsx`) so that a test run cannot overwrite the standard results you are comparing it against.

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
* **Which metrics to include** in the output

Examples for the ZT range:

```text
0-24
```

for the entire day, or:

```text
0-12,12-24
```

for day and night separately.

For the metric selection, the pipeline lists all 17 available metrics, numbered. Press **Enter** (or type `all`) to include everything, or select a subset by number or by name:

```text
1 4 8
1-5, 16-17
Sleep (mins), P(Wake)
```

Each selected metric becomes one sheet in the workbook. Metrics you do not select are not computed or written. The per-day 30-minute binned sleep traces are always included, because the Step 4 sleep profiles are built from them.

The output is an `.xlsx` file containing one sheet per selected metric plus the 30-minute sleep traces.

#### The 17 metrics

Each value is one fly on one recording day, computed over the ZT range you chose.

| # | Sheet | What it is |
|---|---|---|
| 1 | Sleep (mins) | Total minutes scored as sleep |
| 2 | Activity Counts Per min | Total counts ÷ minutes awake |
| 3 | Total Activity Counts | Sum of all beam crossings |
| 4 | Percent Time Rest | Sleep minutes as % of the window |
| 5 | Percent Time Active | Awake minutes as % of the window |
| 6 | Mean sleep bout w ends (mins) | Mean sleep-bout length |
| 7 | Median sleep bout (mins) | Median sleep-bout length |
| 8 | Num sleep bouts | Number of sleep bouts starting in the window |
| 9 | Longest sleep bout (min) | Longest single sleep bout |
| 10 | Time to first sleep bout (min) | Sleep latency from the start of the window |
| 11 | Num active bouts | Number of wake bouts starting in the window |
| 12 | Mean active bout length (mins) | Mean wake-bout length |
| 13 | Median active bout len (mins) | Median wake-bout length |
| 14 | Mean counts per activity bout | Mean beam crossings per wake bout |
| 15 | Peak activity (counts per min) | Highest single-minute count |
| 16 | **P(Wake)** | Probability an immobile fly starts moving in the next minute |
| 17 | **P(Doze)** | Probability a moving fly stops moving in the next minute |

#### About P(Wake) and P(Doze)

These are the minute-to-minute state-transition probabilities from [Wiggin et al. 2020, *PNAS* 117:10024](https://pmc.ncbi.nlm.nih.gov/articles/PMC7211995/). They separate two things that total sleep amount conflates: how hard it is for the fly to stay asleep, P(Wake), versus how readily it falls asleep, P(Doze). Two genotypes can show identical total sleep for opposite reasons, and this pair of numbers distinguishes them.

Following the paper, they are computed on **raw 1-minute activity** rather than on scored sleep. A minute is *inactive* if its count is 0 and *active* if it is above 0:

```text
P(Wake) = (inactive minutes immediately followed by an active minute)
          / (inactive minutes that have a following minute)

P(Doze) = (active minutes immediately followed by an inactive minute)
          / (active minutes that have a following minute)
```

Two consequences are worth knowing:

* **They do not change when you change the sleep definition.** This is intentional — the point of the method is that it is threshold-free. Running the same data at 3, 5 and 10 minutes gives identical P(Wake) and P(Doze), while Sleep (mins) and the bout metrics change.
* **A blank cell means undefined, not zero.** If a fly never moved during the window there are no active minutes, so P(Doze) has a zero denominator. The paper treats this as undefined, and the script leaves the cell empty rather than writing a misleading `0`. Step 3 never uses these two sheets to identify dead flies, for exactly this reason.

#### ZT profiles — Wiggin et al. Fig. 1B

When you select P(Wake) and/or P(Doze), Step 2 also writes per-bin traces (`Day N 60min sliding P(Wake)`, `... P(Doze)` and `Day N 30 min binned activity`) alongside the existing binned sleep sheets. Step 4 turns these into the four-panel figure from the paper — Activity, % Time Asleep, P(Doze), P(Wake) — inside a `wake_doze_profiles\` folder:

* `Wake_doze_profile_<genotype>.png` — one per genotype, stacked panels, double-plotted (the 24 h cycle shown twice so events near ZT0/ZT24 are not cut in half), lights-off shaded, population mean with a 95% CI band.
* `P_Wake_ZT_profile.png`, `P_Doze_ZT_profile.png`, `activity_ZT_profile.png` — all genotypes overlaid on one axis, which is the comparison view a single-genotype Fig. 1B does not give you.
* Matching `P(Wake) ZT Profile` and `P(Doze) ZT Profile` sheets in `Prism_ready_data.xlsx`, in the same XY Mean/SEM/N layout.

**How the probability traces are computed.** The two probability profiles use a **60-minute sliding window advancing 10 minutes at a time** (144 points per day), rather than the 48 independent 30-minute bins used for sleep and activity. Each point is a *fresh* calculation over every minute in its window — not a moving average of bin probabilities — so a wider window gives a larger denominator (a better estimate) instead of smoothing over a noisy one. This matters because the noise it fixes comes from tiny denominators: at night a fly has very few *active* minutes, so P(Doze) over a 30-minute bin can rest on 1–3 observations. Windows are circular within the 24 h cycle, which avoids edge artefacts at ZT0/ZT24.

To change the window, edit `PROB_WINDOW_MINUTES` and `PROB_STEP_MINUTES` near the top of `run_sleep_analysis_pipeline.py`. 90 minutes smooths the residual night-time wobble further, at the cost of blunting the sharp lights-on and lights-off P(Wake) transients. The window width appears in the sheet names (`Day N 60min sliding P(Wake)`) and on the plots, so a smoothed trace is never presented as raw bins.

Three caveats when reading these:

* **This smoothing is our choice, not the paper's.** Wiggin et al. describe no smoothing or sliding window for their Fig. 1B; their traces look clean mainly because n = 60 flies. The "90-min time intervals" in their Methods are *non-overlapping* intervals used for the Fig. 1D–E heatmaps, a different analysis. Sliding-window values are therefore not comparable point-for-point with their published figures — quote the whole-window `P(Wake)`/`P(Doze)` metric sheets instead.
* **The CI band is `mean ± 1.96 × SEM`**, a normal approximation rather than a t-based interval, which avoids a scipy dependency. With n ≥ 15 flies the difference is a few percent, and every plot states the formula in its title.
* **Sliding windows are not independent of each other.** Neighbouring points share most of their minutes, so the trace looks smoother than the underlying data supports. Do not run statistics across the points of one profile; use the per-day metric sheets for that.

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

## 6b. The run log

Every run appends to **`sleep_pipeline_run_log.csv`** in the experiment folder, so you can always answer "what settings produced this file?" without relying on memory. Open it in Excel.

| Column | Meaning |
|---|---|
| `run_id` | Timestamp identifying one run; every row from the same run shares it |
| `timestamp` | When that particular value was recorded |
| `step` | Which step was running |
| `parameter` | What was being decided |
| `value` | What it was set to |
| `source` | `answered` = you typed or picked it · `auto-detected` = the pipeline found it and never asked · `derived` = computed from your answers · `output` = a file that was written |

Three things worth knowing:

* **It is append-only.** New runs are added below the old ones and nothing is overwritten, so re-running the same folder with different settings gives you a side-by-side history.
* **It records more than just prompts.** Auto-detected files, derived values (channels processed, groups found, flies dropped as dead and why, the date range after truncation to whole days) and every output path are all logged, along with settings you were never asked about.
* **It is written even when a run fails or you cancel it**, recording how far it got. If the file cannot be written — for example because it is open in Excel — you get a warning and the analysis itself is unaffected.

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
