table 78604 "BCX Translation Notes"
{
    DataClassification = AccountData;
    Caption = 'BCX Translation Notes';

    fields
    {
        field(10; "Project Code"; code[20])
        {
            DataClassification = AccountData;
            Caption = 'Project Code';
        }

        field(20; "Trans-Unit Id"; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'Trans-Unit Id';
        }
        field(30; "From"; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'From';
        }
        field(40; "Annotates"; Text[50])
        {
            DataClassification = AccountData;
            Caption = 'Annotates';
        }
        field(50; "Priority"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Priority';
        }
        field(60; "Note"; Text[2048])
        {
            DataClassification = AccountData;
            Caption = 'Note';
        }
    }

    keys
    {
        key(PK; "Project Code", "Trans-Unit Id", From)
        {
            Clustered = true;
        }
    }
}