pageextension 50501 CustomerLookupExtension50101 extends "Customer Lookup"
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
        modify("Salesperson Code")
        {
            QuickEntry = false;
        }
    }
}
