table 50123 "S Invoice Import Header"
{
    Caption = 'Sales Invoice Import Header';
    fields
    {
        field(1; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(3; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
        }
        field(4; "Bill-to Customer No."; Code[20])
        {
            Caption = 'Bill-to Customer No.';
        }
        field(5; "Your Reference"; Text[35])
        {
            Caption = 'Your Reference';
        }
        field(6; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
        }
        field(7; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
        }
        field(8; "Due Date"; Date)
        {
            Caption = 'Due Date';
        }
        field(9; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(10; "Shortcut Dimension 1 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 1 Code';
        }
        field(11; "Shortcut Dimension 2 Code"; Code[20])
        {
            Caption = 'Shortcut Dimension 2 Code';
        }
        field(12; "Prices Including VAT"; Boolean)
        {
            Caption = 'Prices Including VAT';
        }
        field(13; "Invoice Disc. Code"; Code[20])
        {
            Caption = 'Invoice Disc. Code';
        }
        field(14; "Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
        }
        field(15; "Document Date"; Date)
        {
            Caption = 'Document Date';
        }
        field(16; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
        }
        field(17; "LT i.SAF register enum LBC"; Enum "LT i.SAF register type LBC")
        {
            Caption = 'LT i.SAF register enum LBC';
        }
        field(18; "LT i.SAF Invoice Type enum LBC"; Enum "LT i.SAF Invoice Type LBC")
        {
            Caption = 'LT i.SAF Invoice Type enum LBC';
        }
        field(19; "LBC VAZ Include in iVAZ"; Boolean)
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

