codeunit 50101 SamsCreateSalesInvoice
{
    Permissions =
        TableData "Location" = RIMD,
        TableData "Sales Header" = RIMD,
        TableData "Sales Line" = RIMD,
        TableData "Warehouse Shipment Header" = RIMD,
        TableData "Warehouse Shipment Line" = RIMD,
        TableData "Registered Whse. Activity Line" = RIMD,
        TableData "Registered Whse. Activity Hdr." = RIMD;

    trigger OnRun()
    var
        MSG: Text;
    begin
        
        repeat
            MSG := GetSalesOrders();
            IF (MSG.Contains('No orders received')) THEN break;
        until MSG.Contains('Done') = false; 


        //MSG := GetSalesOrderPicks('EE_1204334');
        //Message(MSG);
        //DeleteALL();
    end;

    procedure GetSalesOrders() ResultText: Text;
    var
        SOrderText: Text;
        SOrderLines: Text;
        SalesOrders: JsonArray;
        SalesOrderLine: JsonArray;
        SalesOrderToken: JsonToken;
        SalesOrder: JsonObject;
        JsonToken: JsonToken;
        documentId: Code[35];
        SalesOrderNums: JsonArray;
        SalesOrderInfo: JsonObject;
        OrderNum: Code[20];
        ResponseText: Text;
        ShipmentNo: Code[20];
        SamsMySQL: Codeunit "SamsMySQL";
    begin
        ResultText := 'No orders received';
        SOrderText := SamsMySQL.MakeRequest('getSalesOrders', '');
        IF (SOrderText.Contains('Empty')) THEN begin
            exit(ResultText);
        end;
        if not SalesOrders.ReadFrom(SOrderText) then begin
            Error('ERROR: getSalesOrders');
        end
        else begin
            Clear(ResultText);
            foreach SalesOrderToken In SalesOrders DO begin
                SalesOrder := SalesOrderToken.AsObject();
                if SalesOrder.Get('documentId', JsonToken) then begin
                    documentId := JsonToken.AsValue().AsCode();
                    DeleteSalesOrder(documentId);
                    SOrderLines := SamsMySQL.MakeRequest('getSalesOrderLines', documentId);
                    SalesOrderLine.ReadFrom(SOrderLines);
                    SalesOrder.Add('lines', SalesOrderLine);
                    OrderNum := CreateSalesInvoice(SalesOrder);
                    ShipmentNo := GetShipmentNo(documentId);
                    ReleaseWarehouseShipment(ShipmentNo);
                    Clear(SalesOrderInfo);
                    Clear(SalesOrderNums);
                    Clear(ResultText);
                    // Send registration numbers
                    SalesOrderInfo.Add('documentId', documentId);
                    SalesOrderInfo.Add('orderNum', OrderNum);
                    SalesOrderInfo.Add('shipmentNo', ShipmentNo);
                    SalesOrderNums.Add(SalesOrderInfo);
                    SalesOrderNums.WriteTo(ResultText);
                    ResponseText := SamsMySQL.MakeRequest('setSalesOrderNums', ResultText);
                    IF not (ResponseText.Contains('OK')) THEN begin
                        SamsMySQL.MakeRequest('setSalesOrderNums', ResultText);
                    end;
                end;
            end;
            ResponseText := 'Done';
        end;
        exit(ResponseText);
    end;

    procedure GetSalesOrderPicks(documentId: Code[35]) PickLinesText: Text
    var
        PicksText: Text;
        PickLineText: Text;
        PickLine: JsonObject;
        PickLines: JsonArray;
        Picks: JsonArray;
        PickLineToken: JsonToken;
        PickToken: JsonToken;
        ShipmentNo: Code[35];
        Pick: Record "Warehouse Activity Header";
        PickingCompleted: Boolean;
        SamsMySQL: Codeunit "SamsMySQL";
    begin
        PickingCompleted := false;
        ShipmentNo := GetShipmentNo(documentId);
        IF (ShipmentNo = '0') THEN begin
            PickLinesText := 'GetSalesOrderPicks:\ ShipmentNo not found by documentId: ' + documentId;
            Error(PickLinesText);
            exit(PickLinesText);
        end;
        PicksText := SamsMySQL.MakeRequest('getSalesOrderPicks', documentId);
        IF not (PicksText.Contains('Empty')) THEN begin
            if not Picks.ReadFrom(PicksText) then begin
                Error('ERROR: getSalesOrderPicks');
            end
            else begin
                foreach PickToken In Picks DO begin
                    PickLine := PickToken.AsObject();
                    // IF lineNumber = 99999 & Completed = 1 Order picking done
                    IF (99999 = GetJsonToken(PickLine, 'lineNumber').AsValue().AsInteger()) THEN begin
                        PickingCompleted := true;
                    end
                    else begin
                        PickLines.Add(PickToken.AsObject());
                        UpdatePick(ShipmentNo, PickLine);
                    end;
                end;
            end;
            IF (GetPickByDocumentID(documentId, Pick)) THEN begin
                CreateRegisteredPickDoc(Pick);
            end;
            // Process Sales order completion
            IF (PickingCompleted = true) THEN begin
                CompleteSalesOrder(documentId);
            end;
        end;
        PickLines.WriteTo(PickLinesText);
        exit(PickLinesText);
    end;

    var
        DocumentDate, OrderDate, PostingDate : Date;

    procedure Input(jsonText: Text): Text
    var
        JsonObject: JsonObject;
    begin
        if not JsonObject.ReadFrom(jsonText) then
            Error('RESULT_ERROR_READING');

        exit('RESULT_OK');
    end;

    local procedure CreateSalesInvoice(JO: JsonObject) OrderNum: Code[35]
    var
        SalesHeader: Record "Sales Header";
        GetSourceDocOutbound: Codeunit "Get Source Doc. Outbound";
    begin
        DocumentDate := GetJsonToken(JO, 'documentDate').AsValue().AsDate();
        OrderDate := StringToDate(GetJsonToken(JO, 'orderDate').AsValue().AsCode());
        PostingDate := StringToDate(GetJsonToken(JO, 'postingDate').AsValue().AsCode());
        GetDocumentType(JO, SalesHeader);
        InsertSalesHeaders(SalesHeader, JO, OrderNum);
        InsertSalesLines(SalesHeader, JO);
        if (SalesHeader."Location Code" = '') THEN begin
            SalesHeader.Validate("Location Code", 'LC1'); // If no location, set default to LC1
            SalesHeader.Modify(true);
        end;
        ReleaseSalesOrder(SalesHeader);
        GetSourceDocOutbound.CreateFromSalesOrderHideDialog(SalesHeader);
        CreatePickDoc(SalesHeader);
        exit(OrderNum);
    end;

    local procedure StringToDate(Text: Text): Date
    var
        TextToList: List of [Text];
        Day: Integer;
        Month: Integer;
        Year: Integer;
    begin
        TextToList := Text.Split('-');
        Evaluate(Day, TextToList.Get(3));
        Evaluate(Month, TextToList.Get(2));
        Evaluate(Year, TextToList.Get(1));
        exit(DMY2Date(Day, Month, Year));
    end;

    local procedure GetDocumentType(JsonObjectHeader: JsonObject; var SalesHeader: Record "Sales Header")
    var
        DocumentType: Text;
    begin
        DocumentType := LowerCase(GetJsonToken(JsonObjectHeader, 'documentType').AsValue().AsCode()).Trim();

        case DocumentType of
            'sales order':
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Order);
            'sales invoice':
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Invoice);
            'sales credit memo':
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Credit Memo");
            'sales return order':
                SalesHeader.Validate("Document Type", SalesHeader."Document Type"::"Return Order");
            else
                Error('Invalid Document Type');
        end;
    end;

    local procedure InsertSalesHeaders(var SalesHeader: Record "Sales Header"; var JsonObjectHeader: JsonObject; var DocumentNo: Code[35])
    var
        JsonTokenTemp: JsonToken;
        CustNo: Code[10];
    begin
        CustNo := GetJsonToken(JsonObjectHeader, 'customerNo').AsValue().AsCode();
        SalesHeader.Init();
        SalesHeader."Sell-to Customer No." := CustNo;
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustNo);
        SalesHeader.Validate("External Document No.", GetJsonToken(JsonObjectHeader, 'documentId').AsValue().AsCode());
        SalesHeader.Validate("Requested Delivery Date", StringToDate(GetJsonToken(JsonObjectHeader, 'expectedDelivery').AsValue().AsCode()));
        SalesHeader.Validate("Shipping Advice", SalesHeader."Shipping Advice"::Partial);


        SalesHeader.Validate("Document Date", DocumentDate);
        SalesHeader.Validate("Order Date", OrderDate);
        SalesHeader.Validate("Posting Date", PostingDate);
        //SalesHeader.Validate("Tax Liable", GetJsonToken(JsonObjectHeader, 'taxliable').AsValue().AsBoolean());
        DocumentNo := SalesHeader."No.";
        SalesHeader.Modify(true);
    end;

    local procedure InsertSalesLines(var SalesHeader: Record "Sales Header"; var JsonObjectHeader: JsonObject)
    var
        SalesLine: Record "Sales Line";
        OSalesLine: Record "Sales Line Original";
        JsonArrayLine: JsonArray;
        JsonTokenLine: JsonToken;
        JsonObjectLine: JsonObject;
        UnitPrice: Decimal;
        quantity: Decimal;
        LineNo: Integer;
        CustNo: Code[20];
        RefNo: Code[20];
        ItemNo: Code[20];
        LocationCode: Code[12];
    begin
        CustNo := GetJsonToken(JsonObjectHeader, 'customerNo').AsValue().AsCode();
        JsonArrayLine := GetJsonToken(JsonObjectHeader, 'lines').AsArray();
        foreach JsonTokenLine in JsonArrayLine do begin
            JsonObjectLine := JsonTokenLine.AsObject();
            RefNo := GetJsonToken(JsonObjectLine, 'itemReferenceNo').AsValue().AsCode();
            ItemNo := GetJsonToken(JsonObjectLine, 'itemno').AsValue().AsCode();
            quantity := GetJsonToken(JsonObjectLine, 'quantity').AsValue().AsDecimal();
            LineNo := GetJsonToken(JsonObjectLine, 'lineNumber').AsValue().AsInteger() * 100;
            IF ((RefNo = '') OR (RefNo = '0')) THEN RefNo := FindItemReferenceNo(CustNo, itemno);
            IF ((RefNo <> '') AND (RefNo <> '0')) THEN
                RefNo := CreateItemReference(RefNo, CustNo, ItemNo);

            SalesLine.Init();
            SalesLine.Validate("Document Type", SalesHeader."Document Type");
            SalesLine.Validate("Document No.", SalesHeader."No.");
            SalesLine.Validate("Line No.", LineNo);
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Insert(true);

            SalesLine.Validate("Shipment Date", WorkDate());
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate("Unit of Measure Code", GetJsonToken(JsonObjectLine, 'unitOfMeasureCode').AsValue().AsCode());
            SalesLine.Validate("Quantity (Base)", quantity);

            if not ((SalesLine."Document Type" = SalesLine."Document Type"::"Credit Memo") or
                    (SalesLine."Document Type" = SalesLine."Document Type"::"Return Order")) then begin
                //SalesLine.Validate("Qty. to Ship (Base)", quantity);

            end;

            IF (RefNo <> '0') THEN begin
                SalesLine.Validate("Item Reference No.", RefNo);
                SalesLine.Validate("Item Reference Type", "Item Reference Type"::Customer);
                SalesLine.Validate("Item Reference Type No.", CustNo);
            end;

            SalesLine.Validate("Unit Price", GetJsonToken(JsonObjectLine, 'unitPrice').AsValue().AsDecimal());
            SalesLine.Validate("Line Discount %", GetJsonToken(JsonObjectLine, 'discount').AsValue().AsDecimal());

            IF (SalesLine."Location Code" = '') THEN BEGIN // If no location, set default to LC1
                SalesLine.Validate("Location Code", 'LC1');
            END;

            SalesLine.Modify(true);
            OSalesLine.Init();
            OSalesLine.TransferFields(SalesLine);
            OSalesLine.Insert(false);
        end;
    end;

    local procedure ReleaseSalesOrder(var SalesHeader: Record "Sales Header")
    var
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Location: Record "Location";
    begin
        Location.SetFilter("Code", SalesHeader."Location Code");
        IF Location.FindSet(true) THEN BEGIN
            REPEAT
                Location."Require Shipment" := true;
                Location.Modify(true);
            UNTIL Location.Next() = 0;
        END;
        IF (SalesHeader.Status = SalesHeader.Status::Open) then
            ReleaseSalesDoc.PerformManualCheckAndRelease(SalesHeader);
    end;

    local procedure ReleaseWarehouseShipment(ShipmentNo: Code[35])
    var
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        Shipment: Record "Warehouse Shipment Header";
        ShipmentLine: Record "Warehouse Shipment Line";
        quantity: Decimal;
        released: Boolean;
    begin
        released := false;
        ShipmentLine.SetFilter("No.", ShipmentNo);
        IF ShipmentLine.FindSet(true) THEN BEGIN
            REPEAT
                ShipmentLine.DeleteQtyToHandle(ShipmentLine);
            UNTIL ShipmentLine.Next() = 0;
        END;

        Shipment.SetFilter("No.", ShipmentNo);
        IF Shipment.FindSet(true) THEN BEGIN
            REPEAT
                IF (Shipment.Status = Shipment.Status::Open) THEN begin
                    released := true;
                    ReleaseWhseShptDoc.Release(Shipment);
                end;
            UNTIL ((Shipment.Next() = 0) OR (released = true));
        END;
    end;

    procedure GetSalesOrderNo(DocumentID: Code[35]) SalesOrderNo: Code[35]
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesOrderNo := '0';

        SalesHeader.SetFilter("External Document No.", DocumentID);
        IF (SalesHeader.FindFirst()) THEN BEGIN
            SalesOrderNo := SalesHeader."No.";
        END;
        exit(SalesOrderNo);
    end;

    procedure GetSalesOrderLineCount(SalesOrderNo: Code[35]) Num: Integer
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SetFilter("Document No.", SalesOrderNo);
        Num := SalesLine.Count();
        //SalesLine.
        exit(Num);
    end;

    procedure GetShipmentNo(DocumentNo: Code[35]) ShipmentNo: Code[35]
    var
        Shipment: Record "Warehouse Shipment Header";
        exNo: Text;
    begin
        ShipmentNo := '0';
        Shipment.SetFilter("External Document No.", DocumentNo);
        IF Shipment.FindSet() THEN begin
            REPEAT
                exNo := Shipment."External Document No.";
                IF (exNo.Contains(DocumentNo)) then begin
                    ShipmentNo := Shipment."No.";
                end;
            UNTIL Shipment.Next() = 0;
        end;
        exit(ShipmentNo);
    end;

    local procedure FindItemReferenceNo(CustNo: Code[20]; ItemNo: Code[20]) RefNo: Code[20]
    var
        Customer: Record "Customer";
        BillCustomer: Code[20];
        BillCust: Integer;
        ItemReference: Record "Item Reference";
    begin
        RefNo := '0';
        Customer.SetFilter("No.", CustNo);
        IF Customer.FindFirst() THEN begin
            BillCustomer := Customer."Bill-to Customer No.";
            IF Evaluate(BillCust, BillCustomer) THEN begin
                IF (BillCust > 0) THEN begin
                    ItemReference.SetFilter("Reference Type No.", BillCustomer);
                    ItemReference.SetFilter("Item No.", ItemNo);
                    IF (ItemReference.FindSet()) then begin
                        repeat
                            IF (ItemReference."Reference Type" = ItemReference."Reference Type"::Customer) THEN begin
                                RefNo := ItemReference."Reference No.";
                            end;
                        UNTIL ItemReference.Next() = 0;
                    end;
                end;
            end;
        end;
        exit(RefNo);
    end;

    local procedure CreateItemReference(RefNo: Code[20]; CustNo: Code[20]; ItemNo: Code[20]) FoundReference: Code[20];
    var
        IR: Record "Item Reference";
        DeletedOld: Boolean;
    begin
        FoundReference := '0';
        DeletedOld := false;
        IF IR.FindSet(true) THEN BEGIN
            REPEAT
                IF (IR."Reference Type" = IR."Reference Type"::Customer) THEN begin
                    IF ((IR."Reference Type No." = CustNo) AND (IR."Item No." = ItemNo)) THEN begin
                        IF (IR."Reference No." <> RefNo) THEN begin
                            IR.Delete();
                            DeletedOld := true;
                        end
                        ELSE
                            FoundReference := IR."Reference No.";
                    end;
                end;
            UNTIL ((IR.Next() = 0) OR (FoundReference <> '0') OR (DeletedOld = true));
        END;
        IF ((FoundReference = '0') OR (DeletedOld = true)) THEN begin
            InsertReference(RefNo, CustNo, ItemNo);
            FoundReference := RefNo;
        end;

        exit(FoundReference);
    end;

    local procedure InsertReference(RefNo: Code[20]; CustNo: Code[20]; ItemNo: Code[20])
    var
        IR: Record "Item Reference";
    begin
        IR.Init();
        IR.Validate("Reference Type", IR."Reference Type"::Customer);
        IR.Validate("Reference Type No.", CustNo);
        IR.Validate("Item No.", ItemNo);
        IR.Validate("Reference No.", RefNo);
        IR.Insert();
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    local procedure CreatePickDoc(var SalesHeader: Record "Sales Header")
    var
        ShipmentLine: Record "Warehouse Shipment Line";
        Pick: Record "Warehouse Activity Header";
        PickLine: Record "Warehouse Activity Line";
        LineNo: Integer;
    begin
        SalesHeader.TestField(Status, SalesHeader.Status::Released);
        Pick.Init();
        Pick.Validate("Location Code", SalesHeader."Location Code");
        Pick.Validate(Type, Pick.Type::Pick);
        Pick.Validate("Source Document", Pick."Source Document"::"Sales Order");
        Pick.Validate("Source No.", SalesHeader."No.");
        Pick.Validate("External Document No.", SalesHeader."External Document No.");
        Pick.Validate("Destination Type", Pick."Destination Type"::Customer);
        Pick.Validate("Destination No.", SalesHeader."Sell-to Customer No.");
        Pick.Insert(true);

        ShipmentLine.SetFilter(Quantity, '>0');
        ShipmentLine.SetFilter("Source No.", SalesHeader."No.");
        ShipmentLine.SetRange("Completely Picked", false);
        LineNo := 0;
        if ShipmentLine.FindSet() then begin
            REPEAT
                LineNo += 10000;
                CreatePick(LineNo, Pick."No.", PickLine, ShipmentLine, PickLine."Action Type"::Take);
                LineNo += 10000;
                CreatePick(LineNo, Pick."No.", PickLine, ShipmentLine, PickLine."Action Type"::Place);
            UNTIL ShipmentLine.Next() = 0;
            Pick."No. of Lines" := LineNo / 10000;
        end;
    end;

    local procedure GetPickByDocumentID(documentId: Code[35]; var Pick: Record "Warehouse Activity Header"): Boolean
    var
    begin
        Pick.SetFilter("External Document No.", documentId);
        exit(Pick.FindFirst());
    end;

    local procedure CreatePick(LineNo: Integer; PickNo: Code[20]; var PickLine: Record "Warehouse Activity Line";
        var ShipmentLine: Record "Warehouse Shipment Line"; PickAction: Enum "Warehouse Action Type")
    var
    begin
        PickLine.Init();
        PickLine.Validate("Line No.", LineNo);
        PickLine.TransferFromShptLine(ShipmentLine);
        PickLine.Validate("No.", PickNo);
        PickLine.Validate("Action Type", PickAction);
        PickLine.Validate("Source Document", ShipmentLine."Source Document");
        PickLine.Validate("Source No.", ShipmentLine."Source No.");
        PickLine.Validate("Source Line No.", ShipmentLine."Source Line No.");
        PickLine.Validate("Source Type", ShipmentLine."Source Type");
        PickLine.Validate("Destination No.", ShipmentLine."Destination No.");
        PickLine.Validate("Destination Type", ShipmentLine."Destination Type");
        PickLine.Validate("Location Code", ShipmentLine."Location Code");
        PickLine.Validate("Unit of Measure Code", ShipmentLine."Unit of Measure Code");
        PickLine.Validate("Qty. per Unit of Measure", ShipmentLine."Qty. per Unit of Measure");
        PickLine.Validate(Quantity, ShipmentLine.Quantity);
        PickLine.Validate("Qty. to Handle", ShipmentLine.Quantity);
        PickLine.Validate("Qty. Handled", ShipmentLine."Qty. Picked");
        PickLine.Validate("Qty. Handled (Base)", ShipmentLine."Qty. Picked (Base)");
        PickLine.Insert();
        PickLine.Modify(true);
    end;

    local procedure CreateRegisteredPickDoc(var Pick: Record "Warehouse Activity Header")
    var
        RPick: Record "Registered Whse. Activity Hdr.";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        WhseSetup: Record "Warehouse Setup";
        PickLine: Record "Warehouse Activity Line";
        PickLineTMP: Record "Warehouse Activity Line" temporary;
        SalesHeader: Record "Sales Header";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        LineNo: Integer;
        qty_handled: Decimal;
        quantity: Decimal;
    begin
        RPick.SetFilter("Whse. Activity No.", Pick."No.");
        IF not (RPick.FindFirst()) THEN BEGIN
            WhseSetup.FindFirst();
            RPick.Init();
            RPick.Validate("Registering Date", TODAY());
            RPick."No." := '';
            RPick."No. Series" := WhseSetup."Registered Whse. Pick Nos.";
            NoSeriesMgt.InitSeries(WhseSetup."Registered Whse. Pick Nos.", RPick."No. Series", RPick."Registering Date", RPick."No.", RPick."No. Series");
            RPick.Validate("Location Code", Pick."Location Code");
            RPick.Validate(Type, Pick.Type);
            RPick."Assigned User ID" := Pick."Assigned User ID";
            RPick."Assignment Date" := Pick."Assignment Date";
            RPick."Assignment Time" := Pick."Assignment Time";
            RPick."Sorting Method" := Pick."Sorting Method";
            RPick.Validate("Whse. Activity No.", Pick."No.");
            RPick."No. Printed" := Pick."No. Printed";
            RPick.Insert(true);
        END;

        LineNo := 0;
        PickLine.SetFilter("No.", Pick."No.");
        IF (PickLine.FindSet(true)) THEN begin
            SalesHeader.SetFilter("No.", PickLine."Source No.");
            IF (SalesHeader.FindFirst()) THEN begin
                IF (SalesHeader.Status = SalesHeader.Status::Released) THEN
                    ReleaseSalesDoc.PerformManualReopen(SalesHeader);
            end;
            repeat
                LineNo += 10000;
                quantity := PickLine.Quantity;
                qty_handled := PickLine."Qty. Handled";
                IF (qty_handled > 0) THEN BEGIN
                    IF (qty_handled >= quantity) THEN BEGIN
                        quantity := qty_handled;
                        PickLine."Shipping Advice" := PickLine."Shipping Advice"::Complete;
                    END
                    ELSE BEGIN
                        PickLine."Shipping Advice" := PickLine."Shipping Advice"::Partial;
                    END;
                    PickLine."Qty. (Base)" := quantity;
                    PickLine.Quantity := quantity;
                    PickLine."Qty. Outstanding" := quantity;
                    PickLine."Qty. Outstanding (Base)" := quantity;
                    PickLine."Qty. Handled" := qty_handled;
                    PickLine."Qty. Handled (Base)" := qty_handled;
                    CreateRegisteredPick(LineNo, RPick."No.", PickLine);
                    IF (PickLine."Action Type" = PickLine."Action Type"::Place) THEN BEGIN
                        UpdateShipmentLine(PickLine);
                        UpdateSalesOrderLine(PickLine);
                    END;
                    IF (qty_handled >= quantity) THEN
                        PickLine.Delete()
                    ELSE begin
                        PickLineTMP := PickLine;
                        PickLine.Delete();
                        quantity := quantity - qty_handled;
                        PickLineTMP."Qty. (Base)" := quantity;
                        PickLineTMP.Quantity := quantity;
                        PickLineTMP."Qty. Outstanding" := quantity;
                        PickLineTMP."Qty. Outstanding (Base)" := quantity;
                        PickLineTMP."Qty. to Handle" := quantity;
                        PickLineTMP."Qty. to Handle (Base)" := quantity;
                        PickLineTMP."Qty. Handled" := 0;
                        PickLineTMP."Qty. Handled (Base)" := 0;
                        PickLine.Init();
                        PickLine := PickLineTMP;
                        PickLine.Insert();
                    end;
                END;
            UNTIL PickLine.Next() = 0;
            IF (SalesHeader.FindFirst()) THEN begin
                IF (SalesHeader.Status = SalesHeader.Status::Open) THEN
                    ReleaseSalesDoc.PerformManualCheckAndRelease(SalesHeader);
            end;
        end;
        // If no unregistered picks left, finally prepare shipment document
        IF not PickLine.FindFirst() then begin
            // Delete unregistered Pick header
            Pick.Delete();
        end;
    end;

    local procedure CreateRegisteredPick(LineNo: Integer; RPickNo: Code[20]; var PickLine: Record "Warehouse Activity Line")
    var
        RPickLine: Record "Registered Whse. Activity Line";
    begin
        RPickLine.Init();
        RPickLine.Validate("Line No.", LineNo);
        RPickLine."Activity Type" := PickLine."Activity Type";
        RPickLine."No." := RPickNo;
        RPickLine."Source Type" := PickLine."Source Type";
        RPickLine."Source Subtype" := PickLine."Source Subtype";
        RPickLine."Source No." := PickLine."Source No.";
        RPickLine."Source Line No." := PickLine."Source Line No.";
        RPickLine."Source Document" := PickLine."Source Document";
        RPickLine."Location Code" := PickLine."Location Code";
        RPickLine."Shelf No." := PickLine."Shelf No.";
        RPickLine."Sorting Sequence No." := PickLine."Sorting Sequence No.";
        RPickLine."Item No." := PickLine."Item No.";
        RPickLine."Variant Code" := PickLine."Variant Code";
        RPickLine."Unit of Measure Code" := PickLine."Unit of Measure Code";
        RPickLine."Qty. per Unit of Measure" := PickLine."Qty. per Unit of Measure";
        RPickLine."Description" := PickLine.Description;
        RPickLine."Description 2" := PickLine."Description 2";
        RPickLine."Quantity" := PickLine."Qty. Handled";
        RPickLine."Qty. (Base)" := PickLine."Qty. Handled (Base)";
        RPickLine."Shipping Advice" := PickLine."Shipping Advice";
        RPickLine."Due Date" := PickLine."Due Date";
        RPickLine."Destination Type" := PickLine."Destination Type";
        RPickLine."Destination No." := PickLine."Destination No.";
        RPickLine."Whse. Activity No." := PickLine."Whse. Document No.";
        RPickLine."Shipping Agent Code" := PickLine."Shipping Agent Code";
        RPickLine."Shipping Agent Service Code" := PickLine."Shipping Agent Service Code";
        RPickLine."Shipment Method Code" := PickLine."Shipment Method Code";
        RPickLine."Starting Date" := PickLine."Starting Date";
        RPickLine."Serial No." := PickLine."Serial No.";
        RPickLine."Lot No." := PickLine."Lot No.";
        RPickLine."Warranty Date" := PickLine."Warranty Date";
        RPickLine."Expiration Date" := PickLine."Expiration Date";
        RPickLine."Package No." := PickLine."Package No.";
        RPickLine."Bin Code" := PickLine."Bin Code";
        RPickLine."Zone Code" := PickLine."Zone Code";
        RPickLine."Action Type" := PickLine."Action Type";
        RPickLine."Whse. Document Type" := PickLine."Whse. Document Type";
        RPickLine."Whse. Document No." := PickLine."Whse. Document No.";
        RPickLine."Whse. Document Line No." := PickLine."Whse. Document Line No.";
        RPickLine."Cubage" := PickLine.Cubage;
        RPickLine."Weight" := PickLine.Weight;
        RPickLine."Special Equipment Code" := PickLine."Special Equipment Code";
        RPickLine.Insert(true);
    end;

    local procedure UpdatePick(ShipmentNo: Code[35]; PickedLine: JsonObject)
    var
        PickLine: Record "Warehouse Activity Line";
        PickLineTMP: Record "Warehouse Activity Line" temporary;
        itemno: Code[20];
        quantity: Decimal;
        qty_handled: Decimal;
        unitOfMeasure: Code[10];
        lineNumber: Text;
        newItem: Boolean;
        qty_UnitOfMeasure: Decimal;
    begin
        itemno := GetJsonToken(PickedLine, 'itemno').AsValue().AsCode();
        quantity := GetJsonToken(PickedLine, 'quantity').AsValue().AsDecimal();
        qty_handled := GetJsonToken(PickedLine, 'qty_handled').AsValue().AsDecimal();
        unitOfMeasure := GetJsonToken(PickedLine, 'unitOfMeasure').AsValue().AsCode();
        lineNumber := GetJsonToken(PickedLine, 'lineNumber').AsValue().AsText() + '00';
        IF (GetJsonToken(PickedLine, 'newItem').AsValue().AsInteger() = 1) THEN
            newItem := true
        else
            newItem := false;
        qty_UnitOfMeasure := GetJsonToken(PickedLine, 'qty_UnitOfMeasure').AsValue().AsDecimal();

        PickLine.SetFilter("Whse. Document No.", ShipmentNo);
        PickLine.SetFilter("Source Line No.", lineNumber);
        IF PickLine.FindSet(true) THEN begin
            repeat
                PickLineTMP.Init();
                PickLineTMP.TransferFields(PickLine);
                PickLineTMP.Quantity := quantity;
                PickLineTMP."Qty. (Base)" := quantity;
                PickLineTMP."Qty. Outstanding" := quantity;
                PickLineTMP."Qty. Outstanding (Base)" := quantity;
                PickLineTMP."Qty. to Handle" := quantity;
                PickLineTMP."Qty. to Handle (Base)" := quantity;
                PickLineTMP."Qty. Handled" := qty_handled;
                PickLineTMP."Qty. Handled (Base)" := qty_handled;
                PickLineTMP."Item No." := itemno;
                PickLineTMP."Unit of Measure Code" := unitOfMeasure;
                PickLineTMP."Qty. per Unit of Measure" := qty_UnitOfMeasure;
                PickLineTMP.Insert();
                PickLine.Delete();
                PickLine.Init();
                PickLine.TransferFields(PickLineTMP);
                PickLine.Insert();
            UNTIL PickLine.Next() = 0;
        end;
    end;

    local procedure UpdateSalesOrderLine(PickLine: Record "Warehouse Activity Line")
    var
        SalesLine: Record "Sales Line";
        SalesLineTMP: Record "Sales Line" temporary;
        LineNo: Text;
    begin
        LineNo := Format(PickLine."Source Line No.");

        SalesLine.SetFilter("Document No.", PickLine."Source No.");
        SalesLine.SetFilter("Line No.", LineNo);
        IF SalesLine.FindFirst() THEN begin
            SalesLineTMP := SalesLine;
            SalesLineTMP."Outstanding Quantity" := PickLine."Qty. Outstanding";
            SalesLineTMP."Outstanding Qty. (Base)" := PickLine."Qty. Outstanding (Base)";
            SalesLineTMP."Qty. per Unit of Measure" := PickLine."Qty. per Unit of Measure";
            SalesLineTMP.Quantity := PickLine.Quantity;
            SalesLineTMP."Quantity (Base)" := PickLine."Qty. (Base)";
            SalesLineTMP."Qty. to Ship" := PickLine."Qty. Handled";
            SalesLineTMP."Qty. to Ship (Base)" := PickLine."Qty. Handled (Base)";
            SalesLineTMP.Validate("Unit Price", SalesLineTMP."Unit Price");
            SalesLine.Delete();
            SalesLine.Init();
            SalesLine := SalesLineTMP;
            SalesLine.Insert();
        end;
    end;

    local procedure UpdateShipmentLine(PickLine: Record "Warehouse Activity Line")
    var
        ShipmentLine: Record "Warehouse Shipment Line";
        LineNo: Text;
    begin
        LineNo := Format(PickLine."Whse. Document Line No.");
        ShipmentLine.SetFilter("No.", PickLine."Whse. Document No.");
        ShipmentLine.SetFilter("Line No.", LineNo);

        IF (ShipmentLine.FindFirst()) THEN begin
            ShipmentLine."Item No." := PickLine."Item No.";
            IF (ShipmentLine.Quantity <= PickLine.Quantity + ShipmentLine."Qty. Picked") THEN BEGIN
                ShipmentLine.Quantity := PickLine.Quantity + ShipmentLine."Qty. Picked";
                ShipmentLine."Qty. (Base)" := PickLine."Qty. (Base)" + ShipmentLine."Qty. Picked (Base)";
                ShipmentLine."Qty. Outstanding" := PickLine.Quantity + ShipmentLine."Qty. Picked";
                ShipmentLine."Qty. Outstanding (Base)" := PickLine."Qty. (Base)" + ShipmentLine."Qty. Picked (Base)";
            END
            ELSE BEGIN
                ShipmentLine.Quantity += PickLine.Quantity;
                ShipmentLine."Qty. (Base)" += PickLine."Qty. (Base)";
                ShipmentLine."Qty. Outstanding" += PickLine.Quantity;
                ShipmentLine."Qty. Outstanding (Base)" += PickLine."Qty. (Base)";
            END;
            ShipmentLine."Pick Qty." += PickLine."Qty. to Handle" - PickLine."Qty. Handled";
            ShipmentLine."Pick Qty. (Base)" += PickLine."Qty. to Handle (Base)" - PickLine."Qty. Handled (Base)";
            ShipmentLine."Qty. Picked" += PickLine."Qty. Handled";
            ShipmentLine."Qty. Picked (Base)" += PickLine."Qty. Handled (Base)";
            ShipmentLine."Qty. to Ship" += PickLine."Qty. Handled";
            ShipmentLine."Qty. to Ship (Base)" += PickLine."Qty. Handled (Base)";
            ShipmentLine."Unit of Measure Code" := PickLine."Unit of Measure Code";
            ShipmentLine."Qty. per Unit of Measure" := PickLine."Qty. per Unit of Measure";
            ShipmentLine."Completely Picked" := (PickLine."Shipping Advice" = PickLine."Shipping Advice"::Complete);
            ShipmentLine.Modify(false);
        end;
    end;

    local procedure CompleteSalesOrder(DocumentNo: Code[35])
    var
        Shipment: Record "Warehouse Shipment Header";
        ShipmentLine: Record "Warehouse Shipment Line";
        ShipmentLineTMP: Record "Warehouse Shipment Line" temporary;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SalesLineTMP: Record "Sales Line" temporary;
        Pick: Record "Warehouse Activity Header";
        PickLine: Record "Warehouse Activity Line";
        RPick: Record "Registered Whse. Activity Hdr.";
        RPickLine: Record "Registered Whse. Activity Line";
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        ShipmentReady: Boolean;
        SalesOrderReady: Boolean;
        SalesPost: Codeunit "Sales-Post";
    begin
        ShipmentReady := false;
        SalesOrderReady := false;
        Pick.SetFilter("External Document No.", DocumentNo);
        IF (Pick.FindFirst()) THEN begin
            PickLine.SetFilter("No.", Pick."No.");
            IF PickLine.FindSet(true) THEN begin
                PickLine.DeleteAll();
            end;
            Pick.Delete();
        end;
        Shipment.SetFilter("External Document No.", DocumentNo);
        IF (Shipment.FindFirst()) THEN begin
            IF (Shipment.Status = Shipment.Status::Released) THEN
                ReleaseWhseShptDoc.Reopen(Shipment);
            ShipmentLine.SetFilter("No.", Shipment."No.");
            IF (ShipmentLine.FindSet(true)) THEN begin
                repeat
                    IF ((ShipmentLine."Qty. to Ship" = 0) AND (ShipmentLine."Qty. Picked" = 0)) then
                        ShipmentLine.Delete()
                    ELSE BEGIN
                        IF (ShipmentLine."Qty. to Ship" <> ShipmentLine.Quantity) THEN begin
                            ShipmentLineTMP := ShipmentLine;
                            ShipmentLineTMP."Qty. (Base)" := ShipmentLine."Qty. to Ship (Base)";
                            ShipmentLineTMP.Quantity := ShipmentLine."Qty. to Ship";
                            ShipmentLineTMP."Qty. Outstanding" := ShipmentLine."Qty. to Ship";
                            ShipmentLineTMP."Qty. Outstanding (Base)" := ShipmentLine."Qty. to Ship (Base)";
                            ShipmentLine.Delete();
                            ShipmentLine.Init();
                            ShipmentLine := ShipmentLineTMP;
                            ShipmentLine.Insert();
                        end;
                    END;
                UNTIL ShipmentLine.Next() = 0;
            end;
            IF (Shipment.Status = Shipment.Status::Open) THEN
                ReleaseWhseShptDoc.Release(Shipment);
            ShipmentReady := true;
        end;
        IF (ShipmentReady) THEN begin
            SalesHeader.SetFilter("External Document No.", DocumentNo);
            IF (SalesHeader.FindFirst()) THEN begin
                IF (SalesHeader.Status = SalesHeader.Status::Released) THEN
                    ReleaseSalesDoc.Reopen(SalesHeader);
                SalesLine.SetFilter("Document No.", SalesHeader."No.");
                IF SalesLine.FindSet(true) THEN begin
                    repeat
                        IF (SalesLine."Qty. to Ship" = 0) THEN begin
                            SalesLine.Delete();
                        end
                        else begin
                            if (SalesLine.Quantity <> SalesLine."Qty. to Ship") THEN begin
                                SalesLineTMP := SalesLine;
                                SalesLineTMP.Quantity := SalesLine."Qty. to Ship";
                                SalesLineTMP."Quantity (Base)" := SalesLine."Qty. to Ship (Base)";
                                SalesLineTMP."Outstanding Quantity" := SalesLine."Qty. to Ship";
                                SalesLineTMP."Outstanding Qty. (Base)" := SalesLine."Qty. to Ship (Base)";
                                SalesLineTMP.Validate("Unit Price", SalesLine."Unit Price");
                                SalesLine.Delete();
                                SalesLine.Init();
                                SalesLine := SalesLineTMP;
                                SalesLine.Insert();
                            end;
                        end;
                    UNTIL SalesLine.Next() = 0;
                end;
                IF (SalesHeader.Status = SalesHeader.Status::Open) THEN
                    ReleaseSalesDoc.PerformManualCheckAndRelease(SalesHeader);
                SalesOrderReady := true;
            end;
        end;
        IF (ShipmentReady AND SalesOrderReady) THEN begin
            IF (ShipmentLine.FindSet(true)) THEN BEGIN
                CODEUNIT.RUN(CODEUNIT::"Whse.-Post Shipment", ShipmentLine);
                IF (SalesHeader.FindFirst()) then BEGIN
                    SalesHeader.Ship := false;
                    SalesHeader.Invoice := true;
                    Clear(SalesPost);
                    SalesPost.Run(SalesHeader);
                END;
            END;
        end;
    end;

    local procedure DeleteSalesOrder(DocumentNo: Code[35])
    var
        Shipment: Record "Warehouse Shipment Header";
        ShipmentLine: Record "Warehouse Shipment Line";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        OriginalSalesLine: Record "Sales Line Original";
        ShipmentNo: Code[35];
        ReleaseWhseShptDoc: Codeunit "Whse.-Shipment Release";
        ReleaseSalesDoc: Codeunit "Release Sales Document";
        Pick: Record "Warehouse Activity Header";
        PickLine: Record "Warehouse Activity Line";
        RPick: Record "Registered Whse. Activity Hdr.";
        RPickLine: Record "Registered Whse. Activity Line";
    begin
        // Find sales order
        SalesHeader.SetFilter("External Document No.", DocumentNo);
        IF SalesHeader.FindFirst() THEN begin
            // Delete Original Sales Order Lines
            OriginalSalesLine.SetFilter("Document No.", SalesHeader."No.");
            IF (OriginalSalesLine.FindSet()) THEN begin
                repeat
                    OriginalSalesLine.Delete();
                UNTIL OriginalSalesLine.Next() = 0;
            end;
            // Find sales order line
            SalesLine.SetFilter("Document No.", SalesHeader."No.");
            // Find shipment no
            ShipmentNo := GetShipmentNo(DocumentNo);
            Shipment.SetFilter("No.", ShipmentNo);
            // Find shipment line
            ShipmentLine.SetFilter("No.", ShipmentNo);
            // Find pick header
            Pick.SetFilter("External Document No.", DocumentNo);
            // Find pick line
            PickLine.SetFilter("No.", Pick."No.");
            // Find registered pick header
            RPick.SetFilter("Whse. Activity No.", Pick."No.");
            // Find registered pick line
            RPickLine.SetFilter("Source No.", SalesHeader."No.");
            IF (SalesHeader.Status = SalesHeader.Status::Released) THEN
                ReleaseSalesDoc.PerformManualReopen(SalesHeader);
            // Delete all
            IF (RPickLine.FindSet(true)) THEN begin
                repeat
                    RPickLine.Delete();
                UNTIL RPickLine.Next() = 0;
            end;
            IF RPick.FindSet(true) THEN begin
                repeat
                    RPick.Delete();
                until RPick.Next() = 0;
            end;
            IF (PickLine.FindSet(true)) THEN begin
                repeat
                    PickLine.Delete();
                UNTIL PickLine.Next() = 0;
            end;
            IF (Pick.FindSet(true)) THEN begin
                repeat
                    Pick.Delete();
                UNTIL Pick.Next() = 0;
            end;
            IF Shipment.FindFirst() THEN begin
                IF (Shipment.Status = Shipment.Status::Released) THEN
                    ReleaseWhseShptDoc.Reopen(Shipment);
            end;
            IF (ShipmentLine.FindSet(true)) then begin
                repeat
                    ShipmentLine.Delete();
                until ShipmentLine.Next() = 0;
            end;
            IF (Shipment.FindSet(true)) then begin
                repeat
                    Shipment.Delete();
                until Shipment.Next() = 0;
            end;
            IF (SalesLine.FindSet(true)) then begin
                repeat
                    SalesLine.Delete();
                until SalesLine.Next() = 0;
            end;
            IF (SalesHeader.FindSet(true)) then begin
                repeat
                    SalesHeader.Delete();
                until SalesHeader.Next() = 0;
            end;
        end;
    end;

    local procedure DeleteALL()
    var
        ShipmentLine: Record "Warehouse Shipment Line";
        SalesLine: Record "Sales Line";
        PickLine: Record "Warehouse Activity Line";
        RPickLine: Record "Registered Whse. Activity Line";
        OriginalSalesLine: Record "Sales Line Original";
        SalesHeader: Record "Sales Header";
    begin
        IF RPickLine.FindFirst() THEN RPickLine.DeleteAll();
        IF PickLine.FindFirst() THEN PickLine.DeleteAll();
        IF ShipmentLine.FindFirst() THEN ShipmentLine.DeleteAll();
        IF SalesLine.FindFirst() THEN SalesLine.DeleteAll();
        IF OriginalSalesLine.FindFirst() THEN OriginalSalesLine.DeleteAll();
        IF SalesHeader.FindFirst() THEN SalesHeader.DeleteAll();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Line", 'OnBeforeCheckShipmentDateBeforeWorkDate', '', False, False)]
    local procedure CheckShipmentDateBeforeWorkDate(var SalesLine: Record "Sales Line"; xSalesLine: Record "Sales Line"; var HasBeenShown: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := True;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Sales Header", 'OnBeforeMessageIfSalesLinesExist', '', True, False)]
    local procedure OnBeforeMessageIfSalesLinesExist(SalesHeader: Record "Sales Header"; ChangedFieldCaption: Text; var IsHandled: Boolean)
    begin
        IsHandled := True;
    end;


}