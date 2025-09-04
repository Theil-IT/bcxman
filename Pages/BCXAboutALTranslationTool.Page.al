page 78609 "BCX About AL Translation Tool"
{
    Caption = 'About AL Translation Tool';
    PageType = CardPart;
    SourceTable = "BCX Translation Setup";
    ShowFilter = false;

    layout
    {
        area(Content)
        {
            group("About AL Translation Tool")
            {

                Caption = 'About AL Translation Tool';
                InstructionalText = 'Open-Source AL Translate Tool. Source code can be located at https://github.com/Theil-IT/bcxman.';
            }
            grid("App")
            {
                ShowCaption = false;
                GridLayout = Columns;
                group("Group2")
                {
                    ShowCaption = false;
                    field("Version"; AppVersion)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(AppName; AppName)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                    field(AppPublisher; AppPublisher)
                    {
                        ApplicationArea = All;
                        Editable = false;
                    }
                }
            }
        }
    }

    var
        AppVersion: Text[10];
        AppName: Text;
        AppPublisher: Text;
        AppModuleInfo: ModuleInfo;

    trigger OnOpenPage()
    begin
        if NavApp.GetCurrentModuleInfo(AppModuleInfo) then begin
            AppVersion := format(AppModuleInfo.AppVersion);
            AppName := AppModuleInfo.Name;
            AppPublisher := AppModuleInfo.Publisher;
        end;
    end;
}