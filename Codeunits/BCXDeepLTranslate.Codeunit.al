codeunit 78607 "BCX DeepL Translate"
{
    procedure Translate(ProjectCode: Text[20]; inSourceLang: Text[10]; inTargetLang: Text[10]; inText: Text[2048]) outTransText: Text[2048]
    var
        Setup: Record "BCX Translation Setup";
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Payload: JsonObject;
        Texts: JsonArray;
        TmpSrc, TmpTgt : Text;
        ResponseText: Text;
    begin
        // Short-circuit when source == target
        if (inSourceLang = inTargetLang) then begin
            outTransText := inText;
            exit;
        end;

        // Load setup and DeepL API key
        if not Setup.Get() then
            Error('Translation setup is missing.');
        if not Setup."Use DeepL" then
            Error('DeepL translation is disabled in setup.');
        if Setup."DeepL API Key" = '' then
            Error('DeepL API key is missing in translation setup.');


        // Map language codes to the simple two-letter code DeepL expects (e.g. da-DK -> DA)
        TmpTgt := inTargetLang;
        if StrPos(TmpTgt, '-') > 0 then
            TmpTgt := CopyStr(TmpTgt, 1, StrPos(TmpTgt, '-') - 1);
        TmpTgt := UpperCase(TmpTgt);

        TmpSrc := inSourceLang;
        if TmpSrc <> '' then begin
            if StrPos(TmpSrc, '-') > 0 then
                TmpSrc := CopyStr(TmpSrc, 1, StrPos(TmpSrc, '-') - 1);
            TmpSrc := UpperCase(TmpSrc);
        end;


        // Note: For DeepL we need to use Glossaries to protect terms, but that is not implemented yet

        // Build JSON payload { "text": [ "..." ], "target_lang": "DA", "source_lang": "EN" }
        Texts.Add(inText);
        Payload.Add('text', Texts);
        Payload.Add('target_lang', TmpTgt);
        Payload.Add('context', 'You are a professional translator specializing in Microsoft Business Central ERP.');
        if TmpSrc <> '' then
            Payload.Add('source_lang', TmpSrc);

        // Prepare request (always use free endpoint)
        Request.SetRequestUri('https://api-free.deepl.com/v2/translate');
        Request.Method := 'POST';

        Request.GetHeaders(Headers);
        // Authorization header must be exactly: Authorization: DeepL-Auth-Key <API key>
        Headers.TryAddWithoutValidation('Authorization', 'DeepL-Auth-Key ' + Setup."DeepL API Key");

        // Content: JSON
        Content.WriteFrom(Format(Payload)); // Format(JsonObject) used in your existing code patterns
        Content.GetHeaders(Headers); // re-use same headers object to avoid split issues
        Headers.Remove('Content-Type');
        Headers.TryAddWithoutValidation('Content-Type', 'application/json');
        Request.Content := Content;

        // Send
        if not HttpClient.Send(Request, Response) then
            Error('Failed to send request to DeepL API.');

        if not Response.IsSuccessStatusCode() then begin
            Response.Content.ReadAs(ResponseText);
            Error('DeepL returned status %1: %2 -- %3', Response.HttpStatusCode, Response.ReasonPhrase, ResponseText);
        end;

        Response.Content.ReadAs(ResponseText);

        // Parse DeepL response and return first translated text
        outTransText := CopyStr(ParseDeepLResponse(ResponseText), 1, 2048);

        // Unprotect glossary terms - add later
        // outTransText := UnprotectGlossaryTerms(outTransText);
    end;


    local procedure ParseDeepLResponse(JsonText: Text): Text
    var
        Helper: Codeunit "BCX XML Helpers";
        Tok: JsonToken;
        RootObj: JsonObject;
        TranslationsTok: JsonToken;
        TranslationsArr: JsonArray;
        FirstTranslationTok: JsonToken;
        FirstTranslationObj: JsonObject;
        TextTok: JsonToken;
        ResultTxt: Text;
    begin
        if not Tok.ReadFrom(JsonText) then
            Error('Failed to parse DeepL response JSON.');

        RootObj := Tok.AsObject();
        if not RootObj.Get('translations', TranslationsTok) then
            Error('DeepL response missing ''translations'' array.');

        TranslationsArr := TranslationsTok.AsArray();
        if TranslationsArr.Count() = 0 then
            Error('DeepL response contained no translations.');

        // Get the first translation object
        TranslationsArr.Get(0, FirstTranslationTok);
        FirstTranslationObj := FirstTranslationTok.AsObject();

        // Extract the "text" property (out param must be JsonToken)
        if not FirstTranslationObj.Get('text', TextTok) then
            Error('DeepL translation object missing ''text''.');

        ResultTxt := TextTok.AsValue().AsText();
        exit(Helper.TrimText(ResultTxt));
    end;

}