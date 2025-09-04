
page 78601 "BCX Translation Source List"
{
    PageType = List;
    SourceTable = "BCX Translation Source";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;

                }
                field("Trans-Unit Id"; Rec."Trans-Unit Id")
                {
                    ApplicationArea = All;
                    Visible = false;

                }
                field(Source; Rec.Source)
                {
                    ApplicationArea = All;

                }
            }
        }
        area(Factboxes)
        {
            part(TransNotes; "BCX Translation Notes")
            {
                SubPageLink = "Project Code" = field("Project Code"),
                            "Trans-Unit Id" = field("Trans-Unit Id");
                ApplicationArea = All;
            }

        }
    }
    actions
    {
        area(Processing)
        {
            action("Show Empty Captions")
            {
                Caption = 'Show Empty Captions';
                ApplicationArea = All;
                Image = ShowSelected;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetRange(Source, '');
                end;
            }
            action("Show All Captions")
            {
                Caption = 'Show All Captions';
                ApplicationArea = All;
                Image = ShowList;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetRange(Source);
                end;
            }
        }
    }
}
#pragma implicitwith restore
