table 50104 "Customer Contract Line"
{
    Caption = 'Customer Contract Line';
    DrillDownPageID = "Customer Contract Line";
    LookupPageID = "Customer Contract Line";
    Permissions = TableData "Customer Contract Line" = m;

    fields
    {
        field(1; "No."; Integer)
        {
            Caption = 'Entry No.';
            InitValue = 0;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "Customer Contract Header"."No.";
        }
        field(3; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            Editable = false;
            TableRelation = Customer;
        }
        field(4; "Description"; Text[64])
        {
            Caption = 'Item Description';
            Editable = true;
            NotBlank = true;
        }
        field(5; "Units of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            Editable = true;
            NotBlank = true;
            TableRelation = "Unit of Measure";
        }
        field(6; "Price"; Decimal)
        {
            Caption = 'Item Price';
            NotBlank = true;
            Editable = true;
        }
        field(7; "Related Item"; Code[20])
        {
            Caption = 'Related Item';
            NotBlank = true;
            Editable = true;
            TableRelation = Item."No." WHERE("No." = FILTER('Z0*|P0*|T0*|GMT*|GMP*|GMN*|GMD*|GD*'));
            trigger OnValidate()
            var
                ItemCard: Record Item;
            BEGIN
                IF (ValidateItemCode("Related Item", "Units of Measure")) THEN begin
                    ItemCard.SetFilter("No.", "Related Item");
                    IF (ItemCard.FindFirst()) THEN begin
                        "Related Item Description" := ItemCard.Description;
                    end;
                end
                else
                    "Related Item Description" := '';
            END;
        }
        field(8; "Related Item Description"; Text[100])
        {
            Caption = 'Related Item Description';
            NotBlank = false;
            Editable = false;
        }
        field(9; "Expected Quantity"; Decimal)
        {
            Caption = 'Expected Quantity';
            NotBlank = true;
            Editable = true;
            InitValue = 0.0;
        }
        field(10; "Contract No."; Text[35])
        {
            Caption = 'Contract number';
            NotBlank = true;
            Editable = false;
            InitValue = '';
        }
    }
    keys
    {
        key(EntryNo; "No.", "Document No.")
        {
            Clustered = true;
        }
    }
    var
        CodeUnitContract: Codeunit CustomerContract;
        Header: Record "Customer Contract Header";

    local procedure InitDefaults(DocNo: Code[20])
    var
    begin
        IF CodeUnitContract.Get(DocNo, Header) THEN begin
            Rec."Sell-to Customer No." := Header."Sell-to Customer No.";
            Rec."Contract No." := Header."Contract No.";
            IF (Rec."No." = 0) THEN Rec."No." := GetNo();

        end;
    end;

    local procedure ValidateItemCode(ItemNo: Code[20]; Measurement: Code[10]): Boolean
    var
        ItemCode: Text[20];
        CurrentCodeOk: Boolean;
    begin
        ItemCode := ItemNo;
        CurrentCodeOk := false;
        IF (ItemCode.StartsWith('Z0') OR
            ItemCode.StartsWith('P0') OR
            ItemCode.StartsWith('T0') OR
            ItemCode.StartsWith('GMT') OR
            ItemCode.StartsWith('GMP') OR
            ItemCode.StartsWith('GMN') OR
            ItemCode.StartsWith('GMD') OR
            ItemCode.StartsWith('GD')) THEN begin
            CurrentCodeOk := true;
        end;
        IF (CurrentCodeOk = false) THEN begin
            Error('Selected Item currently not in use: ' + ItemCode);
            exit(false);
        end;
        exit(true);
    end;

    local procedure Validate(ItemNo: Code[20]; Measurement: Code[10]): Boolean
    var
        CurrentCodeOk: Boolean;
    BEGIN
        CurrentCodeOk := false;
        IF (ItemNo <> '') THEN begin
            CurrentCodeOk := ValidateItemCode(ItemNo, Measurement);
            IF (ItemExists(ItemNo, "Units of Measure") = false) THEN begin
                Error('Item code not found or Units of Measure does not match: ' + ItemNo);
                exit(false);
            end;
        end;

        exit(CurrentCodeOk);
    END;

    local procedure ItemExists(ItemNo: Code[20]; Measurement: Code[10]): Boolean
    var
        ItemCard: Record Item;
        Found: Boolean;
    BEGIN
        Found := false;
        ItemCard.SetFilter("No.", ItemNo);
        IF (ItemCard.FindSet()) THEN begin
            repeat
                IF (ItemCard."No." = ItemNo) THEN begin
                    if (Found = true) THEN exit(true);
                    Found := true;
                end;
            UNTIL ItemCard.Next() = 0;
        end;
        IF (Found = true) THEN begin
            IF (ItemCard."Base Unit of Measure" = Measurement) THEN exit(true)
        end;
        exit(false);
    END;

    local procedure GetNo(): Integer
    var
        Line: Record "Customer Contract Line";
        LastNumber: Integer;
    BEGIN
        LastNumber := 0;
        IF Line.FindLast() THEN begin
            LastNumber := Line."No.";
        end;
        exit(LastNumber + 1);
    END;

    trigger OnModify()
    var
        ItemCard: Record Item;
    begin
        InitDefaults(Rec."Document No.");
        IF (Validate(Rec."Related Item", Rec."Units of Measure")) THEN begin
            ItemCard.SetFilter("No.", Rec."Related Item");
            IF (ItemCard.FindFirst()) THEN begin
                Rec."Related Item Description" := ItemCard.Description;
            end;
        end
        else
            Rec."Related Item Description" := '';
    end;

    trigger OnInsert()
    var
        ItemCard: Record Item;
    begin
        InitDefaults(Rec."Document No.");
        IF (Validate(Rec."Related Item", Rec."Units of Measure")) THEN begin
            ItemCard.SetFilter("No.", Rec."Related Item");
            IF (ItemCard.FindFirst()) THEN begin
                Rec."Related Item Description" := ItemCard.Description;
            end;
        end
        else
            Rec."Related Item Description" := '';
    end;
}