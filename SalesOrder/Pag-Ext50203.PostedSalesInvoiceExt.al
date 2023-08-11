pageextension 50203 "Posted Sales Invoice Ext" extends "Posted Sales Invoice"
{
    layout
    {
        addlast(General)
        {
            field("Use Customer Contracts"; Rec."Customer Contracts")
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'For this sales order use settings from customer contracts, if any available';
            }
        }
    }

    trigger OnOpenPage()
    var
    BEGIN
        CurrPage.SalesInvLines.Page.UpdateContractSettings(Rec."Customer Contracts" = TRUE);
    END;
}