{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

Unit csvparser;

Interface
uses PlgTypes;

function ExtractCallEntry (s: string; var Call: PCallRec): boolean;


Implementation
uses SysUtils, RegExpr, TlsTypes, TlsFunc;

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

function ExtractCallEntry (s: string; var Call: PCallRec): boolean;
var
     r : TRegExpr;
     tel: string;
     myDate,
     myTime : TDateTime;
     H,M,Sec,Msec: word;

begin
     Result := false;

     r := TRegExpr.Create;
     r.Expression := Pattern;

     DateSeparator := '/';

     try
       myDate := StrToDate (GetValue (s));

       tel := GetValue (s);

       myTime := StrToTime(s);
       DecodeTime(myTime,H,M,Sec,Msec);

       with Call^ do
       if r.Exec (tel) then
       begin
            Date := myDate;
            Time := H * 360 + M * 60 + Sec;
            TelNo := DigiTel (r.Match[0]);
            Result := True;
       end;
     except
     end;
end;

end.
