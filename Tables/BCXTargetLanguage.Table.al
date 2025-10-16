table 78603 "BCX Target Language"
{
    DataClassification = SystemMetadata;
    Caption = 'Target Language';
    DataCaptionFields = "Project Code", "Target Language";

    fields
    {
        field(10; "Project Code"; code[20])
        {
            DataClassification = AccountData;
            Caption = 'Project Code';
            TableRelation = "BCX Translation Project";
            Editable = false;
        }
        field(20; "Project Name"; Text[100])
        {
            Caption = 'Project Name';
            FieldClass = FlowField;
            CalcFormula = lookup("BCX Translation Project"."Project Name" where("Project Code" = field("Project Code")));
            Editable = false;
        }

        field(30; "Source Language"; Code[10])
        {
            DataClassification = AccountData;
            Caption = 'Source Language';
            TableRelation = Language;
            Editable = false;
        }
        field(35; "Source Language ISO code"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Source Language ISO code';
            Editable = false;
        }
        field(40; "Target Language"; Code[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language';
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Target Language") then begin
                    Language.TestField("BCX ISO code");
                    "Target Language ISO code" := Language."BCX ISO code"
                end else
                    clear("Target Language ISO code");
            end;
        }
        field(45; "Target Language ISO code"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Target Language ISO code';
            Editable = false;
        }
        field(50; "File Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }
        field(60; "Equivalent Language"; Code[10])
        {
            DataClassification = AccountData;
            Caption = 'Equivalent Language';
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Equivalent Language") then begin
                    Language.TestField("BCX ISO code");
                    "Equivalent Language ISO code" := Language."BCX ISO code"
                end else
                    clear("Equivalent Language ISO code");
            end;
        }
        field(65; "Equivalent Language ISO code"; Text[10])
        {
            DataClassification = AccountData;
            Caption = 'Equivalent Language ISO code';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Project Code", "Target Language")
        {
            Clustered = true;
        }
    }
}