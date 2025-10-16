#pragma implicitwith disable
page 78600 "BCX Trans Project List"
{
    Caption = 'Translation Projects';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "BCX Translation Project";
    SourceTableView = sorting("Project Code") order(descending);

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Project Code"; Rec."Project Code")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Specifies the unique code for the translation project.';
                }
                field("Project Name"; Rec."Project Name")
                {
                    ToolTip = 'The name of the translation project.';
                    ApplicationArea = All;

                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Open Projects which means projects in process - Released Projects which means sent to customer, but not finished - Finished Projects which means sent to customer and done for now';
                }
                field("NAV Version"; Rec."NAV Version")
                {
                    ToolTip = 'The NAV version for the translation project.';
                    ApplicationArea = All;
                }
                field("File Name"; Rec."File Name")
                {
                    ToolTip = 'The name of the file associated with the translation project.';
                    ApplicationArea = All;
                }
                field("Source Language"; Rec."Source Language")
                {
                    ToolTip = 'The source language for the translation project.';
                    ApplicationArea = All;
                }
                field("Source Language ISO code"; Rec."Source Language ISO code")
                {
                    ToolTip = 'The ISO code of the source language for the translation project.';
                    ApplicationArea = All;
                }
                field("Created By"; Rec."Created By")
                {
                    ToolTip = 'The user who created the translation project.';
                    ApplicationArea = All;
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ToolTip = 'The date when the translation project was created.';
                    ApplicationArea = All;
                }
                field("Base Translation Imported"; Rec."Base Translation Imported")
                {
                    ToolTip = 'Indicates whether the base translation has been imported for the project.';
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Import Project")
            {
                ApplicationArea = All;
                Caption = 'Import Project';
                ToolTip = 'Import a translation project from a ZIP file.';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ProjectImporter: Codeunit "BCX Project Importer";
                begin
                    ProjectImporter.ImportFromZip(Rec."Project Code", Rec."Source Language ISO code", true);
                end;
            }

            action("Import Source")
            {
                ApplicationArea = All;
                Caption = 'Import Source';
                ToolTip = 'Import translation source from an XLIFF file.';
                Image = ImportCodes;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TransSource: Record "BCX Translation Source";
                    TransNotes: Record "BCX Translation Notes";
                    TransProject: Record "BCX Translation Project";
                    XliffParser: Codeunit "BCX Xliff Parser";
                    DeleteWarningTxt: Label 'This will overwrite the Translation source for %1', Comment = 'Warning message when importing translation source that will overwrite existing source. %1 is Project Code';
                    FileName: Text;
                    InS: InStream;
                    ImportedTxt: Label 'The file %1 has been imported into project %2', Comment = 'Message shown when a file has been successfully imported. %1 is the file name, %2 is the project code';
                begin
                    TransSource.SetRange("Project Code", Rec."Project Code");
                    TransNotes.SetRange("Project Code", Rec."Project Code");
                    if not TransSource.IsEmpty then
                        if Confirm(DeleteWarningTxt, false, Rec."Project Code") then begin
                            TransSource.DeleteAll();
                            TransNotes.DeleteAll();
                        end else
                            exit;
                    if not File.UploadIntoStream('Select source XLIFF file', '', 'Xliff files (*.xlf;*.xliff)|*.xlf;*.xliff', FileName, InS) then
                        exit;

                    // Call the new parser codeunit to import source records from the stream
                    XliffParser.ImportSourceFromStream(Rec."Project Code", FileName, InS);

                    // Preserve existing flow: treat as success for message logic
                    Success := true;

                    TransProject.Get(Rec."Project Code");
                    if (TransProject."File Name" <> '') and Success then
                        message(ImportedTxt, TransProject."File Name", Rec."Project Code");
                end;
            }
            action("Target Languages")
            {
                ApplicationArea = All;
                Caption = 'Target Languages';
                ToolTip = 'Manage target languages for the translation project.';
                Image = Language;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BCX Target Language List";
                RunPageLink = "Project Code" = field("Project Code"),
                "Source Language" = field("Source Language"),
                "Source Language ISO code" = field("Source Language ISO code");
            }
            action("Translation Source")
            {
                ApplicationArea = All;
                Caption = 'Translation Source';
                ToolTip = 'View and manage translation source entries for the project.';
                Image = SourceDocLine;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BCX Translation Source List";
                RunPageLink = "Project Code" = field("Project Code");
            }
            action("General Translation Terms")
            {
                Caption = 'General Translation Terms';
                ToolTip = 'View and manage general translation terms for the project.';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BCX Gen. Translation Terms";
                RunPageLink = "Project Code" = field("Project Code");

            }
            action("All Translation Targets")
            {
                Caption = 'All Translation Targets';
                ToolTip = 'View all translation targets for the project.';
                ApplicationArea = All;
                Image = Translate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TargetRec: Record "BCX Translation Target";
                    TranslationTargetList: Page "BCX Translation Target List";
                begin
                    // Determine equivalent language

                    TargetRec.SetRange("Project Code", Rec."Project Code");

                    TranslationTargetList.SetTableView(TargetRec);
                    TranslationTargetList.Run();

                end;
            }
        }
    }
    var
        Success: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        TransSetup: Record "BCX Translation Setup";

    begin
        TransSetup.get();
        Rec.Validate("Source Language", TransSetup."Default Source Language code");
        Rec.Validate("NAV Version", Rec."NAV Version"::"Dynamics 365 Business Central");
    end;

    trigger OnOpenPage()
    var
        UserAccess: Record "BCX User Access";
        FilterTxt: Text;
    begin
        UserAccess.SetRange("User Id", UserId());
        if UserAccess.FindSet() then
            Repeat
                if FilterTxt <> '' then
                    FilterTxt += '|' + UserAccess."Project Code"
                else
                    FilterTxt := UserAccess."Project Code";
            until UserAccess.Next() = 0;
        if FilterTxt <> '' then begin
            Rec.FilterGroup(1);
            Rec.SetFilter("Project Code", FilterTxt);
            Rec.FilterGroup(0);
        end;
    end;
}
#pragma implicitwith restore
