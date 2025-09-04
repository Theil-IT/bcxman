page 78611 "BCX Languages"
{
    Caption = 'Languages (Translate Module)';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = Language;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Windows Language ID"; Rec."Windows Language ID")
                {
                    ApplicationArea = All;
                }
                field("Windows Language Name"; Rec."Windows Language Name")
                {
                    ApplicationArea = All;
                }
                field("BCX ISO code"; Rec."BCX ISO code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}