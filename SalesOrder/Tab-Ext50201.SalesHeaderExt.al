tableextension 50201 "Sales Header Ext" extends "Sales Header"
{
    fields
    {
        field(55001; "Customer Contracts"; Boolean)
        {
            InitValue = false;
        }
    }

    trigger OnAfterInsert()
    var
        CodeUnitContract: Codeunit CustomerContract;
        IsAnyContracts: Boolean;
    BEGIN
        IF (("Sell-to Customer No." <> '') AND (Rec."Sell-to Customer No." <> xRec."Sell-to Customer No.")) THEN begin
            IsAnyContracts := CodeUnitContract.IsAnyContracts("Sell-to Customer No.");
            "Customer Contracts" := IsAnyContracts;
            Modify(false);
        end;
    END;

    trigger OnAfterModify()
    var
        CodeUnitContract: Codeunit CustomerContract;
        IsAnyContracts: Boolean;
    BEGIN
        IF (("Sell-to Customer No." <> '') AND (Rec."Sell-to Customer No." <> xRec."Sell-to Customer No.")) THEN begin
            IsAnyContracts := CodeUnitContract.IsAnyContracts("Sell-to Customer No.");
            "Customer Contracts" := IsAnyContracts;
            Modify(false);
        end;
    END;

}