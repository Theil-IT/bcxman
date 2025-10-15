#pragma implicitwith disable
page 78608 "BCX Gen. Translation Terms"
{
    Caption = 'General Translation Terms';
    PageType = List;
    SourceTable = "BCX Gen. Translation Term";
    AutoSplitKey = true;
    UsageCategory = Tasks;
    ApplicationArea = All;
    DataCaptionFields = "Project Code";

    layout
    {
        area(Content)
        {

            repeater(GroupName)
            {
                field("Apply Pre-Translation"; Rec."Apply Pre-Translation")
                {
                    ApplicationArea = All;
                    ToolTip = 'If checked, the term is used pre-translation. Leave translation empty to use the term as is.';
                }
                field("Target Language"; Rec."Target Language")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the target language for the translation term.';
                }
                field(Term; Rec.Term)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the term to hardcode for translation. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
                field(Translation; Rec.Translation)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translation to be inserted for the term. E.g. ''Journal'' must be translated to ''Worksheet''. Every instance of the term will be replaced with the translation.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        FilterVal: Text;
    begin
        // Get the filter applied to the "Project Code" field
        FilterVal := Rec.GETFILTER("Project Code");
        if FilterVal = '' then
            exit;

        // Strip leading '=' if the filter contains it
        if CopyStr(FilterVal, 1, 1) = '=' then
            FilterVal := CopyStr(FilterVal, 2, StrLen(FilterVal) - 1);

        // Strip surrounding quotes if present (e.g. "PRJ1")
        if (StrLen(FilterVal) >= 2) and (CopyStr(FilterVal, 1, 1) = '"') and (CopyStr(FilterVal, StrLen(FilterVal), 1) = '"') then
            FilterVal := CopyStr(FilterVal, 2, StrLen(FilterVal) - 2);

        // Validate to trigger any table-level logic
        Rec.Validate("Project Code", FilterVal);
    end;

}
#pragma implicitwith restore
