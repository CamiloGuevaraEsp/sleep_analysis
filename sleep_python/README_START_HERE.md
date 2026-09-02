# START HERE — Sleep Analysis, step by step

**This guide assumes you have never written a line of code.** You do not need
to. You will type two commands, answer some questions, and get your results.

If something goes wrong, jump to [Part 8: When something goes wrong](#part-8--when-something-goes-wrong).
Almost every problem is one of five things, and they're all listed there.

---

## What this actually does

You give it: the raw files that come off the DAM monitors.

It gives you back: an Excel file with sleep and activity numbers for every fly,
graphs, and a spreadsheet you can paste straight into GraphPad Prism.

It takes about 15 minutes the first time (mostly installing things), and about
2 minutes every time after that.

---

## Part 1 — Check whether you already have Python

You need a program called **Python**. You probably already have it.

### On a Mac

1. Press `Command` + `Space`, type `Terminal`, press `Enter`.
   A window with white or black text appears. This is the Terminal. You type
   commands here and press `Enter` to run them.
2. Type this exactly and press `Enter`:

```bash
python3 --version
```

3. If you see something like `Python 3.12.4`, you're done — **skip to Part 2**.
   If you see `command not found`, go to https://www.python.org/downloads/,
   click the big yellow download button, open the file it downloads, and click
   through the installer. Then close the Terminal, open it again, and repeat
   step 2.

### On Windows

1. Press the `Windows` key, type `Terminal`, press `Enter`.
2. Type this exactly and press `Enter`:

```powershell
py --version
```

3. If you see something like `Python 3.12.4`, you're done — **skip to Part 2**.
   If Windows says `py` is not recognized, go to
   https://www.python.org/downloads/windows/ and download the installer.
   **When you run the installer, tick the box that says "Add python.exe to
   PATH" before clicking Install.** This box is easy to miss and everything
   fails later without it. Then close the Terminal, open it again, and repeat
   step 2.

> **Note for Windows users:** everywhere in this guide you see `python3`, you
> type `py` instead. Everywhere you see `pip3`, you type `py -m pip` instead.
> That's the only difference.

---

## Part 2 — Install the four add-ons (once, ever)

Copy this line, paste it into the Terminal, press `Enter`:

```bash
pip3 install numpy matplotlib openpyxl python-dateutil
```

(Windows: `py -m pip install numpy matplotlib openpyxl python-dateutil`)

Text will scroll by for a minute. When you get your cursor back and see no
red `ERROR` lines, it worked. If it says `Successfully installed ...` or
`Requirement already satisfied`, both are fine.

**You never have to do Part 1 or Part 2 again.**

---

## Part 3 — Put the two scripts somewhere you can find

You need these two files, **in the same folder as each other**:

```
run_sleep_analysis_pipeline.py
sleep_pipeline.py
```

Put them somewhere obvious, like a folder on your Desktop called
`sleep_python`. Don't split them up — the first one needs the second one to
make the graphs.

---

## Part 4 — Write your groups file (the only file you make by hand)

This is the one thing the computer can't guess: **which flies are which**.

Open **TextEdit** (Mac) or **Notepad** (Windows) and write one line per group,
like this:

```
45, control_male, 1-16
45, control_female, 17-32
46, mutant_male, 1-16
46, mutant_female, 17-32
```

Each line is: **monitor number, group name, which channels**.

So `45, control_male, 1-16` means *"on monitor 45, channels 1 through 16 are
the group I'm calling control_male"*.

A few rules:

- **Commas between the three parts.** That's what separates them.
- **Group names must not contain a comma** — the script would read it as the
  start of a new column.
- **Use underscores instead of spaces:** `23E10GS_pex16_male`, not
  `23E10GS pex16 male`. Spaces do technically work, but they make the group
  names much harder to read in the output spreadsheets and graph labels.
- **Spell each group name identically every time it appears.**
  `control_male` and `Control_male` are two different groups as far as the
  script is concerned.
- **Skipping a channel is fine.** If channel 16 on monitor 45 was empty,
  write `45, control_male, 1-15` and it just won't be included.
- **Non-consecutive channels are fine too:** `1,3,5-8` works.
- If you want the automatic male-vs-female graphs, end **every** group name in
  `_male` or `_female`. If even one group doesn't, those extra graphs are
  skipped (everything else still works).

### Saving it — this part trips people up

1. **Mac TextEdit only:** click the menu **Format → Make Plain Text** first.
   Otherwise TextEdit saves a fancy `.rtf` file that the script can't read.
2. Decide what you'll call this experiment. Use the date, e.g. `20260813`.
3. Make a new empty folder with **exactly that name**: `20260813`
4. Save your file **inside that folder**, named:
   **`20260813_channelGroups.txt`**

The name has to match the folder name, with `_channelGroups.txt` on the end.
If your folder is `20260813`, the file is `20260813_channelGroups.txt`. If
your folder is `Nov_experiment`, the file is
`Nov_experiment_channelGroups.txt`. Get this right and the script finds it by
itself and never asks you about it.

> Make sure it saved as `.txt` and not `.txt.rtf` or `.txt.docx`. On Windows,
> in the Save dialog set "Save as type" to **Text Documents (*.txt)**.

---

## Part 5 — Run it

In the Terminal, type `cd`, then a space, then **drag the folder containing
the two scripts onto the Terminal window** (this pastes its location for you),
then press `Enter`:

```bash
cd /Users/yourname/Desktop/sleep_python
```

Then type this and press `Enter`:

```bash
python3 run_sleep_analysis_pipeline.py
```

(Windows: `py run_sleep_analysis_pipeline.py`)

It's now running, and it will ask you questions one at a time.

---

## Part 6 — Answering the questions

Questions appear either as **pop-up windows** or as **text in the Terminal**,
depending on your computer. Either way the questions are identical.

Some have a **suggested answer already filled in**. If it looks right, just
press `Enter` (or click OK) to accept it.

Here is every question, in order, with what to do.

---

**1. "Which step(s) do you want to run?"**

→ **Just press Enter.** That runs everything.

*(Later on, if you only want to redo the graphs, you'd type `4` here. Ignore
that for now.)*

---

**2. "Select the folder containing the raw Monitor*.txt files"**

→ A folder picker opens. Choose the folder with `Monitor45.txt`,
`Monitor46.txt`, etc. — the files straight off the monitors.

---

**3. "Select (or create) the destination experiment folder"**

→ Choose the folder you made in Part 4 — the one named `20260813` with your
groups file inside it. **This is where all your results will end up.**

⚠️ This is the only prompt that will *create* a folder if you point it
somewhere that doesn't exist. Double-check you picked the right one.

---

**4. "Start date & time of the range to analyze"**

→ Type when your experiment started, like this:

```
2026-08-04 08:35:00
```

Year-month-day, then the time on a 24-hour clock.

---

**5. "End date & time — the LAST minute you want included"**

→ Type the **last minute you want**, not the minute after it.

If you want 7 full days starting `2026-08-04 08:35:00`, the answer is
`2026-08-11 08:34:00`. (Because 08:35 on the last day would be minute number
one of day 8.)

This matches how DAMFileScan does it. If you get it off by a minute the script
tells you and trims to whole days anyway, so it isn't fatal — but you might
lose a day, so it's worth getting right.

---

**6. "Which measurement type?" (CT / MT / Pn)**

→ **You'll usually never see this question.** It only appears if your monitor
files contain more than one type.

---

**7. "Select the experiment folder"**

→ **The same folder as question 3.** The script is now starting the analysis
part and wants to know where the data it just created lives.

---

**8. "How many days were recorded?"**

→ The number is already filled in from your dates. Press `Enter`.

---

**9. "Sleep definition: how many consecutive minutes of immobility count as a
sleep episode?"**

→ **Type `5`** (it's already filled in — just press `Enter`).

5 minutes is what everyone in the fly sleep field uses. Only change it if
you're deliberately testing whether your result depends on that choice. If you
do change it, the results get saved under a different filename
(`..._sleepdef3min_...`) so you can compare them side by side without one
overwriting the other.

---

**10. "Detect flies with behavioral death?"**

→ **Yes** (already selected — press `Enter`).

This finds flies that stopped moving entirely and stayed that way, and removes
them so a dead fly isn't counted as a sleeper. Two follow-up
questions appear; 1) what is the timeframe to consider death? 2) what is the percentage of activity during that window for a dead fly. 

