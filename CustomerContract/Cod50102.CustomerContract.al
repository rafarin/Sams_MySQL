codeunit 50102 "CustomerContract"
{
    TableNo = "Customer Contract Header";

    trigger OnRun()
    begin

    end;

    var
        Contract: Record "Customer Contract Header";
        Line: Record "Customer Contract Line";

    procedure Get(DocNo: Code[20]; var Header: Record "Customer Contract Header"): Boolean
    var
    BEGIN
        Header.SetFilter("No.", DocNo);
        IF (Header.FindFirst()) THEN exit(true);
        Message('Failed to find Customer Contract Header by Document No: ' + DocNo);
        exit(false);
    END;

    procedure SetLineContractNo(DocNo: Code[20]; ContractNo: Code[35]): Boolean
    var
    BEGIN
        Line.SetFilter("Document No.", DocNo);
        IF (Line.FindSet()) THEN begin
            repeat
                Line."Contract No." := ContractNo;
                Line.Modify();
            UNTIL Line.Next() = 0;
            exit(true);
        end;
        exit(false);
    END;

    procedure SetLineCustomerNo(DocNo: Code[20]; CustomerNo: Code[35]): Boolean
    var
    BEGIN
        Line.SetFilter("Document No.", DocNo);
        IF (Line.FindSet()) THEN begin
            repeat
                Line."Sell-to Customer No." := CustomerNo;
                Line.Modify();
            UNTIL Line.Next() = 0;
        end;
        exit(false);
    END;

    procedure IsValidContractDate(Header: Record "Customer Contract Header"): Boolean
    var
    BEGIN
        if (Header."Contract Date" <> 0D) THEN begin
            exit(true);
        end;
        exit(false);
    END;

    procedure isValidExtendDate(var Header: Record "Customer Contract Header"): Boolean;
    var
    begin
        IF (Header."Contract Extend Date" <> 0D) THEN BEGIN
            If (IsValidContractDate(Header)) THEN BEGIN
                if ((Header."Contract Extend Date") <= Header."Contract End Date") THEN begin
                    Clear(Header."Contract Extend Date");
                    exit(false);
                end;
            END;
        END;
        exit(true);
    end;

    procedure isValidStartDate(var Header: Record "Customer Contract Header"): Boolean;
    var
    begin
        if ((Header."Contract Start Date") < Header."Contract Date") THEN begin
            Clear(Header."Contract Start Date");
            exit(false);
        end;
        exit(true);
    end;

    procedure isValidEndDate(var Header: Record "Customer Contract Header"): Boolean;
    var
    begin
        if ((Header."Contract End Date") < Header."Contract Start Date") THEN begin
            Clear(Header."Contract End Date");
            exit(false);
        end;
        exit(true);
    end;

    procedure GetCustomerNo(CustName: Text[100]): Code[10]
    var
        Customer: Record Customer;
        CustNo: Code[10];
        RecordCount: Integer;
    begin
        CustNo := '0';
        Customer.SetFilter(Name, CustName);
        IF (Customer.FindSet()) THEN begin
            repeat
                RecordCount += 1;
                CustNo := Customer."No.";
            until Customer.Next() = 0;
        end;
        IF (RecordCount <> 1) THEN CustNo := '0';
        exit(CustNo);
    end;

    procedure GetCustomerName(CustCode: Code[10]; var CustomerName: Text): Boolean
    var
        Customer: Record Customer;
        RecordCount: Integer;
    begin
        Customer.SetFilter("No.", CustCode);
        IF (Customer.FindSet()) THEN begin
            repeat
                RecordCount += 1;
                CustomerName := Customer.Name;
            until Customer.Next() = 0;
        end;
        if (RecordCount = 1) THEN
            exit(true)
        else begin
            CustomerName := '';
            exit(false);
        end;
    end;

    procedure IsAnyContracts(CustNo: Code[20]): Boolean
    var
    begin
        Clear(Contract);
        if (CustNo <> '') THEN begin
            Contract.SetFilter("Sell-to Customer No.", CustNo);
            IF Contract.FindSet() THEN begin
                exit(true);
            end;
        end;
        exit(false);
    end;

    procedure GetContractLineByEntryNo(EntryNo: Integer; var HeaderLine: Record "Customer Contract Line"): Boolean
    var
        found: Boolean;
    BEGIN
        found := false;
        HeaderLine.SetFilter("No.", FORMAT(EntryNo));
        IF (HeaderLine.FindSet()) THEN begin
            repeat
                IF (HeaderLine."No." = EntryNo) THEN begin
                    exit(true);
                end;
            UNTIL HeaderLine.Next() = 0;
        end;
        exit(found);
    END;

    procedure GetContractByDocumentNo(DocNo: Code[20]; var Header: Record "Customer Contract Header"): Boolean
    var
        found: Boolean;
    BEGIN
        found := false;
        Header.SetFilter("No.", DocNo);
        IF (Header.FindFirst()) THEN found := true;
        exit(found);
    END;
}
