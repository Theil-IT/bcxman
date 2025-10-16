#pragma implicitwith disable
page 78604 "BCX Translation Notes"
{
    PageType = Listpart;
    SourceTable = "BCX Translation Notes";
    Caption = 'Translation Notes';
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(From; Rec.From)
                {
                    Caption = 'From';
                    ToolTip = 'The sender of the note.';
                    ApplicationArea = All;

                }
                field(Annotates; Rec.Annotates)
                {
                    Caption = 'Annotates';
                    ToolTip = 'The person who annotated the note.';
                    ApplicationArea = All;

                }
                field(Note; Rec.Note)
                {
                    Caption = 'Note';
                    ToolTip = 'The content of the note.';
                    ApplicationArea = All;
                }
                field(Priority; Rec.Priority)
                {
                    Caption = 'Priority';
                    ToolTip = 'The priority of the note.';
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}
#pragma implicitwith restore