As default there is 24 and 1, which means that if the fly was not active at least 1% of the following 24 hours it is dead. Change it if needed


---

**11. "How many days should be aggregated?"**

→ Already filled in. Press `Enter`.

---

**12. "Which ZT hour range(s) do you want to analyze?"**

→ **Type `0-24`** for the whole day (already filled in — press `Enter`).

ZT means hours since the lights came on. So:

| You type | You get |
|---|---|
| `0-24` | the whole day |
| `0-12, 12-24` | daytime and nighttime as **two separate result files** |
| `0-3` | only the first 3 hours after lights-on |
| `0-24, 0-12, 12-24` | all three, as three separate files |

You can list as many as you want, separated by commas. Each one produces its
own complete set of results.

---

**13. "Which metrics do you want in the output?"**

→ **Type `all`** (already filled in — press `Enter`).

It lists 17 numbered metrics. `all` gives you every one. If you only want a
few, you can type `1 4 8`, or `1-5, 16-17`, or the names themselves.

Numbers 16 and 17 are **P(Wake)** and **P(Doze)**, which are worth knowing
about: P(Wake) is how likely a still fly is to start moving, P(Doze) is how
likely a moving fly is to stop. If two groups sleep the same total amount,
these two numbers often show they're getting there in completely different
ways.

