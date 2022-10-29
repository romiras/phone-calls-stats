uses types;

function plgInitFile (var UniF: PUniFile; FileName: string80): integer; external 'conv2.dll';
function plgNoMoreRec (var UniF: PUniFile): boolean; external 'conv2.dll';
procedure plgGetRec (var UniF: PUniFile; var Data: string80); external 'conv2.dll';
procedure plgCloseFile (var UniF: PUniFile); external 'conv2.dll';


procedure Abort;
begin
     writeln ('No enough memory');
     halt (1);
end;

procedure AllocMem (var P: pointer; Size: word);
begin
     GetMem (p, Size);
     if p = Nil then
        Abort;
end;

procedure Free (var P: pointer; Size: word);
begin
     if p <> Nil then
        FreeMem (p, Size);
end;

var
   Ptr: Pointer;
   pUF: PUniFile;
   wSize: word;
   str,
   FN: string80;
   Cc: PRec;
   res: integer;

begin
     wSize := SizeOf (TUniFile);
     AllocMem (Ptr, wSize);
     pUF := PUniFile (Ptr);

     if pUF <> Nil then
	writeln ('Memory has been allocated.')
     else
	halt;

     fn := 'str80.db'; {'testuni.pas';}

     write ('Init result: ');
     res := plgInitFile (pUF, fn);
     writeln (res);

     if res = 0 then
     begin
          writeln ('Starting reading of file.');

          while plgNoMoreRec (pUF) = FALSE do
          begin
               writeln ('Getting a record.');
               plgGetRec (pUF, str);
               writeln (str);
          end;

          writeln ('Reading finished.');
     end;

     write ('Closing file... ');
     plgCloseFile (pUF);

     writeln ('Done.');

     Free (Ptr, wSize);
     readln;
end.
