unit UniFile1;

Interface
uses Types;

function plgInitFile (var UniF: PUniFile; FileName: string80): integer; stdcall;
function plgNoMoreRec (var UniF: PUniFile): boolean; stdcall;
procedure plgGetRec (var UniF: PUniFile; var Data: string80); stdcall;
procedure plgCloseFile (var UniF: PUniFile); stdcall;

procedure plgCheckFile (var UniF: PUniFile); stdcall;

Implementation

{ We want to create typed file, so isText=FALSE }

function plgInitFile (var UniF: PUniFile; FileName: string80): integer;
begin
     writeln ('DEBUG: initfile - start');
     writeln (FileName);
     if UniF <> Nil then
     with UniF^ do
     begin
          isText := FALSE;
          writeln ('DEBUG: initfile - before assign');
          Assign (F, FileName);
          writeln ('DEBUG: initfile - before reset');
          {$I-}
          Reset (F, 1);
          {$I+}
          writeln ('DEBUG: initfile - before IOresult');
          plgInitFile := IOresult;
     end
     else
          plgInitFile := -1;
end;


function plgNoMoreRec (var UniF: PUniFile): boolean;
begin
     plgNoMoreRec := EOF (UniF^.F);
     writeln ('EOF: ', result)
end;

procedure plgGetRec (var UniF: PUniFile; var Data: string80);
begin
     blockread (UniF^.F, Data, SizeOf(string80));
end;

procedure plgCloseFile (var UniF: PUniFile);
begin
     Close (UniF^.F)
end;

procedure plgCheckFile (var UniF: PUniFile);
begin
     writeln (Longint (UniF));
end;

end.
