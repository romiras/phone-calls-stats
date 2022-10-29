{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

Uses
     Classes, SysUtils, DateUtils,
     tlstypes, tlsfunc, tlsstat, plgfunc;

procedure Help;
begin
     writeln;
     writeln ('Invalid usage of parameters. Read a manual in README file, please.');
end;

procedure GetParameters (var param1, param2, param3: string);
begin
     if ParamCount <> 3 then
     begin
          Help;
          Halt;
     end;

     param1 := ParamStr(1);
     param2 := ParamStr(2);
     param3 := ParamStr(3);
end;

procedure InitCallList;
begin
     CallList := TCallList.Create;
{     if Not Assigned (CallList) then
     begin
          raise Exception.Create('Error: Call list cannot be created!');
          exit;
     end;}
end;


procedure DoneCallList;
begin
     CallList.FreeItems;
     FreeAndNil (CallList);
end;


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


Var
     InputCSV,
     op,
     param: string;
     pluginname: PlgName;
     res: integer;
     TelStat: TTelStatistics;
     CatStat: TCatStatistics;

Begin
     GetParameters (InputCSV, op, Param);

     InitCallList;

     res := ReadCallList (InputCSV, PluginName, CallList);
     if res <> No_Errors then
     begin
       Writeln ('An error occured while reading file: ');
       case res of
        Err_Unknown:
          writeln (#13#10'The plugin `', PluginName,'` not found. Aborting.');
        Err_Not_Supported:
          writeln ('Wrong plugin version. Aborting.');
        Err_Alloc:
          writeln ('No enough memory for application!');
        Err_ListOp:
          writeln ('Access denied to ', PluginName);
       end;

       halt;
     end;

     //ShowCallList (CallList);

     if op = '1' then
     begin
          TelStat := TTelStatistics.Create (Param, CallList);
          TelStat.Calc;
          TelStat.Show;
          TelStat.Free;
     end
     else
     if op = '2' then
     begin
          writeln ('1');
          CatStat := TCatStatistics.Create (Param, CallList);
          writeln ('2');
          CatStat.Calc;
          writeln ('3');
          CatStat.Show;
          writeln ('4');
          CatStat.Free;
          writeln ('5');
     end;

     DoneCallList;

     writeln ('Good bye !');
end.
