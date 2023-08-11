pageextension 50104 "Customer Card Ext" extends "Customer Card"
{
    layout
    {
        addlast(General)
        {
            field("Active Customer Contracts"; ContractCount)
            {
                ApplicationArea = All;
                Editable = false;
                ToolTip = 'Customer Contract Count';
            }
        }
    }
    actions
    {
        addfirst(navigation)
        {
            action("Customer Contracts")
            {
                ApplicationArea = All;
                RunObject = page "Customer Contract List";
                Image = MakeAgreement;
                RunPageLink = "Sell-to Customer No." = FIELD("No.");
                ToolTip = 'View, edit or set up the customer''s contracts...';
            }
        }
    }
    protected var
        ContractCount: Integer;

    local procedure UpdateContractCount()
    var
        Contract: Record "Customer Contract Header";
    begin
        ContractCount := 0;
        Contract.SetFilter("Sell-to Customer No.", Rec."No.");
        IF Contract.FindSet() THEN begin
            REPEAT
                ContractCount += 1;
            until Contract.Next() = 0;
        end;
    end;

    trigger OnOpenPage()
    begin
        UpdateContractCount();
    end;
}