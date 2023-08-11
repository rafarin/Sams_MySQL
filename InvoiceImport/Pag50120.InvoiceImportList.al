page 50120 "Invoice Import List"
{
    ApplicationArea = Basic, Suite, Assembly;
    Caption = 'Invoice Import List';
    CardPageID = "Invoice Import List";
    Editable = false;
    PageType = List;
    LinksAllowed = false;
    QueryCategory = 'Invoice Import List';
    SourceTable = "Invoice Import List";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = true;
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnAssistEdit()
                    var
                    BEGIN
                        LineOnClick(Rec."Document Type", Rec."Document No.", Rec."Invoice Type", Rec.Department, Rec."File Name");
                    END;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    trigger OnAssistEdit()
                    var
                    BEGIN
                        LineOnClick(Rec."Document Type", Rec."Document No.", Rec."Invoice Type", Rec.Department, Rec."File Name");
                    END;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = All;
                }
                field("Department"; Rec.Department)
                {
                    ApplicationArea = All;
                }
                /*
                field("File Name"; Rec."File Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                */
                field("status"; Rec.status)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            group(ImpAction)
            {
                ShowAs = SplitButton;
                actionref(ActionRef1; "Refresh All")
                {
                }
                actionref(ActionRef2; "Get Purchages/Sales Lines")
                {
                }
                actionref(ActionRef3; "Check Errors")
                {
                }
                actionref(ActionRef4; "Show Errors")
                {
                }
                group(Import)
                {
                    actionref(ActionRef5; "Import Sales")
                    {
                    }
                    actionref(ActionRef6; "Import Purchases")
                    {
                    }
                }
                actionref(ActionRef7; "Clear Completed")
                {
                }
            }
            group(ViewAction)
            {
                ShowAs = SplitButton;
                actionref(View1; "View All")
                {
                }
                actionref(View2; "View New")
                {
                }
                actionref(View3; "View Checked")
                {
                }
                actionref(View4; "View Error")
                {
                }
            }
        }
        area(Processing)
        {
            group(View)
            {
                Caption = 'View';
                Image = View;

                action("View All")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View All';
                    Image = View;

                    trigger OnAction()
                    var
                    begin
                        Clear(Rec);
                        IF (not Rec.FindSet()) THEN Message('No documents');
                    end;
                }
                action("View New")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View New';
                    Image = View;

                    trigger OnAction()
                    var
                    begin
                        Clear(Rec);
                        Rec.SetRange(status, 'not_imported');
                        IF (not Rec.FindSet()) THEN Message('No new documents found');
                    end;
                }
                action("View Checked")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View Checked';
                    Image = View;

                    trigger OnAction()
                    var
                    begin
                        Clear(Rec);
                        Rec.SetRange(status, 'checked');
                        IF (not Rec.FindSet()) THEN Message('No checked documents in the list');
                    end;
                }
                action("View Error")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'View Error';
                    Image = View;

                    trigger OnAction()
                    var
                    begin
                        Clear(Rec);
                        Rec.SetRange(status, 'error');
                        IF (not Rec.FindSet()) THEN Message('No documents having errors in the list');
                    end;
                }
            }
            group(Control)
            {
                Caption = 'Manage';
                Image = Process;
                action("Refresh All")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Refresh List (ALL)';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                        LoadedPurchases: Boolean;
                        LoadedSales: Boolean;
                        currentstatus: Text[20];
                    begin
                        currentstatus := Rec.GetFilter(status);
                        LoadedPurchases := CodeInvoiceImport.RefreshList('Purchases');
                        LoadedSales := CodeInvoiceImport.RefreshList('Sales');
                        Clear(Rec);
                        Rec.SetRange(status, 'not_imported');
                        IF (not Rec.FindSet()) THEN begin
                            Message('No new documents found');
                            Clear(Rec);
                            Rec.SetFilter(status, currentstatus);
                            if (Rec.FindSet()) THEN begin

                            end;
                        end;
                    end;
                }
                action("Refresh Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Refresh List (Sales)';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                        Loaded: Boolean;
                    begin
                        Loaded := CodeInvoiceImport.RefreshList('Sales');
                    end;
                }
                action("Refresh Purchases")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Refresh List (Purchases)';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                        Loaded: Boolean;
                    begin
                        Loaded := CodeInvoiceImport.RefreshList('Purchases');
                    end;
                }
                action("Get Purchages/Sales Lines")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Get Purchages/Sales Lines';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        CodeInvoiceImport.BackgroundDataUpdate();
                    end;
                }
                action("Delete All")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Delete ALL';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        CodeInvoiceImport.DeleteAll();
                    end;
                }
                action("Check Errors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Check Errors';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                        Loaded: Boolean;
                    begin
                        CodeInvoiceImport.CheckDocuments('Sales', false);
                        CodeInvoiceImport.CheckDocuments('Purchases', false);
                    end;
                }
                action("Check Errors ALL")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Check Errors ALL';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                        Loaded: Boolean;
                    begin
                        CodeInvoiceImport.CheckDocuments('Sales', true);
                        CodeInvoiceImport.CheckDocuments('Purchases', true);
                    end;
                }
                action("Show Errors")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show Errors';
                    Image = Process;

                    trigger OnAction()
                    var
                    begin
                        Page.Run(Page::"Invoice Import Error");

                    end;
                }
                action("Import Sales")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Sales';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        IF CodeInvoiceImport.InsertDocuments('Sales') THEN Message('Import sales completed');
                    end;
                }
                action("Import Purchases")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Import Purchases';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        IF CodeInvoiceImport.InsertDocuments('Purchases') THEN Message('Import purchases completed');
                    end;
                }
                action("Clear Completed")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Clear Completed';
                    Image = Process;

                    trigger OnAction()
                    var
                        CodeInvoiceImport: Codeunit "InvoiceImport";
                    begin
                        CodeInvoiceImport.ClearCompleted();
                    end;
                }
                action("Nespausti :)")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Nespausti :)';

                    trigger OnAction()
                    var
                        //SamsMySQL: Codeunit SamsMySQL;
                        CU: Codeunit InvoiceImport;
                    begin
                        //SamsMySQL.ValidateCode('123456AWDS');
                        CU.FixSalesInvoices();
                        CU.FixPurchasesInvoices();
                        //CU.GetData(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]; Department: Text[32]; FileName: Text[35])
                    end;
                }
                group("Backup & Restore")
                {
                    action("Backup List")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpListExport", false, false);
                        end;
                    }
                    action("Backup P Header")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpPHeader", false, false);
                        end;
                    }
                    action("Backup P Line")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpPLine", false, false);
                        end;
                    }
                    action("Backup S Header")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpSHeader", false, false);
                        end;
                    }
                    action("Backup S Line")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpSLine", false, false);
                        end;
                    }
                    action("Restore List")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpListExport", false, true);
                        end;
                    }
                    action("Restore P Header")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpPHeader", false, true);
                        end;
                    }
                    action("Restore P Line")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpPLine", false, true);
                        end;
                    }
                    action("Restore S Header")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpSHeader", false, true);
                        end;
                    }
                    action("Restore S Line")
                    {
                        ApplicationArea = Basic, Suite;
                        Image = Restore;

                        trigger OnAction()
                        var
                        begin
                            Xmlport.Run(Xmlport::"ImpSLine", false, true);
                        end;
                    }
                }
            }
        }
    }
    local procedure LineOnClick(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]; Department: Code[32]; FileName: Text[35]): Boolean
    var
        CodeInvoiceImport: Codeunit "InvoiceImport";
        Loaded: Boolean;
        SHead: Record "S Invoice Import Header";
        PHead: Record "P Invoice Import Header";
    BEGIN
        Loaded := CodeInvoiceImport.GetData(DocType, DocNo, InvType, Department, FileName, false);
        IF (InvType = 'Sales') THEN begin
            SHead.SetFilter("Document No.", DocNo);
            IF SHead.FindFirst() THEN begin
                Page.Run(PAGE::"Sales Invoice Import Header", SHead);
            end;
        end;
        IF (InvType = 'Purchases') THEN begin
            PHead.SetFilter("Document No.", DocNo);
            IF PHead.FindFirst() THEN begin
                Page.Run(PAGE::"Purchases Invoice Import Head", PHead);
            end;
        end;


    END;
}

