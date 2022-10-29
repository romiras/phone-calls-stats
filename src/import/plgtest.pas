{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

program testplugin;

uses Classes, SysUtils, ModuleLoader, Plgfunc, PlgTypes, TlsTypes, TlsFunc;



procedure ShowCallList (myList: TList);
var
     i : Integer;
begin
     writeln;
     for i := 0 to Pred (myList.Count) do
     with TCall (myList[i]) do
          writeln (Format ('%s %15s %4d sec',
           [DateTimeToStr (Date), TelStr (TelNo), Time])
          );
end;


var
  CaList: TCallList;
  res, i: integer;
  dlname,
  FN: PlgName;

BEGIN

  if ParamCount <> 1 then halt;

  StrPCopy (FN, ParamStr (1));


  CaList := TCallList.Create;

  res := ReadCallList (FN, dlname, CaList);

  if res <> 0 then
  begin
    case res of
     -1: writeln (#13#10'The plugin `', dlname,'` not found. Aborting.');
     -2: writeln ('Wrong plugin version. Aborting.');
     -3: writeln ('No enough memory for application!');
     -4: writeln ('Access denied to ', dlname);
    end;
    halt;
  end;

  ShowCallList (CaList);

  for i := 0 to CaList.Count-1 do
    TCall(CaList[i]).Free;
  CaList.Free;


  writeln ('Good bye !');

END.
