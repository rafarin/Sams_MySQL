pageextension 50201 "Sales Order Ext" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("Use Customer Contracts"; Rec."Customer Contracts")
            {
                ApplicationArea = All;
                Editable = true;
                ToolTip = 'For this sales order use settings from customer contracts, if any available';
                trigger OnValidate()
                var
                BEGIN
                    CurrPage.Update(true);
                    CurrPage."SalesLines".Page.UpdateContractSettings(Rec."Customer Contracts", Rec."Sell-to Customer No.", Rec."Document Type", Rec."No.");
                END;

            }
        }
    }

    trigger OnOpenPage()
    var
    BEGIN
        CurrPage.SalesLines.Page.UpdateContractSettings(Rec."Customer Contracts", Rec."Sell-to Customer No.", Rec."Document Type", Rec."No.");
    END;


}