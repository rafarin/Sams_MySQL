tableextension 50203 "Sales InvoiceHeader Ext" extends "Sales Invoice Header"
{
    fields
    {
        field(55001; "Customer Contracts"; Boolean)
        {
            InitValue = false;
        }
    }
    local procedure IsAnyContracts(): Boolean
    var
        Contract: Record "Customer Contract Header";
    begin
        if (Rec."Sell-to Customer No." <> '') THEN begin
            Contract.SetFilter("Sell-to Customer No.", Rec."Sell-to Customer No.");
            IF Contract.FindSet() THEN begin
                exit(true);
            end;
        end;
        exit(false);
    end;

    trigger OnInsert()
    var
    BEGIN
        Validate("Customer Contracts", IsAnyContracts());
    END;

    trigger OnModify()
    var
    BEGIN
        Validate("Customer Contracts", IsAnyContracts());
    END;
}