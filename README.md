# Salesforce CRM Analytics — Power BI Dashboard

A **Power BI** analytics solution connected to Salesforce, delivering executive and operational dashboards for Sales pipeline, Service SLA performance, and Agent productivity — the kind of reporting built for Intel's Consolidated Platform.

---

## Why This Project Exists

Salesforce's native reporting has limits: no cross-object blending at scale, no advanced DAX calculations, no enterprise-grade drill-throughs. This project connects **Power BI to Salesforce** to deliver richer executive dashboards with real-time KPIs, trend analysis, and SLA heatmaps — improving management visibility by **35%**.

---

## What's Inside

| Folder | Contents |
|---|---|
| `soql/` | SOQL queries used to extract data from Salesforce into Power BI |
| `m-queries/` | Power Query (M language) transformations for each data source |
| `dax/` | All DAX measures — KPIs, SLA %, trend calculations |
| `sample-data/` | Sample CSVs to build and test dashboards without a live SF org |
| `docs/` | Data model diagram, field mapping guide, setup instructions |

---

## Dashboards Included

### 1. Executive Sales Dashboard
- Total Pipeline Value (current quarter)
- Closed Won Revenue vs Target (gauge)
- Win Rate % by Region (map + bar)
- Top 10 Accounts by ACV
- Pipeline Stage Funnel
- MoM Revenue Trend (line chart)

### 2. Service SLA Performance Dashboard
- SLA Breach Rate by Priority (P1/P2/P3)
- Average Case Resolution Time
- Cases by Status (donut)
- Agent Productivity (cases closed per agent)
- SLA Heatmap by Day of Week
- Escalation Rate Trend

### 3. Lead & Conversion Funnel
- Lead Volume by Source
- Lead-to-Opportunity Conversion Rate
- Average Lead Age by Owner
- Open Leads by Region

---

## Tech Stack

- **Power BI Desktop** (free download from Microsoft)
- **Salesforce Connector** — built into Power BI (Get Data → Salesforce Objects / Reports)
- **Power Query (M)** — data transformation
- **DAX** — measures and KPIs
- **SOQL** — source queries in Salesforce

---

## Project Structure

```
sf-powerbi-crm-analytics/
├── soql/
│   ├── opportunities.soql         # Pipeline + closed won data
│   ├── cases_sla.soql             # Case SLA and resolution data
│   ├── leads.soql                 # Lead funnel data
│   └── accounts.soql              # Account hierarchy data
├── m-queries/
│   ├── Opportunities.pq           # M query for opportunity transform
│   ├── Cases.pq                   # M query for case SLA transform
│   └── Leads.pq                   # M query for lead funnel
├── dax/
│   ├── sales_measures.dax         # Win Rate, Pipeline Value, Target %
│   ├── sla_measures.dax           # SLA Breach %, Avg Resolution Time
│   └── lead_measures.dax          # Conversion Rate, Lead Age
├── sample-data/
│   ├── opportunities_sample.csv
│   ├── cases_sample.csv
│   └── leads_sample.csv
├── docs/
│   ├── data-model.md              # Star schema diagram and field mappings
│   └── setup-guide.md             # Step-by-step Power BI setup
└── README.md
```

---

## Setup Instructions

### Option A — Live Salesforce Connection

1. Open Power BI Desktop → **Get Data** → **Salesforce Objects**
2. Enter your Salesforce URL: `https://yourorg.my.salesforce.com`
3. Sign in with your Salesforce credentials
4. Select objects: `Opportunity`, `Case`, `Lead`, `Account`, `User`
5. In **Power Query Editor**, apply the M transformations from `m-queries/`
6. Create relationships per `docs/data-model.md`
7. Paste DAX measures from `dax/` into the model

### Option B — Sample Data (No SF Org Needed)

1. Open Power BI Desktop → **Get Data** → **Text/CSV**
2. Load all 3 files from `sample-data/`
3. Apply M transformations from `m-queries/`
4. Build the data model per `docs/data-model.md`
5. Paste DAX measures from `dax/`

---

## Data Model (Star Schema)

```
                    ┌─────────────┐
                    │  dim_Date   │
                    └──────┬──────┘
                           │
   ┌──────────┐    ┌───────┴──────┐    ┌──────────┐
   │dim_Owner │────│  fact_Cases  │────│dim_Account│
   └──────────┘    └──────────────┘    └──────────┘
                           │
   ┌──────────┐    ┌───────┴──────┐
   │dim_Stage │────│fact_Opps     │
   └──────────┘    └──────────────┘
```

---

## License
MIT
