page 78614 "BCX Translation Role Center"
{
    Caption = 'Translation Role Center';
    PageType = RoleCenter;

    layout
    {
        area(RoleCenter)
        {
            part(Activities; "BCX Translation Activities")
            {
                ApplicationArea = all;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Setup)
            {
                Caption = 'Translation Setup';
                ToolTip = 'Open the translation setup page.';
                RunObject = Page "BCX Translation Setup";
                ApplicationArea = All;
            }
        }
        // area(Sections)
        // {
        //     group(SectionsGroupName)
        //     {
        //         Caption = '';
        //         action(SectionsAction)
        //         {
        //             ApplicationArea=All;
        //             //RunObject = Page ObjectName;
        //         }
        //     }
        // }
        area(Embedding)
        {
            action("Translation Projects")
            {
                Caption = 'Translation Projects';
                ToolTip = 'Open the list of translation projects.';
                ApplicationArea = All;
                RunObject = Page "BCX Trans Project List";
            }
        }
    }
}