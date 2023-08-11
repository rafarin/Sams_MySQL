page 50123 "Sales Invoice Import Header"
{
    Caption = 'Sales Invoice Import';
    PageType = Document;
    RefreshOnActivate = true;
    LinksAllowed = false;
    SourceTable = "S Invoice Import Header";
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
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Sell-to Customer No.';
                    TableRelation = Customer."No.";
                    Editable = false;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    Caption = 'Bill-to Customer No.';
                    TableRelation = Customer."No.";
                    Editable = false;
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = All;
                    Caption = 'Document Date';
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
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    Caption = 'External Document No.';
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
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Caption = 'Shortcut Dimension 2 Code';
                    Editable = false;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                    Caption = 'Prices Including VAT';
                    Editable = false;
                }
                field("Your Reference."; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    Caption = 'Your Reference';
                    Editable = false;
                }
                field("Ship-to Code"; Rec."Ship-to Code")
                {
                    ApplicationArea = All;
                    Caption = 'Ship-to Code';
                    Editable = false;
                }
                field("Invoice Disc. Code"; Rec."Invoice Disc. Code")
                {
                    ApplicationArea = All;
                    Caption = 'Invoice Disc. Code';
                    Editable = false;
                }
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    Caption = 'Salesperson Code';
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
            part("SalesInvoiceImportLines"; "S Invoice Import Subform")
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
                            IF (CodeInvoiceImport.DeleteDocument(Rec."Document No.", 'Sales')) THEN begin
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
                        IF (CodeInvoiceImport.CheckDocument(Rec."Document No.", 'Sales')) THEN begin
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
                        IF (CodeInvoiceImport.GetData(Rec."Document Type", Rec."Document No.", 'Sales', '', '', true)) THEN begin
                            IF CodeInvoiceImport.CheckDocument(Rec."Document No.", 'Sales') THEN
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

