xmlport 50123 ImpSHeader
{
    Caption = 'ImpSHeader';
    Direction = Both;
    UseRequestPage = false;
    FileName = 'InvoiceImportSHeader.csv';
    Format = Xml;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(SInvoiceImportHeader; "S Invoice Import Header")
            {
                fieldelement(BilltoCustomerNo; SInvoiceImportHeader."Bill-to Customer No.")
                {
                }
                fieldelement(DocumentDate; SInvoiceImportHeader."Document Date")
                {
                }
                fieldelement(DocumentNo; SInvoiceImportHeader."Document No.")
                {
                }
                fieldelement(DocumentType; SInvoiceImportHeader."Document Type")
                {
                }
                fieldelement(DueDate; SInvoiceImportHeader."Due Date")
                {
                }
                fieldelement(ExternalDocumentNo; SInvoiceImportHeader."External Document No.")
                {
                }
                fieldelement(InvoiceDiscCode; SInvoiceImportHeader."Invoice Disc. Code")
                {
                }
                fieldelement(LBCVAZIncludeiniVAZ; SInvoiceImportHeader."LBC VAZ Include in iVAZ")
                {
                }
                fieldelement(LTiSAFInvoiceTypeenumLBC; SInvoiceImportHeader."LT i.SAF Invoice Type enum LBC")
                {
                }
                fieldelement(LTiSAFregisterenumLBC; SInvoiceImportHeader."LT i.SAF register enum LBC")
                {
                }
                fieldelement(LocationCode; SInvoiceImportHeader."Location Code")
                {
                }
                fieldelement(PostingDate; SInvoiceImportHeader."Posting Date")
                {
                }
                fieldelement(PricesIncludingVAT; SInvoiceImportHeader."Prices Including VAT")
                {
                }
                fieldelement(SalespersonCode; SInvoiceImportHeader."Salesperson Code")
                {
                }
                fieldelement(SelltoCustomerNo; SInvoiceImportHeader."Sell-to Customer No.")
                {
                }
                fieldelement(ShiptoCode; SInvoiceImportHeader."Ship-to Code")
                {
                }
                fieldelement(ShortcutDimension1Code; SInvoiceImportHeader."Shortcut Dimension 1 Code")
                {
                }
                fieldelement(ShortcutDimension2Code; SInvoiceImportHeader."Shortcut Dimension 2 Code")
                {
                }
                fieldelement(SystemCreatedAt; SInvoiceImportHeader.SystemCreatedAt)
                {
                }
                fieldelement(SystemCreatedBy; SInvoiceImportHeader.SystemCreatedBy)
                {
                }
                fieldelement(SystemId; SInvoiceImportHeader.SystemId)
                {
                }
                fieldelement(SystemModifiedAt; SInvoiceImportHeader.SystemModifiedAt)
                {
                }
                fieldelement(SystemModifiedBy; SInvoiceImportHeader.SystemModifiedBy)
                {
                }
                fieldelement(YourReference; SInvoiceImportHeader."Your Reference")
                {
                }
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
