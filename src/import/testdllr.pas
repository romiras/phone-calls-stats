{$IFNDEF VER100}
  {$mode delphi}
{$ENDIF}

program testdll;

uses Classes, SysUtils, UniTypes, ModuleLoader, TlsTypes, TlsFunc;

type

  fInitFile = function (var UniF: PUniFile; FileName: PChar): integer; stdcall;
  fNoMoreRec = function (var UniF: PUniFile): boolean; stdcall;
  pGetRec = procedure (var UniF: PUniFile; var Data: PCallRec); stdcall;
  pCloseFile = procedure (var UniF: PUniFile); stdcall;

const
  {$IFDEF WINDOWS}
  dlext = '.dll';
  {$ELSE}
  dlext = '.so';
  {$ENDIF}

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

procedure CheckIfSymbolsLoaded (var ProcAddr: pointer; Module: TModuleHandle; SymbolName: PChar);
begin
  //ProcAddr := Nil;
  ProcAddr := GetModuleSymbol (Module, SymbolName);
  if ProcAddr = Nil then
  begin
    writeln ('Procedure symbol ', SymbolName, ' was not found!');
    halt;
  end
  else
    writeln ('Symbol ', SymbolName, ' loaded at ', Longint (ProcAddr));
end;

var
  Handle: TModuleHandle;

  pInitFileAddr,
  pNoMoreRecAddr,
  pGetRecAddr,
  pCloseFileAddr  : Pointer;

  Init_File: fInitFile;
  No_More_Rec: fNoMoreRec;
  Get_Rec: pGetRec;
  Close_File: pCloseFile;

  Cc: PCallRec;
  Uf: PUniFile;
//  Str: string80;

  code: integer;
  dlname,
  FN: array [0..31] of char;
  plgext,
  procname: string;
  L: TCallList;

BEGIN

  if ParamCount <> 1 then halt;

  StrPCopy (FN, ParamStr (1));
  plgext := 'csv';
  dlname := StrPCopy (FN, plgext+'imp'+dlext);

   writeln ('Loading library "', dlname, '"');
  if Not LoadModule (Handle, dlname) then
  begin
    writeln (#13#10'Library failed to load!');
    halt;
  end;
   writeln ('Done.');

  L := TCallList.Create;

   writeln ('Loading symbols... ');

  CheckIfSymbolsLoaded (pInitFileAddr, Handle, 'plgInitFile');
  CheckIfSymbolsLoaded (pNoMoreRecAddr, Handle, 'plgNoMoreRec');
  CheckIfSymbolsLoaded (pGetRecAddr, Handle, 'plgGetRec');
  CheckIfSymbolsLoaded (pCloseFileAddr, Handle, 'plgCloseFile');

   writeln ('Done.');

  @Init_File := pInitFileAddr;
  @No_More_Rec := pNoMoreRecAddr;
  @Get_Rec := pGetRecAddr;
  @Close_File := pCloseFileAddr;

  Cc := Nil;
  Uf := Nil;
  New (Cc);
  New (Uf);
  FillChar (Uf^, SizeOf (TUniFile), 0);
   writeln ('Before checking NIL');
  if ((Cc <> Nil) and (Uf <> Nil)) then
  begin
     writeln ('Before Init File');
    code := Init_File (UF, FN);
    if code = 0 then
    begin
       writeln ('Pointer address (decimal): ', Longint(Uf));
      while No_More_Rec (Uf) = FALSE do
      begin
        Get_Rec (Uf, Cc);
        with Cc^ do
          writeln ('Data:', date:10:1, telno:10, time: 8);
      end;
      Close_File (Uf);
    end
    else
      writeln ('Cannot open file: ', code);
    Dispose (Uf);
    Dispose (Cc);
  end
  else
    writeln ('No enough memory!');

  writeln (L.Count);
  ShowCallList (L);

  L.Free;

  UnloadModule (Handle);
   writeln ('Good bye !');

END.
