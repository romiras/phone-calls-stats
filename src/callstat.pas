{$mode objfpc}

Uses
     Classes, SysUtils, DateUtils,
     tlstypes, tlsconv, tlsstat;

procedure ShowBondList (myList: TList);
var
     i : Integer;
begin
     writeln;
     for i := 0 to Pred (myList.Count) do
     with TBond(myList[i]) do
          writeln (
           TelStr (TelNo), ' -- ',
           GetCategoryName (Category)
          );
end;

procedure ShowCallList (myList: TList);
var
     i : Integer;
begin
     writeln;
     for i := 0 to Pred (myList.Count) do
     with TCall (myList[i]) do
          writeln (Format ('%s [%s] %d sec',
           [DateTimeToStr (Date), TelStr (TelNo), Time])
          );
end;

procedure Help;
begin
     writeln;
     writeln ('CallStat /version 0.5/ (c) RoMiras');
     writeln;
     writeln ('CallStat is a program what shows call statistics');
     writeln (' by specific phone number or by groups');
     writeln;
     writeln ('Usage example:');
     writeln;
     writeln ('  callstat <file.csv> 1 <Tel.#>');
     writeln ('    Get call statistics for phone number.');
     writeln ('    ');
     writeln;
     writeln ('  callstat <file.csv> 2 <groups.txt>');
     writeln ('    Get statistics by groups. ');
     writeln;
     writeln ('Input .CSV file must contain following format of each row:');
     writeln ('  dd/mm/yyyy,<destination>,h:mm:ss');
end;


Var
     InputCSV,
     op,
     param: string;
     res: integer;

Begin
     if ParamCount <> 3 then
     begin
          Help;
          Halt;
     end;

     InputCSV := ParamStr(1);
     op := ParamStr(2);
     param := ParamStr(3);

     res := ReadCallList (InputCSV, CallList);
     if res < 0 then
     begin
       Writeln ('An error occured while reading file: ');
       case res of
        Err_Unknown:
          writeln ('Unknown');
        Err_Not_Supported:
          writeln ('File type is not supported.');
        Err_Alloc:
          writeln ('Memory allocation failed.');
        Err_ListOp:
          writeln ('List operation.');
       end;

       halt;
     end;

     if Not Assigned (CallList) then
     begin
          raise Exception.Create('Error: Call list not created!');
          exit;
     end;

     //ShowCallList (CallList);

     if op = '1' then
     begin
          InitTelStatistics (DigiTel(Param));
          GetTelStatistics (CallList);
          ShowTelStatistics (CallList);
     end
     else
     if op = '2' then
     begin
          InitCatStatistics (Param);
          GetCatStatistics (CallList);
          ShowCatStatistics (CallList);
          EndCatStatistics;
     end;

     //FreeItems (CallList);
     FreeAndNil (CallList);
end.
