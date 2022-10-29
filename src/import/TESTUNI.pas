uses types, unifile2;

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

begin
     wSize := SizeOf (TUniFile);
     AllocMem (Ptr, wSize);
     pUF := PUniFile (Ptr);

     fn := 'str80.db'; {'testuni.pas';}

     writeln (InitFile (pUF, fn));

     while NoMoreRec (pUF) = FALSE do
     begin
          GetRec (pUF, str);
          writeln (str);
     end;

     CloseFile (pUF);

     Free (Ptr, wSize);
     readln;
end.
