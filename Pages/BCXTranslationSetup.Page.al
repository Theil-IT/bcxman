page 78607 "BCX Translation Setup"
{
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "BCX Translation Setup";
    Caption = 'Translation Setup';
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Default Source Language code"; Rec."Default Source Language code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Source Languange to be defaulted on every project';
                }
            }
            group("Translate Tools")
            {
                group("Google")
                {
                    ShowCaption = false;

                    field("Use Free Google Translate"; Rec."Use Free Google Translate")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Use the free Google API for translation. The limitation is that it is only possible to access the API a limited number of times each hour.';
                    }
                }
                group("ChatGPT")
                {
                    ShowCaption = false;

                    field("Use ChatGPT"; Rec."Use OpenAI") 
                    { 
                        ToolTip = 'Use the OpenAI API for translation.'; 
                        ApplicationArea = All;
                    }
                    field("ChatGPT API Key"; Rec."OpenAI API Key")
                    {
                        ToolTip = 'API key for accessing the OpenAI API.';
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;

                    }
                    field("ChatGPT Model"; Rec."OpenAI Model")
                    {
                        ToolTip = 'Model to use for the OpenAI API.';
                        ApplicationArea = All;
                    }
                }
                group("DeepL")
                {
                    ShowCaption = false;
                    field("Use DeepL"; Rec."Use DeepL") 
                    { 
                        ToolTip = 'Use the DeepL API for translation.'; 
                        ApplicationArea = All;
                    }
                    field("DeepL API Key"; Rec."DeepL API Key")
                    {
                        ToolTip = 'API key for accessing the DeepL API.';
                        ApplicationArea = All;
                        ExtendedDatatype = Masked;

                    }
                }

            }

        }

    }

    actions
    {
        area(Navigation)
        {
            action("About Al Translation Tool")
            {
                Caption = 'About AL Translation Tool';
                ToolTip = 'Learn more about the AL Translation Tool.';
                RunObject = page "BCX About AL Translation Tool";
                Image = AboutNav;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;
            }

            action("Initialize ISO Languages")
            {
                Caption = 'Initialize ISO Languages';
                ToolTip = 'Initialize or update the ISO language codes in the Language table based on standard mappings.';
                Image = Language;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    UpdateAllLanguages();
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        if not Rec.get() then begin
            Rec.init();
            Rec.Insert();
        end;

    end;



    procedure UpdateAllLanguages()
    var
        Lang: Record "Language";
        Map: Dictionary of [Text, Text];
        IsoTxt: Text;
        Updated: Integer;
        Missing: Integer;
        CodeTxt: Text;
    begin
        InitMap(Map);

        if Lang.FindSet() then
            repeat
                CodeTxt := Format(Lang.Code);
                if Map.ContainsKey(CodeTxt) then begin
                    Map.Get(CodeTxt, IsoTxt);
                    if Lang."BCX Iso Code" <> IsoTxt then begin
                        Lang.Validate("BCX Iso Code", IsoTxt);
                        Lang.Modify(true);
                        Updated += 1;
                    end;
                end else
                    Missing += 1;
            until Lang.Next() = 0;

        Message('Languages updated: %1. Rows with no mapping: %2.', Updated, Missing);
    end;

    local procedure InitMap(var Map: Dictionary of [Text, Text])
    begin
        Map.Add('BGR', 'bg-BG');
        Map.Add('CHS', 'zh-CN');   // Simplified Chinese
        Map.Add('CSY', 'cs-CZ');
        Map.Add('DAN', 'da-DK');
        Map.Add('DEA', 'de-AT');
        Map.Add('DES', 'de-CH');
        Map.Add('DEU', 'de-DE');
        Map.Add('ELL', 'el-GR');
        Map.Add('ENA', 'en-AU');
        Map.Add('ENC', 'en-CA');
        Map.Add('ENG', 'en-GB');
        Map.Add('ENI', 'en-IE');
        Map.Add('ENP', 'en-PH');
        Map.Add('ENU', 'en-US');
        Map.Add('ENZ', 'en-NZ');
        Map.Add('ESM', 'es-MX');
        Map.Add('ESN', 'es-ES');   // Spain (International Sort)
        Map.Add('ESO', 'es-CO');
        Map.Add('ESP', 'es-ES');   // Spain (Traditional Sort) -> keep es-ES
        Map.Add('ESR', 'es-PE');
        Map.Add('ESS', 'es-AR');
        Map.Add('ETI', 'et-EE');
        Map.Add('FIN', 'fi-FI');
        Map.Add('FRA', 'fr-FR');
        Map.Add('FRB', 'fr-BE');
        Map.Add('FRC', 'fr-CA');
        Map.Add('FRS', 'fr-CH');
        Map.Add('HRV', 'hr-HR');
        Map.Add('HUN', 'hu-HU');
        Map.Add('IND', 'en-ID');
        Map.Add('ISL', 'is-IS');
        Map.Add('ITA', 'it-IT');
        Map.Add('ITS', 'it-CH');
        Map.Add('JPN', 'ja-JP');
        Map.Add('KOR', 'ko-KR');
        Map.Add('LTH', 'lt-LT');
        Map.Add('LVI', 'lv-LV');
        Map.Add('MSL', 'ms-MY');   // Malay (Malaysia)
        Map.Add('NLB', 'nl-BE');
        Map.Add('NLD', 'nl-NL');
        Map.Add('NON', 'nn-NO');   // Nynorsk
        Map.Add('NOR', 'nb-NO');   // Bokmål
        Map.Add('PLK', 'pl-PL');
        Map.Add('PTB', 'pt-BR');
        Map.Add('PTG', 'pt-PT');
        Map.Add('ROM', 'ro-RO');
        Map.Add('RUS', 'ru-RU');
        Map.Add('SKY', 'sk-SK');
        Map.Add('SLV', 'sl-SI');
        Map.Add('SRP', 'sr-Latn-RS'); // Serbian (Latin, Serbia)
        Map.Add('SVE', 'sv-SE');
        Map.Add('THA', 'th-TH');
        Map.Add('TRK', 'tr-TR');
        Map.Add('UKR', 'uk-UA');
    end;
}

