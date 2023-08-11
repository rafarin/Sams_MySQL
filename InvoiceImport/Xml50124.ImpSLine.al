xmlport 50124 ImpSLine
{
    Caption = 'ImpSLine';
    Direction = Both;
    UseRequestPage = false;
    FileName = 'InvoiceImportSLine.csv';
    Format = Xml;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(SInvoiceImportLine; "S Invoice Import Line")
            {
                fieldelement(DocumentNo; SInvoiceImportLine."Document No.")
                {
                }
                fieldelement(DocumentType; SInvoiceImportLine."Document Type")
                {
                }
                fieldelement(DynamicsNo; SInvoiceImportLine.DynamicsNo)
                {
                }
                fieldelement(LineNo; SInvoiceImportLine."Line No.")
                {
                }
                fieldelement(LocationCode; SInvoiceImportLine."Location Code")
                {
                }
                fieldelement(No; SInvoiceImportLine."No.")
                {
                }
                fieldelement(Quantity; SInvoiceImportLine.Quantity)
                {
                }
                fieldelement(SystemCreatedAt; SInvoiceImportLine.SystemCreatedAt)
                {
                }
                fieldelement(SystemCreatedBy; SInvoiceImportLine.SystemCreatedBy)
                {
                }
                fieldelement(SystemId; SInvoiceImportLine.SystemId)
                {
                }
                fieldelement(SystemModifiedAt; SInvoiceImportLine.SystemModifiedAt)
                {
                }
                fieldelement(SystemModifiedBy; SInvoiceImportLine.SystemModifiedBy)
                {
                }
                fieldelement(Type; SInvoiceImportLine."Type")
                {
                }
                fieldelement(UnitPrice; SInvoiceImportLine."Unit Price")
                {
                }
                fieldelement(UnitofMeasureCode; SInvoiceImportLine."Unit of Measure Code")
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
