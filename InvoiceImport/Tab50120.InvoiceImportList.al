table 50120 "Invoice Import List"
{
    Caption = 'Invoice Import List';
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
        field(3; "File Name"; Text[35])
        {
            Caption = 'File Name';
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
        }
        field(5; "Invoice Type"; Text[20])
        {
            Caption = 'Invoice Type';
        }
        field(6; "Department"; Text[32])
        {
            Caption = 'Department';
        }
        field(7; "status"; Text[20])
        {
            Caption = 'Data Status';
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

