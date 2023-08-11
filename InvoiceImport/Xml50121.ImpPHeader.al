xmlport 50121 ImpPHeader
{
    Caption = 'ImpPHeader';
    Direction = Both;
    UseRequestPage = false;
    FileName = 'InvoiceImportPHeader.csv';
    Format = Xml;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(PInvoiceImportHeader; "P Invoice Import Header")
            {
                fieldelement(BuyfromVendorNo; PInvoiceImportHeader."Buy-from Vendor No.")
                {
                }
                fieldelement(DocumentDate; PInvoiceImportHeader."Document Date")
                {
                }
                fieldelement(DocumentNo; PInvoiceImportHeader."Document No.")
                {
                }
                fieldelement(DocumentType; PInvoiceImportHeader."Document Type")
                {
                }
                fieldelement(DueDate; PInvoiceImportHeader."Due Date")
                {
                }
                fieldelement(LBCVAZIncludeiniVAZ; PInvoiceImportHeader."LBC VAZ Include in iVAZ")
                {
                }
                fieldelement(LTiSAFInvoiceTypeenumLBC; PInvoiceImportHeader."LT i.SAF Invoice Type enum LBC")
                {
                }
                fieldelement(LTiSAFregisterenumLBC; PInvoiceImportHeader."LT i.SAF register enum LBC")
                {
                }
                fieldelement(LocationCode; PInvoiceImportHeader."Location Code")
                {
                }
                fieldelement(OrderDate; PInvoiceImportHeader."Order Date")
                {
                }
                fieldelement(PaytoVendorNo; PInvoiceImportHeader."Pay-to Vendor No.")
                {
                }
                fieldelement(PostingDate; PInvoiceImportHeader."Posting Date")
                {
                }
                fieldelement(PricesIncludingVAT; PInvoiceImportHeader."Prices Including VAT")
                {
                }
                fieldelement(ShortcutDimension1Code; PInvoiceImportHeader."Shortcut Dimension 1 Code")
                {
                }
                fieldelement(SystemCreatedAt; PInvoiceImportHeader.SystemCreatedAt)
                {
                }
                fieldelement(SystemCreatedBy; PInvoiceImportHeader.SystemCreatedBy)
                {
                }
                fieldelement(SystemId; PInvoiceImportHeader.SystemId)
                {
                }
                fieldelement(SystemModifiedAt; PInvoiceImportHeader.SystemModifiedAt)
                {
                }
                fieldelement(SystemModifiedBy; PInvoiceImportHeader.SystemModifiedBy)
                {
                }
                fieldelement(VATReportingDate; PInvoiceImportHeader."VAT Reporting Date")
                {
                }
                fieldelement(VendorInvoiceNo; PInvoiceImportHeader."Vendor Invoice No.")
                {
                }
                fieldelement(CrMemoNo; PInvoiceImportHeader."Cr. Memo No")
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
