# Sleep Analysis Pipeline (Python)

Turns raw DAM (Drosophila Activity Monitor) data — or, starting from Step 0,
even raw multi-channel Monitor dumps straight off the hardware — into
activity/sleep plots, a GraphPad-ready spreadsheet, and Prism-ready summary
plots. One script, five steps (all run by default), guided prompts the whole way.

- [run_sleep_analysis_pipeline.py](run_sleep_analysis_pipeline.py) — the pipeline
- [sleep_pipeline.py](sleep_pipeline.py) — the plotting/Prism-export engine used by Step 4 (must stay in this same folder)

You don't need to edit the script. Just run it and answer the prompts —
either pop-up dialogs (if you're at a normal desktop) or plain text questions
in the terminal.

> **New to this, or new to the terminal?** Read
> **[README_START_HERE.md](README_START_HERE.md)** instead — it walks through
> installing Python, writing your groups file, and answering every prompt, with
> no assumed coding knowledge. This file is the reference version.

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

### For Step 0 — raw Monitor*.txt dumps + a channel-groups manifest

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

First, it asks **which step(s) to run**. Just press Enter to run **all five
steps, including Step 0** — that's the normal full run, starting from raw
`Monitor*.txt` dumps. Type `1 2 3 4` if you already have a `Raw Data` folder
and want to skip the import, or e.g. `2 3` to only re-run steps 2 and 3.

---

## 4. What each step actually does

### Step 0 — Import raw Monitor data
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
into sleep/wake per 30-minute window.

**It asks you for:**
- **The experiment folder** — the folder from section 2 above (containing
  `Raw Data/` and the channelList).
- **How many days were recorded** — just the number of days your monitors
  ran for this experiment, e.g. `2` or `3`. (Pre-filled if you just ran
  Step 0.)
- **The sleep definition** — how many consecutive minutes of zero activity
  count as a sleep episode. **5** is the field standard for DAM data and is
  what you should use unless you have a reason not to; it's a convention, not
  a measurement, so the script lets you change it. Lowering it to `3` scores
  more (and shorter) stretches as sleep; raising it to `10` scores fewer.
  Anything other than 5 gets stamped into the Step 2 filenames (e.g.
  `..._24hrs_sleepdef3min_multiColumnByFly.xlsx`) so a test run can't quietly
  overwrite the standard results you're comparing it against.

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
- **Which metrics you want** — it lists all 17 available metrics, numbered.
  Press Enter (or type `all`) for everything, or pick a subset by number
  (`1 4 8`, `1-5, 16-17`) or by name (`Sleep (mins), P(Wake)`). Each metric
  you pick becomes one sheet; the ones you don't pick are simply not computed
  or written. The per-day 30-min binned sleep traces are always included —
  they're what the Step 4 sleep profiles are built from.

**It produces** one spreadsheet per range you entered, e.g.
`..._24hrs_multiColumnByFly.xlsx` (full day) or `..._ZT0to3_multiColumn.xlsx`
(a partial range), with one sheet per metric you selected plus a
30-min-resolution sleep trace per recording day.

#### The 17 metrics

Each is one value per fly per recording day, computed over the ZT range you
chose. Sleep and active bouts are detected on the *continuous* multi-day
recording, so a bout spanning midnight stays one bout (attributed to the day
it starts in) instead of being split at the day boundary.

| # | Sheet | What it is |
|---|---|---|
| 1 | Sleep (mins) | Total minutes scored as sleep |
| 2 | Activity Counts Per min | Total counts ÷ minutes awake (activity *while awake*) |
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

These are the minute-to-minute state-transition probabilities from
[Wiggin et al. 2020, *PNAS* 117:10024](https://pmc.ncbi.nlm.nih.gov/articles/PMC7211995/).
They separate two things that total sleep amount conflates: how *hard it is to
stay asleep* (P(Wake)) versus how *readily the fly falls asleep* (P(Doze)).
Two genotypes can have identical total sleep for opposite reasons, and this
pair of numbers tells them apart.

Following the paper, they are computed on **raw 1-minute activity**, not on
scored sleep — a minute is "inactive" if its count is 0 and "active" if it's
above 0:

```
P(Wake) = (inactive minutes immediately followed by an active minute)
          ÷ (inactive minutes that have a following minute)

P(Doze) = (active minutes immediately followed by an inactive minute)
          ÷ (active minutes that have a following minute)
```

Two consequences worth knowing:

- **They do not change when you change the sleep definition.** That's by
  design — the paper's whole point is that these are threshold-free. If you
  run the same data at 3, 5 and 10 minutes, P(Wake) and P(Doze) will be
  identical across all three while Sleep (mins) and the bout metrics move.
- **A blank cell means "undefined", not zero.** If a fly never moved during
  the window there are no active minutes, so P(Doze) has a zero denominator;
  the paper calls this undefined and the script leaves the cell empty rather
  than writing a misleading `0`. (Step 3 never uses these two sheets to decide
  which flies are dead, precisely because of this.)

#### ZT profiles — Wiggin et al. Fig. 1B

When you select P(Wake) and/or P(Doze), Step 2 also writes per-30-min-bin
traces (`Day N 60min sliding P(Wake)`, `... P(Doze)`, and
`Day N 30 min binned activity`) alongside the existing binned sleep sheets. Step 4 turns these into the
four-panel figure from the paper — Activity, % Time Asleep, P(Doze), P(Wake)
— in a `wake_doze_profiles/` folder:

- `Wake_doze_profile_<genotype>.png` — one per genotype, stacked panels, double-plotted
  (the 24 h cycle shown twice so events near ZT0/ZT24 aren't cut in half),
  lights-off shaded, population mean with a 95% CI band.
- `P_Wake_ZT_profile.png`, `P_Doze_ZT_profile.png`, `activity_ZT_profile.png`
  — all genotypes overlaid on one axis, which is the comparison view Fig. 1B
  (a single genotype) doesn't give you.
- Matching `P(Wake) ZT Profile` / `P(Doze) ZT Profile` sheets in
  `Prism_ready_data.xlsx`, in the same XY Mean/SEM/N layout.

**How the probability traces are computed.** The two probability profiles use a
**60-minute sliding window advancing 10 minutes at a time** (144 points per day),
rather than the 48 independent 30-minute bins used for sleep and activity. Each
point is a *fresh* calculation over every minute in its window — not a moving
average of bin probabilities — so a wider window means a larger denominator
(a better estimate) instead of a smoothed-over noisy one. This matters because
the noise it fixes comes from tiny denominators: at night a fly has very few
*active* minutes, so P(Doze) over a 30-minute bin can rest on 1–3 observations.
Windows are circular within the 24 h cycle, which avoids edge artefacts at
ZT0/ZT24 — they sit next to each other in the double plot, where any artefact
would be obvious.

To change the window, edit `PROB_WINDOW_MINUTES` / `PROB_STEP_MINUTES` near the
top of `run_sleep_analysis_pipeline.py`. 90 minutes smooths the residual
night-time wobble further, at the cost of blunting the sharp lights-on and
lights-off P(Wake) transients. The window width is recorded in the sheet names
(`Day N 60min sliding P(Wake)`) and printed on the plots, so a smoothed trace is
never presented as if it were raw bins.

Three caveats about reading these:

- **This smoothing is our choice, not the paper's.** Wiggin et al. describe no
  smoothing or sliding window for their Fig. 1B; their traces look clean mainly
  because n = 60 flies. (The "90-min time intervals" in their Methods are
  *non-overlapping* intervals used for the Fig. 1D–E heatmaps, a different
  analysis.) Sliding windows are not comparable point-for-point with their
  published values — the whole-window `P(Wake)`/`P(Doze)` metric sheets are the
  ones to quote.
- **The CI band is `mean ± 1.96 × SEM`**, a normal approximation, not a
  t-based interval — this avoids a scipy dependency. With n ≥ 15 flies the
  difference is a few percent, and every plot states the formula on the title.
- **Sliding windows are not independent of each other.** Neighbouring points
  share most of their minutes, so the trace looks smoother than the underlying
  data supports. Never run statistics across the points of one profile; use the
  per-day metric sheets for that.

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

## 5. The run log

Every run appends to **`sleep_pipeline_run_log.csv`** in the experiment
folder, so you can always answer "what settings produced this file?" without
relying on memory. Columns:

| Column | Meaning |
|---|---|
| `run_id` | Timestamp identifying one run; every row from the same run shares it |
| `timestamp` | When that particular value was recorded |
| `step` | Which step was running (`0 - import raw monitor data`, `1 - process experiment`, …) |
| `parameter` | What was being decided |
| `value` | What it was set to |
| `source` | `answered` = you typed or picked it · `auto-detected` = the pipeline found it and never asked · `derived` = computed from your answers · `output` = a file that was written |

Three things worth knowing:

- **It's append-only.** New runs are added below the old ones; nothing is ever
  overwritten. Re-running the same folder with different settings gives you a
  side-by-side history.
- **It records more than just prompts.** Auto-detected files (the manifest,
  the channelList, the mat2read), derived values (number of channels
  processed, groups found, which flies were dropped as dead and why, the
  actual date range after truncation to whole days), and every output path all
  get logged. So do settings you were never asked about — e.g. the measurement
  type when only one was present in the data.
- **It's written even when a run fails or you cancel it**, recording exactly
  how far it got. If the log can't be written (disk read-only, file open in
  Excel), you get a warning and the analysis itself is unaffected.

---

## Tips

- You can run steps individually later (e.g. just `4` to re-make plots after
  editing colors, without re-processing raw data).
- If a step can't find a file it expects, it'll ask you to pick one instead —
  nothing runs silently on the wrong file.
- Step 0's destination folder is the one place in this pipeline that gets
  *created* rather than just selected if it doesn't already exist — double
  check the path before confirming it.
