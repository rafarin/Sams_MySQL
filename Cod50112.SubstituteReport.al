codeunit 50112 "Substitute Report"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ReportManagement, 'OnAfterSubstituteReport', '', false, false)]
    local procedure OnSubstituteReport(ReportId: Integer; var NewReportId: Integer)
    begin
        /*
        if ReportId = Report::"LBC REP Sales Invoice (P)" then
            NewReportId := Report::"SAMS Sale Invoice (Posted)";
        */
    end;
}