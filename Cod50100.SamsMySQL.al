codeunit 50100 SamsMySQL
{
    Permissions =
        tabledata "Item Journal Line" = RIMD,
        tabledata "SamsSchedule" = RIMD;

    trigger OnRun()
    var
    begin
        postJrnlMPC();
    end;

    // "{\"Action\": \"awe\", \"Data1\": \"123\", \"Data2\": \"543\"}"
    procedure SetScheduler(sAction: Text; sData1: Text; sData2: Text): Text
    var
        Schedule: Record "SamsSchedule";
        JsonObject: JsonObject;
        ResultText: Text;
    begin
        IF (SAction = 'CLEAR_ALL') THEN begin
            IF Schedule.FindFirst() THEN Schedule.DeleteAll();
            exit('RESULT_CLEARED_ALL');
        end;
        Schedule.SetFilter("Action", sAction);
        Schedule.SetFilter("Data1", sData1);
        IF (Schedule.FindSet(true)) THEN begin
            Schedule.DeleteAll();
        end;
        Schedule.Init();
        Schedule."Action" := sAction;
        Schedule."Data1" := sData1;
        Schedule."Data2" := sData2;
        Schedule.Insert(false);

        exit('RESULT_OK');
    end;

    procedure SetCustomerPriceList(sCustomerNo: Text; sList: Text): Text
    var
        CustomerNo: Code[20];
        Customer: Record "Customer";
        PriceHeader: Record "Price List Header";
        PriceGroup: Record "Customer Price Group";
        PriceGroupCode: Code[10];
    begin
        IF (Evaluate(CustomerNo, sCustomerNo) = FALSE) THEN exit('RESULT_INVALID_CUSTOMERNO');
        Customer.SetFilter("No.", CustomerNo);
        IF (Customer.FindFirst() = false) THEN exit('RESULT_INVALID_CUSTOMERNO');

        IF (Evaluate(PriceGroupCode, sList.ToUpper()) = FALSE) THEN exit('RESULT_INVALID_PRICELIST');

        PriceGroup.SetFilter(Code, PriceGroupCode);
        IF (PriceGroup.FindFirst() <> true) THEN begin
            PriceGroup.Init();
            PriceGroup.Validate(Code, PriceGroupCode);
            PriceGroup.Validate("Price Includes VAT", false);
            PriceGroup.Validate("Allow Invoice Disc.", true);
            PriceGroup.Validate("Allow Line Disc.", true);
            PriceGroup.Description := PriceGroupCode + ' kainoraštis';
            PriceGroup.Validate("Price Calculation Method", "Price Calculation Method"::" ");
            PriceGroup.Insert();
        end;

        PriceHeader.SetFilter("Description", sList);
        IF PriceHeader.FindFirst() THEN begin
            Customer.Validate("Customer Price Group", PriceGroup.Code);
            Customer.Modify(true);
            exit('RESULT_UPDATED');
        end
        else begin
            PriceHeader.Init();
            PriceHeader.Validate("Source Type", PriceHeader."Source Type"::"Customer Price Group");
            PriceHeader.Validate("Source Group", "Price Source Group"::Customer);
            PriceHeader.Validate(Status, PriceHeader.Status::Draft);
            PriceHeader.Validate("Price Type", "Price Type"::Sale);
            PriceHeader.Validate("Source No.", PriceGroupCode);
            PriceHeader.Validate("Assign-to No.", PriceGroupCode);
            PriceHeader.Validate("Amount Type", "Price Amount Type"::Price);
            PriceHeader.Validate("Price Includes VAT", false);
            PriceHeader.Validate(Description, sList);
            PriceHeader.Insert(true);
            Customer.Validate("Customer Price Group", PriceGroupCode);
            Customer.Modify(true);
            exit('RESULT_INSERTED');
        end;
        exit('RESULT_FAILED');
    end;

    procedure SetItemPrice(sItemNo: Text; sPrice: Text; sList: Text): Text
    var
        PriceHeader: Record "Price List Header";
        PriceLine: Record "Price List Line";
        ItemList: Record "Item";
        JsonObject: JsonObject;
        ResultText: Text;
        PriceListNo: Code[20];
        ItemNo: Code[20];
        Unit_Price: Decimal;
        PriceListManagement: Codeunit "Price List Management";
    begin
        ResultText := 'RESULT_FAILED';
        IF (Evaluate(Unit_Price, sPrice) = FALSE) THEN exit('RESULT_INVALID_PRICE');
        IF (Evaluate(ItemNo, sItemNo) = FALSE) THEN exit('RESULT_INVALID_ITEMNO');
        // Check if item exists
        ItemList.SetFilter("No.", ItemNo);
        IF (ItemList.FindFirst() = FALSE) THEN exit('RESULT_INVALID_ITEMNO');

        PriceHeader.SetFilter("Description", sList);
        IF PriceHeader.FindFirst() THEN begin
            PriceListNo := PriceHeader.Code;
            PriceLine.SetFilter("Price List Code", PriceListNo);
            PriceLine.SetFilter("Product No.", ItemNo);
            IF PriceLine.FindFirst() THEN begin
                PriceLine.Validate("Unit Price", Unit_Price);
                PriceLine.Validate("Allow Invoice Disc.", true);
                PriceLine.Validate("Allow Line Disc.", true);
                PriceLine.Modify();
                ResultText := 'RESULT_UPDATED';
            end
            ELSE BEGIN
                PriceLine.Init();
                PriceLine.Validate("Price List Code", PriceListNo);
                PriceLine.Validate("Asset Type", PriceLine."Asset Type"::Item);
                PriceLine.Validate("Product No.", ItemNo);
                PriceLine.Validate("Unit Price", Unit_Price);
                PriceLine.Validate("Allow Invoice Disc.", true);
                PriceLine.Validate("Allow Line Disc.", true);
                PriceLine.Insert();
                ResultText := 'RESULT_INSERTED';
            END;
        end;
        IF (PriceHeader.Status = PriceHeader.Status::Active) THEN begin
            IF (PriceListManagement.ActivateDraftLines(PriceHeader) <> true) THEN ResultText := 'RESULT_ACTIVATE_FAILED';
        end;

        exit(ResultText);
    end;

    procedure CheckSalesOrder(sDocumentIDs: Text): Text
    var
        PayLoadText: Text;
        ResponseText: Text;
        DocIDs: List of [Text];
        DocumentID: Code[35];
        SalesOrderNo: Code[35];
        SalesOrderLineCount: Integer;
        DocIDsLen: Integer;
        Index: Integer;
        SalesOrderInfo: JsonObject;
        SalesOrderNums: JsonArray;
        SamsCreateSalesInvoice: Codeunit SamsCreateSalesInvoice;
    begin
        IF (StrLen(sDocumentIDs) < 2) THEN exit('RESULT_BAD_LIST');
        DocIDs := sDocumentIDs.Split(' ');
        Clear(SalesOrderNums);
        Clear(PayLoadText);

        DocIDsLen := DocIDs.Count();
        FOR Index := 1 TO DocIDsLen do begin
            Clear(SalesOrderInfo);
            SalesOrderLineCount := 0;
            DocumentID := DocIDs.Get(Index);
            SalesOrderNo := SamsCreateSalesInvoice.GetSalesOrderNo(DocumentID);
            IF (SalesOrderNo <> '0') THEN
                SalesOrderLineCount := SamsCreateSalesInvoice.GetSalesOrderLineCount(SalesOrderNo);
            SalesOrderInfo.Add('documentId', DocumentID);
            SalesOrderInfo.Add('orderNum', SalesOrderNo);
            SalesOrderInfo.Add('shipmentNo', SamsCreateSalesInvoice.GetShipmentNo(DocumentID));
            SalesOrderInfo.Add('totalLines', SalesOrderLineCount);
            SalesOrderNums.Add(SalesOrderInfo);
        end;
        SalesOrderNums.WriteTo(PayLoadText);
        ResponseText := MakeRequest('setSalesOrderNums2', PayLoadText);
        IF not (ResponseText.Contains('OK')) THEN begin
            MakeRequest('setSalesOrderNums2', PayLoadText);
        end;

        exit('RESULT_OK');
    end;

    local procedure ProcessSamsSchedule()
    var
        Sch: Record "SamsSchedule";
    begin
        IF Sch.FindFirst() THEN begin

        end;
    end;

    procedure postJrnlMPC()
    var
        ItemJrnl: Record "Item Journal Line";
        DokNum: Text;
    begin
        ItemJrnl.SetFilter("Journal Template Name", 'PREKĖ');
        ItemJrnl.SetRange("Journal Batch Name", 'MPC GAMYBA');

        IF ItemJrnl.FindSet() THEN BEGIN
            REPEAT
                DokNum := ItemJrnl."Document No.";
                IF DokNum.Contains('SAMS_') THEN BEGIN
                    CODEUNIT.RUN(CODEUNIT::"Item Jnl.-Post", ItemJrnl);
                END;
            UNTIL ItemJrnl.Next() = 0;
        END;
    end;

    local procedure GetJsonToken(JsonObject: JsonObject; TokenKey: Text) JsonToken: JsonToken;
    begin
        if not JsonObject.Get(TokenKey, JsonToken) then
            Error('Could not find a token with key %1', TokenKey);
    end;

    procedure MakeRequest(apiAction: Text; payload: Text) responseText: Text;
    var
        client: HttpClient;
        request: HttpRequestMessage;
        response: HttpResponseMessage;
        contentHeaders: HttpHeaders;
        content: HttpContent;
        Ord: JsonObject;
        URL: Text;
    begin
        IF (IsSandBox()) THEN
            URL := 'https://nodejs.pcentras.lt:3000/bcapi'
        ELSE
            URL := 'https://tab.samsonas.lt:443/bcapi';
        // Add the payload to the content
        Ord.Add('SamsKey', 'S@msonasK3taviskese#Raugtas###135DaugD@ugKartu');
        Ord.Add('Action', apiAction);
        Ord.Add('Data', payload);

        Ord.WriteTo(payload);
        content.WriteFrom(payload);

        // Retrieve the contentHeaders associated with the content
        content.GetHeaders(contentHeaders);
        contentHeaders.Clear();
        contentHeaders.Add('Content-Type', 'application/json; charset=utf-8');

        request.Content := content;

        request.SetRequestUri(URL);
        request.Method := 'POST';

        client.Send(request, response);
        if (not response.IsSuccessStatusCode()) then begin
            Error('Failed to connect to BC API');
        end;

        // Read the response content as json.
        response.Content().ReadAs(responseText);
        exit(responseText);
    end;

    procedure ValidateCode(Value: Code[35]): Boolean
    var
        Regex: Codeunit Regex;
        Pattern: Text[64];
    BEGIN
        Pattern := '/[A-Z,0-9]/gi';
        if Regex.IsMatch(Value, Pattern, 0) THEN
            Message('Match')
        else
            Error('No Match')

    END;

    procedure IsSandBox(): Boolean
    var
        CodeUnitEnvironment: Codeunit "Environment Information";
    BEGIN
        exit(CodeUnitEnvironment.IsSandbox());
    END;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var ItemJournalLine: Record "Item Journal Line"; var HideDialog: Boolean; var SuppressCommit: Boolean; var IsHandled: Boolean);
    begin
        HideDialog := true;
    end;
}
