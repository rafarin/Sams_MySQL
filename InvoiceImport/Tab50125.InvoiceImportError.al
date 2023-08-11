table 50125 "Invoice Import Error"
{
    Caption = 'Invoice Import Error List';
    fields
    {
        field(1; "No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Document Type"; Enum "Sales Document Type")
        {
            Caption = 'Document Type';
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
        }
        field(4; "Invoice Type"; Text[20])
        {
            Caption = 'Invoice Type';
        }
        field(5; "Message"; Text[200])
        {
            Caption = 'Type';
        }
    }
    keys
    {
        key(EntryNo; "No.")
        {
            Clustered = true;
        }
    }
}

