table 78609 "BCX Translation Cue"
{
    Caption = 'Translate Cue';
    DataClassification = ToBeClassified;

    fields
    {
        field(10; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = ToBeClassified;
        }
        field(20; "Open Projects"; Integer)
        {
            Caption = 'Open Projects';
            FieldClass = FlowField;
            CalcFormula = count("BCX Translation Project" where(Status = const(Open), "Project Code" = field("Project Filter")));
        }
        field(30; "Released Projects"; Integer)
        {
            Caption = 'Released Projects';
            FieldClass = FlowField;
            CalcFormula = count("BCX Translation Project" where(Status = const(Released), "Project Code" = field("Project Filter")));
        }
        field(40; "Finished Projects"; Integer)
        {
            Caption = 'Finished Projects';
            FieldClass = FlowField;
            CalcFormula = count("BCX Translation Project" where(Status = const(Released), "Project Code" = field("Project Filter")));
        }
        field(50; "Projects this Month"; Integer)
        {
            Caption = 'Projects this Month';
            FieldClass = FlowField;
            CalcFormula = count("BCX Translation Project" where("Creation Date" = field("Month Date Filter"), "Project Code" = field("Project Filter")));
        }
        field(60; "Total Projects"; Integer)
        {
            Caption = 'Total Projects';
            FieldClass = FlowField;
            CalcFormula = count("BCX Translation Project" where("Project Code" = field("Project Filter")));
        }
        field(100; "Month Date Filter"; Date)
        {
            Caption = 'Month Date Filter';
            FieldClass = FlowFilter;
        }
        field(110; "Project Filter"; Text[250])
        {
            Caption = 'Project Filter';
            FieldClass = FlowFilter;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}