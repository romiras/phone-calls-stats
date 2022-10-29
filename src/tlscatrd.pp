{$mode ObjFpc}

unit tlscatrd;

interface

uses Classes;

function ReadBonds (fn: string): TList;

implementation
uses IniFiles, tlstypes,tlsconv;

function ReadBonds (fn: string): TList;
var
  List: TList;
  Bond: TBond;
  Ini : TIniFile;
  Sections, Values: TStringList;
  tel: string[12];
  k, i: integer;
begin
  List := TList.Create;

  Ini := TIniFile.Create (fn);
  Sections := TStringList.Create;

  Try
    Ini.ReadSections (Sections);
    Values := TStringList.Create;

    for k := 0 to Pred (Sections.Count) do
    begin
         Ini.ReadSectionValues (Sections[k], Values);
         {$IFDEF DEBUG}
         {$IFNDEF LCL}
         writeln;
         writeln (Values.Count, ' read');
         {$ENDIF LCL}
         {$ENDIF DEBUG}
         for i := 0 to Pred (Values.Count) do
         begin
            tel := Values[i];
            delete (tel, 1, 1); { delete first '=' }
            Bond := TBond.Create (tel, GetCategoryIndex (Succ(k)));
            List.Add (Bond);
         {$IFDEF DEBUG}
         {$IFNDEF LCL}
            writeln (tel);
         {$ENDIF LCL}
         {$ENDIF DEBUG}
         end;
         Values.Clear;
    end;
  Finally
    Values.Free;
    Sections.Free;
    Ini.Free;
  end;

  Result := List;
end;

end.

