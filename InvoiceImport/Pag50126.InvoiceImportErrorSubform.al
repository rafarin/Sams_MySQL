page 50126 "Invoice Import Error Subform"
{
    ApplicationArea = Basic, Suite, Assembly;
    //Caption = 'Invoice Import Error';
    //CardPageID = "Invoice Import Error";
    Editable = false;
    PageType = ListPart;
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
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }
}

