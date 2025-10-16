table 78607 "BCX Gen. Translation Term"
{
    Caption = 'General Translation Term';
    DataClassification = AccountData;
    DataCaptionFields = "Target Language";

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
        key(PK; "Line No.")
        {
            Clustered = true;
        }
        key(Language; "Target Language", "Line No.")
        {
        }
    }

}