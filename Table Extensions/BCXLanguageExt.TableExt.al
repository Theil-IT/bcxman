tableextension 78600 "BCX Language Ext" extends Language
{
    DrillDownPageId = "BCX Languages";
    LookupPageId = "BCX Languages";

    fields
    {
        field(78600; "BCX ISO code"; Text[10])
        {
            Caption = 'ISO code';
            DataClassification = SystemMetadata;

        }
    }
}