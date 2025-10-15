#pragma implicitwith disable
page 78613 "BCX Translation Activities"
{
    Caption = 'Translation Activities';
    PageType = CardPart;
    SourceTable = "BCX Translation Cue";

    layout
    {
        area(Content)
        {
            cuegroup("Statuses")
            {
                Caption = 'Statuses';
                field("Open Projects"; Rec."Open Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Open Projects - not sent to customer';
                }
                field("Released Projects"; Rec."Released Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Released Projects - sent to customer, but not finished';
                }
                field("Finished Projects"; Rec."Finished Projects")
                {
                    ApplicationArea = All;
                    ToolTip = 'Finished Projects - sent to customer and done for now';
                }
            }
            cuegroup("Totals")
            {
                Caption = 'Totals';
                field("Projects this Month"; Rec."Projects this Month")
                {
                    ToolTip = 'Projects this Month - number of projects with activity this month';
                    ApplicationArea = All;
                }
                field("Total Projects"; Rec."Total Projects")
                {
                    ToolTip = 'Total Projects - total number of projects in the system';
                    ApplicationArea = All;
                }
            }
        }
    }
    var
        ProjectFilterTxt: Text;

    trigger OnOpenPage()
    var
        UserAccess: Record "BCX User Access";
        DateFilterTxt: Text;
        DateFilterLbl: Label '%1..%2', Comment = '%1: Start date, %2: End date';
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        DateFilterTxt := StrSubstNo(DateFilterLbl, CalcDate('<-CM>', Today()), Today());
        Rec.SetFilter("Month Date Filter", DateFilterTxt);
        UserAccess.SetRange("User Id", UserId());
        if UserAccess.FindSet() then
            repeat
                if ProjectFilterTxt <> '' then
                    ProjectFilterTxt += '|' + UserAccess."Project Code"
                else
                    ProjectFilterTxt := UserAccess."Project Code";
            until UserAccess.Next() = 0;
        Rec.SetFilter("Project Filter", ProjectFilterTxt);
    end;
}
#pragma implicitwith restore
