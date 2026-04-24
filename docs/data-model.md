# Data Model & Setup Guide

## Star Schema Overview

Power BI works best with a star schema. Here's the recommended model:

```
                     dim_Date
                        │
         ┌──────────────┼──────────────┐
         │              │              │
   fact_Cases    fact_Opportunities   fact_Leads
         │              │
    dim_Owner      dim_Account
         │
    dim_Priority
```

## Table Relationships

| From Table | From Column | To Table | To Column | Cardinality |
|---|---|---|---|---|
| fact_Cases | OwnerId | dim_Owner | Id | Many → One |
| fact_Cases | AccountId | dim_Account | Id | Many → One |
| fact_Cases | CreatedDate (date) | dim_Date | Date | Many → One |
| fact_Opportunities | OwnerId | dim_Owner | Id | Many → One |
| fact_Opportunities | AccountId | dim_Account | Id | Many → One |
| fact_Opportunities | CloseDate | dim_Date | Date | Many → One |

## dim_Date Table (M Query)

Create a Date dimension using this M query in Power Query:

```m
let
    StartDate = #date(2024, 1, 1),
    EndDate   = #date(2026, 12, 31),
    Duration  = Duration.Days(EndDate - StartDate) + 1,
    DateList  = List.Dates(StartDate, Duration, #duration(1,0,0,0)),
    DateTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}),
    Typed     = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),
    AddYear   = Table.AddColumn(Typed, "Year",    each Date.Year([Date]),    Int64.Type),
    AddMonth  = Table.AddColumn(AddYear, "Month", each Date.Month([Date]),   Int64.Type),
    AddQtr    = Table.AddColumn(AddMonth, "Quarter", each Date.QuarterOfYear([Date]), Int64.Type),
    AddMoName = Table.AddColumn(AddQtr, "MonthName", each Date.MonthName([Date]), type text),
    AddQLabel = Table.AddColumn(AddMoName, "QuarterLabel",
                    each "Q" & Text.From([Quarter]) & " " & Text.From([Year]), type text)
in
    AddQLabel
```

## Step-by-Step Setup in Power BI Desktop

1. **Open Power BI Desktop** (download free from microsoft.com/powerbi)
2. **Get Data → Text/CSV** → load all 3 sample CSVs (or use Salesforce connector for live)
3. **Transform Data** → paste M queries from `m-queries/` in Advanced Editor per table
4. **Close & Apply**
5. **Model view** → create relationships per the table above
6. **Create dim_Date** → New Table → paste M query above
7. **Paste DAX measures** from `dax/` folder into each table (Modeling → New Measure)
8. **Build visuals:**
   - Card visuals for KPIs (Total Pipeline, SLA Compliance %)
   - Bar chart: Revenue by Region / Cases by Priority
   - Donut: Cases by Status
   - Line chart: MoM Revenue Trend
   - Table: Top 10 Accounts
   - Matrix/Heatmap: SLA Breach by Day of Week

## Power BI Salesforce Connector Notes

- Use **Import mode** for historical analysis (faster, supports all DAX)
- Use **Direct Query** only if you need real-time data (limited DAX support)
- Salesforce connector requires Salesforce login (standard user minimum)
- Custom fields (SLA_Breached__c etc.) appear automatically if user has field-level security
- API calls count against your Salesforce API limit — schedule refresh during off-peak hours
