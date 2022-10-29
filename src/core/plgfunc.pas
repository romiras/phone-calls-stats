{$IFNDEF VER100}
  {$mode delphi}
{$ENDIF}

unit plgfunc;

interface
uses ModuleLoader, TlsTypes, PlgTypes;

type
  PlgName = array [0..31] of char;

  fInitFile = function (var UniF: PUniFile; FileName: PChar): integer; stdcall;
  fNoMoreRec = function (var UniF: PUniFile): boolean; stdcall;
  pGetRec = procedure (var UniF: PUniFile; var Data: PCallRec); stdcall;
  pCloseFile = procedure (var UniF: PUniFile); stdcall;

var
  Handle: TModuleHandle;

  Init_File: fInitFile;
  No_More_Rec: fNoMoreRec;
  Get_Rec: pGetRec;
  Close_File: pCloseFile;


procedure GetPlgName (fparam: string; var plgnam: PlgName);
function LoadProcSymbols (var Hnd: TModuleHandle): boolean;
function ReadCallList (FromF: PlgName; var Plugin: PlgName; var CL: TCallList): shortint;

implementation
uses SysUtils;

const
  {$IFDEF WIN32}
  dlext = '.dll';
  {$ELSE}
  dlext = '.so';
  {$ENDIF}


procedure GetPlgName (fparam: string; var plgnam: PlgName);
var
  plgext: string;
begin
  plgext := ExtractFileExt (fparam);
  delete (plgext, 1, 1);
  strPcopy (plgnam, plgext+'imp'+dlext);
end;

function LoadProcSymbols (var Hnd: TModuleHandle): boolean;
var
  pInitFileAddr,
  pNoMoreRecAddr,
  pGetRecAddr,
  pCloseFileAddr  : Pointer;

begin
  Result := FALSE;

//  CheckIfSymbolsLoaded (pInitFileAddr, Hnd, 'plgInitFile');
  pInitFileAddr := GetModuleSymbol (Hnd, 'plgInitFile');
  if pInitFileAddr = Nil then
    exit;
  pGetRecAddr := GetModuleSymbol (Hnd, 'plgGetRec');
  if pGetRecAddr = Nil then
    exit;
  pNoMoreRecAddr := GetModuleSymbol (Hnd, 'plgNoMoreRec');
  if pNoMoreRecAddr = Nil then
    exit;
  pCloseFileAddr := GetModuleSymbol (Hnd, 'plgCloseFile');
  if pCloseFileAddr = Nil then
    exit;

  @Init_File := pInitFileAddr;
  @No_More_Rec := pNoMoreRecAddr;
  @Get_Rec := pGetRecAddr;
  @Close_File := pCloseFileAddr;

  Result := TRUE;
end;


procedure Initialize (var R: PCallRec; var F: PUniFile);
begin
  R := Nil;
  F := Nil;
  New (R);
  New (F);
  FillChar (F^, SizeOf (TUniFile), 0);
end;


procedure Finalize (var R: PCallRec; var F: PUniFile);
var
  i: integer;
begin
  Dispose (R);
  Dispose (F);
end;


function ReadCallList (FromF: PlgName; var Plugin: PlgName; var CL: TCallList): shortint;
var
  Cc: PCallRec;
  Uf: PUniFile;

  k, code: integer;
  Call: TCall;

begin
  result := 0;

  // Extracting plugin name parameters
  GetPlgName (FromF, Plugin);

   writeln ('Loading library `', Plugin, '` ...');
  if Not LoadModule (Handle, Plugin) then
  begin
    result := -1;
    exit;
  end;

   //writeln ('Loading symbols... ');
  if Not LoadProcSymbols (Handle) then
  begin
    result := -2;
    halt;
  end;

   writeln ('The plugin has been loaded successfully.');

  Initialize (Cc, Uf);
  if ((Cc = Nil) OR (Uf = Nil)) then
  begin
    result := -3;
    halt;
  end;

//   writeln ('Before Init File');
  code := Init_File (UF, FromF);
  if code <> 0 then
  begin
    result := -4;
    halt;
  end;
//   writeln ('Pointer address: ', IntToHex(Longint(Uf), 8));

  while No_More_Rec (Uf) = FALSE do
  begin
    Get_Rec (Uf, Cc);

    with Cc^ do
      Call := TCall.Create (date, telno, time);
    if Cc^.telno <> 0 then
      CL.Add (Call);
    //with Cc^ do
      //writeln ('Data:', date:10:1, telno:10, time: 8);
  end;
//   writeln ('Closing file...');
  Close_File (Uf);

  Finalize (Cc, Uf);
  UnloadModule (Handle);
   writeln ('The plugin has been unloaded successfully.');

end;


end.

