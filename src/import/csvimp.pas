Library csvimp;

uses
  SysUtils, plgtypes, unifiler;

procedure GetPlugInfo (var Info: TPluginInfo); stdcall;
begin
  with Info do
  begin
    strcopy (Version, '0.1.0');
    strcopy (FType, 'csv');
  end;
end;

exports
  GetPlugInfo,
  plgInitFile,
  plgNoMoreRec,
  plgGetRec,
  plgCloseFile;

begin
end.
