codeunit 50120 "InvoiceImport"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var

    begin
        RefreshList('Purchases');
        RefreshList('Sales');
        BackgroundDataUpdate();
        CheckDocuments('Sales', false);
        CheckDocuments('Purchases', false);
    end;

    procedure RefreshList(InvType: Text[20]): Boolean
    var
        CodeUnitSamsMySQL: Codeunit SamsMySQL;
        ListArray: JsonArray;
        ListToken: JsonToken;
        ListLine: JsonObject;
        ResponseText: Text;

        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        FileName: Text[35];
        Location: Code[10];
        InvoiceType: Text[20];
        Department: Text[32];
        status: Text[20];
    BEGIN
        ResponseText := CodeUnitSamsMySQL.MakeRequest('NAV_PrepareData', InvType);
        IF (ResponseText.Contains('failed')) THEN begin
            exit(false);
        end;
        IF (ResponseText.Contains('Empty')) THEN begin
            //Message('No new data found');
            exit(false);
        end;
        if not ListArray.ReadFrom(ResponseText) then begin
            Error('ERROR: RefreshList');
        end
        else begin
            foreach ListToken In ListArray DO begin
                ListLine := ListToken.AsObject();
                DocumentType := GetDocumentType(GetJsonToken(ListLine, 'DocumentType').AsValue().AsText().Trim());
                DocumentNo := GetJsonToken(ListLine, 'DocumentNo').AsValue().AsCode();
                FileName := GetJsonToken(ListLine, 'FileName').AsValue().AsText();
                Location := GetJsonToken(ListLine, 'Location').AsValue().AsCode();
                InvoiceType := GetJsonToken(ListLine, 'InvoiceType').AsValue().AsText();
                Department := GetJsonToken(ListLine, 'Department').AsValue().AsText();
                status := GetJsonToken(ListLine, 'status').AsValue().AsText();
                IF ListLineExists(DocumentType, DocumentNo, false) THEN begin
                    DeleteDocument(DocumentNo, InvoiceType);
                end;
                LineInsert(DocumentType, DocumentNo, FileName, Location, InvoiceType, Department, status);
            end;
        end;
        exit(true);
    END;

    procedure FixSalePurchaseDisabled()
    var
        Item: Record Item;
    BEGIN
        Item.SetFilter("No.", 'Z0*|P0*|T0*|GMT*|GMP*|GMN*|GMD*|GD*|S0*');
        IF Item.FindSet() THEN begin
            repeat
                Item."Sales Blocked" := false;
                Item."Purchasing Blocked" := false;
                Item.Modify(false);
            UNTIL Item.Next() = 0;
        end;
    END;

    procedure FixSalesInvoices()
    var
        SHead: Record "Sales Header";
        SLine: Record "Sales Line";
        ImpHead: Record "S Invoice Import Header";
        IsPosted: Boolean;
        exDocNo: Text;
        status: Text;
        TotalAmountPosted: Decimal;
        DocOk: Boolean;
    BEGIN
        SHead.Reset();
        IF SHead.FindSet() THEN begin
            IsPosted := false;
            REPEAT
                IF IsInvoicePosted('Sales', SHead."External Document No.", SHead."Bill-to Customer No.", TotalAmountPosted) THEN BEGIN
                    ImportList.Reset();
                    ImportList.SetFilter("Document No.", SHead."No.");
                    ImportList.SetFilter("Invoice Type", 'Sales');
                    IF (ImportList.FindFirst()) THEN begin
                        IF (ImportList."Document Type" = SHead."Document Type") THEN begin
                            ImportList.status := 'completed';
                            ImportList.Modify(false);
                        end;
                    end;
                    // Delete
                    SLine.SetFilter("Document No.", SHead."No.");
                    IF (SLine.FindSet()) THEN begin
                        repeat
                            IF (SLine."Document Type" = SHead."Document Type") THEN SLine.Delete();
                        until SLine.Next() = 0;
                    end;
                    SHead.Delete();
                END;
            UNTIL SHead.Next() = 0;
        end;
    END;

    procedure FixPurchasesInvoices()
    var
        PHead: Record "Purchase Header";
        PLine: Record "Purchase Line";
        ImpHead: Record "P Invoice Import Header";
        IsPosted: Boolean;
        exDocNo: Text;
        status: Text;
        TotalAmountPosted: Decimal;
        DocOk: Boolean;
    BEGIN
        PHead.Reset();
        IF PHead.FindSet() THEN begin
            IsPosted := false;
            REPEAT
                IF IsInvoicePosted('Purchases', PHead."Vendor Invoice No.", PHead."Pay-to Vendor No.", TotalAmountPosted) THEN BEGIN
                    ImportList.Reset();
                    ImportList.SetFilter("Document No.", PHead."No.");
                    ImportList.SetFilter("Invoice Type", 'Purchases');
                    IF (ImportList.FindFirst()) THEN begin
                        IF (ImportList."Document Type" = PHead."Document Type") THEN begin
                            ImportList.status := 'completed';
                            ImportList.Modify(false);
                        end;
                    end;
                    // Delete
                    PLine.SetFilter("Document No.", PHead."No.");
                    IF (PLine.FindSet()) THEN begin
                        repeat
                            IF (PLine."Document Type" = PHead."Document Type") THEN PLine.Delete();
                        until PLine.Next() = 0;
                    end;
                    PHead.Delete();
                END;
            UNTIL PHead.Next() = 0;
        end;
    END;

    local procedure GetListDataByDocument(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]; var Department: Text[32]; var FileName: Text[35]): Boolean
    var
    BEGIN
        ImportList.Reset();
        ImportList.SetFilter("Document No.", DocNo);
        ImportList.SetFilter("Invoice Type", InvType);
        IF ImportList.FindSet() THEN begin
            REPEAT
                IF (ImportList."Document Type" = DocType) THEN begin
                    Department := ImportList.Department;
                    FileName := ImportList."File Name";
                    exit(true);
                end;
            UNTIL ImportList.Next() = 0;
        end;
        exit(false);
    END;

    procedure GetData(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]; Department: Text[32]; FileName: Text[35]; delete: Boolean): Boolean
    var
        DataInfo: JsonObject;
        ResponseText: Text;
        CodeUnitSamsMySQL: Codeunit SamsMySQL;
        DocumentLine: JsonObject;
        procResult: Boolean;
        isLoaded: Boolean;
        ImpList: Record "Invoice Import List";
    begin
        IF ((Department = '') AND (FileName = '')) THEN begin
            IF (GetListDataByDocument(DocType, DocNo, InvType, Department, FileName) = false) THEN exit(false);
        end;

        isLoaded := false;
        case InvType of
            'Sales':
                isLoaded := SalesHeaderExists(DocType, DocNo, delete);
            'Purchases':
                isLoaded := PurchasesHeaderExists(DocType, DocNo, delete);
        end;
        IF (isLoaded = true) THEN exit(true);
        Clear(DataInfo);
        DataInfo.Add('DocumentNo', DocNo);
        DataInfo.Add('InvoiceType', InvType);
        DataInfo.Add('Department', Department);
        DataInfo.Add('FileName', FileName);
        DataInfo.WriteTo(ResponseText);
        ResponseText := CodeUnitSamsMySQL.MakeRequest('NAV_GetData', ResponseText);
        Clear(DataInfo);
        IF (ResponseText.Contains('failed')) THEN begin
            exit(false);
        end;
        IF (ResponseText.Contains('Empty')) THEN begin
            exit(false);
        end;
        if not DocumentLine.ReadFrom(ResponseText) then begin
            Error('ERROR: GetData');
        end
        else begin
            case InvType of
                'Sales':
                    procResult := processSales(DocumentLine);
                'Purchases':
                    procResult := processPurchases(DocumentLine);
                else
                    Error('Invalid InvoiceType request');
            end;
        end;
        IF (procResult = true) THEN begin
            ImpList.SetFilter("Document No.", DocNo);
            IF (ImpList.FindFirst()) THEN begin
                ImpList.status := 'imported';
                ImpList.Modify(false);
                IF (SetDBStatus(InvType, DocNo, Department, FileName, 'imported') = false) THEN begin
                    SetDBStatus(InvType, DocNo, Department, FileName, 'imported');
                end;
            end;
        end;
        exit(procResult);
    end;

    local procedure processSales(DocLine: JsonObject): Boolean
    var
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        SellCustomerNo: Code[20];
        BillCustomerNo: Code[20];
        Reference: Text[35];
        ShipCode: Code[10];
        PostingDate: Date;
        DueDate: Date;
        Location: Code[10];
        Dim1: Code[20];
        Dim2: Code[20];
        PricesVAT: Boolean;
        DiscCode: Code[20];
        SalesPersonCode: Code[10];
        DocumentDate: Date;
        ExtDocumentNo: Code[35];
        LTiSAFregister: Enum "LT i.SAF register type LBC";
        LTiSAFInvoiceType: Enum "LT i.SAF Invoice Type LBC";
        LBCiVAZ: Boolean;
        JsonArrayLine: JsonArray;
        JsonTokenLine: JsonToken;
        JsonObjectLine: JsonObject;
        SalesHeader: Record "S Invoice Import Header";
        LineCount: Integer;
        LineCheckTXT: Text;
    BEGIN
        DocumentType := GetDocumentType(GetJsonToken(DocLine, 'Document Type').AsValue().AsText().Trim());
        DocumentNo := GetJsonToken(DocLine, 'No.').AsValue().AsCode();
        SellCustomerNo := GetJsonToken(DocLine, 'Sell-to Customer No.').AsValue().AsCode();
        BillCustomerNo := GetJsonToken(DocLine, 'Bill-to Customer No.').AsValue().AsCode();
        Reference := GetJsonToken(DocLine, 'Your Reference').AsValue().AsText();
        ShipCode := GetJsonToken(DocLine, 'Ship-to Code').AsValue().AsCode();
        PostingDate := StringToDate(GetJsonToken(DocLine, 'Posting Date').AsValue().AsText());
        DueDate := StringToDate(GetJsonToken(DocLine, 'Due Date').AsValue().AsText());
        Location := GetJsonToken(DocLine, 'Location Code').AsValue().AsCode();
        Dim1 := GetJsonToken(DocLine, 'Shortcut Dimension 1 Code').AsValue().AsCode();
        Dim2 := GetJsonToken(DocLine, 'Shortcut Dimension 2 Code').AsValue().AsCode();
        PricesVAT := GetJsonToken(DocLine, 'Prices Including VAT').AsValue().AsBoolean();
        DiscCode := GetJsonToken(DocLine, 'Invoice Disc. Code').AsValue().AsCode();
        SalesPersonCode := GetJsonToken(DocLine, 'Salesperson Code').AsValue().AsCode();
        DocumentDate := StringToDate(GetJsonToken(DocLine, 'Document Date').AsValue().AsText());
        ExtDocumentNo := GetJsonToken(DocLine, 'External Document No.').AsValue().AsCode();
        LTiSAFregister := ISAFRegister(GetJsonToken(DocLine, 'LT i.SAF register enum LBC').AsValue().AsText());
        LTiSAFInvoiceType := ISAFRegisterType(GetJsonToken(DocLine, 'LT i.SAF Invoice Type enum LBC').AsValue().AsText());
        LBCiVAZ := GetJsonToken(DocLine, 'LBC VAZ Include in iVAZ').AsValue().AsBoolean();

        IF (not SalesHeaderExists(DocumentType, DocumentNo, true)) THEN begin
            SalesHeader.Init();
            SalesHeader."Document Type" := DocumentType;
            SalesHeader."Document No." := DocumentNo;
            SalesHeader."Sell-to Customer No." := SellCustomerNo;
            SalesHeader."Bill-to Customer No." := BillCustomerNo;
            SalesHeader."Your Reference" := Reference;
            SalesHeader."Ship-to Code" := ShipCode;
            SalesHeader."Posting Date" := PostingDate;
            SalesHeader."Due Date" := DueDate;
            SalesHeader."Location Code" := Location;
            SalesHeader."Shortcut Dimension 1 Code" := Dim1;
            SalesHeader."Shortcut Dimension 2 Code" := Dim2;
            SalesHeader."Prices Including VAT" := PricesVAT;
            SalesHeader."Invoice Disc. Code" := DiscCode;
            SalesHeader."Salesperson Code" := SalesPersonCode;
            SalesHeader."Document Date" := DocumentDate;
            SalesHeader."External Document No." := ExtDocumentNo;
            SalesHeader."LT i.SAF register enum LBC" := LTiSAFregister;
            SalesHeader."LT i.SAF Invoice Type enum LBC" := LTiSAFInvoiceType;
            SalesHeader."LBC VAZ Include in iVAZ" := LBCiVAZ;
            SalesHeader.Insert();
        end;

        JsonTokenLine := GetJsonToken(DocLine, 'Lines');
        JsonTokenLine.WriteTo(LineCheckTXT);
        IF (LineCheckTXT.Contains('no lines') = false) THEN begin
            JsonObjectLine := GetJsonToken(DocLine, 'Lines').AsObject();
            LineCount := 0;
            WHILE (LineCount > -1) DO begin
                IF (JsonTokenExists(JsonObjectLine, FORMAT(LineCount))) THEN begin
                    JsonTokenLine := GetJsonToken(JsonObjectLine, FORMAT(LineCount));
                    InsertSalesLine(JsonTokenLine.AsObject());
                    LineCount += 1;
                end
                ELSE begin
                    LineCount := -1;
                end;
            end;
        end;
        exit(true);
    END;

    local procedure InsertSalesLine(Line: JsonObject): Boolean
    var
        SalesLine: Record "S Invoice Import Line";
        DocumentType: Enum "Sales Document Type";
        DocumentNo: Code[20];
        LineNo: Integer;
        Type: Enum "Sales Line Type";
        No: Code[20];
        Location: Code[10];
        Measurement: Code[10];
        Quantity: Decimal;
        Price: Decimal;
    BEGIN
        DocumentType := GetDocumentType(GetJsonToken(Line, 'Document Type').AsValue().AsText().Trim());
        DocumentNo := GetJsonToken(Line, 'Document No.').AsValue().AsCode();
        LineNo := GetJsonToken(Line, 'Line No.').AsValue().AsInteger();
        Type := GetItemType(GetJsonToken(Line, 'Type').AsValue().AsText());
        No := GetJsonToken(Line, 'No.').AsValue().AsCode();
        Location := GetJsonToken(Line, 'Location Code').AsValue().AsCode();
        Measurement := GetJsonToken(Line, 'Unit of Measure Code').AsValue().AsCode();
        Quantity := GetJsonToken(Line, 'Quantity').AsValue().AsDecimal();
        Price := GetJsonToken(Line, 'Unit Price').AsValue().AsDecimal();

        IF (SalesLineExists(DocumentType, DocumentNo, LineNo, true) = false) THEN begin
            SalesLine.Init();
            SalesLine."Document Type" := DocumentType;
            SalesLine."Document No." := DocumentNo;
            SalesLine."Line No." := LineNo;
            SalesLine.Type := Type;
            SalesLine."No." := No;
            SalesLine."Location Code" := Location;
            SalesLine."Unit of Measure Code" := Measurement;
            SalesLine.Quantity := Quantity;
            SalesLine."Unit Price" := Price;
            SalesLine.Insert();
        end;
        exit(true);
    END;

    local procedure processPurchases(DocLine: JsonObject): Boolean
    var
        DocumentType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        BuyVendorNo: Code[20];
        PayCustomerNo: Code[20];
        OrderDate: Date;
        PostingDate: Date;
        DueDate: Date;
        Location: Code[10];
        Dim1: Code[20];
        PricesVAT: Boolean;
        VendorInvoiceNo: Code[35];
        MemoNo: Code[35];
        DocumentDate: Date;
        VATReportingDate: Date;
        LTiSAFregister: Enum "LT i.SAF register type LBC";
        LTiSAFInvoiceType: Enum "LT i.SAF Invoice Type LBC";
        LBCiVAZ: Boolean;
        JsonArrayLine: JsonArray;
        JsonTokenLine: JsonToken;
        JsonObjectLine: JsonObject;
        PurchasesHeader: Record "P Invoice Import Header";
        LineCount: Integer;
        LineCheckTXT: Text;
    BEGIN
        DocumentType := GetDocumentType(GetJsonToken(DocLine, 'Document Type').AsValue().AsText().Trim());
        DocumentNo := GetJsonToken(DocLine, 'No.').AsValue().AsCode();
        BuyVendorNo := GetJsonToken(DocLine, 'Buy-from Vendor No.').AsValue().AsCode();
        PayCustomerNo := GetJsonToken(DocLine, 'Pay-to Vendor No.').AsValue().AsCode();
        OrderDate := StringToDate(GetJsonToken(DocLine, 'Order Date').AsValue().AsText());
        PostingDate := StringToDate(GetJsonToken(DocLine, 'Posting Date').AsValue().AsText());
        DueDate := StringToDate(GetJsonToken(DocLine, 'Due Date').AsValue().AsText());
        Location := GetJsonToken(DocLine, 'Location Code').AsValue().AsCode();
        Dim1 := GetJsonToken(DocLine, 'Shortcut Dimension 1 Code').AsValue().AsCode();
        PricesVAT := GetJsonToken(DocLine, 'Prices Including VAT').AsValue().AsBoolean();
        VendorInvoiceNo := GetJsonToken(DocLine, 'Vendor Invoice No.').AsValue().AsCode();
        MemoNo := GetJsonToken(DocLine, 'Cr. Memo No').AsValue().AsCode();
        DocumentDate := StringToDate(GetJsonToken(DocLine, 'Document Date').AsValue().AsText());
        VATReportingDate := StringToDate(GetJsonToken(DocLine, 'VAT Reporting Date').AsValue().AsText());
        LTiSAFregister := ISAFRegister(GetJsonToken(DocLine, 'LT i.SAF register enum LBC').AsValue().AsText());
        LTiSAFInvoiceType := ISAFRegisterType(GetJsonToken(DocLine, 'LT i.SAF Invoice Type enum LBC').AsValue().AsText());
        LBCiVAZ := GetJsonToken(DocLine, 'LBC VAZ Include in iVAZ').AsValue().AsBoolean();

        IF (not PurchasesHeaderExists(DocumentType, DocumentNo, true)) THEN begin
            PurchasesHeader.Init();
            PurchasesHeader."Document Type" := DocumentType;
            PurchasesHeader."Document No." := DocumentNo;
            PurchasesHeader."Buy-from Vendor No." := BuyVendorNo;
            PurchasesHeader."Pay-to Vendor No." := PayCustomerNo;
            PurchasesHeader."Order Date" := OrderDate;
            PurchasesHeader."Posting Date" := PostingDate;
            PurchasesHeader."Due Date" := DueDate;
            PurchasesHeader."Location Code" := Location;
            PurchasesHeader."Shortcut Dimension 1 Code" := Dim1;
            PurchasesHeader."Prices Including VAT" := PricesVAT;
            PurchasesHeader."VAT Reporting Date" := VATReportingDate;
            PurchasesHeader."Vendor Invoice No." := VendorInvoiceNo;
            PurchasesHeader."Cr. Memo No" := MemoNo;
            PurchasesHeader."Document Date" := DocumentDate;
            PurchasesHeader."LT i.SAF register enum LBC" := LTiSAFregister;
            PurchasesHeader."LT i.SAF Invoice Type enum LBC" := LTiSAFInvoiceType;
            PurchasesHeader."LBC VAZ Include in iVAZ" := LBCiVAZ;
            PurchasesHeader.Insert();
        end;

        JsonTokenLine := GetJsonToken(DocLine, 'Lines');
        JsonTokenLine.WriteTo(LineCheckTXT);
        IF (LineCheckTXT.Contains('no lines') = false) THEN begin
            JsonObjectLine := GetJsonToken(DocLine, 'Lines').AsObject();
            LineCount := 0;
            WHILE (LineCount > -1) DO begin
                IF (JsonTokenExists(JsonObjectLine, FORMAT(LineCount))) THEN begin
                    JsonTokenLine := GetJsonToken(JsonObjectLine, FORMAT(LineCount));
                    InsertPurchasesLine(JsonTokenLine.AsObject());
                    LineCount += 1;
                end
                ELSE begin
                    LineCount := -1;
                end;
            end;
        end;
        exit(true);
    END;

    local procedure InsertPurchasesLine(Line: JsonObject): Boolean
    var
        PurchasesLine: Record "P Invoice Import Line";
        DocumentType: Enum "Purchase Document Type";
        DocumentNo: Code[20];
        LineNo: Integer;
        Type: Enum "Purchase Line Type";
        No: Code[20];
        Measurement: Code[10];
        Quantity: Decimal;
        DirectCost: Decimal;
        UnitCost: Decimal;
    BEGIN
        DocumentType := GetDocumentType(GetJsonToken(Line, 'Document Type').AsValue().AsText().Trim());
        DocumentNo := GetJsonToken(Line, 'Document No.').AsValue().AsCode();
        LineNo := GetJsonToken(Line, 'Line No.').AsValue().AsInteger();
        Type := GetItemType(GetJsonToken(Line, 'Type').AsValue().AsText());
        No := GetJsonToken(Line, 'No.').AsValue().AsCode();
        Measurement := GetJsonToken(Line, 'Unit of Measure Code').AsValue().AsCode();
        Quantity := GetJsonToken(Line, 'Quantity').AsValue().AsDecimal();
        DirectCost := GetJsonToken(Line, 'Direct Unit Cost').AsValue().AsDecimal();
        UnitCost := GetJsonToken(Line, 'Unit Cost').AsValue().AsDecimal();
        IF (PurchasesLineExists(DocumentType, DocumentNo, LineNo, true) = false) THEN begin
            PurchasesLine.Init();
            PurchasesLine."Document Type" := DocumentType;
            PurchasesLine."Document No." := DocumentNo;
            PurchasesLine."Line No." := LineNo;
            PurchasesLine.Type := Type;
            PurchasesLine."No." := No;
            PurchasesLine."Unit of Measure Code" := Measurement;
            PurchasesLine.Quantity := Quantity;
            PurchasesLine."Direct Unit Cost" := DirectCost;
            PurchasesLine."Unit Cost" := UnitCost;
            PurchasesLine.Insert();
        end;
        exit(true);
    END;

    local procedure LineInsert(DocType: Enum "Sales Document Type"; DocNo: Code[20]; FName: Text[35]; Location: Code[10]; InvType: Text[20]; Department: Text[32]; status: Text[20])
    var
    BEGIN
        ImportList.Init();
        ImportList."Document Type" := DocType;
        ImportList."Document No." := DocNo;
        ImportList."File Name" := FName;
        ImportList."Location Code" := Location;
        ImportList."Invoice Type" := InvType;
        ImportList.Department := Department;
        ImportList.status := status;
        ImportList.Insert();
    END;

    local procedure SalesHeaderExists(DocType: Enum "Sales Document Type"; DocNo: Code[20]; delete: Boolean): Boolean
    var
        SalesHeader: Record "S Invoice Import Header";
        SalesLine: Record "S Invoice Import Line";
    BEGIN
        SalesHeader.SetFilter("Document No.", DocNo);
        IF SalesHeader.FindSet() THEN begin
            repeat
                IF (SalesHeader."Document Type" = DocType) THEN begin
                    if delete THEN begin
                        SalesLine.SetFilter("Document No.", DocNo);
                        IF SalesLine.FindSet() THEN begin
                            repeat
                                IF (SalesLine."Document Type" = DocType) THEN SalesLine.Delete();
                            until SalesLine.Next() = 0;
                        end;
                        SalesHeader.Delete();
                        exit(false);
                    end;
                    exit(true);
                end;
            UNTIL SalesHeader.Next() = 0;
        end;
        exit(false);
    END;

    local procedure SalesLineExists(DocType: Enum "Sales Document Type"; DocNo: Code[20]; LineNo: Integer; delete: Boolean): Boolean
    var
        SalesLine: Record "S Invoice Import Line";
    BEGIN
        SalesLine.SetFilter("Document No.", DocNo);
        IF SalesLine.FindSet() THEN begin
            repeat
                IF (SalesLine."Document Type" = DocType) THEN begin
                    IF (SalesLine."Line No." = LineNo) THEN begin
                        if delete THEN begin
                            SalesLine.Delete();
                            exit(false);
                        end;
                        exit(true);
                    end;
                end;
            UNTIL SalesLine.Next() = 0;
        end;
        exit(false);
    END;

    local procedure PurchasesHeaderExists(DocType: Enum "Purchase Document Type"; DocNo: Code[20]; delete: Boolean): Boolean
    var
        PurchasesHeader: Record "P Invoice Import Header";
        PurchasesLine: Record "P Invoice Import Line";
    BEGIN
        PurchasesHeader.SetFilter("Document No.", DocNo);
        IF PurchasesHeader.FindSet() THEN begin
            repeat
                IF (PurchasesHeader."Document Type" = DocType) THEN begin
                    if delete THEN begin
                        PurchasesLine.SetFilter("Document No.", DocNo);
                        IF PurchasesLine.FindSet() THEN begin
                            repeat
                                IF (PurchasesLine."Document Type" = DocType) THEN PurchasesLine.Delete();
                            until PurchasesLine.Next() = 0;
                        end;
                        PurchasesHeader.Delete();
                        exit(false);
                    end;
                    exit(true);
                end;
            UNTIL PurchasesHeader.Next() = 0;
        end;
        exit(false);
    END;

    local procedure PurchasesLineExists(DocType: Enum "Purchase Document Type"; DocNo: Code[20]; LineNo: Integer; delete: Boolean): Boolean
    var
        PurchasesLine: Record "P Invoice Import Line";
    BEGIN
        PurchasesLine.SetFilter("Document No.", DocNo);
        IF PurchasesLine.FindSet() THEN begin
            repeat
                IF (PurchasesLine."Document Type" = DocType) THEN begin
                    IF (PurchasesLine."Line No." = LineNo) THEN begin
                        if delete THEN BEGIN
                            PurchasesLine.Delete();
                            exit(false);
                        END;
                        exit(true);
                    end;
                end;
            UNTIL PurchasesLine.Next() = 0;
        end;
        exit(false);
    END;

    local procedure ListLineExists(DocType: Enum "Sales Document Type"; DocNo: Code[20]; Delete: Boolean): Boolean
    var
        existed: Boolean;
    BEGIN
        Clear(ImportList);
        existed := false;
        ImportList.SetFilter("Document No.", DocNo);
        IF ImportList.FindSet() THEN begin
            repeat
                IF (ImportList."Document Type" = DocType) THEN begin
                    IF (Delete = true) THEN ImportList.Delete();
                    existed := true;
                end;
            UNTIL ImportList.Next() = 0;
        end;
        exit(existed);
    END;

    local procedure GetDocumentType(DocType: Text[20]): Enum "Sales Document Type"
    var
    begin
        case DocType of
            'Invoice':
                exit("Sales Document Type"::Invoice);
            'Credit Memo':
                exit("Sales Document Type"::"Credit Memo");
            'Return Order':
                exit("Sales Document Type"::"Return Order");
            'Order':
                exit("Sales Document Type"::Order);
            'Quote':
                exit("Sales Document Type"::Quote);
            'Blanket Order':
                exit("Sales Document Type"::"Blanket Order");
            else
                Error('Invalid Document Type');
        end;
    end;

    local procedure GetItemType(ItemType: Text[20]): Enum "Sales Line Type"
    var
    BEGIN
        case ItemType of
            'Item':
                exit("Sales Line Type"::Item);
            'G/L Account':
                exit("Sales Line Type"::"Fixed Asset");
            'Resource':
                exit("Sales Line Type"::Resource);
            'Fixed Asset':
                exit("Sales Line Type"::"Fixed Asset");
            'Charge (Item)':
                exit("Sales Line Type"::"Charge (Item)");
            else
                Error('Invalid Item Type');
        end;

    END;

    local procedure ISAFRegister(DocType: Text[20]): Enum "LT i.SAF register type LBC"
    var
        SalesHeader: Record "Sales Header";
    begin
        case DocType of
            'Issued':
                exit("LT i.SAF register type LBC"::Issued);
            'Exclude':
                exit("LT i.SAF register type LBC"::Exclude);
            'Received':
                exit("LT i.SAF register type LBC"::Received);
            else
                Error('Invalid ISAFRegister Document Type');
        end;
    end;

    local procedure ISAFRegisterType(DocType: Text[20]): Enum "LT i.SAF Invoice Type LBC"
    var
        SalesHeader: Record "Sales Header";
    begin
        case DocType of
            'Credit':
                exit("LT i.SAF Invoice Type LBC"::Credit);
            'Debit':
                exit("LT i.SAF Invoice Type LBC"::Debit);
            'Invoice':
                exit("LT i.SAF Invoice Type LBC"::Invoice);
            else
                Error('Invalid ISAFRegisterType Document Type');
        end;
    end;

    local procedure StringToDate(Text: Text): Date
    var
        TextToList: List of [Text];
        Day: Integer;
        Month: Integer;
        Year: Integer;
        tmpDate: Date;
    begin
        IF (StrLen(Text) < 6) THEN begin
            Clear(tmpDate);
            exit(tmpDate);
        end;
        TextToList := Text.Split('-');
        Evaluate(Day, TextToList.Get(3));
        Evaluate(Month, TextToList.Get(2));
        Evaluate(Year, TextToList.Get(1));
        exit(DMY2Date(Day, Month, Year));
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    local procedure JsonTokenExists(JsonObject: JsonObject; TokenKey: Text): Boolean;
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(TokenKey, JsonToken) then
            exit(true);
        exit(false);
    end;

    procedure BackgroundDataUpdate()
    var
        Loaded: Boolean;
        DocType: Enum "Sales Document Type";
        DocNo: Code[20];
        InvType: Text[20];
        Dep: Text[32];
        FName: Text[35];
    BEGIN
        Clear(ImportList);
        ImportList.SetFilter(status, 'not_imported');
        IF (ImportList.FindSet()) THEN begin
            REPEAT
                DocType := ImportList."Document Type";
                DocNo := ImportList."Document No.";
                InvType := ImportList."Invoice Type";
                Dep := ImportList.Department;
                FName := ImportList."File Name";
                Loaded := GetData(DocType, DocNo, InvType, Dep, FName, false);
            UNTIL ImportList.Next() = 0;
        end;
    END;

    procedure DeleteAll()
    var
        PHeader: Record "P Invoice Import Header";
        SHeader: Record "S Invoice Import Header";
        PLine: Record "P Invoice Import Line";
        SLine: Record "S Invoice Import Line";
    BEGIN
        Clear(ImportList);
        IF ImportList.FindSet() THEN begin
            ImportList.DeleteAll();
        end;
        IF PHeader.FindSet() THEN PHeader.DeleteAll();
        IF SHeader.FindSet() THEN SHeader.DeleteAll();
        IF SLine.FindSet() THEN SLine.DeleteAll();
        IF PLine.FindSet() THEN PLine.DeleteAll();
    END;

    local procedure SetDBStatus(InvType: Text[20]; DocNo: Code[20]; Dep: Text[32]; FName: Text[35]; status: Text[20]): Boolean
    var
        CodeUnitSamsMySQL: Codeunit SamsMySQL;
        DataInfo: JsonObject;
        ResponseText: Text;
    BEGIN
        Clear(DataInfo);
        DataInfo.Add('DocumentNo', DocNo);
        DataInfo.Add('InvoiceType', InvType);
        DataInfo.Add('Department', Dep);
        DataInfo.Add('FileName', FName);
        DataInfo.Add('status', status);
        DataInfo.WriteTo(ResponseText);
        ResponseText := CodeUnitSamsMySQL.MakeRequest('NAV_SetDBStatus', ResponseText);
        IF (ResponseText.Contains('OK')) THEN begin
            exit(true);
        end;
        exit(false);
    END;

    local procedure GetItemNoByVariant(VariantNo: Code[20]): Code[20]
    var
        ItemVariant: Record "Item Variant";
    BEGIN
        ItemVariant.SetFilter(Code, VariantNo);
        ItemVariant.SetFilter("Item No.", 'Z0*|P0*|T0*|GMT*|GMP*|GMN*|GMD*|GD*|S0*');
        IF (ItemVariant.FindSet()) THEN begin
            repeat
                IF (ItemVariant.Code = VariantNo) THEN exit(ItemVariant."Item No.");
            UNTIL ItemVariant.Next() = 0;
        end;
        exit('');
    END;

    local procedure CustomerExists(CustNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    BEGIN
        Customer.SetFilter("No.", CustNo);
        IF Customer.FindSet() THEN begin
            repeat
                IF (Customer."No." = CustNo) THEN exit(true);
            until Customer.Next() = 0;
        end;
        exit(false);
    END;

    local procedure CustomerBlocked(CustNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    BEGIN
        Customer.SetFilter("No.", CustNo);
        IF Customer.FindSet() THEN begin
            repeat
                IF (Customer."No." = CustNo) THEN exit(Customer.Blocked <> Customer.Blocked::" ");
            until Customer.Next() = 0;
        end;
        exit(false);
    END;

    local procedure VendorExists(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    BEGIN
        Vendor.SetFilter("No.", VendorNo);
        IF (Vendor.FindSet()) THEN begin
            repeat
                IF (Vendor."No." = VendorNo) then exit(true);
            UNTIL Vendor.Next() = 0;
        end;
        exit(false);
    END;

    local procedure VendorBlocked(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    BEGIN
        Vendor.SetFilter("No.", VendorNo);
        IF (Vendor.FindSet()) THEN begin
            repeat
                IF (Vendor."No." = VendorNo) THEN exit(Vendor.Blocked <> Vendor.Blocked::" ");
            UNTIL Vendor.Next() = 0;
        end;
        exit(false);
    END;

    local procedure ItemBlocked(ItemNo: Code[20]; var Measurement: Code[10]): Boolean
    var
        Item: Record Item;
    BEGIN
        Item.SetFilter("No.", ItemNo);
        IF Item.FindFirst() THEN begin
            IF (Item."Base Unit of Measure" <> Measurement) THEN begin
                IF (ItemMeasurementExists(ItemNo, Measurement) = false) then Measurement := Item."Base Unit of Measure";
            end
            else begin
                Measurement := Item."Base Unit of Measure";
            end;
            IF (Item.Blocked = true) THEN exit(true);
            IF (Item."Sales Blocked" = true) THEN exit(true);
            IF (Item."Purchasing Blocked" = true) THEN exit(true);
        end;
        exit(false);
    END;

    local procedure ItemMeasurementExists(ItemNo: Code[20]; var Measurement: Code[10]): Boolean
    var
        MeasureRec: Record "Item Unit of Measure";
    BEGIN
        MeasureRec.SetFilter("Item No.", ItemNo);
        IF (MeasureRec.FindSet()) THEN begin
            repeat
                IF (MeasureRec.Code = Measurement) THEN begin
                    Measurement := MeasureRec.Code;
                    exit(true);
                end;
            UNTIL MeasureRec.Next() = 0;
        end;
        Measurement := '';
        exit(false);
    END;

    procedure InsertDocuments(InvType: Text[20]): Boolean
    var
    BEGIN
        Clear(ImportList);
        ImportList.SetFilter(status, 'checked');
        ImportList.SetFilter("Invoice Type", InvType);
        IF ImportList.FindSet() THEN begin
            case InvType of
                'Sales':
                    begin
                        repeat
                            IF InsertSaleDocument(ImportList."Document Type", ImportList."Document No.") then BEGIN
                                ImportList.status := 'completed';
                                ImportList.Modify(true);
                            END;
                        until ImportList.Next() = 0;
                    end;
                'Purchases':
                    begin
                        repeat
                            IF InsertPurchaseDocument(ImportList."Document Type", ImportList."Document No.") then BEGIN
                                ImportList.status := 'completed';
                                ImportList.Modify(true);
                            END;
                        until ImportList.Next() = 0;
                    end;
            end;
        end;
        exit(true);
    END;

    local procedure InsertSaleDocument(DocType: Enum "Sales Document Type"; DocNo: Code[20]): Boolean
    var
        ImpHead: Record "S Invoice Import Header";
        ImpLine: Record "S Invoice Import Line";
        SalesHead: Record "Sales Header";
        SalesLine: Record "Sales Line";
        TotalCost: Decimal;
    BEGIN
        SalesLine.SetFilter("Document No.", DocNo);
        IF SalesLine.FindSet() THEN SalesLine.DeleteAll();
        SalesHead.SetFilter("No.", DocNo);
        IF SalesHead.FindFirst() THEN SalesHead.Delete();

        ImpHead.SetFilter("Document No.", DocNo);
        IF (ImpHead.FindFirst() = false) THEN exit(false);

        SalesHead.Init();
        SalesHead.Validate("Document Type", ImpHead."Document Type");
        SalesHead."No." := ImpHead."Document No.";
        SalesHead.Insert(true);

        SalesHead.Validate("Sell-to Customer No.", ImpHead."Sell-to Customer No.");
        SalesHead.Validate("Bill-to Customer No.", ImpHead."Bill-to Customer No.");
        SalesHead."Posting Date" := ImpHead."Posting Date";
        SalesHead."Your Reference" := ImpHead."Your Reference";
        SalesHead."Ship-to Code" := ImpHead."Ship-to Code";
        SalesHead."Due Date" := ImpHead."Due Date";
        SalesHead."Location Code" := ImpHead."Location Code";
        SalesHead.Validate("Shortcut Dimension 1 Code", ImpHead."Shortcut Dimension 1 Code");
        SalesHead.Validate("Shortcut Dimension 2 Code", ImpHead."Shortcut Dimension 2 Code");
        SalesHead."Prices Including VAT" := ImpHead."Prices Including VAT";
        SalesHead."Invoice Disc. Code" := ImpHead."Invoice Disc. Code";
        SalesHead."Salesperson Code" := ImpHead."Salesperson Code";
        SalesHead."Document Date" := ImpHead."Document Date";
        SalesHead."External Document No." := ImpHead."External Document No.";
        SalesHead."VAT Reporting Date" := ImpHead."Posting Date";
        SalesHead."Shipment Date" := ImpHead."Posting Date";
        SalesHead."LT i.SAF register LBC" := ImpHead."LT i.SAF register enum LBC";
        SalesHead."LT i.SAF Invoice Type LBC" := ImpHead."LT i.SAF Invoice Type enum LBC";
        SalesHead."LBC VAZ Include in iVAZ" := ImpHead."LBC VAZ Include in iVAZ";
        SalesHead.Modify(true);

        ImpLine.SetFilter("Document No.", DocNo);
        TotalCost := 0.0;
        IF (ImpLine.FindSet()) THEN begin
            REPEAT
                SalesLine.Init();
                SalesLine.Validate("Document Type", ImpLine."Document Type");
                SalesLine."Document No." := ImpLine."Document No.";
                SalesLine."Line No." := ImpLine."Line No." * 10000;
                SalesLine.Insert(true);
                SalesLine.Type := ImpLine.Type;
                SalesLine.Validate("No.", ImpLine."DynamicsNo");
                SalesLine."Location Code" := ImpLine."Location Code";
                SalesLine."Unit of Measure Code" := ImpLine."Unit of Measure Code";
                SalesLine.Validate("Quantity", ImpLine."Quantity");
                SalesLine.Validate("Unit Price", ImpLine."Unit Price");
                SalesLine.Modify(true);
                TotalCost += (ImpLine."Unit Price" * ImpLine."Quantity");
            UNTIL ImpLine.Next() = 0;
        end;

        IF (TotalCost > 0.0) THEN BEGIN
            IF (IsCustomerVATPayer(ImpHead."Bill-to Customer No.") = false) then
                SalesHead."LT i.SAF register LBC" := SalesHead."LT i.SAF register LBC"::Exclude
            else
                SalesHead."LT i.SAF register LBC" := SalesHead."LT i.SAF register LBC"::Received;
        END
        else
            SalesHead."LT i.SAF register LBC" := SalesHead."LT i.SAF register LBC"::Exclude;
        SalesHead.Modify(false);
        exit(true);
    END;

    local procedure InsertPurchaseDocument(DocType: Enum "Purchase Document Type"; DocNo: Code[20]): Boolean
    var
        ImpHead: Record "P Invoice Import Header";
        ImpLine: Record "P Invoice Import Line";
        PurHead: Record "Purchase Header";
        PurLine: Record "Purchase Line";
        TotalCost: Decimal;
    BEGIN
        PurLine.SetFilter("Document No.", DocNo);
        IF PurLine.FindSet() THEN PurLine.DeleteAll();
        PurHead.SetFilter("No.", DocNo);
        IF PurHead.FindFirst() THEN PurHead.Delete();

        ImpHead.SetFilter("Document No.", DocNo);
        IF (ImpHead.FindFirst() = false) THEN exit(false);

        PurHead.Init();
        PurHead.Validate("Document Type", ImpHead."Document Type");
        PurHead."No." := ImpHead."Document No.";
        PurHead.Insert(true);

        PurHead.Validate("Buy-from Vendor No.", ImpHead."Buy-from Vendor No.");
        PurHead.Validate("Pay-to Vendor No.", ImpHead."Pay-to Vendor No.");
        PurHead."Order Date" := ImpHead."Order Date";
        PurHead."Posting Date" := ImpHead."Posting Date";
        PurHead."Due Date" := ImpHead."Due Date";
        PurHead."Location Code" := ImpHead."Location Code";
        PurHead.Validate("Shortcut Dimension 1 Code", ImpHead."Shortcut Dimension 1 Code");
        PurHead."Prices Including VAT" := ImpHead."Prices Including VAT";
        PurHead."Vendor Cr. Memo No." := ImpHead."Cr. Memo No";
        PurHead."Vendor Invoice No." := ImpHead."Vendor Invoice No.";
        PurHead."Document Date" := ImpHead."Document Date";
        PurHead."VAT Reporting Date" := ImpHead."VAT Reporting Date";
        PurHead."LT i.SAF Invoice Type enum LBC" := ImpHead."LT i.SAF Invoice Type enum LBC";
        PurHead."LBC VAZ Include in iVAZ" := ImpHead."LBC VAZ Include in iVAZ";
        PurHead.Modify(true);

        ImpLine.SetFilter("Document No.", DocNo);
        TotalCost := 0.0;
        IF (ImpLine.FindSet()) THEN begin
            REPEAT
                PurLine.Init();
                PurLine.Validate("Document Type", ImpLine."Document Type");
                PurLine."Document No." := ImpLine."Document No.";
                PurLine."Line No." := ImpLine."Line No." * 10000;
                PurLine.Insert(true);
                PurLine.Type := ImpLine.Type;
                PurLine.Validate("No.", ImpLine."DynamicsNo");
                PurLine."Unit of Measure Code" := ImpLine."Unit of Measure Code";
                PurLine.Validate("Quantity", ImpLine."Quantity");
                PurLine.Validate("Direct Unit Cost", ImpLine."Direct Unit Cost");
                PurLine.Validate("Unit Cost", ImpLine."Unit Cost");
                PurLine.Modify(true);
                TotalCost += (ImpLine."Unit Cost" * ImpLine."Quantity");
            UNTIL ImpLine.Next() = 0;
        end;
        IF (TotalCost > 0.0) THEN BEGIN
            IF (IsVendorVATPayer(ImpHead."Pay-to Vendor No.") = false) then
                PurHead."LT i.SAF register enum LBC" := PurHead."LT i.SAF register enum LBC"::Exclude
            else
                PurHead."LT i.SAF register enum LBC" := PurHead."LT i.SAF register enum LBC"::Received;
        END
        else
            PurHead."LT i.SAF register enum LBC" := PurHead."LT i.SAF register enum LBC"::Exclude;
        PurHead.Modify(false);
        exit(true);
    END;

    local procedure IsCustomerVATPayer(CustNo: Code[20]): Boolean
    var
        Customer: Record Customer;
    begin
        Customer.SetFilter("No.", CustNo);
        IF Customer.FindFirst() THEN begin
            IF (Customer."VAT Registration No." = 'ND') THEN
                exit(false)
            else
                exit(true);
        end;
        exit(true);
    end;

    local procedure IsVendorVATPayer(VendorNo: Code[20]): Boolean
    var
        Vendor: Record Vendor;
    begin
        Vendor.SetFilter("No.", VendorNo);
        IF Vendor.FindFirst() THEN begin
            IF (Vendor."VAT Registration No." = 'ND') THEN
                exit(false)
            else
                exit(true);
        end;
        exit(true);
    end;

    procedure CheckDocuments(InvType: Text[20]; ForceCheck: Boolean): Boolean
    var
        DocOk: Boolean;
        SalesHead: Record "S Invoice Import Header";
        PurchasesHead: Record "P Invoice Import Header";
        ImpList: Record "Invoice Import List";
    begin
        ClearErrors(InvType);
        Clear(ImpList);
        DocOk := false;
        ImpList.SetFilter("Invoice Type", InvType);
        IF (ForceCheck) THEN
            ImpList.SetFilter(status, 'imported|error|checked|no_lines')
        else
            ImpList.SetFilter(status, 'imported|error');
        IF ImpList.FindSet() THEN begin
            repeat
                case InvType of
                    'Sales':
                        begin
                            IF GetSalesHeader(ImpList."Document No.", SalesHead) THEN begin
                                DocOk := CheckSalesDocument(SalesHead);
                                IF DocOk THEN
                                    ImpList.status := 'checked'
                                else
                                    ImpList.status := 'error';
                                ImpList.Modify(false);
                            end;
                        end;
                    'Purchases':
                        begin
                            IF GetPurchasesHeader(ImpList."Document No.", PurchasesHead) THEN begin
                                DocOk := CheckPurchasesDocument(PurchasesHead);
                                IF (DocOk) THEN
                                    ImpList.status := 'checked'
                                else
                                    ImpList.status := 'error';
                                ImpList.Modify(false);
                            end;
                        end;
                END;
            UNTIL ImpList.Next() = 0;
        end;

    end;

    local procedure InsertErrors(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]; ErrorMsg: Text[100])
    var
        RecError: Record "Invoice Import Error";
    begin
        RecError.Init();
        RecError."No." := GetNo();
        RecError."Document Type" := DocType;
        RecError."Document No." := DocNo;
        RecError."Invoice Type" := InvType;
        RecError.Message := ErrorMsg;
        RecError.Insert();

    end;

    local procedure ClearErrors(InvType: Text[20])
    var
        RecError: Record "Invoice Import Error";
    BEGIN
        RecError.SetFilter("Invoice Type", InvType);
        IF (RecError.FindSet()) THEN RecError.DeleteAll();
    END;

    local procedure ClearDocumentErrors(InvType: Text[20]; DocNo: Code[20])
    var
        RecError: Record "Invoice Import Error";
    BEGIN
        RecError.SetFilter("Invoice Type", InvType);
        RecError.SetFilter("Document No.", DocNo);
        IF (RecError.FindSet()) THEN RecError.DeleteAll();
    END;

    local procedure GetNo(): BigInteger
    var
        Line: Record "Invoice Import Error";
        LastNumber: BigInteger;
    BEGIN
        LastNumber := 0;
        IF Line.FindLast() THEN begin
            LastNumber := Line."No.";
        end;
        exit(LastNumber + 1);
    END;

    local procedure GetSalesHeader(DocNo: Code[20]; var Head: Record "S Invoice Import Header"): Boolean
    var
    BEGIN
        Clear(Head);
        Head.SetFilter("Document No.", DocNo);
        IF Head.FindFirst() THEN exit(true);
        exit(false);
    END;

    local procedure GetPurchasesHeader(DocNo: Code[20]; var Head: Record "P Invoice Import Header"): Boolean
    var
    BEGIN
        Clear(Head);
        Head.SetFilter("Document No.", DocNo);
        IF Head.FindFirst() THEN exit(true);
        exit(false);
    END;

    procedure CheckSalesDocument(Header: Record "S Invoice Import Header"): Boolean
    var
        isError: Boolean;
        LineOk: Boolean;
        Line: Record "S Invoice Import Line";
        TotalAmountPosted: Decimal;
        TotalAmountImport: Decimal;
        ErrorText: Text[100];
    BEGIN
        Clear(Line);
        isError := false;
        Line.SetFilter("Document No.", Header."Document No.");
        IF Line.FindSet() THEN begin
            repeat
                LineOk := CheckSalesLine(Line);
                IF (LineOk = false) THEN isError := true;
            UNTIL Line.Next() = 0;
        end
        else begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Sales', Header."Document No." + ' dokumentas neturi eilučių');
            isError := true;
        end;

        IF (Header."Document Type" = Header."Document Type"::Invoice) THEN BEGIN
            IF (IsInvoicePosted('Sales', Header."External Document No.", Header."Bill-to Customer No.", TotalAmountPosted)) THEN BEGIN
                TotalAmountImport := 0.0;
                Line.SetFilter("Document No.", Header."Document No.");
                IF Line.FindSet() THEN begin
                    repeat
                        TotalAmountImport += (Line."Unit Price" * Line.Quantity);
                    UNTIL Line.Next() = 0;
                end;
                LineOk := IsSalesInvoiceMatch(Header);
                ErrorText := 'Dok. jau užreg. ' + Header."External Document No." + ' (suma ' + FORMAT(TotalAmountPosted) + '). ' +
                    'Imp. dok. suma: ' + FORMAT(TotalAmountImport) + '.';
                IF (LineOk) THEN
                    ErrorText += ' Sumos ir kiekiai vienodi.'
                else
                    ErrorText += ' Sumos ir/ar kiekiai skiriasi';
                InsertErrors(Header."Document Type", Header."Document No.", 'Sales', ErrorText);
                exit(false);
            end;
        END;

        IF (CustomerExists(Header."Bill-to Customer No.") = false) then begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Sales', 'Mokėtojo kodas nerastas: ' + Header."Bill-to Customer No.");
            isError := true;
        end
        else begin
            IF (CustomerBlocked(Header."Bill-to Customer No.")) THEN begin
                InsertErrors(Header."Document Type", Header."Document No.", 'Sales', 'Mokėtojas blokuotas: ' + Header."Bill-to Customer No.");
                isError := true;
            end;
        end;

        IF (CustomerExists(Header."Sell-to Customer No.") = false) then begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Sales', 'Gavėjas kodas nerastas: ' + Header."Sell-to Customer No.");
            isError := true;
        end
        else begin
            IF (CustomerBlocked(Header."Sell-to Customer No.")) THEN begin
                InsertErrors(Header."Document Type", Header."Document No.", 'Sales', 'Gavėjas blokuotas: ' + Header."Sell-to Customer No.");
                isError := true;
            end;
        end;
        IF isError THEN exit(false);
        exit(true);
    END;

    local procedure CheckSalesLine(var Line: Record "S Invoice Import Line"): Boolean
    var
        ItemNo: Code[20];
        MeasurementBC: Code[10];
    BEGIN
        ItemNo := GetItemNoByVariant(Line."No.");
        IF (ItemNo = '') THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Sales', 'Nerastas prekės ryšys pagal kodą ' + Line."No.");
            exit(false);
        end;
        Line.DynamicsNo := ItemNo;
        Line.Modify(false);
        MeasurementBC := Line."Unit of Measure Code";
        IF (ItemBlocked(ItemNo, MeasurementBC)) THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Sales', 'Prekė arba jos pirkimas/pardavimas blokuotas: ' + ItemNo);
            exit(false);
        end;
        IF (Line."Unit of Measure Code" <> MeasurementBC) THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Sales',
                'Mato vnt. nesutampa: ' + Line."No." + ' (' + Line."Unit of Measure Code" + ') su ' + ItemNo + ' (' + MeasurementBC + ')');
            exit(false);
        end;
        exit(true);
    END;

    local procedure CheckPurchasesDocument(Header: Record "P Invoice Import Header"): Boolean
    var
        isError: Boolean;
        LineOk: Boolean;
        Line: Record "P Invoice Import Line";
        SalesLine: Record "Sales Invoice Line";
        TotalAmountPosted: Decimal;
        TotalAmountImport: Decimal;
        ErrorText: Text[100];
    BEGIN
        Clear(Line);
        isError := false;
        Line.SetFilter("Document No.", Header."Document No.");
        IF Line.FindSet() THEN begin
            repeat
                LineOk := CheckPurchasesLine(Line);
                IF (LineOk = false) THEN isError := true;
            UNTIL Line.Next() = 0;
        end
        else begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', Header."Document No." + ' dokumentas neturi eilučių');
            isError := true;
        end;
        IF (Header."Document Type" = Header."Document Type"::Invoice) THEN BEGIN
            IF (IsInvoicePosted('Purchases', Header."Vendor Invoice No.", Header."Pay-to Vendor No.", TotalAmountPosted)) THEN begin
                TotalAmountImport := 0.0;
                Line.SetFilter("Document No.", Header."Document No.");
                IF Line.FindSet() THEN begin
                    repeat
                        TotalAmountImport += (Line."Unit Cost" * Line.Quantity);
                    UNTIL Line.Next() = 0;
                end;
                LineOk := IsPurchasesInvoiceMatch(Header);
                ErrorText := 'Dok. jau užreg. ' + Header."Vendor Invoice No." + ' (suma ' + FORMAT(TotalAmountPosted) + '). ' +
                    'Imp. dok. suma: ' + FORMAT(TotalAmountImport) + '.';

                IF (LineOk) THEN
                    ErrorText += ' Sumos ir kiekiai vienodi.'
                else
                    ErrorText += ' Sumos ir/ar kiekiai skiriasi';
                InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', ErrorText);
                exit(false);
            end;
        END;

        IF (VendorExists(Header."Pay-to Vendor No.") = false) then begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', 'Tiekėjo kodas nerastas: ' + Header."Pay-to Vendor No.");
            isError := true;
        end
        else begin
            IF (VendorBlocked(Header."Pay-to Vendor No.")) THEN begin
                InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', 'Tiekėjas blokuotas: ' + Header."Pay-to Vendor No.");
                isError := true;
            end;
        end;

        IF (VendorExists(Header."Buy-from Vendor No.") = false) then begin
            InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', 'Tiekėjo kodas nerastas: ' + Header."Buy-from Vendor No.");
            isError := true;
        end
        else begin
            IF (VendorBlocked(Header."Buy-from Vendor No.")) THEN begin
                InsertErrors(Header."Document Type", Header."Document No.", 'Purchases', 'Tiekėjas blokuotas: ' + Header."Buy-from Vendor No.");
                isError := true;
            end;
        end;

        exit(isError = false);
    END;

    local procedure CheckPurchasesLine(var Line: Record "P Invoice Import Line"): Boolean
    var
        ItemNo: Code[20];
        MeasurementBC: Code[10];
    BEGIN
        ItemNo := GetItemNoByVariant(Line."No.");
        IF (ItemNo = '') THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Purchases', 'Nerastas prekės ryšys pagal kodą ' + Line."No.");
            exit(false);
        end;
        Line.DynamicsNo := ItemNo;
        Line.Modify(false);
        MeasurementBC := Line."Unit of Measure Code";
        IF (ItemBlocked(ItemNo, MeasurementBC)) THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Purchases', 'Prekė arba jos pirkimas/pardavimas blokuotas: ' + ItemNo);
            exit(false);
        end;
        IF (Line."Unit of Measure Code" <> MeasurementBC) THEN begin
            InsertErrors(Line."Document Type", Line."Document No.", 'Purchases',
                'Mato vnt. nesutampa: ' + Line."No." + ' (' + Line."Unit of Measure Code" + ') su ' + ItemNo + ' (' + MeasurementBC + ')');
            exit(false);
        end;
        exit(true);
    END;

    local procedure IsSalesInvoiceMatch(ImpHead: Record "S Invoice Import Header"): Boolean
    var
        SPostHeader: Record "Sales Invoice Header";
        SPostLine: Record "Sales Invoice Line";
        ImpLine: Record "S Invoice Import Line";
        PostCount: Integer;
        ImpCount: Integer;
        IsMatch: Boolean;
        PostCodes: List of [Code[20]];
        PostCounts: List of [Integer];
        PostTotals: List of [Decimal];
        ItemCount: Integer;
        ItemTotalPrice: Decimal;
        Index: Integer;
    BEGIN
        Clear(PostCodes);
        Clear(PostCounts);
        PostCount := 0;
        ImpCount := 0;
        Index := 0;
        IsMatch := true;
        SPostHeader.SetFilter("External Document No.", ImpHead."External Document No.");
        SPostHeader.SetFilter("Bill-to Customer No.", ImpHead."Bill-to Customer No.");
        IF SPostHeader.FindSet() THEN begin
            repeat
                IF ((SPostHeader.Cancelled = false) AND (SPostHeader."LT i.SAF Invoice Type LBC" = SPostHeader."LT i.SAF Invoice Type LBC"::Invoice)) THEN BEGIN
                    SPostLine.SetFilter("Document No.", SPostHeader."No.");
                    IF SPostLine.FindSet() THEN begin
                        repeat
                            PostCount += 1;
                            Index := PostCodes.IndexOf(SPostLine."No.");
                            IF (Index > 0) THEN begin
                                PostCounts.Set(Index, PostCounts.Get(Index) + 1);
                                PostTotals.Set(Index, PostTotals.Get(Index) + (SPostLine."Unit Price" * SPostLine.Quantity));
                            end
                            else begin
                                PostCodes.Add(SPostLine."No.");
                                PostCounts.Add(1);
                                PostTotals.Add(SPostLine."Unit Price" * SPostLine.Quantity);
                            end;
                        UNTIL SPostLine.Next() = 0;
                    end;
                END;
            UNTIL SPostHeader.Next() = 0;
        end;
        ImpLine.SetFilter("Document No.", ImpHead."Document No.");
        IF (ImpLine.FindSet()) THEN begin
            repeat
                ImpCount += 1;
                IF (ImpLine."Document No." <> '') THEN BEGIN
                    IF (FindImportLineTotalItemPrice('Sales', ImpLine."Document No.", ImpLine.DynamicsNo, ItemCount, ItemTotalPrice)) THEN BEGIN
                        Index := PostCodes.IndexOf(ImpLine.DynamicsNo);
                        IF (Index > 0) THEN begin
                            IF (ItemCount <> PostCounts.Get(Index)) THEN IsMatch := false;
                            IF (ItemTotalPrice <> PostTotals.Get(Index)) THEN IsMatch := false;
                        end
                        else
                            IsMatch := false;
                    END;
                END
                ELSE
                    IsMatch := false;
            UNTIL ImpLine.Next() = 0;
        end;
        if (ImpCount <> PostCount) THEN IsMatch := false;
        exit(IsMatch);
    END;

    local procedure IsPurchasesInvoiceMatch(ImpHead: Record "P Invoice Import Header"): Boolean
    var
        PPostHeader: Record "Purch. Inv. Header";
        PPostLine: Record "Purch. Inv. Line";
        ImpLine: Record "P Invoice Import Line";
        PostCount: Integer;
        ImpCount: Integer;
        IsMatch: Boolean;
        PostCodes: List of [Code[20]];
        PostCounts: List of [Integer];
        PostTotals: List of [Decimal];
        ItemCount: Integer;
        ItemTotalPrice: Decimal;
        Index: Integer;
    BEGIN
        Clear(PostCodes);
        Clear(PostCounts);
        PostCount := 0;
        ImpCount := 0;
        Index := 0;
        IsMatch := true;
        PPostHeader.SetFilter("Vendor Invoice No.", ImpHead."Vendor Invoice No.");
        PPostHeader.SetFilter("Pay-to Vendor No.", ImpHead."Pay-to Vendor No.");
        IF PPostHeader.FindSet() THEN begin
            repeat
                IF ((PPostHeader.Cancelled = false) AND (PPostHeader."LT i.SAF Invoice Type enum LBC" = PPostHeader."LT i.SAF Invoice Type enum LBC"::Invoice)) THEN BEGIN
                    PPostLine.SetFilter("Document No.", PPostHeader."No.");
                    IF PPostLine.FindSet() THEN begin
                        repeat
                            PostCount += 1;
                            Index := PostCodes.IndexOf(PPostLine."No.");
                            IF (Index > 0) THEN begin
                                PostCounts.Set(Index, PostCounts.Get(Index) + 1);
                                PostTotals.Set(Index, PostTotals.Get(Index) + (PPostLine."Unit Cost" * PPostLine.Quantity));
                            end
                            else begin
                                PostCodes.Add(PPostLine."No.");
                                PostCounts.Add(1);
                                PostTotals.Add(PPostLine."Unit Cost" * PPostLine.Quantity);
                            end;
                        UNTIL PPostLine.Next() = 0;
                    end;
                END;
            UNTIL PPostHeader.Next() = 0;
        end;
        ImpLine.SetFilter("Document No.", ImpHead."Document No.");
        IF (ImpLine.FindSet()) THEN begin
            repeat
                ImpCount += 1;
                IF (ImpLine."Document No." <> '') THEN BEGIN
                    IF (FindImportLineTotalItemPrice('Purchases', ImpLine."Document No.", ImpLine.DynamicsNo, ItemCount, ItemTotalPrice)) THEN BEGIN
                        Index := PostCodes.IndexOf(ImpLine.DynamicsNo);
                        IF (Index > 0) THEN begin
                            IF (ItemCount <> PostCounts.Get(Index)) THEN IsMatch := false;
                            IF (ItemTotalPrice <> PostTotals.Get(Index)) THEN IsMatch := false;
                        end
                        else
                            IsMatch := false;
                    END;
                END
                ELSE
                    IsMatch := false;
            UNTIL ImpLine.Next() = 0;
        end;
        if (ImpCount <> PostCount) THEN IsMatch := false;
        exit(IsMatch);
    END;

    local procedure FindImportLineTotalItemPrice(InvType: Text[20]; DocNo: Code[20]; ItemNo: Code[20]; var ItemCount: Integer; var ItemTotalPrice: Decimal): Boolean
    var
        ImpLineS: Record "S Invoice Import Line";
        ImpLineP: Record "P Invoice Import Line";
        found: Boolean;
    BEGIN
        ItemCount := 0;
        ItemTotalPrice := 0.0;
        found := false;
        case InvType of
            'Sales':
                begin
                    ImpLineS.SetFilter("Document No.", DocNo);
                    ImpLineS.SetFilter(DynamicsNo, ItemNo);
                    IF ImpLineS.FindSet() THEN begin
                        repeat
                            IF (ImpLineS.DynamicsNo = ItemNo) THEN begin
                                found := true;
                                ItemCount += 1;
                                ItemTotalPrice += (ImpLineS."Unit Price" * ImpLineS.Quantity);
                            end;
                        UNTIL ImpLineS.Next() = 0;
                    end;
                end;
            'Purchases':
                begin
                    ImpLineP.SetFilter("Document No.", DocNo);
                    ImpLineP.SetFilter(DynamicsNo, ItemNo);
                    IF ImpLineP.FindSet() THEN begin
                        repeat
                            IF (ImpLineP.DynamicsNo = ItemNo) THEN begin
                                found := true;
                                ItemCount += 1;
                                ItemTotalPrice += (ImpLineP."Unit Cost" * ImpLineP.Quantity);
                            end;
                        UNTIL ImpLineP.Next() = 0;
                    end;
                end;
        end;
        exit(found);
    END;

    local procedure IsInvoicePosted(InvType: Text[20]; exDocNo: Code[35]; CustNo: Code[20]; var TotalAmount: Decimal): Boolean
    var
        SPostHeader: Record "Sales Invoice Header";
        SPostLine: Record "Sales Invoice Line";
        PPostHeader: Record "Purch. Inv. Header";
        PPostLine: Record "Purch. Inv. Line";
        HeadFound: Boolean;
    BEGIN
        TotalAmount := 0.0;
        HeadFound := false;
        IF (StrLen(exDocNo) < 2) THEN exit(false);
        case InvType of
            'Sales':
                begin
                    SPostHeader.SetFilter("External Document No.", exDocNo);
                    SPostHeader.SetFilter("Bill-to Customer No.", CustNo);
                    IF SPostHeader.FindSet() THEN begin
                        REPEAT
                            IF ((SPostHeader.Cancelled = false) AND (SPostHeader.Reversed = false) AND (SPostHeader."LT i.SAF Invoice Type LBC" = SPostHeader."LT i.SAF Invoice Type LBC"::Invoice)) THEN BEGIN
                                HeadFound := true;
                                SPostLine.SetFilter("Document No.", SPostHeader."No.");
                                IF SPostLine.FindSet() then begin
                                    REPEAT
                                        IF (SPostLine."Sell-to Customer No." = '') THEN exit(false);
                                        TotalAmount += (SPostLine."Unit Price" * SPostLine.Quantity);
                                    UNTIL SPostLine.Next() = 0;
                                end;
                            END;
                        UNTIL SPostHeader.Next() = 0;
                    end;
                end;
            'Purchases':
                begin
                    PPostHeader.SetFilter("Vendor Invoice No.", exDocNo);
                    PPostHeader.SetFilter("Pay-to Vendor No.", CustNo);
                    IF PPostHeader.FindSet() THEN begin
                        REPEAT
                            IF ((PPostHeader.Cancelled = false) AND (PPostHeader."LT i.SAF Invoice Type enum LBC" = PPostHeader."LT i.SAF Invoice Type enum LBC"::Invoice)) THEN BEGIN
                                HeadFound := true;
                                PPostLine.SetFilter("Document No.", PPostHeader."No.");
                                IF PPostLine.FindSet() then begin
                                    REPEAT
                                        IF (PPostLine."Pay-to Vendor No." = '') THEN exit(false);
                                        TotalAmount += (PPostLine."Unit Cost" * PPostLine.Quantity);
                                    UNTIL PPostLine.Next() = 0;
                                end;
                            END;
                        UNTIL PPostHeader.Next() = 0;
                    end;
                end;
        end;
        exit(HeadFound);
    END;

    local procedure SetListStatus(DocNo: Code[20]; InvType: Text[20]; status: Text[20])
    var
    BEGIN
        Clear(ImportList);
        ImportList.SetFilter("Document No.", DocNo);
        ImportList.SetFilter("Invoice Type", InvType);
        IF ImportList.FindFirst() THEN begin
            ImportList.status := status;
            ImportList.Modify(false);
        end;
    END;

    procedure GetListStatus(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]): Text[20]
    var
    BEGIN
        Clear(ImportList);
        ImportList.SetFilter("Document No.", DocNo);
        ImportList.SetFilter("Invoice Type", InvType);
        IF ImportList.FindFirst() THEN begin
            IF (ImportList."Document Type" = DocType) THEN exit(ImportList.status);
        end;
        exit('');
    END;

    procedure ClearCompleted(): Boolean
    var
        SImpHead: Record "S Invoice Import Header";
        SImpLine: Record "S Invoice Import Line";
        PImpHead: Record "P Invoice Import Header";
        PImpLine: Record "P Invoice Import Line";
    BEGIN
        Clear(ImportList);
        ImportList.SetFilter(status, 'completed');
        IF ImportList.FindSet() THEN begin
            REPEAT
                case ImportList."Invoice Type" of
                    'Sales':
                        begin
                            SImpLine.SetFilter("Document No.", ImportList."Document No.");
                            IF SImpLine.FindSet() THEN SImpLine.DeleteAll();
                            SImpHead.SetFilter("Document No.", ImportList."Document No.");
                            IF SImpHead.FindSet() THEN SImpHead.DeleteAll();
                        end;
                    'Purchases':
                        begin
                            PImpLine.SetFilter("Document No.", ImportList."Document No.");
                            IF PImpLine.FindSet() THEN PImpLine.DeleteAll();
                            PImpHead.SetFilter("Document No.", ImportList."Document No.");
                            IF PImpHead.FindSet() THEN PImpHead.DeleteAll();
                        end;

                end;
                ImportList.Delete();
            UNTIL ImportList.Next() = 0;
        end;
        exit(true);
    END;

    procedure CheckDocument(DocNo: Code[20]; InvType: Text[20]): Boolean
    var
        PHeader: Record "P Invoice Import Header";
        SHeader: Record "S Invoice Import Header";
        ErrorLine: Record "Invoice Import Error";
        Found: Integer;
        DocOk: Boolean;
    BEGIN
        Found := 0;
        DocOk := false;
        Clear(ImportList);
        ImportList.SetFilter("Document No.", DocNo);
        ImportList.SetFilter("Invoice Type", InvType);
        IF (ImportList.FindSet() = false) THEN exit(false);
        repeat
            Found += 1;
        UNTIL ImportList.Next() = 0;
        IF (Found <> 1) THEN exit(false);
        IF (ImportList.status = 'completed') THEN exit(true);
        IF ImportList.FindFirst() THEN begin
            case ImportList."Invoice Type" of
                'Sales':
                    begin
                        IF GetSalesHeader(ImportList."Document No.", SHeader) THEN begin
                            ClearDocumentErrors(InvType, DocNo);
                            IF (ImportList."Document Type" = SHeader."Document Type") THEN BEGIN
                                DocOk := CheckSalesDocument(SHeader);
                                IF DocOk THEN
                                    ImportList.status := 'checked'
                                else
                                    ImportList.status := 'error';
                                ImportList.Modify(false);
                            END;
                        end;
                    end;
                'Purchases':
                    begin
                        IF GetPurchasesHeader(ImportList."Document No.", PHeader) THEN begin
                            ClearDocumentErrors(InvType, DocNo);
                            IF (ImportList."Document Type" = PHeader."Document Type") THEN BEGIN
                                DocOk := CheckPurchasesDocument(PHeader);
                                IF DocOk THEN
                                    ImportList.status := 'checked'
                                else
                                    ImportList.status := 'error';
                                ImportList.Modify(false);
                            END;
                        end;
                    end;
            end;
        end;
        exit(DocOk);
    END;

    procedure DeleteDocument(DocNo: Code[20]; InvType: Text[20]): Boolean
    var
        PHeader: Record "P Invoice Import Header";
        SHeader: Record "S Invoice Import Header";
        PLine: Record "P Invoice Import Line";
        SLine: Record "S Invoice Import Line";
        ErrorLine: Record "Invoice Import Error";
        Found: Integer;
    BEGIN
        Found := 0;
        Clear(ImportList);
        ImportList.SetFilter("Document No.", DocNo);
        ImportList.SetFilter("Invoice Type", InvType);
        IF (ImportList.FindSet() = false) THEN exit(false);
        repeat
            Found += 1;
        UNTIL ImportList.Next() = 0;
        IF (Found <> 1) THEN exit(false);
        IF ImportList.FindFirst() THEN begin
            case ImportList."Invoice Type" of
                'Sales':
                    begin
                        SLine.SetFilter("Document No.", DocNo);
                        IF SLine.FindSet() THEN begin
                            repeat
                                IF (SLine."Document Type" = ImportList."Document Type") THEN begin
                                    SLine.Delete();
                                end;
                            until SLine.Next() = 0;
                        end;
                        SHeader.SetFilter("Document No.", DocNo);
                        IF (SHeader.FindSet()) THEN begin
                            repeat
                                IF (SHeader."Document Type" = ImportList."Document Type") THEN begin
                                    SHeader.Delete();
                                end;
                            UNTIL SHeader.Next() = 0;
                        end;
                    end;
                'Purchases':
                    begin
                        PLine.SetFilter("Document No.", DocNo);
                        IF PLine.FindSet() THEN begin
                            repeat
                                IF (PLine."Document Type" = ImportList."Document Type") THEN begin
                                    PLine.Delete();
                                end;
                            until PLine.Next() = 0;
                        end;
                        PHeader.SetFilter("Document No.", DocNo);
                        IF (PHeader.FindSet()) THEN begin
                            repeat
                                IF (PHeader."Document Type" = ImportList."Document Type") THEN begin
                                    PHeader.Delete();
                                end;
                            UNTIL PHeader.Next() = 0;
                        end;
                    end;
            End;
            ErrorLine.SetFilter("Document No.", DocNo);
            ErrorLine.SetFilter("Invoice Type", InvType);
            IF (ErrorLine.FindSet()) THEN ErrorLine.DeleteAll();

            ImportList.Delete();
        end;
        exit(true);
    END;

    procedure UnitOfMeasurementChooser(Question: Text[64]; CurrentCode: Code[10]; var NewCode: Code[10]): Boolean
    var
        ListUnit: Record "Unit of Measure";
        Options: Text[32];
        ListOptions: List of [Code[10]];
        CurrentIndex: Integer;
        CurrentMeasurementIndex: Integer;
    BEGIN
        Clear(Options);
        Clear(ListOptions);
        CurrentIndex := 0;
        CurrentMeasurementIndex := 0;
        NewCode := '';
        ListUnit.SetFilter(Code, 'G|KG|VNT|M');
        IF (ListUnit.FindSet()) THEN begin
            repeat
                CurrentIndex += 1;
                ListOptions.Add(ListUnit.Code);
                IF (CurrentCode = ListUnit.Code) THEN CurrentMeasurementIndex := CurrentIndex;
                Options := Options + ListUnit.Code + ' ';
            UNTIL ListUnit.Next() = 0;
            Options := Options.Trim();
            Options := Options.Replace(' ', ',');
            CurrentIndex := Dialog.StrMenu(Options, CurrentMeasurementIndex, Question);
            IF (CurrentIndex > 0) THEN begin
                NewCode := ListOptions.Get(CurrentIndex);
                exit(true);
            end;
        END;
        exit(false);
    END;

    var
        ImportList: Record "Invoice Import List";
}
