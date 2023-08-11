pageextension 50204 "Posted Sales Inv Subform Ext" extends "Posted Sales Invoice Subform"
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
    }
    procedure UpdateContractSettings(newStatus: Boolean)
    var
    BEGIN
        CustomerContractEnabled := newStatus;
        CurrPage.Update(true);
    END;

    var
        CustomerContractEnabled: Boolean;
}