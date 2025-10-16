#pragma implicitwith disable
page 78605 "BCX Trans Target Factbox"
{
    PageType = CardPart;
    SourceTable = "BCX Translation Target";
    Caption = 'Translation Target Factbox';
    Editable = false;

    layout
    {
        area(Content)
        {
            group(Line)
            {
                ShowCaption = false;
                field(Instances; Instances)
                {
                    Caption = 'Instances';
                    ToolTip = 'Number of instances of this target language in the translation source for the selected project.';
                    ApplicationArea = All;
                }
            }
            group(Totals)
            {
                field(TotalCaptions; TotalCaptions)
                {
                    Caption = 'Total Captions';
                    ToolTip = 'Total number of captions in the translation target for the selected project.';
                    ApplicationArea = all;
                }
                field(TotalMissingTranslations; TotalMissingTranslations)
                {
                    Caption = 'Total Missing Translations';
                    ToolTip = 'Total number of missing translations in the translation target for the selected project.';
                    ApplicationArea = all;
                }
                field(TotalMissingCaptions; TotalMissingCaptions)
                {
                    Caption = 'Total Missing Captions';
                    ToolTip = 'Total number of missing captions in the translation target for the selected project.';
                    ApplicationArea = all;
                }
            }
        }
    }

    var
        Instances: Integer;
        TotalCaptions: Integer;
        TotalMissingCaptions: Integer;
        TotalMissingTranslations: Integer;

    trigger OnAfterGetCurrRecord()
    var
        Target: Record "BCX Translation Target";
    begin
        Target.SetRange("Project Code", Rec."Project Code");
        TotalCaptions := Target.Count;
        Target.SetRange(Source, '');
        TotalMissingCaptions := Target.Count;
        Target.SetFilter(Source, '<>%1', '');
        Target.SetRange(Target, '');
        TotalMissingTranslations := Target.Count;
    end;

    trigger OnAfterGetRecord()
    var
        TransTarget: Record "BCX Translation Target";
    begin
        TransTarget.SetRange(Source, Rec.Source);
        Instances := TransTarget.Count;
    end;

}
#pragma implicitwith restore
