page 78612 "BCX User Access"
{
    Caption = 'User Access';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BCX User Access";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;

                }
                field("User Id"; Rec."User Id")
                {
                    ApplicationArea = All;

                }
                field("Project Name"; Rec."Project Name")
                {
                    ApplicationArea = All;

                }
                field("User Name"; Rec."User Name")
                {
                    ApplicationArea = All;

                }
            }
        }
    }
    trigger OnOpenPage()
    var
        UserAccess: Record "BCX User Access";
        NoAccessTxt: Label 'No Access';
    begin
        UserAccess.SetRange("User Id", Rec."User Id");
        if not UserAccess.IsEmpty then
            Error(NoAccessTxt)
    end;
}