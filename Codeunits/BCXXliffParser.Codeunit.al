codeunit 78605 "BCX Xliff Parser"
{

    // Public entry points for the three import types the XMLPorts used to handle
    procedure ImportSourceFromStream(ProjectCode: Code[20]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'Source', '', '');
    end;

    procedure ImportBaseTargetFromStream(ProjectCode: Code[20]; SourceLangISO: Text[10]; TargetLangISO: Text[10]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'BaseTarget', SourceLangISO, TargetLangISO);
    end;

    procedure ImportTargetFromStream(ProjectCode: Code[20]; SourceLangISO: Text[10]; TargetLangISO: Text[10]; FileName: Text; var InS: InStream)
    begin
        ParseAndInsert(ProjectCode, FileName, InS, 'Target', SourceLangISO, TargetLangISO);
    end;

    local procedure ParseAndInsert(ProjectCode: Code[20]; FileName: Text; var InS: InStream; Mode: Text; SourceLangISO: Text[10]; TargetLangISO: Text[10])
    var
        RecSource: Record "BCX Translation Source";
        RecTarget: Record "BCX Translation Target";
        RecExistingTarget: Record "BCX Translation Target";
        RecBaseTarget: Record "BCX Base Translation Target";
        RecNote: Record "BCX Translation Notes";
        RecBaseNote: Record "BCX Base Translation Notes";
        RecProject: Record "BCX Translation Project";
        RecTargetLanguage: Record "Language";
        XmlHelper: Codeunit "BCX XML Helpers";

        XmlDoc: XmlDocument;
        RootEl: XmlElement;
        ns: Text;
        FileElements: XmlNodeList;
        FileNode: XmlNode;
        FileEl: XmlElement;

        TransUnitList: XmlNodeList;
        TransNode: XmlNode;
        TransEl: XmlElement;
        SourceNodes: XmlNodeList;
        sn: XmlNode;
        TargetNodes: XmlNodeList;
        tn: XmlNode;

        // fields extracted from trans-unit
        TransUnitId: Text[250];
        SourceText: Text;
        TargetText: Text;
        TargetStatus: Text[50];
        SizeUnit: Text[50];
        TranslateAttr: Text[50];
        AlObjectTarget: Text[250];

        // notes
        NoteList: XmlNodeList;
        NoteNode: XmlNode;
        NoteEl: XmlElement;
        NoteFrom: Text[100];
        NoteAnnotates: Text[50];
        NotePriority: Text[10];
        NoteText: Text;

        i: Integer;
        j: Integer;


    begin
        // Parse XML
        XmlHelper.ReadXmlFromInStream(InS, XmlDoc);
        XmlHelper.GetRoot(XmlDoc, RootEl); // <xliff>

        // Namespace handling: many XLIFF have default namespace; use it when selecting children
        ns := RootEl.NamespaceUri();

        // Get the first <file> element under root (we need 'original', source/target languages possibly)
        FileElements := RootEl.GetChildElements('file', ns);
        if FileElements.Count() = 0 then
            FileElements := RootEl.GetChildElements('file'); // fallback
        if FileElements.Count() > 0 then begin
            FileElements.Get(1, FileNode);
            FileEl := FileNode.AsXmlElement();

#pragma warning disable AA0139
            // If Mode didn't pass source/target ISO, take from file attributes
            if SourceLangISO = '' then
                SourceLangISO := XmlHelper.GetAttr(FileEl, 'source-language');

            if TargetLangISO = '' then 
                TargetLangISO := XmlHelper.GetAttr(FileEl, 'target-language');
#pragma warning restore AA0139
        

            RecTargetLanguage.SetRange("BCX ISO code", TargetLangISO);
            RecTargetLanguage.FindFirst();

            // If the <file original="..."> contains an original project name, update project (optional)
            if (mode = 'Source') then begin
                RecProject.Get(ProjectCode);
                RecProject."File Name" := CopyStr(FileName, 1, MaxStrLen(RecProject."File Name"));
                if XmlHelper.GetAttr(FileEl, 'original') <> '' then
                    RecProject.Validate("Project Name", CopyStr(XmlHelper.GetAttr(FileEl, 'original'), 1, MaxStrLen(RecProject."Project Name")));

                RecProject.Modify(true);
            end;
        end;

        // Find all trans-unit elements anywhere under the document.
        // Use GetDescendantElements so it finds them even if nested.
        TransUnitList := XmlDoc.GetDescendantElements('trans-unit', ns);

        for i := 1 to TransUnitList.Count() do begin
            TransUnitList.Get(i, TransNode);
            TransEl := TransNode.AsXmlElement();

            // Attributes
            TransUnitId := CopyStr(XmlHelper.GetAttr(TransEl, 'id'), 1, MaxStrLen(TransUnitId));
            SizeUnit := CopyStr(XmlHelper.GetAttr(TransEl, 'size-unit'), 1, MaxStrLen(SizeUnit));
            TranslateAttr := CopyStr(XmlHelper.GetAttr(TransEl, 'translate'), 1, MaxStrLen(TranslateAttr));
            AlObjectTarget := CopyStr(XmlHelper.GetAttr(TransEl, 'al-object-target'), 1, MaxStrLen(AlObjectTarget));

            // Child elements: source (optional content)
            SourceText := '';
            SourceNodes := TransEl.GetChildElements('source', ns);
            if (SourceNodes.Count() = 0) then
                SourceNodes := TransEl.GetChildElements('source'); // fallback

            if (SourceNodes.Count() > 0) then begin
                SourceNodes.Get(1, sn);
                SourceText := sn.AsXmlElement().InnerText();
            end;

            // Child elements: target (optional)
            TargetText := '';
            TargetNodes := TransEl.GetChildElements('target', ns);
            if (TargetNodes.Count() = 0) then
                TargetNodes := TransEl.GetChildElements('target'); // fallback
            if (TargetNodes.Count() > 0) then begin
                TargetNodes.Get(1, tn);
                TargetText := tn.AsXmlElement().InnerText();
                TargetStatus := CopyStr(XmlHelper.GetAttr(tn.AsXmlElement(), 'state'), 1, MaxStrLen(TargetStatus));
            end;

            // If both source and target empty -> skip
            if (SourceText = '') and (TargetText = '') then
                continue;

            // Prepare notes collection for this trans-unit
            NoteList := TransEl.GetChildElements('note', ns);
            if NoteList.Count() = 0 then
                NoteList := TransEl.GetChildElements('note');

            // Insert into appropriate table depending on Mode
#pragma warning disable AA0022
            if Mode = 'Source' then begin
                RecSource.Init();
                RecSource."Project Code" := ProjectCode;
                RecSource."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(RecSource."Trans-Unit Id"));
                RecSource.Source := CopyStr(SourceText, 1, MaxStrLen(RecSource.Source));


                // handle notes as BCX Translation Notes
                for j := 1 to NoteList.Count() do begin
                    NoteList.Get(j, NoteNode);
                    NoteEl := NoteNode.AsXmlElement();
                    NoteFrom := CopyStr(XmlHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                    NoteAnnotates := CopyStr(XmlHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                    NotePriority := CopyStr(XmlHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                    NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(RecNote.Note));

                    RecNote.Init();
                    RecNote."Project Code" := ProjectCode;
                    RecNote."Trans-Unit Id" := RecSource."Trans-Unit Id";
                    RecNote.From := NoteFrom;
                    RecNote.Annotates := NoteAnnotates;
                    RecNote.Priority := NotePriority;
                    RecNote.Note := CopyStr(NoteText, 1, MaxStrLen(RecNote.Note));
                    if ((RecNote.Note <> '') and ((RecSource."Field Name" = '') or (RecNote.From = 'Xliff Generator'))) then
                        RecSource."Field Name" := RecNote."Note";
                    if not RecNote.Insert() then
                        RecNote.Modify();
                end;
                if not RecSource.Insert() then
                    RecSource.Modify();
            end else 
            if Mode = 'BaseTarget' then begin
                RecBaseTarget.Init();
                RecBaseTarget."Project Code" := ProjectCode;
                RecBaseTarget."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(RecBaseTarget."Trans-Unit Id"));
                RecBaseTarget.Source := CopyStr(SourceText, 1, MaxStrLen(RecBaseTarget.Source));
                RecBaseTarget.Target := CopyStr(TargetText, 1, MaxStrLen(RecBaseTarget.Target));
                RecBaseTarget."size-unit" := CopyStr(SizeUnit, 1, MaxStrLen(RecBaseTarget."size-unit"));
                RecBaseTarget.TranslateAttr := CopyStr(TranslateAttr, 1, MaxStrLen(RecBaseTarget.TranslateAttr));
                RecBaseTarget."al-object-target" := CopyStr(AlObjectTarget, 1, MaxStrLen(RecBaseTarget."al-object-target"));
                RecBaseTarget.Validate("Target Language ISO code", TargetLangISO);
                RecBaseTarget."Target Language" := RecTargetLanguage.Code;

                // Base target notes => BCX Base Translation Notes
                for j := 1 to NoteList.Count() do begin
                    NoteList.Get(j, NoteNode);
                    NoteEl := NoteNode.AsXmlElement();
                    NoteFrom := CopyStr(XmlHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                    NoteAnnotates := CopyStr(XmlHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                    NotePriority := CopyStr(XmlHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                    NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(RecBaseNote.Note));

                    RecBaseNote.Init();
                    RecBaseNote."Project Code" := ProjectCode;
                    RecBaseNote."Trans-Unit Id" := RecBaseTarget."Trans-Unit Id";
                    RecBaseNote.From := NoteFrom;
                    RecBaseNote.Annotates := NoteAnnotates;
                    RecBaseNote.Priority := NotePriority;
                    RecBaseNote.Note := CopyStr(NoteText, 1, MaxStrLen(RecBaseNote.Note));
                    if ((RecBaseNote.Note <> '') and ((RecBaseTarget."Field Name" = '') or (RecBaseNote.From = 'Xliff Generator'))) then
                        RecBaseTarget."Field Name" := RecBaseNote."Note";
                    if not RecBaseNote.Insert() then
                        RecBaseNote.Modify();

                    if not RecBaseTarget.Insert() then
                        RecBaseTarget.Modify();
                end;
            end else begin // Mode = 'Target'
                RecTarget.Init();
                RecTarget."Project Code" := ProjectCode;
                RecTarget."Trans-Unit Id" := CopyStr(TransUnitId, 1, MaxStrLen(RecTarget."Trans-Unit Id"));
                RecTarget.Source := CopyStr(SourceText, 1, MaxStrLen(RecTarget.Source));
                RecTarget.Target := CopyStr(TargetText, 1, MaxStrLen(RecTarget.Target));
                RecTarget."Target Language ISO code" := TargetLangISO;

                RecTarget.Translate := false;
                if (RecTarget.Target = '') then begin
                    RecExistingTarget.Init();
                    RecExistingTarget.SetRange("Source", RecTarget.Source);
                    RecExistingTarget.SetRange("Target Language ISO code", RecTarget."Target Language ISO code");
                    RecExistingTarget.SetRange("Translate", false);
                    if RecExistingTarget.FindFirst() then
                        RecTarget.Target := RecExistingTarget.Target
                    else
                        RecTarget.Translate := true;
                end else 
                    if (TargetStatus = 'needs-adaptation') or (TargetStatus = 'needs-translation') then
                        RecTarget.Translate := true
                    else
                        RecTarget.Translate := false;
            

                RecTarget."size-unit" := CopyStr(SizeUnit, 1, MaxStrLen(RecTarget."size-unit"));
                RecTarget.TranslateAttr := CopyStr(TranslateAttr, 1, MaxStrLen(RecTarget.TranslateAttr));
                RecTarget."al-object-target" := CopyStr(AlObjectTarget, 1, MaxStrLen(RecTarget."al-object-target"));

                RecTarget."Target Language" := RecTargetLanguage.Code;

                // Translation notes => BCX Translation Notes
                for j := 1 to NoteList.Count() do begin
                    NoteList.Get(j, NoteNode);
                    NoteEl := NoteNode.AsXmlElement();
                    NoteFrom := CopyStr(XmlHelper.GetAttr(NoteEl, 'from'), 1, MaxStrLen(NoteFrom));
                    NoteAnnotates := CopyStr(XmlHelper.GetAttr(NoteEl, 'annotates'), 1, MaxStrLen(NoteAnnotates));
                    NotePriority := CopyStr(XmlHelper.GetAttr(NoteEl, 'priority'), 1, MaxStrLen(NotePriority));
                    NoteText := CopyStr(NoteEl.InnerText(), 1, MaxStrLen(RecNote.Note));

                    RecNote.Init();
                    RecNote."Project Code" := ProjectCode;
                    RecNote."Trans-Unit Id" := RecTarget."Trans-Unit Id";
                    RecNote.From := NoteFrom;
                    RecNote.Annotates := NoteAnnotates;
                    RecNote.Priority := NotePriority;
                    RecNote.Note := CopyStr(NoteText, 1, MaxStrLen(RecNote.Note));
                    if ((RecNote.Note <> '') and ((RecTarget."Field Name" = '') or (RecNote.From = 'Xliff Generator'))) then
                        RecTarget."Field Name" := RecNote."Note";
                    if not RecNote.Insert() then
                        RecNote.Modify();
                end;

                if not RecTarget.Insert() then
                    RecTarget.Modify();

            end;
#pragma warning restore AA0022
        end;
    end;

}
