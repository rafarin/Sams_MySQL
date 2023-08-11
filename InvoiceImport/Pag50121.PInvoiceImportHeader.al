page 50121 "Purchases Invoice Import Head"
{
    Caption = 'Purchases Invoice Import';
    PageType = Document;
    RefreshOnActivate = true;
    LinksAllowed = false;
    SourceTable = "P Invoice Import Header";
    UsageCategory = None;
    Editable = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type."; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document Type';
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Document No.';
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Buy-from Vendor No.';
                    TableRelation = Vendor."No.";
                    Editable = false;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    Caption = 'Pay-to Vendor No.';
                    TableRelation = Vendor."No.";
                    Editable = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    Caption = 'Order Date';
                    Editable = false;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Posting Date';
                    Editable = false;
                }
                field("Due Date"; Rec."Due Date")
                {
                    ApplicationArea = All;
                    Caption = 'Due Date';
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Caption = 'Location Code';
                    TableRelation = Location.Code;
                    Editable = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shortcut Dimension 1 Code';
                    Editable = false;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'Prices Including VAT';
                    Editable = false;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                    Caption = 'Vendor Invoice No.';
                    Editable = false;
                }
                field("Cr. Memo No"; Rec."Cr. Memo No")
                {
                    ApplicationArea = All;
                    Caption = 'Cr. Memo No';
                    Editable = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date';
                    Editable = false;
                }
                field("VAT Reporting Date"; Rec."VAT Reporting Date")
                {
                    ApplicationArea = All;
                    Caption = 'VAT Reporting Date';
                    Editable = false;
                }
                field("LT i.SAF register LBC"; Rec."LT i.SAF register enum LBC")
                {
                    ApplicationArea = All;
                    Caption = 'LT i.SAF register LBC';
                    Editable = false;
                }
                field("LT i.SAF Invoice Type LBC"; Rec."LT i.SAF Invoice Type enum LBC")
                {
                    ApplicationArea = All;
                    Caption = 'LT i.SAF Invoice Type LBC';
                    Editable = false;
                }
            }
            part("PurchasesInvoiceImportLines"; "P Invoice Import Subform")
            {
                ApplicationArea = Basic, Suite;
                Enabled = true;
                SubPageLink = "Document No." = FIELD("Document No.");
                UpdatePropagation = Both;

            }
            part("InvoiceImportError"; "Invoice Import Error Subform")
            {
                ApplicationArea = Basic, Suite;
                Enabled = true;
                SubPageLink = "Document No." = FIELD("Document No.");
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(Button1; "Check Document")
            {
            }
            actionref(Button2; "Delete Document")
            {
            }

        }
        area(Processing)
        {
            group(Control)
            {
                Caption = 'Manage';
                Image = Document;
                action("Delete Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delete Document';
                    Image = Delete;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        IF (Dialog.Confirm('Are you sure to delete document: %1?', true, Rec."Document No.") = true) THEN begin
                            IF (CodeInvoiceImport.DeleteDocument(Rec."Document No.", 'Purchases')) THEN begin
                                CurrPage.Close();
                                Message('Document deleted ' + Rec."Document No.");
                            end
                            else begin
                                Message('Error. Failed to delete, not found or found more then one document');
                            end;
                        end;

                    end;
                }
                action("Check Document")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Check Document for Errors';
                    Image = Check;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        IF (CodeInvoiceImport.CheckDocument(Rec."Document No.", 'Purchases')) THEN begin
                            Message('No errors found on document ' + Rec."Document No.");
                        end
                        else begin
                            Message('Document did not pass the check');
                        end;
                    end;
                }
                action("Get Document Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Get Document Lines';
                    Image = Download;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        IF (CodeInvoiceImport.GetData(Rec."Document Type", Rec."Document No.", 'Purchases', '', '', true)) THEN begin
                            IF CodeInvoiceImport.CheckDocument(Rec."Document No.", 'Purchases') THEN
                                Message('New data reimported for ' + Rec."Document No." + '. No errors found.')
                            else
                                Message('New data reimported for ' + Rec."Document No." + '. Errors found.');
                        end
                        else begin
                            Message('No data found for ' + Rec."Document No.");
                        end;
                    end;
                }
            }
        }
    }
}

