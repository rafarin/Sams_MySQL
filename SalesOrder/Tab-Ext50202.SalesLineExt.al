tableextension 50202 "Sales Line Ext" extends "Sales Line"
{
    fields
    {
        field(55001; "Contract No."; Code[20])
        {
            InitValue = '';
        }
        field(55002; "Contract Item Entry No."; Integer)
        {
            InitValue = 0;
            TableRelation = "Customer Contract Line";

            trigger OnValidate()
            var
                Contract: Record "Customer Contract Header";
                ContractLine: Record "Customer Contract Line";
                found: Boolean;
            BEGIN
                found := false;
                IF ("Contract Item Entry No." > 0) THEN begin
                    IF (CodeUnitContract.GetContractLineByEntryNo("Contract Item Entry No.", ContractLine)) THEN begin
                        IF (CodeUnitContract.GetContractByDocumentNo(ContractLine."Document No.", Contract)) THEN begin
                            IF (ContractLine."Sell-to Customer No." = "Sell-to Customer No.") THEN BEGIN
                                found := true;
                                Validate(Type, Type::Item);
                                Validate("No.", ContractLine."Related Item");
                                Validate("Unit Price", ContractLine.Price);
                                "Contract Item Description" := ContractLine.Description;
                                "Contract No." := Contract."Contract No.";
                                "Contract Item Entry No." := ContractLine."No.";
                            END
                            ELSE begin
                                Message('Customer doest not have contract on selected item');
                            end;
                        end;
                    end;
                end;

                IF (found = false) THEN begin
                    "Contract No." := '';
                    "Contract Item Description" := '';
                    "Contract Item Entry No." := 0;
                end;
            END;
        }
        field(55003; "Contract Item Description"; Text[64])
        {
            InitValue = '';
        }
    }
    var
        CodeUnitContract: Codeunit CustomerContract;


}