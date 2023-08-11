pageextension 50502 VendorLookupExtension50502 extends "Vendor Lookup"
{
    layout
    {
        modify("Responsibility Center")
        {
            QuickEntry = true;
        }
        modify(Name)
        {
            QuickEntry = true;
        }
        modify("Location Code")
        {
            QuickEntry = false;
        }
        modify("Post Code")
        {
            QuickEntry = false;
        }
        modify(Address)
        {
            QuickEntry = true;
        }
        modify("Phone No.")
        {
            QuickEntry = false;
        }
        modify(Contact)
        {
            QuickEntry = false;
        }
    }
}
