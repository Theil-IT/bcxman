codeunit 78602 "BCX GPT Translate Rest"
{
    procedure SendHttpRequestWithAuth(HttpMethod: Text[10]; Url: Text; Payload: Text; ContentType: Text; HeaderName: Text; HeaderValue: Text; var Response: HttpResponseMessage)
    var
        Client: HttpClient;
        Request: HttpRequestMessage;
        RequestHeaders: HttpHeaders;
        Content: HttpContent;
    begin
        // Create request
        Request.SetRequestUri(Url);
        Request.Method := HttpMethod;

        Request.GetHeaders(RequestHeaders);
        if (HeaderName <> '') and not RequestHeaders.Contains(HeaderName) then
            RequestHeaders.Add(HeaderName, HeaderValue);

        if (ContentType <> '') and not RequestHeaders.Contains('Content-Type') then
            RequestHeaders.Add('Content-Type', ContentType);

        // Write body
        Content.WriteFrom(Payload);
        Request.Content := Content;

        // Send request
        if not Client.Send(Request, Response) then
            Error('%1 request failed: %2', HttpMethod, Url);
    end;


    procedure ReadResponseAsText(Response: HttpResponseMessage): Text
    var
        ResponseText: Text;
    begin
        Response.Content().ReadAs(ResponseText);
        exit(ResponseText);
    end;



    local procedure UnprotectGlossaryTerms(var Text: Text[2048]): Text[2048]
    begin
#pragma warning disable AA0139
        Text := Text.Replace('__KEEP__', '');
        Text := Text.Replace('__/KEEP__', '');
#pragma warning restore AA0139
        exit(Text);
    end;

    // Main translation function
    procedure Translate(ProjectCode: Text[20]; inSourceLang: Text[10]; inTargetLang: Text[10]; inText: Text[4000]) outTransText: Text[2048]
    var
        Setup: Record "BCX Translation Setup";
        TransTerms: Record "BCX Translation Term";
        GenTransTerms: Record "BCX Gen. Translation Term";
        TypeHelper: Codeunit "Type Helper";
        HttpClient: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        Content: HttpContent;
        Payload: JsonObject;
        Messages: JsonArray;
        SystemMsg, UserMsg : JsonObject;
        ResponseText: Text;
        GlossaryTerms: Text;
        SystemPrompt: Text;
        Glossary: List of [Text];
        Term: Text;
    begin
        if (inSourceLang = inTargetLang) then begin
            outTransText := CopyStr(inText, 1, 2048);
            exit;
        end;
        if not Setup.Get() then
            Error('Translation setup is missing.');
        if not Setup."Use OpenAI" then
            Error('OpenAI translation is disabled in setup.');
        // Add General Translation Terms marked as pre-translation to glossary
        if (GenTransTerms.FindSet()) then
            repeat
                if not GenTransTerms."Apply Pre-Translation" then
                    continue; // Skip terms that are not marked for pre-translation
                GlossaryTerms += GenTransTerms.Term + ', ';
                Glossary.Add(GenTransTerms.Term);
            until GenTransTerms.Next() = 0;
        TransTerms.SetFilter("Project Code", '%1', ProjectCode);
        if (TransTerms.FindSet()) then
            repeat
                if not TransTerms."Apply Pre-Translation" then
                    continue; // Skip terms that are not marked for pre-translation
                GlossaryTerms += TransTerms.Term + ', ';
                Glossary.Add(TransTerms.Term);
            until TransTerms.Next() = 0;
        SystemPrompt :=
          'You are a professional translator specializing in Microsoft Business Central ERP. ' +
          'Translate from English (US) to the language specified in the first line (ISO format, e.g., da-DK). ' +
          'Use terminology consistent with Microsoft ERP and business applications. ' +
          'Preserve all placeholders exactly as-is (e.g., %1, <x>, <x id="1">). ' +
          'Do not translate product or feature names: ' + GlossaryTerms + '. ' +
          'Return only the translated sentence. No explanations. ' +
          'Do not return the language name or ISO code. Do not repeat the language code.';

        // Prepare JSON body
        SystemMsg.Add('role', 'system');

        SystemMsg.Add('content', SystemPrompt);
        Messages.Add(SystemMsg);

        UserMsg.Add('role', 'user');

        foreach Term in Glossary do
#pragma warning disable AA0139
            InText := InText.Replace(Term, '__KEEP__' + Term + '__/KEEP__');
#pragma warning restore AA0139

        UserMsg.Add('content', inTargetLang + TypeHelper.NewLine() + inText);
        Messages.Add(UserMsg);

        Payload.Add('model', Format(Setup."OpenAI Model"));
        Payload.Add('temperature', 0);
        Payload.Add('max_tokens', 256);
        Payload.Add('messages', Messages);

        // Set up request
        Request.SetRequestUri('https://api.openai.com/v1/chat/completions');
        Request.Method := 'POST';
        Request.GetHeaders(Headers);
        Headers.TryAddWithoutValidation('Authorization', 'Bearer ' + Setup."OpenAI API Key");

        Content.WriteFrom(Format(Payload));
        Content.GetHeaders(Headers); // reuse same Headers to avoid split issues
        Headers.Remove('Content-Type');
        Headers.TryAddWithoutValidation('Content-Type', 'application/json');
        Request.Content := Content;

        // Send and check
        if not HttpClient.Send(Request, Response) then
            Error('Failed to send request to OpenAI API.');

        if not Response.IsSuccessStatusCode() then
            Error('OpenAI returned status %1: %2', Response.HttpStatusCode, Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);
        outTransText := CopyStr(ParseTranslatedText(ResponseText), 1, 2048); // Prevent overflow
        outTransText := UnprotectGlossaryTerms(outTransText);
    end;

    local procedure ParseTranslatedText(JsonText: Text): Text
    var
        Tok: JsonToken;
        Obj: JsonObject;
        ChoicesTok: JsonToken;
        ChoicesArr: JsonArray;
        ChoiceTok: JsonToken;
        ChoiceObj: JsonObject;
        MsgTok: JsonToken;
        MsgObj: JsonObject;
        ContentTok: JsonToken;
        Result: Text;
    begin
        if not Tok.ReadFrom(JsonText) then
            Error('Failed to parse GPT response JSON.');

        Obj := Tok.AsObject();
        if not Obj.Get('choices', ChoicesTok) then
            Error('GPT response missing ''choices'' array.');

        ChoicesArr := ChoicesTok.AsArray();

        if ChoicesArr.Count() = 0 then
            Error('GPT response contained no choices.');

        ChoicesArr.Get(0, ChoiceTok);
        ChoiceObj := ChoiceTok.AsObject();

        if not ChoiceObj.Get('message', MsgTok) then
            Error('GPT response choice missing ''message''.');

        MsgObj := MsgTok.AsObject();
        if not MsgObj.Get('content', ContentTok) then
            Error('GPT response message missing ''content''.');

        Result := ContentTok.AsValue().AsText();
        exit(Result);
    end;





}
