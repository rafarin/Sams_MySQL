table 50103 "Customer Contract Header"
{
    Caption = 'Customer Contract Header';
    DataCaptionFields = "No.", "Sell-to Customer Name";
    LookupPageID = "Customer Contract List";

    fields
    {
        field(1; "Sell-to Customer No."; Code[20])
        {
            Caption = 'Sell-to Customer No.';
            TableRelation = Customer;
            trigger OnValidate()
            var
                CustName: Text[100];
            begin
                IF CodeUnitContract.GetCustomerName("Sell-to Customer No.", CustName) THEN begin
                    "Sell-to Customer Name" := CustName;
                    CodeUnitContract.SetLineCustomerNo("No.", "Sell-to Customer No.");

                end
                else begin
                    "Sell-to Customer Name" := '';
                    "Sell-to Customer No." := '';
                end;
            end;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            trigger OnValidate()
            begin
                if "No." <> xRec."No." then begin
                    SalesSetup.Get();
                    NoSeriesMgt.TestManual(SalesSetup."Customer Contract Nos.");
                    "No. Series" := SalesSetup."Customer Contract Nos.";
                end;
            end;
        }
        field(3; "Sell-to Customer Name"; Text[100])
        {
            Caption = 'Sell-to Customer Name';
        }
        field(4; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        field(5; "Contract No."; Code[35])
        {
            Caption = 'Contract No.';
            NotBlank = true;
            Editable = true;

            trigger OnValidate()
            var
            begin
                CodeUnitContract.SetLineContractNo("No.", "Contract No.");
            end;
        }
        field(6; "Contract Description"; Text[100])
        {
            Caption = 'Contract Description';
            Editable = true;
        }
        field(7; "Contract Date"; Date)
        {
            Caption = 'Contract Date';
            Editable = true;
            trigger OnValidate()
            begin
                CodeUnitContract.isValidContractDate(Rec);
            end;
        }
        field(8; "Contract Start Date"; Date)
        {
            Caption = 'Contract Start Date';
            Editable = true;
            NotBlank = true;
            trigger OnValidate()
            begin
                CodeUnitContract.isValidStartDate(Rec);
            end;
        }
        field(9; "Contract End Date"; Date)
        {
            Caption = 'Contract End Date';
            Editable = true;
            NotBlank = true;
            trigger OnValidate()
            begin
                CodeUnitContract.isValidEndDate(Rec);
            end;
        }
        field(10; "Contract Extend Date"; Date)
        {
            Caption = 'Contract Extend Date';
            Editable = true;
            NotBlank = false;
            trigger OnValidate()
            begin
                IF CodeUnitContract.isValidExtendDate(Rec) <> true THEN begin
                    Message('Contract extension date can not be equal or less then contract end date');
                end;
            end;
        }
        field(11; "Override Items"; Boolean)
        {
            Caption = 'Override Items';
            Editable = true;
            NotBlank = true;
            InitValue = true;
        }
        field(12; "Override Item Prices"; Boolean)
        {
            Caption = 'Override Item Prices';
            Editable = true;
            NotBlank = true;
            InitValue = true;
        }
        field(13; "Contract Value"; Decimal)
        {
            Caption = 'Contract maximum value without VAT';
            Editable = true;
            NotBlank = true;
            InitValue = 0.0;
        }
        field(14; "Allow Expired Prices"; Boolean)
        {
            Caption = 'Use contract item prices even contract max value reached';
            Editable = true;
            NotBlank = true;
            InitValue = true;
        }
    }
    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    var
    begin
        if "No." = '' then begin
            SalesSetup.Get();
            SalesSetup.TestField(SalesSetup."Customer Contract Nos.");
            IF ((SalesSetup."Customer Contract Nos.") = '') THEN begin
                Error('Check Sales & Receivalables Setup for Customer Contract Nos.');
            end;
            NoSeriesMgt.InitSeries(SalesSetup."Customer Contract Nos.", xRec."No. Series", 0D, "No.", "No. Series");
            /*
            IF (Rec."Contract Value" <= 0.0) THEN begin
                Message('Update contract value. Current: ' + Format(Rec."Contract Value"));
            end;
            */
            Message('Customer Contract Created ' + "No.");
        end;
    end;

    trigger OnModify()
    var
    begin
        IF (CodeUnitContract.isValidContractDate(Rec) = false) THEN begin
            Error('Check contract dates. Incorrect contract date');
        end;
        IF (CodeUnitContract.isValidStartDate(Rec) = false) THEN begin
            Error('Check contract dates. Incorrect contract start date');
        end;
        IF (CodeUnitContract.isValidEndDate(Rec) = false) THEN begin
            Error('Check contract dates. Incorrect contract end date');
        end;
        IF (CodeUnitContract.isValidExtendDate(Rec) = false) THEN begin
            Error('Contract extension date can not be equal or less then contract end date');
        end;
        IF (Rec."Contract Value" <= 0.0) THEN begin
            Message('Update contract value. Current: ' + Format(Rec."Contract Value") + ' Eur.');
        end;
    end;

    trigger OnDelete()
    var
        Line: Record "Customer Contract Line";
    begin
        Line.SetFilter("Document No.", Rec."No.");
        IF (Line.FindSet()) THEN begin
            Line.DeleteAll();
        end;
    end;

    protected var
        Customer: Record Customer;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        CodeUnitContract: Codeunit CustomerContract;
        SalesSetup: Record "Sales & Receivables Setup";
}