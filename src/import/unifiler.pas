{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

unit UniFileR;

Interface
uses PlgTypes;

function plgInitFile (var UniF: PUniFile; FileName: PChar): integer; stdcall;
function plgNoMoreRec (var UniF: PUniFile): boolean; stdcall;
procedure plgGetRec (var UniF: PUniFile; var Data: PCallRec); stdcall;
procedure plgCloseFile (var UniF: PUniFile); stdcall;

Implementation

uses csvparser;

{ We want to create typed file, so isText=FALSE }

function plgInitFile (var UniF: PUniFile; FileName: PChar): integer; stdcall;
begin
     if UniF <> Nil then
     with UniF^ do
     begin
          isText := TRUE;
//          writeln ('Assign- Before');
          Assign (T, FileName);
//          writeln ('Assign');
          {$I-}
          Reset (T);
//          writeln ('Reset');
          {$I+}
          plgInitFile := IOresult;
//          writeln ('Result: ', Result);
     end
     else
          plgInitFile := -1;
end;


function plgNoMoreRec (var UniF: PUniFile): boolean; stdcall;
begin
     plgNoMoreRec := EOF (UniF^.T)
end;

procedure plgGetRec (var UniF: PUniFile; var Data: PCallRec); stdcall;
var
     S: string;
begin
     readln (UniF^.T, S);
//      writeln ('Entry: ', S);
     if Not ExtractCallEntry (S, Data) then
     with Data^ do
     begin
//        writeln ('Failed!');
       TelNo := 0;
       Date := 0.0;
       Time := 0;
     end;
end;

procedure plgCloseFile (var UniF: PUniFile); stdcall;
begin
     Close (UniF^.T)
end;

end.
