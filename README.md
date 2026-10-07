# Supply Chain Late-Delivery Diagnostic

**Author:** Disha Kanojia
**Tools:** Python (pandas) · MySQL · Power BI

## The question

DataCo, a global online retailer, delivers **57.3% of its orders late**. That's 36,048 of 62,897 orders, worth $18.1M, and the number hasn't moved in three years. I wanted to find out **why**, and what the company could fix first.

## How I approached it

I listed every reason an order could be late (the region it goes to, the type of customer, the product, the time of year, the shipping mode, or the delivery promise itself) and tested each one against the data. If a factor really causes lateness, its groups should look very different. If they all look the same, it isn't the cause.

1. **Cleaned the data in Python.** The raw file had 180,519 product lines, 53 columns, personal data and cancelled orders mixed in. I kept only what I needed, confirmed that "late" means *actual days > promised days*, removed cancelled orders, and turned it into one row per order.
2. **Analysed it in MySQL.** I worked out the late rate for every group of every factor, then compared what each shipping mode promises with how long it actually takes.
3. **Built a 2-page Power BI dashboard** so the findings can be explored with a few clicks.

## What I found

**It isn't where the order goes, or who orders it.** Every region is late 53–60% of the time, every market and customer segment about 57%, and every product department 57–61%. The rate has been flat for 13 quarters.

**It's the shipping mode, and the premium options are the worst.**

| Shipping mode | Promised | Actually takes | Late |
|---|---|---|---|
| First Class | 1 day | 2 days, every single time | **100%** |
| Second Class | 2 days | 2–6 days | **80%** |
| Same Day | same day | 0–1 day | 48% |
| Standard Class | 4 days | 2–6 days | 40% |

**The real problem is the promise.** First Class has never once been delivered in one day. Second Class takes exactly as long as Standard (4 days on average), so customers pay more for no extra speed. Most late orders are only 1–2 days late, which is what an over-ambitious promise looks like, not a broken network.

## What I'd recommend

I kept the real delivery times exactly as they are and only changed the promises:

| Scenario | Late orders |
|---|---|
| Today | 36,048 (57.3%) |
| Honest promises for First Class (2 days) and Same Day (next day) | 24,798 (39.4%) |
| ...and Second Class promised like Standard (4 days) | **19,903 (31.6%)** |

1. **Fix the First Class and Same Day promises now.** It costs nothing and cuts late orders by a third.
2. **Stop selling Second Class as faster than Standard** until it actually is: re-price it or merge it.
3. **Then work on real speed.** Standard and Second Class deliveries vary from 2 to 6 days, and narrowing that is the next operations project.

## Limitations

- The data has no refunds or repeat purchases, so I measured impact in late orders and revenue, not money lost.
- Changing a promise doesn't make a parcel faster. It makes the promise honest, and fixing actual speed is a separate project.
- The delivery-time patterns look partly simulated, so with a real client I'd confirm them with the operations team first.

## Files

| Folder | What's inside |
|---|---|
| `notebooks/` | Python cleaning notebook, every step with its output |
| `sql/` | MySQL files, run in order: load (00), analysis (01), root cause and what-if (02), Power BI table (03) |
| `powerbi/` | the dashboard: open `supply_chain_dashboard.pbip` in Power BI Desktop and click Refresh |
| `data/processed/` | cleaned data used by MySQL and Power BI |
| `outputs/sql_results.txt` | results of every SQL query |
| `docs/` | full project write-up and a guide to each file |

**To run it:** download the raw data (link in `data/raw/README.md`), run the notebook, load the clean files into MySQL with `sql/00`, run `sql/01`–`03`, then open the Power BI file.

**Data:** DataCo Smart Supply Chain, Mendeley Data (Constante, Silva & Pereira, 2019), CC BY 4.0.
