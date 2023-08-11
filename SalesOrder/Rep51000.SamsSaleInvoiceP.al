report 51000 "SAMS Sale Invoice (Posted)"
{
    Caption = 'Sales VAT Invoice (P) (Samsonas)';
    Description = 'Sales VAT Invoice (P) (Samsonas)';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/report/SamsSalesInvoiceP.Report.rdlc';
    PreviewMode = PrintLayout;

    dataset
    {
        dataitem(Header; "Sales Invoice Header")
        {
            DataItemTableView = sorting("No.");
            RequestFilterFields = "No.", "Sell-to Customer No.";
            

            column(No_Header; "No.") { }

            //Heading Values
            column(HeaderText2; GetReportTitle()) { }
            //column(HeaderDateText; LBCREPFunctions.GetDocumentDate("Posting Date", "Document Date")) { }
            column(HeaderDateText; Format(DocumentDate, 0, 9)) { }
            //column(HeaderDocNoText; LBCREPFunctions.GetDocumentNo("External Document No.", "No.", false)) { }
            column(HeaderDocNoText; DocSeriesNoText) { }
            column(YourReference; "Your Reference") { }

            //Document Values
            column(LCYCode_GLSetup; CurrencyCodeLCY) { }
            column(CurrencyCode_Header; CurrencyCode) { }
            column(DueDate; LBCREPFunctions.FormatDueDate("Payment Terms Code", "Due Date")) { }
            column(PaymentTermsCode; "Payment Terms Code") { }
            column(PaymentTerms; LBCREPFunctions.GetPaymentTerms("Payment Terms Code", LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }
            column(PaymentMethodCode; "Payment Method Code") { }
            column(PaymentMethod; LBCREPFunctions.GetPaymentMethod("Payment Method Code", LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }
            column(ShipmentMethodCode; "Shipment Method Code") { }
            column(ShipmentMethod; LBCREPFunctions.GetShipmentMethod("Shipment Method Code", LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }

            //Switch Values
            column(PrintWaybInfo; PrintWaybInfo) { }
            column(PrintHeaderComments; PrintHeaderComments) { }
            column(PrintLineComments; PrintLineComments) { }
            column(PrintVATPercCol; PrintVATPercCol) { }
            column(PrintLotSerNos; PrintLotSerNos <> PrintLotSerNos::None) { }
            column(PrintAmountInWords; PrintAmountInWords) { }
            column(PrintWeights; PrintWeights) { }
            column(PrintBillReceived; PrintBillReceived) { }
            column(PrintOrderPrepared; PrintOrderPrepared) { }
            column(PrintVATClause; PrintVATClause) { }
            column(PricesIncludedVAT; "Prices Including VAT") { }
            column(PrintPayer; PrintPayer) { }

            //Parties Values
            column(FullName_CompanyInfo; LBCREPFunctions.FormFullName(CompanyInformation.Name, CompanyInformation."Name 2")) { }
            column(FullAddress_CompanyInfo; LBCREPFunctions.GetFullAddress(CompanyInformation.Address, CompanyInformation."Address 2", CompanyInformation."Post Code", CompanyInformation.City, CompanyInformation."Country/Region Code", true, LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }
            column(RegistrationNo_CompanyInfo; CompanyInformation."Registration No.") { }
            column(VATRegistrationNo_CompanyInfo; CompanyInformation."VAT Registration No.") { }
            column(CompanyRegisterInfo_CompanyInfo; LBCREPFunctions.GetCompanyRegisterInfo()) { }
            column(Picture_CompanyInfo; CompanyInformation.Picture) { }
            column(PhoneNo_CompanyInfo; CompanyInformation."Phone No.") { }
            column(FaxNo_CompanyInfo; CompanyInformation."Fax No.") { }
            column(EMail_CompanyInfo; CompanyInformation."E-Mail") { }
            column(BankName_Header; "Bank Name LBC") { }
            column(SWIFTCode_Header; "SWIFT Code LBC") { }
            column(IBAN_Header; "IBAN LBC") { }

            column(No_Buyer; "Sell-to Customer No.") { }
            column(FullName_Buyer; LBCREPFunctions.FormFullName("Sell-to Customer Name", "Sell-to Customer Name 2")) { }
            column(FullAddress_Buyer; LBCREPFunctions.GetFullAddress("Sell-to Address", "Sell-to Address 2", "Sell-to Post Code", "Sell-to City", "Sell-to Country/Region Code", true, LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }
            column(RegistrationNo_Buyer; CustomerSell."Registration No. LBC") { }
            column(VATRegistrationNo_Buyer; CustomerSell."VAT Registration No.") { }

            column(No_Payer; "Bill-to Customer No.") { }
            column(FullName_Payer; LBCREPFunctions.FormFullName("Bill-to Name", "Bill-to Name 2")) { }
            column(FullAddress_Payer; LBCREPFunctions.GetFullAddress("Bill-to Address", "Bill-to Address 2", "Bill-to Post Code", "Bill-to City", "Bill-to Country/Region Code", true, LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }
            column(RegistrationNo_Payer; CustomerBill."Registration No. LBC") { }
            column(VATRegistrationNo_Payer; CustomerBill."VAT Registration No.") { }

            column(FullName_ShipTo; LBCREPFunctions.FormFullName("Ship-to Name", "Ship-to Name 2")) { }
            column(FullAddress_ShipTo; LBCREPFunctions.GetFullAddress("Ship-to Address", "Ship-to Address 2", "Ship-to Post Code", "Ship-to City", "Ship-to Country/Region Code", true, LBCREPFunctions.GetReportLanguage(ReportLanguage, "Language Code"))) { }

            // Customer Contract
            column(CustomerContract; "Customer Contracts") { }

            //Totals Values
            column(TotalSubTotal; TotalSubTotal) { }
            column(TotalAmount; TotalAmount) { }
            column(TotalAmountInclVAT; TotalAmountInclVAT) { }
            column(TotalAmountVAT; TotalAmountVAT) { }
            column(TotalInvDiscAmount; TotalInvDiscAmount) { }
            column(TotalLineDiscountAmount; TotalLineDiscountAmount) { }
            column(TotalVATAmount; TotalVATAmount) { }
            column(TotalVATAmountExempt; TotalVATAmountExempt) { }
            column(TotalVATAmountReverse; TotalVATAmountReverse) { }

            column(Formated_TotalSubTotal; LBCREPFunctions.FormatAmount(TotalSubTotal, Header."Currency Code")) { }
            column(Formated_TotalAmount; LBCREPFunctions.FormatAmount(TotalAmount, Header."Currency Code")) { }
            column(Formated_TotalAmountInclVAT; LBCREPFunctions.FormatAmount(TotalAmountInclVAT, Header."Currency Code")) { }
            column(Formated_TotalAmountVAT; LBCREPFunctions.FormatAmount(TotalAmountVAT, Header."Currency Code")) { }
            column(Formated_TotalInvDiscAmount; LBCREPFunctions.FormatAmount(TotalInvDiscAmount, Header."Currency Code")) { }
            column(Formated_TotalLineDiscountAmount; LBCREPFunctions.FormatAmount(TotalLineDiscountAmount, Header."Currency Code")) { }
            column(Formated_TotalVATAmount; LBCREPFunctions.FormatAmount(TotalVATAmount, Header."Currency Code")) { }
            column(Formated_TotalVATAmountExempt; LBCREPFunctions.FormatAmount(TotalVATAmountExempt, Header."Currency Code")) { }
            column(Formated_TotalVATAmountReverse; LBCREPFunctions.FormatAmount(TotalVATAmountReverse, Header."Currency Code")) { }

            //WayBill Values
            column(OrderPreparedByText; OrderPreparedByText) { }
            column(InvIssuedByText; InvIssuedByText) { }
            column(InvReceivedByText; InvReceivedByText) { }
            column(WaybIssueDateTime; LBCREPFunctions.FormDateTime("Waybill Document Date LBC", "Waybill Document Time LBC")) { }
            column(WaybIssueLocationText; DocIssueLocationText) { }
            column(WaybUnloadDateTime; LBCREPFunctions.FormDateTime("Waybill Unload Date LBC", "Waybill Unload Time LBC")) { }
            column(WaybUnloadLocationText; UnloadLocationText) { }
            column(WaybLoadDateTime; LBCREPFunctions.FormDateTime("Waybill Load Date LBC", "Waybill Load Time LBC")) { }
            column(WaybLoadLocationText; LoadLocationText) { }
            column(WaybItemsGivenByText; ItemsGivenByText) { }
            column(WaybItemsAcceptedByText; ItemsAcceptedByText) { }
            column(WaybVehicleInfoText; VehicleInfoText) { }
            column(WaybDriverText; DriverText) { }

            //Heading Lables
            column(IssueDateCaption; HeaderIssueDateCaptionLbl) { }
            column(PageCaption; HeaderPageCaptionLbl) { }
            column(ContinuedCaption; ContinuedCaptionLbl) { }
            column(YourReferenceCaption; YourReferenceLbl) { }

            //Parties Labels
            column(SellerCaption; SellerCaptionLbl) { }
            column(BuyerPayerCaption; BuyerPayerCaptionLbl) { }
            column(BuyerRecipientCaption; BuyerRecipientCaptionLbl) { }
            column(BuyerShipCaption; BuyerShipCaptionLbl) { }
            column(PhoneNoCaption; PhoneNoCaptionLbl) { }
            column(FaxNoCaption; FaxNoCaptionLbl) { }
            column(EMailCaption; EMailCaptionLbl) { }
            column(RegistrationNoCaption; RegistrationNoCaptionLbl) { }
            column(VATRegistrationNoCaption; VATRegistrationNoCaptionLbl) { }
            column(RegisterInfoCaption; RegisterInfoCaptionLbl) { }
            column(BankNameCaption; BankNameCaptionLbl) { }
            column(SWIFTcodeCaption; SWIFTcodeCaptionLbl) { }
            column(AccNoTBSNCaption; AccNoIBANCaptionLbl) { }
            column(PaymentTypeCaption; PaymentTypeCaptionLbl) { }
            column(PaymentTermCaption; PaymentTermCaptionLbl) { }
            column(ShipmentMethodCaption; ShipmentMethodLbl) { }

            //Lines Labels
            column(CodeCaption; CodeCaptionLbl) { }
            column(DescriptionCaption; DescriptionCaptionLbl) { }
            column(UnitOfMeasCaption; UnitOfMeasCaptionLbl) { }
            column(QuantityCaption; QuantityCaptionLbl) { }
            column(UnitPriceInclVATCaption; UnitPriceInclVATCaptionLbl) { }
            column(UnitPriceExclVATCaption; UnitPriceExclVATCaptionLbl) { }
            column(DiscountPercCaption; DiscountPercCaptionLbl) { }
            column(VATPercCaption; VATPercCaptionLbl) { }
            column(AmExclVATInclDiscCaption; AmExclVATInclDiscCaptionLbl) { }
            column(RequestedReceiptDateLinesCaption; RequestedReceiptDateLinesLbl) { }

            //Totals Labels
            column(SubTotalCaption; SubTotalCaptionLbl) { }
            column(TotAmountCaption; TotAmountCaptionLbl) { }
            column(TotAmExclDiscCaption; TotAmExclDiscCaptionLbl) { }
            column(DiscountAmountCaption; DiscountAmountCaptionLbl) { }
            column(InvDiscAmountCaption; InvDiscAmountCaptionLbl) { }
            column(TotAmountInclDiscCaption; TotAmountInclDiscCaptionLbl) { }
            column(TotAmountInclVATCaption; TotAmountInclVATCaptionLbl) { }
            column(VATAmountLCYCaption; VATAmountLCYCaptionLbl) { }

            //Additional Info Labels
            column(ExpirationDateCaption; ExpirationDateLbl) { }
            column(LotNoCaption; LotNoLbl) { }
            column(CommentsCaption; CommentsCaptionLbl) { }
            column(VATClauseLbl; VATClauseLbl) { }
            column(NetWeightLbl; TotalNetWeightLbl) { }
            column(GrossWeightLbl; TotalGrossWeightLbl) { }

            //WayBill Labels
            column(OrderSignatureCaptionLbl; OrderSignatureCaptionLbl) { }
            column(OrderPreparedByCaptionLbl; OrderPreparedByCaptionLbl) { }
            column(InvSignatureCaptionLbl; InvSignatureCaptionLbl) { }
            column(InvIssuedByCaptionLbl; InvIssuedByCaptionLbl) { }
            column(InvReceivedByCaptionLbl; InvReceivedByCaptionLbl) { }
            column(SignatureCaptionLbl; SignatureCaptionLbl) { }
            column(DocIssueDateTimePlaceCaptionLbl; DocIssueDateTimePlaceCaptionLbl) { }
            column(UnloadDateTimePlaceCaptionLbl; UnloadDateTimePlaceCaptionLbl) { }
            column(LoadDateTimePlaceCaptionLbl; LoadDateTimePlaceCaptionLbl) { }
            column(VehicleInfoCaptionLbl; VehicleInfoCaptionLbl) { }
            column(DriverLbl; DriverLbl) { }
            column(ItemsGivenByCaptionLbl; ItemsGivenByCaptionLbl) { }
            column(ItemsAcceptedByCaptionLbl; ItemsAcceptedByCaptionLbl) { }

            //Additional UNI Values & Labels
            column(DimensionName; DimensionName) { }
            column(DimensionValueName; DimensionValueName) { }
            column(ShortcutDimension1Code; "Shortcut Dimension 1 Code") { }
            column(ShortcutDimension2Code; "Shortcut Dimension 2 Code") { }
            column(PrintReceiver; PrintReceiver) { }
            dataitem(CopyLoop; "Integer")
            {
                DataItemTableView = sorting(Number);
                column(Number_CopyLoop; Number) { }
                dataitem(Lines; "Sales Invoice Line")
                {
                    DataItemLink = "Document No." = field("No.");
                    DataItemLinkReference = Header;
                    DataItemTableView = sorting("Document No.", "Line No.");
                    column(LineNo_Lines; LineNo) { }
                    // Customer Contract
                    column(ContractNo; "Contract No.") { }
                    column(ContractEntryNo; "Contract Item Entry No.") { }
                    column(ContractItemDescription; "Contract Item Description") { }
                    // 
                    column(Type_Lines; TypeNo) { }
                    column(No_Lines; ItemNo) { }
                    column(Description_Lines; LBCREPFunctions.GetLineDescription(Lines, LBCREPFunctions.GetReportLanguage(ReportLanguage, Header."Language Code"))) { }
                    column(UnitPrice_Lines_Caption; FieldCaption("Unit Price")) { }
                    column(LineAmount_Lines_Caption; FieldCaption("Line Amount")) { }

                    column(Quantity_Lines; Sign * Quantity * SignOptionPrint) { DecimalPlaces = 0 : 5; }
                    column(UnitPrice_Lines; UnitPrice * SignOptionPrint) { }
                    column(UnitPriceExclVAT_Lines; UnitPriceExclVAT * SignOptionPrint) { }
                    column(Amount_Lines; Sign * Amount) { }
                    column(LineAmount_Lines; Sign * "Line Amount") { }
                    column(LineDiscountPerc_Lines; "Line Discount %") { }
                    column(LineDiscountAmount_Lines; Sign * "Line Discount Amount") { }
                    column(InvDiscountAmount_Lines; "Inv. Discount Amount") { }

                    column(Formated_Quantity_Lines; LBCREPFunctions.FormatQuantity(Sign * Quantity * SignOptionPrint)) { }
                    column(Formated_UnitPrice_Lines; LBCREPFunctions.FormatUnitAmount(UnitPrice * SignOptionPrint, Header."Currency Code")) { }
                    column(Formated_UnitPriceExclVAT_Lines; LBCREPFunctions.FormatUnitAmount(UnitPriceExclVAT * SignOptionPrint, Header."Currency Code")) { }
                    column(Formated_Amount_Lines; LBCREPFunctions.FormatUnitAmount(Sign * Amount, Header."Currency Code")) { }
                    column(Formated_LineAmount_Lines; LBCREPFunctions.FormatAmount(Sign * "Line Amount", Header."Currency Code")) { }
                    column(Formated_LineDiscountPerc_Lines; LBCREPFunctions.FormatPercent("Line Discount %")) { }
                    column(Formated_LineDiscountAmount_Lines; LBCREPFunctions.FormatAmount(Sign * "Line Discount Amount", Header."Currency Code")) { }
                    column(Formated_InvDiscountAmount_Lines; LBCREPFunctions.FormatAmount("Inv. Discount Amount", Header."Currency Code")) { }

                    column(UOMName_Lines; LBCREPFunctions.GetUOMName("Unit of Measure Code", LBCREPFunctions.GetReportLanguage(ReportLanguage, Header."Language Code"))) { }
                    column(VATPerc_Lines; LineVATPercent) { }
                    column(LotText; LotText) { }
                    column(GroupField; GroupField) { }
                    dataitem(TempTrackingSpecification; "Tracking Specification")
                    {
                        DataItemTableView = sorting("Lot No.", "Serial No.");
                        UseTemporary = true;
                        column(EntryNo_TempTrackingSpecBuffer; TempTrackingSpecification."Entry No.") { }
                        column(ExpirationDate_TempTrackingSpecBuffer; LBCREPFunctions.FormatLotSN(Format(TempTrackingSpecification."Expiration Date", 0, 9), Format(TempTrackingSpecification."Warranty Date", 0, 9))) { }
                        column(LotNo_TempTrackingSpecBuffer; LBCREPFunctions.FormatLotSN(TempTrackingSpecification."Lot No.", TempTrackingSpecification."Serial No.")) { }
                        column(QuantityBase_TempTrackingSpecBuffer; TempTrackingSpecification."Quantity (Base)")
                        {
                            DecimalPlaces = 0 : 5;
                        }

                        trigger OnPreDataItem()
                        begin
                            if (PrintLotSerNos <> PrintLotSerNos::Detailed) then
                                CurrReport.Break();

                            TempTrackingSpecification.SetRange("Source Ref. No.", Lines."Line No.");
                        end;

                        trigger OnAfterGetRecord()
                        begin
                            if TempTrackingSpecification."Expiration Date" = 0D then
                                TempTrackingSpecification.InitExpirationDate();
                        end;
                    }
                    dataitem(LinesCommentLine; "Sales Comment Line")
                    {
                        DataItemLink = "No." = field("Document No."), "Document Line No." = field("Line No.");
                        DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const("Posted Invoice"));
                        column(LineNo_LinesCommentLine; "Line No.") { }
                        column(Comment_LinesCommentLine; Comment) { }
                    }

                    trigger OnAfterGetRecord()
                    var
                        ItemReference: Record "Item Reference";
                    begin
                        if (Type = Type::" ") and (Description = '') then
                            CurrReport.Skip();

                        if (Type <> Type::" ") and (("No." = '') or (Quantity = 0)) then
                            CurrReport.Skip();

                        if (Type = Type::" ") and (not PrintLineComments) then
                            CurrReport.Skip();

                        LineNo := "Line No.";
                        TypeNo := Type.AsInteger();

                        ItemNo := LBCREPFunctions.FindItemNo(Type = Type::Item, "No.", "Variant Code", false, '');

                        LotText := '';
                        if (PrintLotSerNos = PrintLotSerNos::Simple) and (Type = Type::Item) then
                            LotText := LBCREPTracking.FormTrackingInfoLine(TempTrackingSpecification, "Line No.");

                        if not VATPostingSetup.Get("VAT Bus. Posting Group", "VAT Prod. Posting Group") then
                            VATPostingSetup.Init();

                        case true of
                            LBCREPFunctions.GetIfReverseChargeVAT(VATPostingSetup):
                                begin
                                    LineVATPercent := Format(VATPostingSetup."VAT %");
                                    LBCREPFunctions.FillVATAmountLineBuf(TempVATAmountLineReverse, Lines, true, VATPostingSetup."VAT %");
                                    ItemNo := '* ' + ItemNo;
                                end;
                            ("VAT %" = 0) and LBCREPFunctions.GetIfExemptfromVAT(VATPostingSetup):
                                begin
                                    LineVATPercent := '-';
                                    LBCREPFunctions.FillVATAmountLineBuf(TempVATAmountLineExempt, Lines, false, VATPostingSetup."VAT %");
                                end;
                            else begin
                                LineVATPercent := Format(Lines."VAT %");
                                LBCREPFunctions.FillVATAmountLineBuf(TempVATAmountLine, Lines, false, VATPostingSetup."VAT %");
                            end;
                        end;

                        if PrintVATClause then
                            TempREPVATClauseBuffer.FillTempVATClauseBuf("VAT Bus. Posting Group", "VAT Prod. Posting Group");

                        UnitPrice := "Unit Price";

                        if Header."Prices Including VAT" then
                            UnitPriceExclVAT := Round(UnitPrice / (1 + "VAT %" / 100), Currency."Unit-Amount Rounding Precision")
                        else
                            UnitPriceExclVAT := Round(UnitPrice, Currency."Unit-Amount Rounding Precision");

                        if (Type = Type::Item) then begin
                            TotalGrossWeight += Quantity * "Gross Weight";
                            TotalNetWeight += Quantity * "Net Weight";
                        end;

                        if PrintLineComments then begin
                            if (Type <> Type::" ") then
                                if ("SMN Group Field No." <> 0) and not "SMN Group Field" then
                                    GroupField := true;

                            if "SMN Group Field" then begin
                                Amount := "SMN Group Amount";
                                "Line Amount" := "SMN Group Amount";
                                UnitPrice := Round("SMN Group Unit Price", 0.00001);
                                Quantity := "SMN Group Quantity";
                                LineNo := "SMN Group Field No.";
                                LineVATPercent := Format("SMN Group VAT %");
                                TypeNo := 1;
                                GroupField := false;
                            end;

                            if not "SMN Group Field" then begin
                                TotalSubTotal += "Line Amount";
                                TotalInvDiscAmount -= "Inv. Discount Amount";
                                TotalLineDiscountAmount += "Line Discount Amount";
                                TotalAmount += Amount;
                                TotalAmountVAT += "Amount Including VAT" - Amount;
                                TotalAmountInclVAT += "Amount Including VAT";
                            end;
                        end
                        else begin
                            TotalSubTotal += "Line Amount";
                            TotalInvDiscAmount -= "Inv. Discount Amount";
                            TotalLineDiscountAmount += "Line Discount Amount";
                            TotalAmount += Amount;
                            TotalAmountVAT += "Amount Including VAT" - Amount;
                            TotalAmountInclVAT += "Amount Including VAT";
                        end;

                        case SalesReceivablesSetup."SMN Print Item Ref. No." of
                            SalesReceivablesSetup."SMN Print Item Ref. No."::Barcode:
                                begin
                                    ItemReference.SetRange("Item No.", Lines."No.");
                                    ItemReference.SetRange("Variant Code", Lines."Variant Code");
                                    ItemReference.SetRange("Unit of Measure", Lines."Unit of Measure Code");
                                    ItemReference.SetRange("Reference Type", Lines."Item Reference Type"::"Bar Code");
                                    ItemReference.SetRange("Reference No.", Lines."Item Reference No.");
                                    if ItemReference.FindFirst() then
                                        ItemNo := ItemReference."Reference No."
                                    else begin
                                        ItemReference.SetRange("Reference No.");
                                        if ItemReference.FindFirst() then
                                            ItemNo := ItemReference."Reference No."
                                    end;
                                end;
                            SalesReceivablesSetup."SMN Print Item Ref. No."::Customer:
                                begin
                                    ItemReference.SetRange("Item No.", Lines."No.");
                                    ItemReference.SetRange("Variant Code", Lines."Variant Code");
                                    ItemReference.SetRange("Unit of Measure", Lines."Unit of Measure Code");
                                    ItemReference.SetRange("Reference Type", Lines."Item Reference Type"::Customer);
                                    ItemReference.SetRange("Reference Type No.", Lines."Item Reference Type No.");
                                    ItemReference.SetRange("Reference No.", Lines."Item Reference No.");
                                    if ItemReference.FindFirst() then
                                        ItemNo := ItemReference."Reference No.";
                                end;
                        end;

                        if SalesReceivablesSetup."SMN Print Receiver" = true then
                            PrintReceiver := true
                        else
                            PrintReceiver := false;

                        if SalesReceivablesSetup."SMN Print Payer" = true then
                            PrintPayer := true
                        else
                            PrintPayer := false;
                    end;

                    trigger OnPreDataItem()
                    begin
                        AddLoadFields("SMN Group Field No.", "SMN Group Field", "SMN Group Amount", "SMN Group Quantity", "SMN Group Unit Price", "SMN Group VAT %");
                        ClearValuesOnLines();
                    end;
                }
                dataitem(TempVATAmountLine; "VAT Amount Line")
                {
                    DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);
                    UseTemporary = true;
                    column(LineAmount_TempVATAmountLine; Sign * "Line Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmount_TempVATAmountLine; Sign * "VAT Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATBase_TempVATAmountLine; Sign * "VAT Base")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmountLCY_VatAmountLine; Sign * VATAmountLCY) { }
                    column(VATBaseLCY_VatAmountLine; Sign * VATBaseLCY) { }
                    column(VATPct_VatAmountLine; "VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(BaseAmountCaption; BaseAmountCaptionLbl) { }
                    column(TotAmInclDiscRateCaption; StrSubstNo(TotAmInclDiscRateCaptionLbl, "VAT %")) { }
                    column(VATCaption; StrSubstNo(VATCaptionLbl, "VAT %")) { }

                    trigger OnAfterGetRecord()
                    begin
                        VATBaseLCY :=
                          GetBaseLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");
                        VATAmountLCY :=
                          GetAmountLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");

                        TotalVATAmount += "VAT Amount";
                        TotalVATAmountLCY += VATAmountLCY;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(VATBaseLCY);
                        Clear(VATAmountLCY);
                        Clear(TotalVATAmount);
                        Clear(TotalVATAmountLCY);
                    end;
                }
                dataitem(TempVATAmountLineExempt; "VAT Amount Line")
                {
                    DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);
                    UseTemporary = true;
                    column(LineAmount_TempVATAmountLineExempt; Sign * "Line Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmount_TempVATAmountLineExempt; Sign * "VAT Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }

                    column(VATBase_TempVATAmountLineExempt; Sign * "VAT Base")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmountLCY_TempVATAmountLineExempt; Sign * VATAmountLCYExempt) { }
                    column(VATBaseLCY_TempVATAmountLineExempt; Sign * VATBaseLCYExempt) { }
                    column(VATPct_TempVATAmountLineExempt; "VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(BaseAmountCaptionExempt; BaseAmountCaptionLbl) { }
                    column(TotAmInclDiscRateCaptionExempt; StrSubstNo(TotAmInclDiscRateCaptionLbl, "VAT %")) { }
                    column(VATCaptionExempt; VATExemptCaptionLbl) { }

                    trigger OnAfterGetRecord()
                    begin
                        VATBaseLCYExempt :=
                          GetBaseLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");
                        VATAmountLCYExempt :=
                          GetAmountLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");

                        TotalVATAmountExempt += "VAT Amount";
                        TotalVATAmountLCYExempt += VATAmountLCYExempt;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(VATBaseLCYExempt);
                        Clear(VATAmountLCYExempt);
                        Clear(TotalVATAmountLCYExempt);
                        Clear(TotalVATAmountExempt);
                    end;
                }
                dataitem(TempVATAmountLineReverse; "VAT Amount Line")
                {
                    DataItemTableView = sorting("VAT Identifier", "VAT Calculation Type", "Tax Group Code", "Use Tax", Positive);
                    UseTemporary = true;
                    column(LineAmount_TempVATAmountLineReverse; Sign * "Line Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmount_TempVATAmountLineReverse; Sign * "VAT Amount")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }

                    column(VATBase_TempVATAmountLineReverse; Sign * "VAT Base")
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(VATAmountLCY_TempVATAmountLineReverse; Sign * VATAmountLCYReverse) { }
                    column(VATBaseLCY_TempVATAmountLineReverse; Sign * VATBaseLCYReverse) { }
                    column(VATPct_TempVATAmountLineReverse; "VAT %")
                    {
                        DecimalPlaces = 0 : 5;
                    }
                    column(BaseAmountCaptionReverse; BaseAmountCaptionLbl) { }
                    column(TotAmInclDiscRateCaptionReverse; StrSubstNo(TotAmInclDiscRateCaptionLbl, "VAT %")) { }
                    column(VATCaptionReverse; StrSubstNo(VATReverseCaptionLbl, "VAT %")) { }

                    trigger OnAfterGetRecord()
                    begin
                        VATBaseLCYReverse :=
                          GetBaseLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");
                        VATAmountLCYReverse :=
                          GetAmountLCY(
                            Header."Posting Date", Header."Currency Code",
                            Header."Currency Factor");

                        TotalVATAmountReverse += "VAT Amount";
                        TotalVATAmountLCYReverse += VATAmountLCYReverse;
                    end;

                    trigger OnPreDataItem()
                    begin
                        Clear(VATBaseLCYReverse);
                        Clear(VATAmountLCYReverse);
                        Clear(TotalVATAmountLCYReverse);
                        Clear(TotalVATAmountReverse);
                    end;
                }
                dataitem(TempReportTotalsBuffer; "Report Totals Buffer")
                {
                    DataItemTableView = sorting("Line No.");
                    UseTemporary = true;
                    column(Description_ReportTotalsLine; Description) { }
                    column(Amount_ReportTotalsLine; Amount)
                    {
                        AutoFormatExpression = Header."Currency Code";
                        AutoFormatType = 1;
                    }
                    column(AmountFormatted_ReportTotalsLine; "Amount Formatted") { }
                    column(FontBold_ReportTotalsLine; "Font Bold") { }
                    column(FontItalics_ReportTotalsLine; "Font Italics") { }
                    column(FontUnderline_ReportTotalsLine; "Font Underline") { }

                    trigger OnPreDataItem()
                    begin
                        CreateReportTotalsBuffer();
                    end;
                }
                dataitem(AmountToWords; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(Number_AmountToWords; Number) { }
                    column(TotAmountLCY_AmountToWords; LBCREPFunctions.FormatAmountToPay(Sign * TotalAmountLCY)) { }
                    column(TotAmountToPay_AmountToWords; StrSubstNo(AmountInWordsCaptionLbl, Currency.GetCurrencySymbol(), LBCREPFunctions.FormatAmountToPay(Sign * TotalAmountToPay))) { }
                    column(TotAmountToPayLCY_AmountToWords; StrSubstNo(AmountInWordsCaptionLbl, LBCREPFunctions.GetLCYCurrencySymbol(), LBCREPFunctions.FormatAmountToPay(Sign * TotalAmountToPayLCY))) { }
                    column(TotAmountToPayText_AmountToWords; LBCREPFunctions.Amount2WordsLanguage(Sign * TotalAmountToPay, CurrencyCode, CurrReport.Language())) { }
                    column(TotAmountToPayLCYText_AmountToWords; LBCREPFunctions.Amount2WordsLanguage(Sign * TotalAmountToPayLCY, CurrencyCodeLCY, CurrReport.Language())) { }

                    trigger OnAfterGetRecord()
                    begin
                        TotalAmountLCY := LBCREPFunctions.ExchangeAmtFCYToLCY(Header."Posting Date", Header."Currency Code", TotalAmount, Header."Currency Factor");
                        TotalAmountToPay := TotalAmount + TotalVATAmount;
                        TotalAmountToPayLCY := LBCREPFunctions.ExchangeAmtFCYToLCY(Header."Posting Date", Header."Currency Code", TotalAmountToPay, Header."Currency Factor")
                    end;
                }
                dataitem(TotalWeight; "Integer")
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(Number_TotalWeight; Number) { }
                    column(TotalGrossWeight; TotalGrossWeight) { }
                    column(TotalNetWeight; TotalNetWeight) { }
                }
                dataitem(ReportNote; Integer)
                {
                    DataItemTableView = sorting(Number) where(Number = const(1));
                    column(Number_ReportNote; Number) { }
                    column(ReportNoteText; LBCREPFunctions.GetComment(StandTextCode, LBCREPFunctions.GetReportLanguage(ReportLanguage, Header."Language Code"))) { }
                }
                dataitem(HeaderCommentLine; "Sales Comment Line")
                {
                    DataItemLink = "No." = field("No.");
                    DataItemLinkReference = Header;
                    DataItemTableView = sorting("Document Type", "No.", "Document Line No.", "Line No.") where("Document Type" = const("Posted Invoice"), "Document Line No." = const(0));
                    column(Comment_HeaderCommentLine; Comment) { }

                    trigger OnPreDataItem()
                    begin
                        if not PrintHeaderComments then
                            CurrReport.Break();
                    end;
                }
                dataitem(TempREPVATClauseBuffer; "LBC REP VAT Clause Buffer")
                {
                    DataItemTableView = sorting("VAT Bus. Posting Group", "VAT Prod. Posting Group", "VAT Clause Code");
                    UseTemporary = true;
                    column(VATClauseDescription; VATClauseDescription) { }

                    trigger OnAfterGetRecord()
                    begin
                        VATClauseDescription :=
                          TempREPVATClauseBuffer.GetDescription(Header, LBCREPFunctions.GetReportLanguage(ReportLanguage, Header."Language Code"));

                        if VATClauseDescription = '' then
                            CurrReport.Skip();
                    end;

                    trigger OnPreDataItem()
                    begin
                        TempREPVATClauseBuffer.Reset();
                    end;
                }

                trigger OnPreDataItem()
                begin
                    NoOfLoops := LBCREPFunctions.CalcNoOfLoops(NoOfCopies, 0);
                    SetRange(Number, 1, NoOfLoops);
                end;
            }

            trigger OnAfterGetRecord()
            var
                DocumentNoLbl: Label 'No. %1', Comment = '%1 - Document No.';
                UnknownParameterErr: Label 'Unknown Parameter in Setup %1', Comment = '%1 - Setup Field';
            begin
                ClearValuesOnHeader();

                SetReportLanguage(Header."Language Code");

                LBCREPFunctions.GetCustomerInfo("Sell-to Customer No.", "Bill-to Customer No.", CustomerSell, CustomerBill);

                LBCREPFunctions.ReadCurrency("Currency Code", "Currency Factor", Currency, CurrencyCode, CurrencyCodeLCY);

                GetPreparedInfo(Header);
                GetSignersInfo(Header);
                GetWaybillInfo(Header);

                if PrintLotSerNos <> PrintLotSerNos::None then
                    LBCREPTracking.RetrieveDocumentItemTracking(TempTrackingSpecification, Header."No.", Database::"Sales Invoice Header", 0);

                if not IsReportInPreviewMode() then
                    Codeunit.Run(Codeunit::"Sales Inv.-Printed", Header);

                case SalesReceivablesSetup.UseDocumentNoLBC of
                    SalesReceivablesSetup.UseDocumentNoLBC::"Document No.":
                        DocSeriesNoText := StrSubstNo(DocumentNoLbl, "No.");
                    SalesReceivablesSetup.UseDocumentNoLBC::"External Document No.":
                        DocSeriesNoText := StrSubstNo(DocumentNoLbl, "External Document No.");
                    else
                        Error(UnknownParameterErr, SalesReceivablesSetup.FieldCaption(UseDocumentNoLBC))
                end;

                case SalesReceivablesSetup.UseDateLBC of
                    SalesReceivablesSetup.UseDateLBC::"Document Date":
                        DocumentDate := "Document Date";
                    SalesReceivablesSetup.UseDateLBC::"Posting Date":
                        DocumentDate := "Posting Date";
                    else
                        Error(UnknownParameterErr, SalesReceivablesSetup.FieldCaption(UseDateLBC))
                end;

                if PrintDimensionName then begin
                    DimensionName := '';
                    DimensionValueName := '';
                    DimensionSetEntry.SetRange("Dimension Set ID", Header."Dimension Set ID");
                    DimensionSetEntry.SetRange("Dimension Value Code", Header."Shortcut Dimension 1 Code");
                    if DimensionSetEntry.FindFirst() then begin
                        DimensionSetEntry.CalcFields("Dimension Name", "Dimension Value Name");
                        DimensionName := DimensionSetEntry."Dimension Name";
                        if DimensionName <> '' then
                            DimensionName += ':';
                        DimensionValueName := DimensionSetEntry."Dimension Value Name"
                    end;
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(Content)
            {
                group(OptionsCtrl)
                {
                    Caption = 'Options';
                    field(NoOfCopiesCtrl; NoOfCopies)
                    {
                        ApplicationArea = All;
                        Caption = 'No. of Add. Copies';
                        ToolTip = 'No. of Add. Copies';
                    }
                    field(PrintHeaderCommentsCtrl; PrintHeaderComments)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Comments';
                        ToolTip = 'Print Comments';
                    }
                    field(PrintLineCommentsCtrl; PrintLineComments)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Line Comments';
                        ToolTip = 'Print Line Comments';
                    }
                    field(PrintLotSerNosCtrl; PrintLotSerNos)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Item Lot/Serial Nos.';
                        ToolTip = 'Print Item Lot/Serial Nos.';
                    }
                    field(PrintBillReceivedCtrl; PrintBillReceived)
                    {
                        ApplicationArea = All;
                        Caption = 'Print "Bill Received"';
                        ToolTip = 'Print "Bill Received"';
                    }
                    field(PrintWaybInfoCtrl; PrintWaybInfo)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Waybill Information';
                        ToolTip = 'Print Waybill Information';
                    }
                    field(PrintVATClauseCtrl; PrintVATClause)
                    {
                        ApplicationArea = All;
                        Caption = 'Print VAT Clause';
                        ToolTip = 'Print VAT Clause';
                    }
                    field(PrintDimensionNameCtrl; PrintDimensionName)
                    {
                        ApplicationArea = All;
                        Caption = 'Print Dimension Name';
                        ToolTip = 'Print Dimension Name';
                    }
                    field(StandTextCodeCtrl; StandTextCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Standard Text';
                        ToolTip = 'Standard Text';
                        TableRelation = "Standard Text";
                    }
                    field(ReportLanguageCtrl; ReportLanguage)
                    {
                        ApplicationArea = All;
                        Caption = 'Report Language';
                        ToolTip = 'Report Language';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            LBCREPFunctions.InitNoOfCopies(NoOfCopies);
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        CompanyInformation.SetAutoCalcFields(Picture);
        CompanyInformation.Get();

        PrintOrderPrepared := false;
        PrintBillReceived := false; //true
        PrintAdvInvoice := false;
        PrintReportTotalsBuffer := true;
        PrintAmountInWords := true;
        PrintWeights := false;
    end;

    trigger OnPreReport()
    begin
        SalesReceivablesSetup.Get();

        Sign := LBCREPFunctions.GetSignByTable(Header);

        case SignOption of
            SignOption::Quantity:
                SignOptionPrint := 1;
            SignOption::Price:
                SignOptionPrint := -1;
        end;
    end;

    var
        CompanyInformation: Record "Company Information";
        Currency: Record Currency;
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerSell: Record Customer;
        CustomerBill: Record Customer;
        DimensionSetEntry: Record "Dimension Set Entry";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        LBCREPFunctions: Codeunit "LBC REP Functions";
        LBCREPTracking: Codeunit "LBC REP Tracking";
        StandTextCode: Code[20];
        CurrencyCode: Code[10];
        CurrencyCodeLCY: Code[10];
        DocumentDate: Date;
        LineNo: Integer;
        ItemNo: Text;
        LotText: Text;
        VATClauseDescription: Text;

        OrderPreparedByText: Text;
        InvIssuedByText: Text;
        InvReceivedByText: Text;
        DocIssueLocationText: Text;
        UnloadLocationText: Text;
        LoadLocationText: Text;
        ItemsGivenByText: Text;
        ItemsAcceptedByText: Text;
        VehicleInfoText: Text;
        DriverText: Text;
        LineVATPercent: Text;
        DimensionName: Text;
        DimensionValueName: Text;
        DocSeriesNoText: Text;

        PrintReportTotalsBuffer: Boolean;
        PrintAdvInvoice: Boolean;
        PrintLotSerNos: Enum "LBC REP TrackingOption";
        PrintHeaderComments: Boolean;
        PrintLineComments: Boolean;
        PrintWaybInfo: Boolean;
        PrintBillReceived: Boolean;
        PrintOrderPrepared: Boolean;
        PrintVATClause: Boolean;
        PrintVATPercCol: Boolean;
        PrintAmountInWords: Boolean;
        PrintWeights: Boolean;
        PrintPayer: Boolean;
        SkipPrintVATBasis: Boolean;
        PrintDimensionName: Boolean;
        GroupField: Boolean;
        PrintReceiver: Boolean;

        UnitPrice: Decimal;
        UnitPriceExclVAT: Decimal;
        VATBaseLCY: Decimal;
        VATAmountLCY: Decimal;
        TotalVATAmount: Decimal;
        TotalVATAmountLCY: Decimal;
        VATBaseLCYExempt: Decimal;
        VATAmountLCYExempt: Decimal;
        TotalVATAmountExempt: Decimal;
        TotalVATAmountLCYExempt: Decimal;
        VATBaseLCYReverse: Decimal;
        VATAmountLCYReverse: Decimal;
        TotalVATAmountReverse: Decimal;
        TotalVATAmountLCYReverse: Decimal;
        TotalAmountToPay: Decimal;
        TotalAmountToPayLCY: Decimal;

        NoOfCopies: Integer;
        NoOfLoops: Integer;
        TotalGrossWeight: Decimal;
        TotalNetWeight: Decimal;
        TotalSubTotal: Decimal;
        TotalAmount: Decimal;
        TotalAmountLCY: Decimal;
        TotalAmountInclVAT: Decimal;
        TotalAmountVAT: Decimal;
        TotalInvDiscAmount: Decimal;
        TotalLineDiscountAmount: Decimal;

        Sign: Integer;
        SignOptionPrint: Integer;
        TypeNo: Integer;
        SignOption: Enum "LBC REP SignOption";
        ReportLanguage: Enum "LBC REP ReportLanguage";
        ReportTitle1Txt: Label 'INVOICE';
        ReportTitle3Txt: Label 'ADVANCE INVOICE';

        //DocNoWithSeriesNoLbl: Label 'Series %1 No. %2';
        HeaderIssueDateCaptionLbl: Label 'Issue Date:';
        HeaderPageCaptionLbl: Label 'Page %1 of %2', Comment = '%1 - page number; %2 - total pages';
        ContinuedCaptionLbl: Label 'Continued';

        SellerCaptionLbl: Label 'Seller:';
        BuyerPayerCaptionLbl: Label 'Buyer:';
        BuyerRecipientCaptionLbl: Label 'Payer:';
        BuyerShipCaptionLbl: Label 'Receiver:';
        PhoneNoCaptionLbl: Label 'Phone No.:';
        FaxNoCaptionLbl: Label 'Fax No.:';
        EMailCaptionLbl: Label 'E-Mail:';
        RegistrationNoCaptionLbl: Label 'Registration No.:';
        VATRegistrationNoCaptionLbl: Label 'VAT Registration No.:';
        RegisterInfoCaptionLbl: Label 'Register Information:';
        BankNameCaptionLbl: Label 'Bank Name:';
        SWIFTcodeCaptionLbl: Label 'SWIFT Code:';
        AccNoIBANCaptionLbl: Label 'Account No.:';
        PaymentTypeCaptionLbl: Label 'Payment Method:';
        PaymentTermCaptionLbl: Label 'Payment Term:';
        ShipmentMethodLbl: Label 'Shipment Method:';

        CodeCaptionLbl: Label 'Code';
        DescriptionCaptionLbl: Label 'Description';
        UnitOfMeasCaptionLbl: Label 'Unit of Meas.';
        QuantityCaptionLbl: Label 'Quantity';
        UnitPriceInclVATCaptionLbl: Label 'Unit Price Incl. VAT';
        UnitPriceExclVATCaptionLbl: Label 'Unit Price Excl. VAT';
        DiscountPercCaptionLbl: Label 'Disc. %';
        VATPercCaptionLbl: Label 'VAT %';
        AmExclVATInclDiscCaptionLbl: Label 'Amount Excl. VAT Incl. Discount';
        RequestedReceiptDateLinesLbl: Label 'Request. Receipt Date';

        SubTotalCaptionLbl: Label 'Subtotal';
        TotAmountCaptionLbl: Label 'Total Amount';
        TotAmountInclVATCaptionLbl: Label 'Total Amount Incl. VAT';

        TotalNetWeightLbl: Label 'Net Weight, kg: ';
        TotalGrossWeightLbl: Label 'Gross Weight, kg: ';

        DiscountAmountCaptionLbl: Label 'Discount Amount';
        InvDiscAmountCaptionLbl: Label 'Invoice Discount Amount';
        TotAmExclDiscCaptionLbl: Label 'Total Amount Excl. Disc.';
        TotAmountInclDiscCaptionLbl: Label 'Total Amount Incl. Disc.';
        TotAmInclDiscRateCaptionLbl: Label 'Total Amount Incl. Disc. (rate %2%)', Comment = '%2 - rate';

        VATAmountLCYCaptionLbl: Label 'VAT Amount %1', Comment = '%1 - rate';
        BaseAmountCaptionLbl: Label 'Basis (%1)', Comment = '%1 - rate';
        VATCaptionLbl: Label '%1% VAT', Comment = '%1 - rate';
        VATReverseCaptionLbl: Label '* %1% Reverse charge', Comment = '%1 - rate';
        VATExemptCaptionLbl: Label 'VAT Not applicable';
        VATBasisCaptionLbl: Label '%1 (Basis %2 %3)', Comment = '%1 - VAT, %2 - amount, %3 - currency';

        //AmountInWordsCaptionLbl: Label 'Amount Incl. VAT in Words, %2 %1';
        AmountInWordsCaptionLbl: Label 'Amount to pay %2 %1', Comment = '%1 - currency; %2 - amount';
        CommentsCaptionLbl: Label 'Notes:';
        ExpirationDateLbl: Label 'Exp. Date/Warr. Date';
        LotNoLbl: Label 'Lot/Serial No.';
        VATClauseLbl: Label 'VAT Clause';

        OrderSignatureCaptionLbl: Label '(position, name, signature)';
        OrderPreparedByCaptionLbl: Label 'Order Prepared By:';
        InvSignatureCaptionLbl: Label '(position, name, signature)';
        InvIssuedByCaptionLbl: Label 'Invoice Issued By:';
        InvReceivedByCaptionLbl: Label 'Invoice Received by:';
        SignatureCaptionLbl: Label '(position, name, signature)';
        DocIssueDateTimePlaceCaptionLbl: Label 'Document''s Location, Date, and Time of Issue:';
        UnloadDateTimePlaceCaptionLbl: Label 'Unload Location, Date, and Time';
        LoadDateTimePlaceCaptionLbl: Label 'Load Location, Date, and Time';
        VehicleInfoCaptionLbl: Label 'Vehicle Brand and Registration No.';
        DriverLbl: Label 'Driver:';
        ItemsGivenByCaptionLbl: Label 'Items Given by:';
        ItemsAcceptedByCaptionLbl: Label 'Items Accepted by:';
        YourReferenceLbl: Label 'Your Reference:';

    local procedure ClearValuesOnHeader()
    begin
        TempTrackingSpecification.Reset();
        TempTrackingSpecification.DeleteAll();
    end;

    local procedure ClearValuesOnLines()
    begin
        TempVATAmountLine.Reset();
        TempVATAmountLine.DeleteAll();

        TempVATAmountLineExempt.Reset();
        TempVATAmountLineExempt.DeleteAll();

        TempVATAmountLineReverse.Reset();
        TempVATAmountLineReverse.DeleteAll();

        TempREPVATClauseBuffer.Reset();
        TempREPVATClauseBuffer.DeleteAll();

        TotalGrossWeight := 0;
        TotalNetWeight := 0;

        TotalSubTotal := 0;
        TotalAmount := 0;
        TotalAmountInclVAT := 0;
        TotalAmountVAT := 0;
        TotalInvDiscAmount := 0;
        TotalLineDiscountAmount := 0;
    end;

    local procedure GetReportTitle(): Text
    begin
        case true of
            PrintAdvInvoice:
                exit(ReportTitle3Txt);
            else
                exit(ReportTitle1Txt);
        end;
    end;

    local procedure CreateReportTotalsBuffer()
    var
        VATAmountLineText: Text[250];
        TotalText: Text[50];
        TotalExclVATText: Text[50];
        TotalInclVATText: Text[50];
        SubtotalText: Text[50];
        TotalInvDiscountText: Text[50];
    begin
        if not PrintReportTotalsBuffer then
            exit;

        TempReportTotalsBuffer.DeleteAll();

        LBCREPFunctions.SetTotalLabels(Currency.GetCurrencySymbol(), TotalText, TotalInclVATText, TotalExclVATText, SubtotalText, TotalInvDiscountText);

        //SUBTOTAL
        TempReportTotalsBuffer.Add(SubtotalText, Sign * TotalSubTotal, true, false, false);

        if TotalInvDiscAmount <> 0 then
            //INVOICE DISCOUNT
            TempReportTotalsBuffer.Add(TotalInvDiscountText, Sign * TotalInvDiscAmount, true, false, false);

        if Header."Prices Including VAT" then
            //TOTAL INCLUDING VAT
            TempReportTotalsBuffer.Add(TotalInclVATText, Sign * TotalAmountInclVAT, true, false, false)
        else
            //TOTAL EXCLUDING VAT
            TempReportTotalsBuffer.Add(TotalExclVATText, Sign * TotalAmount, true, false, false);

        //if TotalVATAmount <> 0 then
        if TempVATAmountLine.FindSet() then
            repeat
                //VAT AMOUNT
                VATAmountLineText := StrSubstNo(VATCaptionLbl, TempVATAmountLine."VAT %");

                if SkipPrintVATBasis then
                    TempReportTotalsBuffer.Add(VATAmountLineText, Sign * TempVATAmountLine."VAT Amount", false, false, true)
                else
                    TempReportTotalsBuffer.Add(StrSubstNo(VATBasisCaptionLbl, VATAmountLineText, Sign * TempVATAmountLine."VAT Base", Currency.GetCurrencySymbol()), Sign * TempVATAmountLine."VAT Amount", false, false, true);
            until TempVATAmountLine.Next() = 0;

        //if TotalVATAmountExempt <> 0 then
        if TempVATAmountLineExempt.FindSet() then
            repeat
                //EXEMPT VAT AMOUNT
                VATAmountLineText := VATExemptCaptionLbl;

                if SkipPrintVATBasis then
                    TempReportTotalsBuffer.Add(VATAmountLineText, Sign * TempVATAmountLineExempt."VAT Amount", false, false, true)
                else
                    TempReportTotalsBuffer.Add(StrSubstNo(VATBasisCaptionLbl, VATAmountLineText, Sign * TempVATAmountLineExempt."VAT Base", Currency.GetCurrencySymbol()), Sign * TempVATAmountLineExempt."VAT Amount", false, false, true);
            until TempVATAmountLineExempt.Next() = 0;

        //if TotalVATAmountReverse <> 0 then
        if TempVATAmountLineReverse.FindSet() then
            repeat
                //REVERSE VAT AMOUNT
                VATAmountLineText := StrSubstNo(VATReverseCaptionLbl, TempVATAmountLineReverse."VAT %");

                if SkipPrintVATBasis then
                    TempReportTotalsBuffer.Add(VATAmountLineText, Sign * TempVATAmountLineReverse."VAT Amount", false, false, true)
                else
                    TempReportTotalsBuffer.Add(StrSubstNo(VATBasisCaptionLbl, VATAmountLineText, Sign * TempVATAmountLineReverse."VAT Base", Currency.GetCurrencySymbol()), Sign * TempVATAmountLineReverse."VAT Amount", false, false, true)
            until TempVATAmountLineReverse.Next() = 0;

        if (TotalVATAmount <> 0) or (TotalVATAmountExempt <> 0) or (TotalVATAmountReverse <> 0) then begin
            //TOTAL AMOUNT INCLUDING VAT
            TempReportTotalsBuffer.Add(TotalText, Sign * TotalAmount + Sign * TotalVATAmount + Sign * TotalVATAmountExempt + Sign * TotalVATAmountReverse, true, false, false);

            if CurrencyCode <> CurrencyCodeLCY then
                TempReportTotalsBuffer.Add(StrSubstNo(VATAmountLCYCaptionLbl, LBCREPFunctions.GetLCYCurrencySymbol()), Sign * TotalVATAmountLCY + Sign * TotalVATAmountLCYExempt + Sign * TotalVATAmountLCYReverse, false, false, true);
        end;
    end;

    local procedure GetPreparedInfo(var SalesInvoiceHeader2: Record "Sales Invoice Header")
    begin
        if not PrintOrderPrepared then
            exit;

        OrderPreparedByText := '';
        LBCREPFunctions.GetSignerName(SalesInvoiceHeader2."Waybill Issued By Code LBC", OrderPreparedByText, true, SalesInvoiceHeader2.Relation("Waybill Issued By Code LBC"));
        if OrderPreparedByText = '' then
            LBCREPFunctions.GetSignerName(SalesInvoiceHeader2."Salesperson Code", OrderPreparedByText, true, SalesInvoiceHeader2.Relation("Salesperson Code"));
    end;

    local procedure GetSignersInfo(var SalesInvoiceHeader2: Record "Sales Invoice Header")
    begin
        InvIssuedByText := '';
        LBCREPFunctions.GetSignerName(SalesInvoiceHeader2."Waybill Issued By Code LBC", InvIssuedByText, true, SalesInvoiceHeader2.Relation("Waybill Issued By Code LBC"));
        if InvIssuedByText = '' then
            LBCREPFunctions.GetSignerName(SalesInvoiceHeader2."Salesperson Code", InvIssuedByText, true, SalesInvoiceHeader2.Relation("Salesperson Code"));

        InvReceivedByText := '';
    end;

    local procedure GetWaybillInfo(var SalesInvoiceHeader2: Record "Sales Invoice Header")
    var
        Location: Record Location;
    begin
        if not PrintWaybInfo then
            exit;

        if not Location.Get(SalesInvoiceHeader2."Location Code") then
            LBCREPFunctions.FillLocationFromCompany(Location);

        DocIssueLocationText :=
          LBCREPFunctions.GetFullAddress(
            Location.Address, Location."Address 2", Location."Post Code", Location.City, Location."Country/Region Code",
            true, LBCREPFunctions.GetReportLanguage(ReportLanguage, SalesInvoiceHeader2."Language Code"));

        LoadLocationText :=
          LBCREPFunctions.GetFullAddress(
            Location.Address, Location."Address 2", Location."Post Code", Location.City, Location."Country/Region Code",
            true, LBCREPFunctions.GetReportLanguage(ReportLanguage, SalesInvoiceHeader2."Language Code"));

        UnloadLocationText :=
          LBCREPFunctions.GetFullAddress(
            SalesInvoiceHeader2."Ship-to Address", SalesInvoiceHeader2."Ship-to Address 2", SalesInvoiceHeader2."Ship-to Post Code", SalesInvoiceHeader2."Ship-to City", SalesInvoiceHeader2."Ship-to Country/Region Code",
            true, LBCREPFunctions.GetReportLanguage(ReportLanguage, SalesInvoiceHeader2."Language Code"));

        VehicleInfoText := SalesInvoiceHeader2."Waybill Vehicle Name LBC";
        DriverText := SalesInvoiceHeader2."Waybill Driver Name LBC";

        ItemsGivenByText := '';
        LBCREPFunctions.GetSignerName(SalesInvoiceHeader2."Waybill Items Given Code LBC", ItemsGivenByText, true, SalesInvoiceHeader2.Relation("Waybill Items Given Code LBC"));
        ItemsAcceptedByText := SalesInvoiceHeader2."Waybill Accepted Name LBC";
    end;

    local procedure SetReportLanguage(LanguageCode: Code[10])
    begin
        CurrReport.Language := LBCREPFunctions.GetCurrReportLanguageID(LanguageCode, ReportLanguage);
    end;

    local procedure IsReportInPreviewMode(): Boolean
    var
        MailManagement: Codeunit "Mail Management";
    begin
        exit(CurrReport.Preview or MailManagement.IsHandlingGetEmailBody());
    end;
}