pageextension 78600 "BCX User Card" extends Users
{
    actions
    {
        addfirst(processing)
        {
            action("BCX User Access")
            {
                Caption = 'User Access';
                ApplicationArea = All;
                Image = ServiceAccessories;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BCX User Access";
                RunPageLink = "User Id" = field("User Name");
            }
        }
    }
}