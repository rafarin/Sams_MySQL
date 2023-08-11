tableextension 50200 SalesReceivablesSetupExt extends "Sales & Receivables Setup"
{
    fields
    {
        field(50200; "Customer Contract Nos."; Code[20])
        {
            Caption = 'Customer Contract Nos.';
            TableRelation = "No. Series";
        }
    }
}