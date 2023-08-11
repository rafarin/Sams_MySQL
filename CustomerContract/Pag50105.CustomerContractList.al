page 50105 "Customer Contract List"
{
    ApplicationArea = Basic, Suite, Assembly;
    Caption = 'Customer Contracts';
    CardPageID = "Customer Contract";
    DataCaptionFields = "No.";
    Editable = false;
    PageType = List;
    QueryCategory = 'Customer Contract List';
    SourceTable = "Customer Contract Header";
    UsageCategory = Administration;

    AboutTitle = 'About sales orders';
    AboutText = 'Use a sales order when you partially ship or invoice an order, and when you use drop shipments or prepayments. For sales that are fully shipped and invoiced in one go, sales invoices are typically used instead.';

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Customer Number';
                }
                field("Customer Name."; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Sell-to Customer Name';
                }
                field("Contract No."; Rec."Contract No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer contract number.';
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer contract description: item or service groups.';
                }
                field("Contract Date"; Rec."Contract Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Customer contract registration date.';
                }
            }
        }
    }
}

