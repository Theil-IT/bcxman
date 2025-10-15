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
                    ApplicationArea = All;
                }
            }
            group(Totals)
            {
                field(TotalCaptions; TotalCaptions)
                {
                    Caption = 'Total Captions';
                    ApplicationArea = all;
                }
                field(TotalMissingTranslations; TotalMissingTranslations)
                {
                    Caption = 'Total Missing Translations';
                    ApplicationArea = all;
                }
                field(TotalMissingCaptions; TotalMissingCaptions)
                {
                    Caption = 'Total Missing Captions';
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
