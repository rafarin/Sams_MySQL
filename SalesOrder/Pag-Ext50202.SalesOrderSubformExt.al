pageextension 50202 "Sales Order Subform Ext" extends "Sales Order Subform"
{
    layout
    {
        addbefore("No.")
        {
            field("Contract No."; Rec."Contract No.")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = CustomerContractEnabled;
                QuickEntry = true;
                ToolTip = 'Contract number of item settings used';
            }
            field("Contract Item Entry No."; Rec."Contract Item Entry No.")
            {
                ApplicationArea = All;
                Editable = true;
                Visible = CustomerContractEnabled;
                QuickEntry = false;
                ToolTip = 'Item entry number of contract';

                trigger OnLookup(var Text: Text): Boolean
                var
                    ContractLine: Record "Customer Contract Line";
                    SalesLine: Record "Sales Line";
                    LastLine: Integer;
                begin
                    Clear(ContractLine);
                    ContractLine.SetFilter("Sell-to Customer No.", CurrentCustomer);
                    IF (CurrentCustomer <> '') THEN begin
                        ContractLine.FindSet();
                    end;

                    if Page.RunModal(Page::"Customer Contract Line", ContractLine) = Action::LookupOK then begin
                        IF (Rec."No." = '') THEN begin
                            LastLine := 10000;
                            SalesLine.SetFilter("Document No.", CurrentDocumentNo);
                            IF SalesLine.FindLast() THEN begin
                                LastLine += SalesLine."Line No.";
                            end;
                            Rec.Init();
                            Rec."Document No." := CurrentDocumentNo;
                            Rec."Line No." := LastLine;
                            Rec.Type := Rec.Type::Item;
                            Rec."Sell-to Customer No." := CurrentCustomer;
                            Rec.Insert(false);
                        end;
                        Rec.Validate("Contract Item Entry No.", ContractLine."No.");
                        Rec.Modify(false);
                    end;
                end;
            }
            field("Contract Item Description"; Rec."Contract Item Description")
            {
                ApplicationArea = All;
                Editable = false;
                Visible = CustomerContractEnabled;
                QuickEntry = true;
                ToolTip = 'Item Description taken from contract used for this sales order line';
            }
        }
        modify("Shortcut Dimension 1 Code")
        {
            Visible = false;
        }
        modify("Description 2 LBC")
        {
            Visible = false;
        }
        modify(FilteredTypeField)
        {
            Width = 4;
        }
        modify("No.")
        {
            Editable = (CustomerContractEnabled = false);
        }
        modify("Description")
        {
            Editable = (CustomerContractEnabled = false);
        }
        modify("Item Reference No.")
        {
            Width = 6;
        }
        modify("Location Code")
        {
            Width = 5;
        }
        modify(Quantity)
        {
            Width = 7;
        }
        modify("Qty. to Assemble to Order")
        {
            Visible = false;
        }
        modify("Reserved Quantity")
        {
            Width = 6;
        }
        modify("Unit of Measure Code")
        {
            Width = 4;
            Editable = (CustomerContractEnabled = false);
        }
        modify("Unit Price")
        {
            Width = 9;
            Editable = (CustomerContractEnabled = false);
        }
        modify("Line Discount %")
        {
            Width = 8;
            Editable = (CustomerContractEnabled = false);
        }
        moveafter("Unit Price"; "Line Amount")
        modify("Qty. to Ship")
        {
            Width = 5;
        }
        modify("Quantity Shipped")
        {
            Width = 6;
        }
        modify("Qty. to Invoice")
        {
            Width = 6;
        }
        modify("Quantity Invoiced")
        {
            Width = 7;
        }
        modify("Qty. to Assign")
        {
            Width = 7;
        }
        modify("Item Charge Qty. to Handle")
        {
            Visible = false;
        }
        modify("Shortcut Dimension 2 Code")
        {
            Visible = false;
        }
        modify("Qty. Assigned")
        {
            Width = 8;
        }
        modify(ShortcutDimCode3)
        {
            Visible = false;
        }
        modify(ShortcutDimCode4)
        {
            Visible = false;
        }
        modify(ShortcutDimCode5)
        {
            Visible = false;
        }
        modify("SMN Group Quantity")
        {
            Visible = false;
        }
        modify("SMN Group Unit Price")
        {
            Visible = false;
        }
        modify("SMN Group Amount")
        {
            Visible = false;
        }
        modify("SMN Sum Group Quantity")
        {
            Visible = false;
        }
        modify("SMN Group Field")
        {
            Visible = false;
        }
        modify("SMN Group Field No.")
        {
            Visible = false;
        }
        modify("LBC Net Weight")
        {
            Width = 7;
        }
        modify("LBC Country/Region of Origin Code")
        {
            Width = 6;
        }
        modify("LBC Area")
        {
            Width = 3;
        }
        addafter("LBC Area")
        {
            field("Shpfy Order No.05429"; Rec."Shpfy Order No.")
            {
                ApplicationArea = All;
                Width = 6;
            }
            field("Shpfy Order Line Id74464"; Rec."Shpfy Order Line Id")
            {
                ApplicationArea = All;
                Width = 8;
            }
        }
        addafter("Line Discount %")
        {
            field("Outstanding Quantity98421"; Rec."Outstanding Quantity")
            {
                ApplicationArea = All;
                Width = 11;
            }
        }
    }

    procedure UpdateContractSettings(newState: Boolean; CustNo: Code[20]; DocType: Enum "Sales Document Type"; DocNo: Code[20])
    var
    BEGIN
        CustomerContractEnabled := newState;
        CurrentCustomer := CustNo;
        CurrentDocumentType := DocType;
        CurrentDocumentNo := DocNo;
        CurrPage.Update(true);
    END;

    var
        CustomerContractEnabled: Boolean;
        CurrentCustomer: Code[20];
        CurrentDocumentNo: Code[20];
        CurrentDocumentType: Enum "Sales Document Type";
}