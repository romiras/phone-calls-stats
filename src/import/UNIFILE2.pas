unit UniFile2;

Interface
uses Types;

function plgInitFile (var UniF: PUniFile; FileName: string80): integer; export;
function plgNoMoreRec (var UniF: PUniFile): boolean; export;
procedure plgGetRec (var UniF: PUniFile; var Data: string80); export;
procedure plgCloseFile (var UniF: PUniFile); export;

Implementation

{ We want to create typed file, so isText=FALSE }

function plgInitFile (var UniF: PUniFile; FileName: string80): integer; export;
begin
     writeln ('DEBUG: initfile - start');
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


function plgNoMoreRec (var UniF: PUniFile): boolean; export;
begin
     plgNoMoreRec := EOF (UniF^.F)
end;

procedure plgGetRec (var UniF: PUniFile; var Data: string80); export;
begin
     blockread (UniF^.F, Data, SizeOf(string80));
end;

procedure plgCloseFile (var UniF: PUniFile); export;
begin
     Close (UniF^.F)
end;

end.
