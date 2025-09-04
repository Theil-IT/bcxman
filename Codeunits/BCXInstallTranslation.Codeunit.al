codeunit 78601 "BCX Install Translations"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        UserPersonalization: Record "User Personalization";
        User: Record User;
    begin
        if User.FindSet() then
            repeat
                UserPersonalization.SetRange("User ID", User."User Name");
                if UserPersonalization.IsEmpty then begin
                    // UserPersonalization.Init();
                    // UserPersonalization.Validate("User ID", User."User Name");
                    // UserPersonalization.Validate("Profile ID", 'BCX Translation');
                    // UserPersonalization.Insert();
                end else begin
                    if UserPersonalization.FindSet() then
                        repeat
                            UserPersonalization.Validate("Profile ID", 'BCX Translation');
                            UserPersonalization.Modify();
                        until UserPersonalization.Next() = 0;
                end;
            until user.Next() = 0;

    end;
}