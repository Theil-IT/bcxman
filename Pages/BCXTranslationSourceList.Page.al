
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
                    ToolTip = 'The name of the field to be translated.';
                    ApplicationArea = All;

                }
                field("Trans-Unit Id"; Rec."Trans-Unit Id")
                {
                    ToolTip = 'The unique identifier for the translation unit.';
                    ApplicationArea = All;
                    Visible = false;

                }
                field(Source; Rec.Source)
                {
                    ToolTip = 'The original text that needs to be translated.';
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
                ToolTip = 'Show all captions that are currently empty.';
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
                ToolTip = 'Show all captions, including those that are already translated.';
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
