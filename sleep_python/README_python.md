# Sleep Analysis Pipeline (Python)

Turns raw DAM (Drosophila Activity Monitor) data — or, starting from Step 0,
even raw multi-channel Monitor dumps straight off the hardware — into
activity/sleep plots, a GraphPad-ready spreadsheet, and Prism-ready summary
plots. One script, five optional steps, guided prompts the whole way.

- [run_sleep_analysis_pipeline.py](run_sleep_analysis_pipeline.py) — the pipeline
- [sleep_pipeline.py](sleep_pipeline.py) — the plotting/Prism-export engine used by Step 4 (must stay in this same folder)

You don't need to edit the script. Just run it and answer the prompts —
either pop-up dialogs (if you're at a normal desktop) or plain text questions
in the terminal.

*(There's also a MATLAB version of steps 1–4 in this same folder, producing
identical numbers, if you'd rather use that — see [README.md](README.md).)*

---

## 1. Install what you need

You need **Python 3** with four packages. Open Terminal and run:

```bash
pip3 install numpy matplotlib openpyxl python-dateutil
```

(`tkinter`, used for the pop-up dialogs, normally comes bundled with Python —
you don't need to install it separately. If it's missing, the script just
falls back to typed text prompts instead of pop-ups; everything still works.)

---

## 2. What files you need before you start

### For Step 0 (optional) — raw Monitor*.txt dumps + a channel-groups manifest

Skip this if you already have a `Raw Data` folder of one-file-per-channel
`.txt` files (go to the next section instead). Use this if what you have
instead is the *raw* multi-channel dump straight off the DAM hardware — one
file per monitor (e.g. `Monitor38.txt`), each row holding one minute for
*every* channel on that monitor, for one measurement type (CT/MT/Pn),
covering the monitor's entire continuous logging span (often weeks, well
beyond any one experiment).

You need:
1. **The folder of raw dumps** — `Monitor38.txt`, `Monitor39.txt`, etc.
2. **A channel-groups manifest** — a plain text file *you* write, naming
   which channels on which monitors belong to which group. It goes inside
   the destination experiment folder (the folder Step 0 will create/fill —
   see below), named `<folder name>_channelGroups.txt`:

   ```
   # monitor, group, channel_range
   38, 23E10GS_pex16_male, 1-16
   38, 23E10GS_pex16_female, 17-32
   39, pex16_control_male, 1-16
   39, pex16_control_female, 17-32
   ```
   No header row (the `#` line above is just a comment for your own
   reference — any line starting with `#` is ignored). Channel ranges accept
   `1-16` or a comma/semicolon list like `1,3,5-8`.

Step 0 then asks for the destination experiment folder (created for you if
it doesn't exist yet) and a date/time range (e.g. `2026-07-28 10:10:00` to
`2026-07-30 10:10:00`), and writes a `Raw Data/` folder plus a
`channelList.txt` there — exactly the inputs Step 1 needs, described next.

### For Step 1 — one experiment folder, laid out like this:

```
20260804/                              <- name this whatever you want; it becomes part of the output filenames
├── Raw Data/
│   ├── 20260804M001C01.txt            <- one .txt file per channel, straight off the DAM monitor
│   ├── 20260804M001C02.txt
│   └── ...
└── 20260804_channelList.txt           <- must be named "<folder name>_channelList.txt" (or .xlsx)
```

If you ran Step 0, this folder was just built for you automatically. If
you're building it yourself (or already have it from before), the
channelList has **no header row** — each row is one channel, comma-separated:

```
1,23E10GS_pex16_male,1
2,23E10GS_pex16_male,1
3,pex16_control_male,1
...
```
(channel, group, monitor). An Excel `.xlsx` file with the same three columns
also works, if that's what you already have.

### For Step 2 — a "mat2read" file listing which experiments to combine

**If you ran Step 0**, this was already created for you —
`<folder name>_mat2read.txt`, one row, with the group names taken straight
from your channel-groups manifest. Step 2 finds it automatically; you don't
need to make anything yourself. Skip to Step 3 unless you want to pool in
*other* experiments too (see below).

Otherwise, this is a separate file, e.g. `20260804_mat2read.txt`, also **no
header row**. One row per experiment (folder) you want pooled together; one
column per group you want in the final output, comma-separated:

```
/path/to/20260804,20260804_channelList,23E10GS_pex16_male,pex16_control_male
/path/to/20260805,20260805_channelList,23E10GS_pex16_male,pex16_control_male
```

(experiment folder path, base name of the `.pkl` Step 1 created, then one
group name per column.) If you're only analyzing one experiment, this file
just has one row. The group names in each column must exactly match a group
name from that row's channelList. An Excel `.xlsx` file with the same
columns also works, if that's what you already have.

You don't need to build this by hand from scratch every time — it's a small
spreadsheet you maintain and reuse/extend as you add experiments.

---

## 3. Running it

In Terminal:
```bash
cd "/Users/camilog/Desktop/MAC_sleep_codes"
python3 run_sleep_analysis_pipeline.py
```
After cd is the directory where your codes run_sleep_analysis_pipeline.py and sleep_pipeline.py are stored

First, it asks **which step(s) to run** — type `1 2 3 4` (or just press
Enter) to run everything except Step 0, or e.g. `2 3` to only re-run steps 2
and 3. Add `0` at the front (`0 1 2 3 4`) if you're starting from raw
`Monitor*.txt` dumps rather than an existing `Raw Data` folder — Step 0 is
opt-in, so it's *not* included when you just press Enter.

---

## 4. What each step actually does

### Step 0 — Import raw Monitor data (optional)
Slices one measurement type and one date/time range out of the raw,
everything-mixed-together monitor dumps, and writes it into the same
per-channel format Step 1 expects.

**It asks you for:**
- **The folder of raw Monitor*.txt dumps.**
- **The destination experiment folder** (created if it doesn't exist).
- **The date & time range to analyze** — e.g. `2026-07-28 10:10:00` to
  `2026-07-30 10:10:00`. Auto-truncated to a whole number of days if it isn't
  one exactly.
- **Which measurement type to use** (CT/MT/Pn) — only asked if more than one
  is present across the monitor files you need; defaults to `CT`, the
  standard beam-crossing activity count.

**It produces**, inside the destination folder: a `Raw Data/` folder (one
legacy-format `.txt` file per channel), a `channelList.txt`, and a
`mat2read.txt` (one row, groups taken from your manifest) — ready for Steps 1
and 2, which will find all three automatically. No further manual file
creation needed for a single-experiment analysis.

### Step 1 — Process one experiment
Reads the raw `.txt` files for every channel and bins each fly's activity
into sleep/wake per 30-minute window (a fly is "asleep" during any stretch of
≥5 minutes with zero activity — the standard DAM sleep definition).

**It asks you for:**
- **The experiment folder** — the folder from section 2 above (containing
  `Raw Data/` and the channelList).
- **How many days were recorded** — just the number of days your monitors
  ran for this experiment, e.g. `2` or `3`. (Pre-filled if you just ran
  Step 0.)

**It produces**, next to your channelList file:
- `<name>_channelList.pkl` — the binned data, used by Step 2. You won't open
  this yourself.
- `<name>_channelList.pdf` — one page per fly, showing its activity and sleep
  trace for every day recorded. Good for spot-checking that a fly's data
  looks reasonable (or catching a dead/stuck channel).

Run this once per experiment folder.

### Step 2 — Aggregate experiments into a GraphPad Excel export
Pools the flies from one or more experiments (per the mat2read file) into a
single spreadsheet, grouped by genotype, with per-fly sleep amount, activity
level, and sleep-bout statistics (number of bouts, longest bout, latency to
first sleep, etc.) for each day.

**It asks you for:**
- **The mat2read file** — auto-detected if you ran Step 0 (no prompt at all);
  otherwise the one from section 2 above.
- **How many days to aggregate** — should match what you recorded.
- **Which ZT hour range(s) to analyze** — "ZT" (Zeitgeber Time) is just hours
  since lights-on, 0–24. Type e.g.:
  - `0-24` for the whole day (the normal default)
  - `0-12, 12-24` to get day and night computed separately, as two files
  - `0-3` if you only care about, say, the first 3 hours
  - You can comma-separate as many ranges as you want; each produces its own
    output file.

**It produces** one spreadsheet per range you entered, e.g.
`..._24hrs_multiColumnByFly.xlsx` (full day) or `..._ZT0to3_multiColumn.xlsx`
(a partial range), with a sheet each for total sleep, activity, bout stats,
and a 30-min-resolution sleep trace per recording day.

### Step 3 — Remove dead animals
Scans the Step 2 spreadsheet for flies with missing data (a common sign a fly
died partway through the recording) and removes that row from every sheet.

**It asks you for:**
- Whether to clean the file Step 2 just made (usually yes), or a different
  file if you're running Step 3 on its own.

**It produces** `..._edited.xlsx` — the same spreadsheet, minus dead flies,
plus a "Dead Flies" sheet listing which rows were removed.

### Step 4 — Generate Prism-ready plots & tables
Takes the cleaned Step 3 spreadsheet and makes publication-style plots plus a
copy/paste-ready workbook for GraphPad Prism.

**It asks you for:**
- Whether to use the file Step 3 just cleaned (usually yes), or a different
  multi-column file.

**It produces** a `<name>_prism_export/` folder next to that file, containing:
- `combined/` — one bar+dot plot per metric (all genotypes together), plus a
  sleep-over-time profile and a continuous multi-day profile (if you recorded
  more than one day).
- `by_sex/` — the same, split by sex, *only if* every genotype name in your
  channelList ends in `_male` or `_female`.
- `Prism_ready_data.xlsx` — every metric as a Prism "Column" table, ready to
  paste straight into Prism.

---

## Tips

- You can run steps individually later (e.g. just `4` to re-make plots after
  editing colors, without re-processing raw data).
- If a step can't find a file it expects, it'll ask you to pick one instead —
  nothing runs silently on the wrong file.
- Step 0's destination folder is the one place in this pipeline that gets
  *created* rather than just selected if it doesn't already exist — double
  check the path before confirming it.
