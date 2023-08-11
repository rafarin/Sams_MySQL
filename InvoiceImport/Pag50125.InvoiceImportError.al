page 50125 "Invoice Import Error"
{
    ApplicationArea = Basic, Suite, Assembly;
    Caption = 'Invoice Import Error';
    //CardPageID = "Invoice Import Error";
    Editable = false;
    PageType = List;
    LinksAllowed = false;
    QueryCategory = 'Invoice Import Error';
    SourceTable = "Invoice Import Error";
    UsageCategory = None;

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
                    Visible = true;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = true;
                    trigger OnAssistEdit()
                    var
                    BEGIN
                        LineOnClick(Rec."Document Type", Rec."Document No.", Rec."Invoice Type");
                    END;
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = All;
                    Visible = true;
                }
            }
        }
    }
    local procedure LineOnClick(DocType: Enum "Sales Document Type"; DocNo: Code[20]; InvType: Text[20]): Boolean
    var
        SHead: Record "S Invoice Import Header";
        PHead: Record "P Invoice Import Header";
    BEGIN
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

