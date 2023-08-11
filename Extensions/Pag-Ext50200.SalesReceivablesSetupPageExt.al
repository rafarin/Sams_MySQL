pageextension 50200 SalesReceivablesSetupPageExt extends "Sales & Receivables Setup"
{
    layout
    {
        addafter("Customer Nos.")
        {
            field("Customer Contract Nos."; Rec."Customer Contract Nos.")
            {
                Caption = 'Customer Contract Nos.';
                ApplicationArea = All;
            }
        }
    }
}