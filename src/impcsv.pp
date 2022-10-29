{$mode objfpc}

unit impcsv;

interface

uses Classes, tlstypes;

function ReadCSV (Fn: string; var List: TCallList): integer;

implementation

uses SysUtils, TlsConv, RegExpr;

const
    delimiter: char = ',';  {data separator character}
    //MaxValues = 3; { Max. of CSV data cells }
    Pattern = '([\d]{9,}|[\d]{3,4}?\*)';

function GetValue (var ss: string): string;
var
     m: integer;
     value: string;
begin
     m := pos (delimiter, ss);
     if m <> 0 then
     if m = 1 then
          value := ''
     else
          value := copy (ss, 1, m-1);
     delete (ss, 1, m);
     while ss[1] in [' ',#9] do delete (ss, 1, 1);
     GetValue := Value;
end;

function ExtractCallEntry (s: string): TCall;
var
     r : TRegExpr;
     tel: string;
     myDate,
     myTime : TDateTime;
     H,M,Sec,Msec: word;
     oCall: TCall;

begin
     r := TRegExpr.Create;
     r.Expression := Pattern;

     DateSeparator := '/';
     myDate := StrToDate (GetValue (s));

     tel := GetValue (s);

     myTime := StrToTime(s);
     DecodeTime(myTime,H,M,Sec,Msec);

     if r.Exec (tel) then
     begin
          oCall := TCall.Create (myDate, DigiTel (r.Match[0]), H * 360 + M * 60 + Sec);
          //writeln (r.InputString);
     end
     else
          oCall := Nil;

     Result := oCall
end;

function ReadCSV (Fn: string; var List: TCallList): integer;
var
     Fin: TStringList;
     Call: TCall;
     k: word;
begin
     Try
          if Not Assigned (List) then
          begin
               Result := Err_Alloc;
               exit;
          end;

          Fin := TStringList.Create;
          if Not Assigned (Fin) then
          begin
               Result := Err_Alloc;
               exit;
          end;

          Fin.LoadFromFile (Fn);
          for k := 1 to Fin.Count - 1 do // CSV! Skip first line (desc.)
          begin
               Call := ExtractCallEntry (Fin[k]);
               if Assigned (Call) then
                    List.Add (Call);
          end;
     except
          //on E:Exception do
          Result := Err_ListOp;
     end;

     List.Pack;
     Fin.Free;

     Result := No_Errors;
end;

end.

