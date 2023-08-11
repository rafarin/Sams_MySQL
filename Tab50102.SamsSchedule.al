table 50102 "SamsSchedule"
{
    Caption = 'Sams Schedule';
    fields
    {
        field(1; "Action"; Code[35])
        {
            Caption = 'Scheduler action';
        }
        field(2; "Data1"; Code[64])
        {
            Caption = 'Action argument 1';
        }
        field(3; "Data2"; Code[64])
        {
            Caption = 'Action argument 2';
        }
    }
}

