codeunit 78606 "BCX XML Helpers"
{

    procedure ReadXmlFromInStream(var InS: InStream; var XmlDoc: XmlDocument)
    begin
        // Reads/parses XML from the provided InStream into XmlDoc
        XmlDocument.ReadFrom(InS, XmlDoc);
    end;

    procedure GetRoot(var XmlDoc: XmlDocument; var Root: XmlElement)
    begin
        // Returns the document root (<xliff> in your case)
        XmlDoc.GetRoot(Root);
    end;

    procedure GetAttr(Element: XmlElement; Name: Text): Text
    var
        Attrs: XmlAttributeCollection;
        Attr: XmlAttribute;
    begin
        // Case-insensitive attribute lookup (returns '' if not found)
        if not Element.HasAttributes() then
            exit('');

        Attrs := Element.Attributes();
        foreach Attr in Attrs do
            if LowerCase(Attr.Name()) = LowerCase(Name) then
                exit(Attr.Value());

        exit('');
    end;

    procedure GetChildElements(Element: XmlElement; LocalName: Text; NamespaceUri: Text; var NodeList: XmlNodeList)
    begin
        // Try with namespace first (if supplied)
        NodeList := Element.GetChildElements(LocalName, NamespaceUri);
        if NodeList.Count() = 0 then
            NodeList := Element.GetChildElements(LocalName);
    end;

    procedure TryGetFirstChildElement(Element: XmlElement; LocalName: Text; NamespaceUri: Text; var ChildElement: XmlElement): Boolean
    var
        NL: XmlNodeList;
        N: XmlNode;
    begin
        GetChildElements(Element, LocalName, NamespaceUri, NL);
        if NL.Count() = 0 then
            exit(false);
        NL.Get(1, N);
        ChildElement := N.AsXmlElement();
        exit(true);
    end;

    procedure GetDescendantElements(var XmlDoc: XmlDocument; LocalName: Text; NamespaceUri: Text; var NodeList: XmlNodeList)
    begin
        // Descendant search with namespace fallback
        NodeList := XmlDoc.GetDescendantElements(LocalName, NamespaceUri);
        if NodeList.Count() = 0 then
            NodeList := XmlDoc.GetDescendantElements(LocalName);
    end;

    procedure ElementInnerText(El: XmlElement): Text
    begin
        exit(El.InnerText());
    end;

    procedure ReadStreamToText(var InS: InStream; var OutText: Text)
    var
        chunk: Text;
    begin
        OutText := '';
        while not InS.EOS() do begin
            InS.ReadText(chunk);
            OutText += chunk;
        end;
    end;

    procedure StripCommonBOMs(var Txt: Text)
    var
        First3: Text;
        First1: Text;
    begin
        // Remove the common CP1252-decoded BOM sequence 'ï»¿'
        if StrLen(Txt) >= 3 then begin
            First3 := CopyStr(Txt, 1, 3);
            if First3 = 'ï»¿' then
                Txt := CopyStr(Txt, 4, StrLen(Txt) - 3);
        end;
        // Remove real U+FEFF (ZERO WIDTH NO-BREAK SPACE) if present as first character
        if StrLen(Txt) >= 1 then begin
            First1 := CopyStr(Txt, 1, 1);
            if First1 = '﻿' then // literal U+FEFF
                Txt := CopyStr(Txt, 2, StrLen(Txt) - 1);
        end;
    end;

    procedure TrimText(Input: Text): Text
    var
        Char: Char;
    begin
        while (StrLen(Input) > 0) do begin
            Evaluate(Char, CopyStr(Input, 1, 1));
            if not (Char in [' ', 9, 10, 13]) then
                break;
            Input := CopyStr(Input, 2);
        end;

        while (StrLen(Input) > 0) do begin
            Evaluate(Char, CopyStr(Input, StrLen(Input), 1));
            if not (Char in [' ', 9, 10, 13]) then
                break;
            Input := CopyStr(Input, 1, StrLen(Input) - 1);
        end;

        exit(Input);
    end;
}
