// Cases.pq
// --------
// Power Query (M) transformation for Salesforce Case object.
// Adds resolution hours, SLA status category, and day-of-week columns.

let
    Source = Salesforce.Data("https://yourorg.my.salesforce.com", [ApiVersion = "59.0"]),
    Case   = Source{[Name="Case"]}[Data],

    SelectedCols = Table.SelectColumns(Case, {
        "Id", "CaseNumber", "Subject", "Status", "Priority", "Origin",
        "OwnerId", "Owner.Name", "AccountId", "Account.Name",
        "CreatedDate", "ClosedDate", "IsClosed", "IsEscalated",
        "SLA_Due_DateTime__c", "SLA_Breached__c", "SLA_Breach_Timestamp__c",
        "First_Response_Due__c", "Type", "Reason"
    }),

    RenamedCols = Table.RenameColumns(SelectedCols, {
        {"Owner.Name",     "OwnerName"},
        {"Account.Name",   "AccountName"},
        {"SLA_Due_DateTime__c",      "SLADueDateTime"},
        {"SLA_Breached__c",          "SLABreached"},
        {"SLA_Breach_Timestamp__c",  "SLABreachTimestamp"},
        {"First_Response_Due__c",    "FirstResponseDue"}
    }),

    TypedTable = Table.TransformColumnTypes(RenamedCols, {
        {"CreatedDate",       type datetime},
        {"ClosedDate",        type datetime},
        {"SLADueDateTime",    type datetime},
        {"SLABreachTimestamp",type datetime},
        {"FirstResponseDue",  type datetime},
        {"IsClosed",          type logical},
        {"IsEscalated",       type logical},
        {"SLABreached",       type logical}
    }),

    // Add resolution hours (null for open cases)
    AddResolutionHours = Table.AddColumn(TypedTable, "ResolutionHours",
        each if [IsClosed] = true and [ClosedDate] <> null
             then Duration.TotalHours([ClosedDate] - [CreatedDate])
             else null,
        type number),

    // Add SLA status category for slicing
    AddSLAStatus = Table.AddColumn(AddResolutionHours, "SLAStatusCategory",
        each if [SLABreached] = true         then "Breached"
             else if [IsClosed] = false and
                     [SLADueDateTime] <> null and
                     Duration.TotalHours([SLADueDateTime] - DateTime.LocalNow()) < 2
                  then "At Risk"
             else "On Track",
        type text),

    // Add day of week (for heatmap viz)
    AddDayOfWeek = Table.AddColumn(AddSLAStatus, "DayOfWeek",
        each Date.DayOfWeekName(DateTime.Date([CreatedDate])), type text),

    // Add created month for trend charts
    AddCreatedMonth = Table.AddColumn(AddDayOfWeek, "CreatedMonth",
        each Date.StartOfMonth(DateTime.Date([CreatedDate])), type date)

in
    AddCreatedMonth
