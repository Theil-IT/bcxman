codeunit 78603 "BCX Translate Dispatcher"
{
    var
        CachedSetup: Record "BCX Translation Setup";
        SetupLoaded: Boolean;

    procedure Translate(ProjectCode: Text[20]; SourceLang: Text[10]; TargetLang: Text[10]; TextToTranslate: Text[2048]): Text[2048]
    var
        GPT: Codeunit "BCX GPT Translate Rest";
        Google: Codeunit "BCX Google Translate Rest";
        DeepL: Codeunit "BCX DeepL Translate";
    begin
        EnsureSetupLoaded();

        if CachedSetup."Use OpenAI" then
            exit(GPT.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate))
        else 
            if CachedSetup."Use DeepL" then
                exit(DeepL.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate))
            else 
                if CachedSetup."Use Free Google Translate" then
                    exit(Google.Translate(ProjectCode, SourceLang, TargetLang, TextToTranslate));
    end;

    procedure UseChatGPT(): Boolean
    begin
        EnsureSetupLoaded();
        exit(CachedSetup."Use OpenAI");
    end;

    local procedure EnsureSetupLoaded()
    begin
        if SetupLoaded then
            exit;

        if not CachedSetup.Get() then
            Error('Translation setup is missing.');

        SetupLoaded := true;
    end;
}
