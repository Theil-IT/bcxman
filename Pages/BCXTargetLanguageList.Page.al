
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
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language"; Rec."Source Language")
                {
                    ApplicationArea = All;
                    QuickEntry = false;

                }
                field("Source Language ISO code"; Rec."Source Language ISO code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }

                field("Target Language"; Rec."Target Language")
                {
                    ApplicationArea = All;
                }
                field("Target Language ISO code"; Rec."Target Language ISO code")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Equivalent Language"; Rec."Equivalent Language")
                {
                    ApplicationArea = All;
                    QuickEntry = false;
                }
                field("Equivalent Language ISO code"; Rec."Equivalent Language ISO code")
                {
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
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    ExportTranslation: XmlPort "BCX Export Translation Target";
                    TransProject: Record "BCX Translation Project";
                    TargetLangRec: Record "BCX Target Language"; // adjust if different
                    TempBlob: Codeunit "Temp Blob";
                    DataCompression: Codeunit "Data Compression";
                    OutStream: OutStream;
                    InStream: InStream;
                    FileName: Text;
                    TargetLang: Code[10];
                    ZipBlob: Codeunit "Temp Blob";
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
                        TargetLang := Rec."Equivalent Language ISO code" <> ''
                            ? Rec."Equivalent Language ISO code"
                            : Rec."Target Language ISO code";

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
                                TargetLang := TargetLangRec."Equivalent Language ISO code" <> ''
                                    ? TargetLangRec."Equivalent Language ISO code"
                                    : TargetLangRec."Target Language ISO code";

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
                Image = ImportLog;
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    XliffParser: Codeunit "BCX Xliff Parser";
                    InS: InStream;

                    TransTarget: Record "BCX Translation Target";
                    TransProject: Record "BCX Translation Project";
                    DeleteWarningTxt: Label 'This will overwrite existing Translation Target entries for %1 - %2';
                    ImportedTxt: Label 'The file %1 has been imported into project %2';
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
        Rec."Project Code" := Rec.GetFilter("Project Code");
    end;

}
#pragma implicitwith restore
