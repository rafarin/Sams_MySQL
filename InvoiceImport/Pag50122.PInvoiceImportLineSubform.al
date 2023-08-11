page 50122 "P Invoice Import Subform"
{
    ApplicationArea = Basic, Suite;
    PageType = ListPart;
    Editable = true;
    LinksAllowed = false;
    Caption = 'Purchases Invoice Import Subform';
    SourceTable = "P Invoice Import Line";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Type"; Rec."Type")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Dynamics No."; Rec."DynamicsNo")
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = Item."No." WHERE("No." = FILTER('Z0*|P0*|T0*|GMT*|GMP*|GMN*|GMD*|GD*'));
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Basic, Suite;
                    TableRelation = "Unit of Measure".Code;
                    Editable = true;

                    trigger OnDrillDown()
                    var
                        NewCode: Code[10];
                        CodeUnitInvoiceImport: Codeunit InvoiceImport;
                        InvStatus: Text[20];
                    begin
                        IF (Rec.DynamicsNo <> '') THEN BEGIN
                            InvStatus := CodeUnitInvoiceImport.GetListStatus(Rec."Document Type", Rec."Document No.", 'Purchases');
                            IF (InvStatus = 'error') THEN BEGIN
                                IF (CodeUnitInvoiceImport.UnitOfMeasurementChooser('Choose Unit of Measurement for ' + Rec."No." + ':', Rec."Unit of Measure Code", NewCode)) THEN begin
                                    Rec.Validate("Unit of Measure Code", NewCode);
                                    Rec.Modify(false);
                                end;
                            END;
                        END;
                    end;
                }
                field("Quantity"; Rec."Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Basic, Suite;
                    Editable = false;
                }
            }
        }
    }
}

