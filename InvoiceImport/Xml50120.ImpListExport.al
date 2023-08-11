xmlport 50120 ImpListExport
{
    Caption = 'ImpListExport';
    Direction = Both;
    UseRequestPage = false;
    FileName = 'InvoiceImportList.csv';
    Format = Xml;
    schema
    {
        textelement(Root)
        {
            tableelement(InvoiceImportList; "Invoice Import List")
            {
                fieldattribute(Department; InvoiceImportList.Department)
                {
                }
                fieldattribute(DocumentNo; InvoiceImportList."Document No.")
                {
                }
                fieldattribute(DocumentType; InvoiceImportList."Document Type")
                {
                }
                fieldattribute(FileName; InvoiceImportList."File Name")
                {
                }
                fieldattribute(InvoiceType; InvoiceImportList."Invoice Type")
                {
                }
                fieldattribute(LocationCode; InvoiceImportList."Location Code")
                {
                }
                fieldattribute(SystemCreatedAt; InvoiceImportList.SystemCreatedAt)
                {
                }
                fieldattribute(SystemCreatedBy; InvoiceImportList.SystemCreatedBy)
                {
                }
                fieldattribute(SystemId; InvoiceImportList.SystemId)
                {
                }
                fieldattribute(SystemModifiedAt; InvoiceImportList.SystemModifiedAt)
                {
                }
                fieldattribute(SystemModifiedBy; InvoiceImportList.SystemModifiedBy)
                {
                }
                fieldattribute(status; InvoiceImportList.status)
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
