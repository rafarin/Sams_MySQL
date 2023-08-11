table 50124 "S Invoice Import Line"
{
    Caption = 'Sales Invoice Import Line';
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
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Type"; Enum "Sales Line Type")
        {
            Caption = 'Type';
        }
        field(5; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(6; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(8; "Quantity"; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 2 : 5;
        }
        field(9; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            DecimalPlaces = 2 : 5;
        }
        field(10; "DynamicsNo"; Code[20])
        {
            Caption = 'Dynamics No.';
            InitValue = '';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }
}

