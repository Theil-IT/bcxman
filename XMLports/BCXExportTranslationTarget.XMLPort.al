xmlport 78601 "BCX Export Translation Target"
{
    Caption = 'Export Translation Target';
    DefaultNamespace = 'urn:oasis:names:tc:xliff:document:1.2';
    Direction = Export;
    Encoding = UTF8;
    XmlVersionNo = V10;
    Format = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(xliff)
        {
            textattribute(version)
            {
                trigger OnBeforePassVariable()
                begin
                    version := '1.2';
                end;

            }
            textelement(infile)
            {
                XmlName = 'file';
                textattribute(datatype)
                {
                    trigger OnBeforePassVariable()
                    begin
                        datatype := 'xml';
                    end;
                }
                textattribute("source-language")
                {
                    trigger OnBeforePassVariable()
                    begin
                        "source-language" := SourceTransCode;
                    end;
                }
                textattribute("target-language")
                {
                    trigger OnBeforePassVariable()
                    begin
                        "target-language" := TargetTransCode;
                    end;
                }
                textattribute(original)
                {
                    trigger OnBeforePassVariable()
                    begin
                        original := TransProject.OrginalAttr;
                    end;
                }
                textelement(body)
                {
                    textelement(group)
                    {
                        textattribute(id1)
                        {
                            XmlName = 'id';
                            trigger OnBeforePassVariable()
                            begin
                                id1 := 'body';
                            end;
                        }
                        tableelement(Target; "BCX Translation Target")
                        {
                            XmlName = 'trans-unit';

                            fieldattribute(id; Target."Trans-Unit Id")
                            {
                            }
                            textattribute("size-unit")
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    "size-unit" := Target."size-unit";
                                end;
                            }
                            textattribute(translate)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    translate := Target.TranslateAttr;
                                end;
                            }
                            textattribute("al-object-target")
                            {
                                Occurrence = Optional;
                                trigger OnAfterAssignVariable()
                                begin
                                    target."al-object-target" := "al-object-target";
                                end;
                            }
                            fieldelement(Source; Target.Source)
                            {
                                XmlName = 'source';
                            }
                            fieldelement(Target; Target.Target)
                            {
                                XmlName = 'target';
                            }

                            tableelement(note; "BCX Translation Notes")
                            {
                                LinkTable = Target;
                                LinkFields = "Project Code" = field("Project Code"), "Trans-Unit Id" = field("Trans-Unit Id");

                                fieldattribute(from; note.From)
                                {
                                }
                                fieldattribute(annotates; note.Annotates)
                                {
                                }
                                fieldattribute(priority; note.Priority)
                                {
                                }
                                fieldattribute(note; note.Note)
                                {

                                }
                            }

                        }
                    }
                }
            }
        }
    }

    var
        TransProject: Record "BCX Translation Project";
        ProjectCode: Code[20];
        SourceTransCode: Text[10];
        TargetTransCode: Text[10];
        EquivalentTransCode: Text[10];

    trigger OnPreXmlPort()
    var
        TempFile: Text;
        TargetLanguage: Text;
    begin
        TransProject.Get(target.getfilter("Project Code"));
        TargetLanguage := TargetTransCode;
        TempFile := TransProject."File Name";

        if StrPos(lowercase(TempFile), '.g.xlf') > 0 then
            currXMLport.Filename := CopyStr(TempFile, 1, StrPos(lowercase(TempFile), '.g.xlf')) +
                                     TargetLanguage + '.xlf'
        else
            if StrPos(lowercase(TempFile), '.xlf') > 0 then
                currXMLport.Filename := CopyStr(TempFile, 1, StrPos(lowercase(TempFile), '.xlf')) +
                                         TargetLanguage + '.xlf'
            else
                if StrPos(lowercase(TempFile), '.xlif') > 0 then
                    currXMLport.Filename := CopyStr(TempFile, 1, StrPos(lowercase(TempFile), '.xlif')) +
                                             TargetLanguage + '.xlif';
    end;

    procedure GetFilename(): Text
    begin
        exit(currXMLport.Filename);
    end;


    procedure SetProjectCode(inProjectCode: Code[20]; InSourceLang: Text[10]; InTargetLang: Text[10])
    begin
        SetProjectCode(inProjectCode, InSourceLang, InTargetLang, '');
    end;

    procedure SetProjectCode(inProjectCode: Code[20]; InSourceLang: Text[10]; InTargetLang: Text[10]; InEquivalentLang: Text[10])
    begin
        Target.Reset();
        Target.SetRange("Project Code", inProjectCode);
        Target.SetRange("Target Language ISO code", (InEquivalentLang <> '') ? InEquivalentLang : InTargetLang);
#pragma warning disable AA0206
        ProjectCode := inProjectCode;
#pragma warning restore AA0206
        SourceTransCode := InSourceLang;
        TargetTransCode := InTargetLang;
        EquivalentTransCode := InEquivalentLang;
    end;

}

