#pragma implicitwith disable
page 78603 "BCX Translation Target List"
{
    Caption = 'Translation Target List';
    PageType = List;
    SourceTable = "BCX Translation Target";
    PopulateAllFields = true;
    DataCaptionFields = "Project Code", "Target Language ISO code";

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
                field("Target Language ISO code"; Rec."Target Language ISO code")
                {
                    Visible = ShowTargetLanguageCode;
                    ApplicationArea = All;
                }
                field(Translate2; Rec.Translate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the Translate field to no if you don''t want it to be translated';
                }
                field(Target; Rec.Target)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translated text';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;

                }
                field(Occurrencies; Rec.Occurrencies)
                {
                    Visible = true;
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
                Editable = false;
                ApplicationArea = All;
            }
            part(TargetFactbox; "BCX Trans Target Factbox")
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
            action("Translate")
            {
                ApplicationArea = All;
                Caption = 'Translate';
                Image = Translation;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = ShowTranslate;

                trigger OnAction();
                var
                    Translater: Codeunit "BCX Translate Dispatcher";
                    Project: Record "BCX Translation Project";
                begin
                    Project.get(Rec."Project Code");
                    Rec.Target := Translater.Translate(Project."Project Code", Project."Source Language ISO code",
                                              Rec."Target Language ISO code",
                                              Rec.Source);
                    Rec.Target := ReplaceTermInTranslation(Rec."Target Language ISO code", Rec.Target);
                    Rec.Validate(Target);
                end;
            }
            action("Translate All")
            {
                ApplicationArea = All;
                Caption = 'Translate All';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;
                Enabled = ShowTranslate;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    MenuSelectionTxt: Label 'Convert all,Convert only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            TranslateAll(false);

                        2:
                            TranslateAll(true);
                    end;
                end;
            }
            action("Copy")
            {
                ApplicationArea = All;
                Caption = 'Copy';
                Image = Copy;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = ShowTranslate;

                trigger OnAction();
                begin
                    Rec.Target := Rec.Source;
                    Rec.Validate(Target);
                end;
            }
            action("Copy All")
            {
                ApplicationArea = All;
                Caption = 'Copy All';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;
                Enabled = ShowTranslate;
                PromotedCategory = Process;

                trigger OnAction();
                var
                    MenuSelectionTxt: Label 'Copy all,Copy only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            CopyAll(false);

                        2:
                            CopyAll(true);
                    end;
                end;
            }
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WarningTxt: Label 'Mark all untranslated lines to be translated?';
                    TransTarget: Record "BCX Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then
                        TransTarget.Reset();
                    TransTarget.SetRange(Target, '');
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, true);
                    CurrPage.Update(false);

                end;
            }
            action("Select Empty Translations")
            {
                Caption = 'Select Empty Translations';
                Image = SelectEntries;
                ApplicationArea = All;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.SetRange(Target, '');
                end;
            }
            action("Deselect All")
            {
                ApplicationArea = All;
                Caption = 'Deselect All';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WarningTxt: Label 'Remove mark from all lines and disable translation?';
                    TransTarget: Record "BCX Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then
                        TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Translate, false);
                    CurrPage.Update(false);
                end;
            }
            action("Clear All translations")
            {
                ApplicationArea = All;
                Caption = 'Clear All translations within filter';
                Image = RemoveLine;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WarningTxt: Label 'Remove all translations?';
                    TransTarget: Record "BCX Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    //if TransTarget.Count = 1 then
                    //    TransTarget.Reset();
                    if Confirm(WarningTxt) then
                        TransTarget.ModifyAll(Target, '');
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
                RunObject = page "BCX Translation terms";
                RunPageLink = "Project Code" = field("Project Code"),
                            "Target Language" = field("Target Language ISO code");
            }
            action("Export Translation File")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    WarningTxt: Label 'Export the Translation file?';
                    ExportTranslation: XmlPort "BCX Export Translation Target";

                    TransProject: Record "BCX Translation Project";
                begin
                    if Confirm(WarningTxt) then begin
                        TransProject.get(Rec."Project Code");
                        case TransProject."NAV Version" of
                            TransProject."NAV Version"::"Dynamics 365 Business Central":
                                begin
                                    ExportTranslation.SetProjectCode(Rec."Project Code", TransProject."Source Language ISO code", Rec."Target Language ISO code");
                                    ExportTranslation.Run();
                                end;

                        end;
                    end;
                end;

            }
            action("Find Duplicates")
            {
                Caption = 'Find Duplicates';
                Image = Find;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    FindDuplicatesTxt: Label 'Find Duplicates?';
                begin
                    if Confirm(FindDuplicatesTxt) then
                        FindDuplicates();
                end;
            }
            action("Update From Source")
            {
                Caption = 'Update From Source';
                Image = UpdateXML;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                var
                    FindDuplicatesTxt: Label 'Update from Source?';
                begin
                    if Confirm(FindDuplicatesTxt) then
                        UpdateFromSource();
                end;
            }

        }
    }
    var
        ShowTranslate: Boolean;
        ShowTargetLanguageCode: Boolean;
        TargetLanguageFilter: Text[10];
        TargetLanguageIsoFilter: Text[10];


    trigger OnOpenPage()
    var
        TransSource: Record "BCX Translation Source";
        TransTarget: Record "BCX Translation Target";
        TransSetup: Record "BCX Translation Setup";
        TransExistingTarget: Record "BCX Translation Target";
        TargetLanguage: Record "BCX Target Language";
    begin
        TransSetup.get();
        ShowTranslate := TransSetup."Use Free Google Translate" or TransSetup."Use OpenAI" or TransSetup."Use DeepL";
        ShowTargetLanguageCode := true;
        TargetLanguageFilter := Rec.GetFilter("Target Language");
        TargetLanguageIsoFilter := Rec.GetFilter("Target Language ISO code");
        if (TargetLanguageFilter <> '') then begin

            TransSource.SetFilter("Project Code", Rec.GetFilter("Project Code"));
            if TransSource.FindSet() then
                repeat
                    TransTarget.Init();
                    TransTarget.TransferFields(TransSource);
                    TransTarget."Target Language" := TargetLanguageFilter;
                    TransTarget."Target Language ISO code" := TargetLanguageIsoFilter;

                    TransExistingTarget.SetRange("Source", TransTarget.Source);
                    TransExistingTarget.SetRange("Target Language ISO code", TargetLanguageIsoFilter);
                    TransExistingTarget.SetRange("Translate", false);
                    if TransExistingTarget.FindFirst() then begin
                        TransTarget.Target := TransExistingTarget.Target;
                        TransTarget.Translate := false;
                    end else
                        TransTarget.Translate := true;

                    if TransTarget.Insert() then;
                until TransSource.Next() = 0;
        end
        else begin
            // No Target language, loop through all languages. 
            TargetLanguage.SetFilter("Project Code", Rec.GetFilter("Project Code"));
            if TargetLanguage.FindSet() then
                repeat
                    if (TargetLanguage."Equivalent Language" = '') then begin
                        TransSource.Reset();
                        TransSource.SetFilter("Project Code", Rec.GetFilter("Project Code"));
                        if TransSource.FindSet() then
                            repeat
                                TransTarget.TransferFields(TransSource);
                                TransTarget."Target Language" := TargetLanguage."Target Language";
                                TransTarget."Target Language ISO code" := TargetLanguage."Target Language ISO code";
                                if TransTarget.Insert() then;
                            until TransSource.Next() = 0;
                    end;
                until TargetLanguage.Next() = 0;
        end;
    end;


    local procedure CopyAll(inOnlyEmpty: Boolean)
    var
        TransTarget: Record "BCX Translation Target";
        TransTarget2: Record "BCX Translation Target";
        Project: Record "BCX Translation Project";
        Window: Dialog;
        DialogTxt: Label 'Copying #1###### of #2######';
        Counter: Integer;
        TotalCount: Integer;
        EscapedSource: Text;
    begin
        Project.Get(Rec."Project Code");
        if inOnlyEmpty then
            TransTarget.SetRange(Target, '');
        // TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", Project."Project Code");
        TransTarget.SetRange("Target Language ISO code", Rec."Target Language ISO code");

        TotalCount := TransTarget.Count;
        Window.Open(DialogTxt);

        if TransTarget.FindSet() then begin
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                TransTarget.Target := TransTarget.Source;
                TransTarget.Translate := false;
                TransTarget.Modify();
                Commit();
            until TransTarget.Next() = 0;
        end;

        Window.Close();
    end;

    local procedure TranslateAll(inOnlyEmpty: Boolean)
    var
        Translater: Codeunit "BCX Translate Dispatcher";
        TransTarget: Record "BCX Translation Target";
        TransTarget2: Record "BCX Translation Target";
        Project: Record "BCX Translation Project";
        Window: Dialog;
        DialogTxt: Label 'Converting #1###### of #2######';
        Counter: Integer;
        TotalCount: Integer;
        EscapedSource: Text;
    begin
        Project.Get(Rec."Project Code");

        if inOnlyEmpty then
            TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", Project."Project Code");
        if (TargetLanguageIsoFilter <> '') then
            TransTarget.SetRange("Target Language ISO code", TargetLanguageIsoFilter);

        TotalCount := TransTarget.Count;
        Window.Open(DialogTxt);

        TransTarget.SetCurrentKey(Source);
        if TransTarget.FindSet() then begin
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);

                TransTarget.Target :=
                  Translater.Translate(Project."Project Code",
                                       Project."Source Language ISO code",
                                       TransTarget."Target Language ISO code",
                                       TransTarget.Source);
                TransTarget.Target :=
                  ReplaceTermInTranslation(TransTarget."Target Language ISO code", TransTarget.Target);
                TransTarget.Translate := false;
                TransTarget.Modify();
                // Escape source for filter
                TransTarget2.Reset();
                TransTarget2.SetRange("Project Code", Project."Project Code"); // keep within project
                TransTarget2.SetFilter(Source, '%1', TransTarget.Source);
                TransTarget2.SetFilter("Target Language ISO code", TransTarget."Target Language ISO code");
                if inOnlyEmpty then
                    TransTarget2.SetRange(Target, '');

                TransTarget2.ModifyAll(Translate, false);
                TransTarget2.ModifyAll(Target, TransTarget.Target);

                Commit();
                SelectLatestVersion();

            // Skip already-handled source
            // TransTarget.SetFilter(Source, '<>%1', TransTarget.Source);
            until TransTarget.Next() = 0;
        end;

        Window.Close();
    end;


    // This does the post-translation replacement of terms
    local procedure ReplaceTermInTranslation(TargetLanguageIsoCode: Text[10]; inTarget: Text[250]) outTarget: Text[250]
    var
        TransTerm: Record "BCX Translation Term";
        StartPos: Integer;
        StartLetterIsUppercase: Boolean;
        Found: Boolean;
    begin
        TransTerm.SetRange("Project Code", Rec."Project Code");
        if TransTerm.FindSet() then
            repeat
                if TransTerm."Apply Pre-Translation" then
                    continue; // Skip terms that are marked for pre-translation only
                StartPos := strpos(LowerCase(inTarget), LowerCase(TransTerm.Term));
                if StartPos > 0 then begin
                    StartLetterIsUppercase := copystr(inTarget, StartPos, 1) = uppercase(copystr(inTarget, StartPos, 1));
                    if StartLetterIsUppercase then
                        TransTerm.Translation := UpperCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2)
                    else
                        TransTerm.Translation := LowerCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2);
                    if (StartPos > 1) then begin
                        outTarget := CopyStr(inTarget, 1, StartPos - 1) +
                                     TransTerm.Translation +
                                     CopyStr(inTarget, StartPos + strlen(TransTerm.Term));
                        Found := true;
                    end else begin
                        outTarget := TransTerm.Translation +
                                     CopyStr(inTarget, strlen(TransTerm.Term) + 1);
                        Found := true;
                    end;
                end;
                if Found then
                    inTarget := outTarget;
            until TransTerm.Next() = 0;
        if not Found then
            outTarget := inTarget;
    end;

    local procedure FindDuplicates()
    var
        TransTarget: Record "BCX Translation Target";
        TransTargetDup: Record "BCX Translation Target";
        TransTargetTrans: Record "BCX Translation Target";
        Counter: Integer;
        FinishedTxt: Label '%1 Duplicate captions found';
    begin
        TransTarget.CopyFilters(Rec);
        TransTarget.SetRange(Target, '');
        if TransTarget.FindSet() then
            repeat
                TransTargetTrans.CopyFilters(Rec);
                TransTargetTrans.SetRange(Source, TransTarget.Source);
                TransTargetTrans.SetFilter(Target, '<>%1', '');
                if TransTargetTrans.FindFirst() then begin
                    TransTargetDup.CopyFilters(Rec);
                    TransTargetDup.SetRange(Source, TransTarget.Source);
                    TransTargetDup.SetRange(Target, '');
                    TransTargetDup.ModifyAll(Target, TransTargetTrans.Target);
                    Counter += 1;
                end;
            until TransTarget.Next() = 0;
        message(FinishedTxt, Counter);
    end;

    local procedure UpdateFromSource()
    var
        TransTarget: Record "BCX Translation Target";
        TransSource: Record "BCX Translation Source";
        Counter: Integer;
        DeletedCounter: Integer;
        FinishedTxt: Label '%1 source captions updated. %2 obsolete targets deleted.';
    begin
        TransTarget.Modifyall(Translate, false);
        if TransSource.FindSet() then
            repeat
                TransTarget.SetRange("Project Code", TransSource."Project Code");
                TransTarget.SetRange("Trans-Unit Id", TransSource."Trans-Unit Id");
                if TransTarget.FindSet() then
                    repeat
                        if TransTarget.Source <> TransSource.Source then begin
                            TransTarget.Source := TransSource.Source;
                            TransTarget.Translate := true;
                            TransTarget.Modify();
                            Counter += 1;
                        end;
                    until TransTarget.Next() = 0;
            until TransSource.Next() = 0;


        // Check for targets that no longer exist in source
        TransTarget.Reset();
        if TransTarget.FindSet() then
            repeat
                TransSource.SetRange("Project Code", TransTarget."Project Code");
                TransSource.SetRange("Trans-Unit Id", TransTarget."Trans-Unit Id");
                if not TransSource.FindFirst() then begin
                    TransTarget.Delete();
                    DeletedCounter += 1;
                end;
            until TransTarget.Next() = 0;
        Message(FinishedTxt, Counter, DeletedCounter);

    end;


}
#pragma implicitwith restore
