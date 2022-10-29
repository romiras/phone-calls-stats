{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

Unit TlsFunc;

Interface

function DigiTel (Tel: string): Cardinal;
function TelStr (D: Cardinal): string;

Implementation
Uses SysUtils;

function DigiTel (Tel: string): Cardinal;
var L: word;
begin
     //write (Tel, ' = '); //debug
     Result := 0;
     L := length (Tel);
     if Tel[L] = '*' then
          delete (Tel, L, 1);
     if (L >= 9) AND (Tel[1] = '0') then
          delete (Tel, 1, 1);
     if L >= 12 then
          delete (Tel, 1, 3);
     Result := StrToInt (Tel);
end;

function TelStr (D: Cardinal): string;
begin
     if D >= 10000000 then
        Result := '0' + IntToStr(D)
     else
        Result := '*' + IntToStr(D);
end;

end.
