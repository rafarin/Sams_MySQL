page 50103 "Customer Contract"
{
    Caption = 'Customer Contract';
    PageType = Card;
    RefreshOnActivate = true;
    SourceTable = "Customer Contract Header";
    UsageCategory = Administration;

    AboutTitle = 'About sales order details';
    AboutText = 'Choose the order details and fill in order lines with quantities of what you are selling. Post the order when you are ready to ship or invoice. This creates posted sales shipments and posted sales invoices.';
    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Customer No.';
                    NotBlank = true;
                    ShowMandatory = true;
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update(true);
                    end;
                }
                field("Sell-to Customer Name"; Rec."Sell-to Customer Name")
                {
                    ApplicationArea = Basic, Suite;
                    Enabled = false;
                    Caption = 'Customer Name';
                    ToolTip = 'Specifies the name of the customer who will receive the products and be billed by default.';

                    AboutTitle = 'Who are you selling to?';
                    AboutText = 'You can choose existing customers, or add new customers when you create orders. Orders can automatically choose special prices and discounts that you have set for each customer.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Importance = Additional;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field("Modified at"; Rec.SystemModifiedAt)
                {
                    ApplicationArea = All;
                    Editable = false;
                    NotBlank = false;
                    ToolTip = 'The last time this customer contract modified in any kind.';
                }
            }
            group(Contract)
            {
                field("Contract No."; Rec."Contract No.")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    NotBlank = true;
                    ToolTip = 'Customer contract number, must be exact.';
                }
                field("Contract Description"; Rec."Contract Description")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = false;
                    NotBlank = false;
                    ToolTip = 'Customer contract description: item or service groups.';
                }
                field("Contract Date"; Rec."Contract Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    NotBlank = false;
                    ToolTip = 'Customer contract registration date.';
                }
                field("Contract Start Date"; Rec."Contract Start Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    NotBlank = true;
                    ToolTip = 'Beginning of validity of the customer contract.';
                }
                field("Contract End Date"; Rec."Contract End Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    NotBlank = true;
                    ToolTip = 'Contract expiration date.';
                }
                field("Contract Extend Date"; Rec."Contract Extend Date")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = false;
                    NotBlank = false;
                    ToolTip = 'Contract expiration date of extension';
                }
                field("Contract Value"; Rec."Contract Value")
                {
                    ApplicationArea = All;
                    Editable = true;
                    ShowMandatory = true;
                    NotBlank = false;
                    ToolTip = 'Value without VAT includes (maximum) with agreed all value extents';
                }
            }
            group("Pricing Setup")
            {
                field("Override Items"; Rec."Override Items")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Use Item description from contract lines';
                    ToolTip = 'Replace item description with items from contract';
                }
                field("Override Item Prices"; Rec."Override Item Prices")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Use Item price from contract lines';
                    ToolTip = 'Replace item prices with prices from contract';
                }
                field("Allow Expired Prices"; Rec."Allow Expired Prices")
                {
                    ApplicationArea = All;
                    Editable = true;
                    Caption = 'Use Item price from contract lines, if contract maximum value reached';
                    ToolTip = 'Replace item prices with prices from contract even if customer exceeded maximum contract value';
                }
            }
            group("Items & Definitions")
            {
                part(CustomerContractLines; "Customer Contract Line Subform")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = true;
                    Enabled = true;
                    SubPageLink = "Document No." = FIELD("No.");
                    UpdatePropagation = Both;
                }
            }
        }
    }
}

