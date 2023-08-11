table 50121 "P Invoice Import Header"
{
    Caption = 'Sales Invoice Import Header';
    fields
    {
        field(1; "Document Type"; Enum "Purchase Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
        }
        field(5; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(7; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(9; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(10; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(11; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
        }
        field(12; "Cr. Memo No"; Code[20])
        {
            Caption = 'Cr. Memo No';
        }
        field(13; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(14; "VAT Reporting Date"; Date)
        {
            Caption = 'VAT Reporting Date';
        }
        field(15; "LT i.SAF register enum LBC"; Enum "LT i.SAF register type LBC")
        {
            Caption = 'LT i.SAF register enum LBC';
        }
        field(16; "LT i.SAF Invoice Type enum LBC"; Enum "LT i.SAF Invoice Type LBC")
        {
            Caption = 'LT i.SAF Invoice Type enum LBC';
        }
        field(17; "LBC VAZ Include in iVAZ"; Boolean)
        {
            Caption = 'LBC VAZ Include in iVAZ';
            InitValue = false;
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.")
        {
            Clustered = true;
        }
    }
}

