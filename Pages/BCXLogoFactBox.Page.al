#pragma implicitwith disable
page 78610 "BCX AL Logo FactBox"
{
    PageType = CardPart;
    SourceTable = "BCX Translation Setup";
    Editable = false;
    Caption = 'AL Translation Tool';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                ShowCaption = false;
                field(Logo; Rec.Logo)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                }
            }
        }
    }
}
#pragma implicitwith restore