---

**14. "Clean the file(s) just created in step 2?"**

→ **Yes** (press `Enter`). This removes flies with missing data.

---

**15. "Use the multi-column export(s) just created?"**

→ **Yes** (press `Enter`). This makes the graphs.

---

Now wait. It prints a lot of text — that's normal, it's telling you what it's
doing. When it's finished you'll see:

```
Pipeline finished.
Run log (every setting used): .../sleep_pipeline_run_log.csv
```

---

## Part 7 — Where your results are

Open your experiment folder (`20260813`). You'll find:

| What | What it's for |
|---|---|
| **`..._edited.xlsx`** | **Your main results.** One sheet per metric, one row per fly, one column per day. Dead flies already removed. |
| **`..._prism_export/`** folder | Your graphs and Prism tables — see below |
| `..._channelList.pdf` | One page per fly showing its activity trace. Flip through this to sanity-check your data. |
| `sleep_pipeline_run_log.csv` | Every setting you chose, with the date and time. See below. |
| `..._channelList.pkl` | Internal working file. Ignore it, don't delete it. |
| `Raw Data/` folder | The per-fly files it extracted. Ignore. |

Inside the **`..._prism_export/`** folder:

- **`Prism_ready_data.xlsx`** — open this, copy a block, paste it into
  GraphPad Prism. The first sheet (README) explains which Prism table type to
  use for each sheet.
- **`combined/`** — a graph for each metric, all groups together, plus the
  sleep-over-time profiles.
- **`by_sex/`** — the same graphs split into males and females. *(Only appears
  if all your group names end in `_male` or `_female`.)*

### About the run log

`sleep_pipeline_run_log.csv` opens in Excel. Every time you run the pipeline
on this folder, it adds rows recording every answer you gave, every setting,
and every file produced — each run tagged with its own date and time.



---

## Part 8 — When something goes wrong

Read the last few lines the Terminal printed. The answer is almost always
there. Here are the ones people actually hit:

---

**`command not found: python3`** (Mac) or **`py is not recognized`** (Windows)

Python isn't installed, or on Windows you missed the "Add python.exe to PATH"
tickbox. Go back to Part 1. On Windows, reinstall and tick the box.

---

**`ModuleNotFoundError: No module named 'numpy'`** (or matplotlib, openpyxl,
dateutil)

You skipped Part 2, or it didn't finish. Run the `pip3 install` line again.

---

**`can't open file 'run_sleep_analysis_pipeline.py'`**

You're not in the right folder. Do the `cd` step in Part 5 again — type `cd`,
a space, then drag the folder onto the Terminal window.

---

**`No module named 'sleep_pipeline'`**

`sleep_pipeline.py` isn't sitting next to `run_sleep_analysis_pipeline.py`.
Put both files in the same folder.

---

**`expected 'monitor, group, channel_range', got: ...`**

A line in your groups file is malformed. Check that line for:
missing commas, a group name containing a space or a comma, or a stray blank
line with punctuation on it. The error message tells you the exact line
number.

---

**It asks you to pick the channel-groups manifest instead of finding it**

The file name doesn't match the folder name. Folder `20260813` needs the file
`20260813_channelGroups.txt`, spelled exactly. Also check it isn't secretly
saved as `.rtf` — in TextEdit, use **Format → Make Plain Text** before saving.

---

**`Could not find .../Monitor45.txt`**

Your groups file mentions monitor 45, but there's no `Monitor45.txt` in the
raw dumps folder you selected. Either you picked the wrong folder, or you
typed the wrong monitor number in the groups file.

---

**`Range is only N minute(s)` or `truncating to N whole day(s)`**

Your start and end date/time don't cover a whole number of days. Re-read
question 5 in Part 6 — the end time is the **last minute you want included**,
so for 7 days it's one minute *before* the same clock time on the last day.

---

**`Permission denied` when it writes the run log, or a file won't save**

You have that Excel file open. Close it in Excel and run again.

---

**Something else**

Copy the last 15 lines the Terminal printed and bring them to whoever set this
up. The error text is what makes it fixable — a screenshot of it is fine, but
"it didn't work" isn't enough to go on.

---

## Cheat sheet

Once you've done this once, the whole thing is:

```bash
cd /Users/yourname/Desktop/sleep_python
python3 run_sleep_analysis_pipeline.py
```

then: **Enter → pick raw folder → pick experiment folder → type your two
dates → Enter through everything else.**

---

## Want more detail?

- [README_python.md](README_python.md) — what every step does, what every
  metric means, the maths behind P(Wake) and P(Doze)
- [readme_windows.md](readme_windows.md) — the same, written for Windows
