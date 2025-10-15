page 78615 "BCX Trans Source Factbox"
{
    PageType = CardPart;
    SourceTable = "BCX Translation Source";
    Caption = 'Source Factbox';
    Editable = false;

    layout
    {
        area(Content)
        {
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
        TotalCaptions: Integer;
        TotalMissingCaptions: Integer;
        TotalMissingTranslations: Integer;

    trigger OnAfterGetRecord()
    var
        Source: Record "BCX Translation Source";
    begin
        Source.SetRange("Project Code", Rec."Project Code");
        TotalCaptions := Source.Count;
        Source.SetRange(Source, '');
        TotalMissingCaptions := Source.Count;
        Source.SetFilter(Source, '<>%1', '');
        Source.SetRange(Source, '');
        TotalMissingTranslations := Source.Count;
    end;
}
