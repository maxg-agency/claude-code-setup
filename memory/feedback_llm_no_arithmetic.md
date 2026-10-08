---
name: feedback_llm_no_arithmetic
description: The model does not compute; calculations go through code and the model quotes the result; no computation means no number
metadata:
  type: feedback
---
Any number that comes from a calculation (sums, percentages, rates, projections) is produced by code: a Python script, a spreadsheet formula, a `bc` call. The model quotes the output. If there was no computation, the answer says "not computed" rather than giving a plausible figure.

**Why:** in a finance bot the strongest model, asked twice in a row, counted 78 records instead of 71 out of 214 rows, and called a spending line an outlier by comparing 9 days of the current month with 31 days of the previous ones without normalizing. The user: "all math only through a Python script, otherwise the model hallucinates". After the calculations moved into code, four check questions came back exact.

**How to apply:** before writing a number into a report, find the line of code or the cell that produced it. If there is none, run it or refuse the number. Rounding and unit conversion count as computation.
