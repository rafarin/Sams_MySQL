xmlport 50122 ImpPLine
{
    Caption = 'ImpPLine';
    Direction = Both;
    UseRequestPage = false;
    FileName = 'InvoiceImportPLine.csv';
    Format = Xml;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(PInvoiceImportLine; "P Invoice Import Line")
            {
                fieldelement(DirectUnitCost; PInvoiceImportLine."Direct Unit Cost")
                {
                }
                fieldelement(DocumentNo; PInvoiceImportLine."Document No.")
                {
                }
                fieldelement(DocumentType; PInvoiceImportLine."Document Type")
                {
                }
                fieldelement(DynamicsNo; PInvoiceImportLine.DynamicsNo)
                {
                }
                fieldelement(LineNo; PInvoiceImportLine."Line No.")
                {
                }
                fieldelement(No; PInvoiceImportLine."No.")
                {
                }
                fieldelement(Quantity; PInvoiceImportLine.Quantity)
                {
                }
                fieldelement(SystemCreatedAt; PInvoiceImportLine.SystemCreatedAt)
                {
                }
                fieldelement(SystemCreatedBy; PInvoiceImportLine.SystemCreatedBy)
                {
                }
                fieldelement(SystemId; PInvoiceImportLine.SystemId)
                {
                }
                fieldelement(SystemModifiedAt; PInvoiceImportLine.SystemModifiedAt)
                {
                }
                fieldelement(SystemModifiedBy; PInvoiceImportLine.SystemModifiedBy)
                {
                }
                fieldelement(Type; PInvoiceImportLine."Type")
                {
                }
                fieldelement(UnitCost; PInvoiceImportLine."Unit Cost")
                {
                }
                fieldelement(UnitofMeasureCode; PInvoiceImportLine."Unit of Measure Code")
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
