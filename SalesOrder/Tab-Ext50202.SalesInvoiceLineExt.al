tableextension 50204 "Sales Invoice Line Ext" extends "Sales Invoice Line"
{
    fields
    {
        field(55001; "Contract No."; Code[20])
        {
            InitValue = '';
        }
        field(55002; "Contract Item Entry No."; Integer)
        {
            InitValue = 0;
        }
        field(55003; "Contract Item Description"; Text[64])
        {
            InitValue = '';
        }
    }
}