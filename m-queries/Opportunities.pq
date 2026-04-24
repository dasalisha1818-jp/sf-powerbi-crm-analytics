// Opportunities.pq
// ----------------
// Power Query (M) transformation applied to the Salesforce Opportunity object.
// Paste this in Power BI Desktop → Power Query Editor → Advanced Editor.

let
    // Step 1: Connect to Salesforce
    Source = Salesforce.Data("https://yourorg.my.salesforce.com", [ApiVersion = "59.0"]),
    Opportunity = Source{[Name="Opportunity"]}[Data],

    // Step 2: Select relevant columns
    SelectedCols = Table.SelectColumns(Opportunity, {
        "Id", "Name", "AccountId", "Account.Name", "OwnerId", "Owner.Name",
        "StageName", "Amount", "CloseDate", "CreatedDate", "Probability",
        "ForecastCategory", "LeadSource", "Type", "IsClosed", "IsWon",
        "FiscalQuarter", "FiscalYear", "CurrencyIsoCode"
    }),

    // Step 3: Rename for clarity
    RenamedCols = Table.RenameColumns(SelectedCols, {
        {"Account.Name", "AccountName"},
        {"Owner.Name", "OwnerName"}
    }),

    // Step 4: Set data types
    TypedTable = Table.TransformColumnTypes(RenamedCols, {
        {"Amount",      type number},
        {"Probability", type number},
        {"CloseDate",   type date},
        {"CreatedDate", type datetime},
        {"IsClosed",    type logical},
        {"IsWon",       type logical}
    }),

    // Step 5: Add a CloseMonth column for time-based slicing
    AddCloseMonth = Table.AddColumn(TypedTable, "CloseMonth",
        each Date.StartOfMonth([CloseDate]), type date),

    // Step 6: Add a CloseQuarter label e.g. "Q1 FY2025"
    AddCloseQuarter = Table.AddColumn(AddCloseMonth, "CloseQuarterLabel",
        each "Q" & Text.From([FiscalQuarter]) & " FY" & Text.From(Date.Year([CloseDate])),
        type text),

    // Step 7: Filter out test/dummy records (amount = 0 or null)
    FilteredTable = Table.SelectRows(AddCloseQuarter,
        each [Amount] <> null and [Amount] > 0)

in
    FilteredTable
