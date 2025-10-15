
page 78602 "BCX Target Language List"
{
    PageType = List;
    SourceTable = "BCX Target Language";
    Caption = 'Target Language List';
    PopulateAllFields = true;
    DataCaptionFields = "Project Code", "Project Name";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Project Name"; Rec."Project Name")
                {
                    Caption = 'Project Name';
                    ToolTip = 'Name of the project.';
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language"; Rec."Source Language")
                {
                    Caption = 'Source Language';
                    ToolTip = 'Source language of the project.';
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language ISO code"; Rec."Source Language ISO code")
                {
                    Caption = 'Source Language ISO code';
                    ToolTip = 'ISO code of the source language of the project.';
                    ApplicationArea = All;
                    QuickEntry = false;
                }

                field("Target Language"; Rec."Target Language")
                {
                    Caption = 'Target Language';
                    ToolTip = 'Target language to translate to.';
                    ApplicationArea = All;
                }
                field("Target Language ISO code"; Rec."Target Language ISO code")
                {
                    Caption = 'Target Language ISO code';
                    ToolTip = 'ISO code of the target language.';
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Equivalent Language"; Rec."Equivalent Language")
                {
                    Caption = 'Equivalent Language';
                    ToolTip = 'Equivalent language to use instead of the target language.';
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Equivalent Language ISO code"; Rec."Equivalent Language ISO code")
                {
                    Caption = 'Equivalent Language ISO code';
                    ToolTip = 'ISO code of the equivalent language.';
                    ApplicationArea = All;
                    QuickEntry = false;
                }
            }
        }
        area(FactBoxes)
        {
            part(FactBox; "BCX Trans Source Factbox")
            {
                SubPageLink = "Project Code" = field("Project Code");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Translation Target")
            {
                Caption = 'Translation Target';
                ToolTip = 'Open the translation target.';
                ApplicationArea = All;
                Image = Translate;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TargetRec: Record "BCX Translation Target";
                    TranslationTargetList: Page "BCX Translation Target List";
                    TargetLangIso: Text[10];
                    TargetLang: Text[10];
                begin
                    // Determine equivalent language
                    TargetLangIso := Rec."Equivalent Language ISO code" <> '' ? Rec."Equivalent Language ISO code" : Rec."Target Language ISO code";
                    TargetLang := Rec."Equivalent Language" <> '' ? Rec."Equivalent Language" : Rec."Target Language";

                    TargetRec.SetRange("Project Code", Rec."Project Code");
                    TargetRec.SetRange("Target Language", TargetLang);
                    TargetRec.SetRange("Target Language ISO code", TargetLangIso);

                    TranslationTargetList.SetTableView(TargetRec);
                    TranslationTargetList.Run();

                end;
            }
            action("Translation Terms")
            {
                Caption = 'Translation Terms';
                ToolTip = 'Open the translation terms for this project and target language.';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TransTermRec: Record "BCX Translation Term";
                    TranslationTerms: Page "BCX Translation terms";
                    TargetLang: Text[10];
                begin
                    // Determine equivalent language
                    TargetLang := Rec."Equivalent Language ISO code" <> ''
                        ? Rec."Equivalent Language ISO code"
                        : Rec."Target Language ISO code";

                    TransTermRec.SetRange("Project Code", Rec."Project Code");
                    TransTermRec.SetRange("Target Language", TargetLang);

                    TranslationTerms.SetTableView(TransTermRec);
                    TranslationTerms.Run();
                end;
            }
            action("Project Terms")
            {
                Caption = 'Project Terms';
                ToolTip = 'Open language neutral translation terms for this project.';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BCX Translation terms";
                RunPageLink = "Project Code" = field("Project Code"),
                            "Target Language" = const('');
            }
            action("Export Translation Files")
            {
                ApplicationArea = All;
                Caption = 'Export Translation Files';
                ToolTip = 'Export translation files for the target language or all languages in the project.';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TargetLangRec: Record "BCX Target Language"; // adjust if different
                    TransProject: Record "BCX Translation Project";
                    TempBlob: Codeunit "Temp Blob";
                    DataCompression: Codeunit "Data Compression";
                    ZipBlob: Codeunit "Temp Blob";
                    ExportTranslation: XmlPort "BCX Export Translation Target";
                    OutStream: OutStream;
                    InStream: InStream;
                    FileName: Text;
                    ToFile: Text;
                    ChoiceTxt: Label 'Export current language only,Export all languages';
                    Choice: Integer;
                begin
                    Choice := StrMenu(ChoiceTxt, 1); // default = current language
                    if Choice = 0 then
                        exit; // user cancelled

                    TransProject.Get(Rec."Project Code");

                    if Choice = 1 then begin
                        // -------------------
                        // Export current only
                        // -------------------
                        TempBlob.CreateOutStream(OutStream);
                        ExportTranslation.SetProjectCode(
                            Rec."Project Code",
                            Rec."Source Language ISO code",
                            Rec."Target Language ISO code",
                            Rec."Equivalent Language ISO code");
                        ExportTranslation.SetDestination(OutStream);
                        ExportTranslation.Export();

                        TempBlob.CreateInStream(InStream);
                        FileName := ExportTranslation.GetFilename();
                        ToFile := FileName;
                        if DownloadFromStream(InStream, 'Export Translation', '', 'XLIFF files (*.xlf)|*.xlf', ToFile) then
                            Message('Translation exported to %1', ToFile);
                    end else begin
                        // -------------------
                        // Export all languages to ZIP
                        // -------------------
                        DataCompression.CreateZipArchive();

                        TargetLangRec.SetRange("Project Code", Rec."Project Code");
                        if TargetLangRec.FindSet() then
                            repeat

                                Clear(ExportTranslation); // new instance per language
                                Clear(TempBlob);
                                TempBlob.CreateOutStream(OutStream);
                                ExportTranslation.SetProjectCode(
                                    Rec."Project Code",
                                    Rec."Source Language ISO code",
                                    TargetLangRec."Target Language ISO code",
                                    TargetLangRec."Equivalent Language ISO code");
                                ExportTranslation.SetDestination(OutStream);

                                ExportTranslation.Export();

                                // Use the filename logic from XmlPort itself
                                FileName := ExportTranslation.GetFilename();

                                TempBlob.CreateInStream(InStream);
                                DataCompression.AddEntry(InStream, FileName);
                            until TargetLangRec.Next() = 0;

                        ZipBlob.CreateOutStream(OutStream);
                        DataCompression.SaveZipArchive(OutStream);

                        ZipBlob.CreateInStream(InStream);
                        ToFile := Rec."Project Name" + '_Translations.zip';
                        if DownloadFromStream(InStream, 'Export All Translations', '', 'ZIP files (*.zip)|*.zip', ToFile) then
                            Message('All translations exported to %1', ToFile);
                    end;
                end;
            }


            action("Import Target")
            {
                ApplicationArea = All;
                Caption = 'Import Target';
                ToolTip = 'Import translation target from an XLIFF file for the target language.';
                Image = ImportLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TransTarget: Record "BCX Translation Target";
                    TransProject: Record "BCX Translation Project";
                    XliffParser: Codeunit "BCX Xliff Parser";
                    InS: InStream;

                    DeleteWarningTxt: Label 'This will overwrite existing Translation Target entries for %1 - %2', Comment = '%1: Project Code, %2: Target Language ISO code';
                    ImportedTxt: Label 'The file %1 has been imported into project %2', Comment = '%1: File name, %2: Project Code';
                    FileName: Text;
                begin
                    TransTarget.SetRange("Project Code", Rec."Project Code");
                    TransTarget.SetRange("Target Language ISO code", Rec."Target Language ISO code");
                    if not TransTarget.IsEmpty then begin
                        if not Confirm(DeleteWarningTxt, false, Rec."Project Code", Rec."Target Language ISO code") then
                            exit;
                        TransTarget.DeleteAll();
                    end;
                    TransProject.get(Rec."Project Code");

                    if not File.UploadIntoStream('Select target XLIFF file', '', 'Xliff files (*.xlf;*.xliff)|*.xlf;*.xliff', FileName, InS) then
                        exit;
                    XliffParser.ImportTargetFromStream(Rec."Project Code", Rec."Source Language ISO code", Rec."Target Language ISO code", FileName, InS);
                    Success := true;

                    while (strpos(FileName, '\') > 0) do
                        FileName := copystr(FileName, strpos(FileName, '\') + 1);
                    if Success then
                        message(ImportedTxt, FileName, Rec."Project Code");
                end;
            }


        }
    }
    var
        Success: Boolean;

    trigger OnNewRecord(BelowxRec: Boolean)

    begin
        // Set the project code to the filter value the page was called with
        Rec."Project Code" := COPYSTR(FORMAT(Rec.GetFilter("Project Code")), 1, MAXSTRLEN(Rec."Project Code"));
    end;

}
#pragma implicitwith restore
