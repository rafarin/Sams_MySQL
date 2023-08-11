page 50106 "Customer Contract Line Subform"
{
    ApplicationArea = Basic, Suite;
    PageType = ListPart;
    Editable = true;
    LinksAllowed = false;
    Caption = 'Customer Contract Lines Subform';
    SourceTable = "Customer Contract Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Entry No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Entry number';
                    Visible = true;
                    QuickEntry = false;
                    Editable = false;
                    DrillDown = false;
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contract document number.';
                    Visible = true;
                    Editable = false;
                    QuickEntry = true;
                    DrillDown = true;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the contract document number.';
                    Visible = false;
                    Editable = false;
                    QuickEntry = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the customer.';
                    Visible = false;
                    Editable = false;
                }
                field("Description"; Rec."Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies item description in contract.';
                    Visible = true;
                    Editable = true;
                    ShowMandatory = true;
                    QuickEntry = true;
                    DrillDown = true;
                }
                field("Units of Measure"; Rec."Units of Measure")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies item units of measure.';
                    Visible = true;
                    Editable = true;
                    ShowMandatory = true;
                    QuickEntry = true;
                    DrillDown = true;
                }
                field("Price"; Rec."Price")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies item price in contract.';
                    Visible = true;
                    Editable = true;
                    ShowMandatory = true;
                    QuickEntry = true;
                    DrillDown = true;
                }
                field("Related Item"; Rec."Related Item")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies related item no.';
                    Visible = true;
                    Editable = true;
                    ShowMandatory = true;
                    QuickEntry = false;
                    DrillDown = false;
                }
                field("Related Item Description"; Rec."Related Item Description")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies related item description';
                    Visible = true;
                    Editable = false;
                    ShowMandatory = false;
                    QuickEntry = false;
                    DrillDown = false;
                }
                field("Expected Quantity"; Rec."Expected Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies expected quantity by contract';
                    Visible = true;
                    Editable = true;
                    ShowMandatory = false;
                    QuickEntry = false;
                    DrillDown = false;
                }
            }
        }
    }
}

