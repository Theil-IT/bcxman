table 78605 "BCX Translation Term"
{
    Caption = 'Translation Term';
    DataClassification = AccountData;
    DataCaptionFields = "Project Code", "Target Language";

    fields
    {
        field(10; "Project Code"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Project Code';
            Editable = false;
        }
        field(20; "Target Language"; code[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language';
            Editable = false;
        }
        field(30; "Line No."; Integer)
        {
            DataClassification = AccountData;
            Caption = 'Line No.';
        }
        field(40; Term; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'Term';
        }
        field(50; Translation; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'Translation';
        }
        field(60; "Apply Pre-Translation"; Boolean)
        {
            DataClassification = AccountData;
            Caption = 'Apply Pre-Translation';
        }
    }

    keys
    {
        key(PK; "Project Code", "Target Language", "Line No.")
        {
            Clustered = true;
        }
    }
}