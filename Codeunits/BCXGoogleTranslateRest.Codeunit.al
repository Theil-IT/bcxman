codeunit 78600 "BCX Google Translate Rest"
{

    local procedure PrepareForTranslation(TextToTranslate: Text): Text
    begin
        TextToTranslate := TextToTranslate.Replace('%1', '[[1]]');
        TextToTranslate := TextToTranslate.Replace('%2', '[[2]]');
        exit(TextToTranslate);
    end;

    local procedure RestorePlaceholders(TranslatedText: Text): Text
    begin
        TranslatedText := TranslatedText.Replace('[[1]]', '%1');
        TranslatedText := TranslatedText.Replace('[[2]]', '%2');
        exit(TranslatedText);
    end;

    procedure Translate(ProjectCode: Text[20]; inSourceLang: Text[10]; inTargetLang: Text[10]; inText: Text[2048]) outTransText: text[2048]
    var
        EndPoint: Text;
        PreparedText: Text;
        TranslatedText: Text;
    begin
        if (inSourceLang = inTargetLang) then begin
            outTransText := inText;
            exit;
        end;
        PreparedText := PrepareForTranslation(inText);
        HttpClient.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
        EndPoint := 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=%1&tl=%2&dt=t&q=%3';
        EndPoint := StrSubstNo(EndPoint, inSourceLang, inTargetLang, PreparedText);
        if not HttpClient.Get(EndPoint, ResponseMessage) then
            Error('The call to the web service failed.');
        if not ResponseMessage.IsSuccessStatusCode then
            error('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
        ResponseMessage.Content.ReadAs(TransText);

        TranslatedText := GetLines(TransText);
        outTransText := CopyStr(RestorePlaceholders(TranslatedText), 1, 2048);
    end;


    local procedure GetLines(inTxt: Text): Text
    var
        JsonTok: JsonToken;
        JsonArr: JsonArray;
        OuterTok: JsonToken;
        InnerArr: JsonArray;
        InnerTok: JsonToken;
        DeepArr: JsonArray;
        ValueTok: JsonToken;
        Value: Text;
    begin
        if not JsonTok.ReadFrom(inTxt) then
            Error('Failed to parse JSON response.');

        JsonArr := JsonTok.AsArray();
        if JsonArr.Count() = 0 then
            exit('');

        // Get first element of outer array
        JsonArr.Get(0, OuterTok);
        InnerArr := OuterTok.AsArray();

        // Get first element of inner array
        InnerArr.Get(0, InnerTok);
        DeepArr := InnerTok.AsArray();

        // Get first element of deep array
        DeepArr.Get(0, ValueTok);

        // Get text value
        Value := ValueTok.AsValue().AsText();

        exit(Value);
    end;


    var
        HttpClient: HttpClient;
        ResponseMessage: HttpResponseMessage;
        TransText: text;
}