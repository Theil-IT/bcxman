table 78606 "BCX Translation Setup"
{
    DataClassification = SystemMetadata;
    Caption = 'Translation Setup';

    fields
    {
        field(10; "Primary Key"; code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Primary Key';
        }
        field(30; "Default Source Language code"; code[10])
        {
            DataClassification = SystemMetadata;
            Caption = 'Default Source Language code';
            TableRelation = Language;
        }
        field(40; "Use Free Google Translate"; Boolean)
        {
            DataClassification = SystemMetadata;
            Caption = 'Use Free Google Translate';
            InitValue = true;
            // To prepare for other translation API's
        }
        field(50; Logo; MediaSet)
        {
            DataClassification = SystemMetadata;
            Caption = 'Logo';
        }

        field(60; "Use OpenAI"; Boolean)
        {
            Caption = 'Use OpenAI';
            DataClassification = SystemMetadata;
        }

        field(70; "OpenAI API Key"; Text[512])
        {
            Caption = 'OpenAI API Key';
            DataClassification = SystemMetadata;
        }

        field(80; "OpenAI Model"; Option)
        {
            Caption = 'OpenAI Model';
            OptionMembers = "gpt-3.5-turbo","gpt-4o";

            DataClassification = SystemMetadata;
        }

        field(90; "Use DeepL"; Boolean)
        {
            Caption = 'Use DeepL';
            DataClassification = SystemMetadata;
        }

        field(100; "DeepL API Key"; Text[512])
        {
            Caption = 'DeepL API Key';
            DataClassification = SystemMetadata;
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