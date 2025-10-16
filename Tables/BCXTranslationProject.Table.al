table 78600 "BCX Translation Project"
{
    Caption = 'Translation Project Name';
    DataClassification = SystemMetadata;
    DataCaptionFields = "Project Code", "Project Name";

    fields
    {
        field(10; "Project Code"; code[20])
        {
            Caption = 'Project Code';
            DataClassification = SystemMetadata;

        }
        field(20; "Project Name"; Text[100])
        {
            Caption = 'Project Name';
            DataClassification = AccountData;
        }
        field(30; "Source Language"; Code[10])
        {
            Caption = 'Source Language';
            DataClassification = AccountData;
            TableRelation = Language;
            trigger OnValidate()
            var
                Language: Record Language;
            begin
                if Language.Get("Source Language") then begin
                    Language.TestField("BCX ISO code");
                    "Source Language ISO code" := Language."BCX ISO code"
                end else
                    clear("Source Language ISO code");
            end;
        }
        field(32; "Target Language"; Text[10])
        {
            Caption = 'Target Language';
            DataClassification = AccountData;
        }

        field(35; "Source Language ISO code"; Text[10])
        {
            Caption = 'Source Language';
            DataClassification = AccountData;
            Editable = false;
        }
        field(40; "Creation Date"; Date)
        {
            DataClassification = AccountData;
            Caption = 'Creation Date';
            Editable = false;
        }
        field(50; "Created By"; Text[100])
        {
            DataClassification = AccountData;
            Caption = 'Created By';
            Editable = false;
        }
        field(60; "Xml Version"; Text[250])
        {
            Caption = 'Xml Version';
            DataClassification = AccountData;
        }
        field(70; "Xliff Version"; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'Xliff Version';

        }
        field(80; "File Datatype"; Text[250])
        {
            DataClassification = AccountData;
            Caption = 'File Datatype';

        }
        field(90; "File Name"; Text[250])
        {
            DataClassification = SystemMetadata;
            Caption = 'File Name';
        }
        field(100; "No. Series"; Code[10])
        {
            Editable = false;
            Caption = 'No. Series';
            TableRelation = "No. Series";
            DataClassification = SystemMetadata;
        }
        field(110; OrginalAttr; Text[100])
        {
            Editable = false;
            Caption = 'OrginalAttr';
            DataClassification = SystemMetadata;
        }
        field(120; "NAV Version"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'NAV Version';
            OptionMembers = "Dynamics 365 Business Central";
            OptionCaption = 'Dynamics 365 Business Central';
            InitValue = 1;
        }
        field(130; Status; Option)
        {
            Caption = 'Status';
            DataClassification = SystemMetadata;
            OptionMembers = Open,Released,Closed;
            OptionCaption = 'Open,Released,Closed';
        }
        field(140; "Base Translation Imported"; Boolean)
        {
            Caption = 'Base Translation Imported';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Project Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup("DropDown"; "Project Code", "Project Name")
        {

        }
    }

    trigger OnInsert()
    var
        TransSetup: Record "BCX Translation Setup";
    begin
        "Created By" := copystr(UserId(), 1, MaxStrLen(("Created By")));
        "Creation Date" := Today;
        TransSetup.get();
        if "Source Language" = '' then
            validate("Source Language", TransSetup."Default Source Language code");

    end;

    trigger OnDelete()
    var
        TransSource: Record "BCX Translation Source";
        TransTarget: Record "BCX Translation Target";
        TargetLanguage: Record "BCX Target Language";
        TargetBaseLanguage: Record "BCX Base Translation Target";
        TranNote: Record "BCX Translation Notes";
        TransTerm: Record "BCX Translation Term";
    begin
        TransSource.SetRange("Project Code", "Project Code");
        TransSource.DeleteAll();
        TransTarget.SetRange("Project Code", "Project Code");
        TransTarget.DeleteAll();
        TargetLanguage.SetRange("Project Code", "Project Code");
        TargetLanguage.DeleteAll();
        TargetBaseLanguage.SetRange("Project Code", "Project Code");
        TargetBaseLanguage.DeleteAll();
        TranNote.SetRange("Project Code", "Project Code");
        TranNote.DeleteAll();
        TransTerm.SetRange("Project Code", "Project Code");
        TransTerm.DeleteAll();
    end;

}