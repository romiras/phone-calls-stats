{$IFDEF FPC}
  {$mode objfpc}
{$ENDIF}

{$IFDEF LCL}
 {$DEFINE GUI}
{$ENDIF}

Unit TlStypes;


Interface
Uses Classes;

const
  No_Errors         = 0;
  Err_Unknown       = -1;
  Err_Not_Supported = -2;
  Err_Alloc         = -3;
  Err_ListOp        = -4;

Type
     TCategory = (Relatives,Friends,Work,Others);
     TCatHist = array [TCategory] of word;

     {$IFNDEF FPC}
     LongWord = Cardinal;
     {$ENDIF}

     TBond = class
       TelNo: LongWord;
       Category: TCategory;
       constructor Create (Tel: string; Cat: TCategory);
     end;

     TCall = class (TObject)
       Date: TDateTime;
       TelNo: LongWord;
       Time: word;
       constructor Create (dDate: TDateTime; cTelNo: LongWord; wTime: word);
     end;

     TListSorted = class (TList)
      public
        // Allow duplicate objects in the
        // list of objects based on
        // compare(item1,item2) = 0
        // Default to dupIgnore (dupes ok)
        Duplicates : TDuplicates;

        constructor Create;

        // an abstract compare function
        // this should be overridden by an inheriting class
        // it should return   -1 if item1 < item2
        //                    0 if item1 = item2
        //                    1 if item1 > item2
        function Compare(Item1, Item2: Pointer): Integer; virtual; abstract;

        function Add(Item: Pointer): Integer;

        // returns the index of Item using the compare method to find
        // the object
        // note: if more than one object matches using the compare method,
        //       this does not look for the same memory address by
        //       matching the pointers, it looks for the same value
        //       ie compare method returns 0
        // then any one of those matching could be returned
        // The index returned, ranges from 0 to Count-1
        // A value of -1 indicates that no Item was found
        function FindObject(Item : Pointer) : Integer;
        function FindObjectByTelNo (No: LongWord) : Integer;
     end;

     TCallList = class (TListSorted)
     public
        function Compare(Item1, Item2: Pointer): Integer; override;
        //procedure LoadFromFile (fn: string); virtual; abstract;
        procedure FreeItems;
     end;

     TBondList = class (TListSorted)
     public
        function Compare(Item1, Item2: Pointer): Integer; override;
        procedure LoadFromFile (fn: string);
     end;

     TBaseStatistics = class
     protected
        SourceDB: TCallList;
     public
        constructor Create (SrcDB: TCallList);// overload;
        procedure   Calc; virtual; abstract;
     end;


function GetCategoryName (Cat: TCategory): string;
function GetCategoryIndex (Ind: byte): TCategory;
function CompareByTel (Item1 : Pointer; Item2 : Pointer) : Integer;
procedure CP_Free;

var
  CallList: TCallList;
  CPList: TList;  // List of TStrings - used for storage of called party numbers
  CPItems,        // Called party numbers
  CPImported: TStringList;  // Called party imported from DB file

Implementation
Uses SysUtils, IniFiles, TlsFunc;


function GetCategoryName (Cat: TCategory): string;
begin
     case Cat of
     Relatives:
      Result := 'Relatives';
     Friends:
      Result := 'Friends';
     Work:
      Result := 'Work';
     else
      Result := 'Others';
     end;
end;


function GetCategoryIndex (Ind: byte): TCategory;
begin
     case Ind of
     1:
      Result := Relatives;
     2:
      Result := Friends;
     3:
      Result := Work;
     else
      Result := Others;
     end;
end;


constructor TBond.Create (Tel: string; Cat: TCategory);
begin
     Inherited Create;
     Self.TelNo := DigiTel (Tel);
     Self.Category := Cat;
end;


constructor TCall.Create (dDate: TDateTime; cTelNo: LongWord; wTime: word);
begin
     Inherited Create;
     Self.Date := dDate;
     Self.TelNo := cTelNo;
     Self.Time := wTime;
end;


function CompareByTel (Item1 : Pointer; Item2 : Pointer) : Integer;
var
  TBond1, TBond2 : TBond;
begin
  TBond1 := TBond(Item1);
  TBond2 := TBond(Item2);

  if TBond1.TelNo > TBond2.TelNo then
     Result := 1
  else
  if TBond1.TelNo = TBond2.TelNo then
     Result := 0
  else
     Result := -1;
end;


constructor TListSorted.Create;

begin
   inherited Create;
   Duplicates := dupIgnore;
end;


function TListSorted.Add(Item : Pointer) : Integer;
var
   nCount  : Integer;
   bFound  : Boolean;
   nResult : Integer;

begin
   nCount := 0;
   bFound := False;
   // search the list of objects until we find the
   // correct position for the new object we are adding
   while (not bFound) and (nCount < Count) do begin
      if (Compare(Items[nCount],Item) >= 0) then
         bFound := True
      else
         inc(nCount);
   end;
   if (bFound) then begin
      if (Duplicates = dupIgnore) or (Compare(Items[nCount],Item) <> 0) then begin
         Insert(nCount,Item);
         nResult := nCount;
      end else
         nResult := -1;
   end else
      nResult := inherited Add(Item);
   Add := nResult;
end;


function TCallList.Compare (Item1, Item2: Pointer): Integer;
begin
  if TCall(Item1).TelNo > TCall(Item2).TelNo then
     Result := 1
  else
  if TCall(Item1).TelNo < TCall(Item2).TelNo then
     Result := -1
  else
     Result := 0;
end;

constructor TBaseStatistics.Create (SrcDB: TCallList);
begin
  Inherited Create;
  SourceDB := SrcDB;
end;


function TListSorted.FindObject(Item : Pointer) : Integer;
// Find the object using the compare method and
// a binary chop search

var
   nResult   : Integer;
   nLow      : Integer;
   nHigh     : Integer;
   nCompare  : Integer;
   nCheckPos : Integer;

begin
   nLow := 0;
   nHigh := Count-1;
   nResult := -1;
   // keep searching until found or
   // no more items to search
   while (nResult = -1) and (nLow <= nHigh) do begin
      nCheckPos := (nLow + nHigh) div 2 ;
      nCompare := Compare(Item,Items[nCheckPos]);
      if (nCompare = -1) then                // less than
         nHigh := Pred(nCheckPos)
      else if (nCompare = 1) then            // greater than
         nLow := Succ(nCheckPos)
       else                                  // equal to
         nResult := nCheckPos;
   end;
   FindObject := nResult;
end;


function TListSorted.FindObjectByTelNo (No: LongWord) : Integer;
var C: TCall;
begin
    C := TCall.Create (TDateTime(0), No, 0);
    result := FindObject (C);
    C.Free;
end;


function TBondList.Compare (Item1, Item2: Pointer): Integer;
begin
  if TBond(Item1).TelNo > TBond(Item2).TelNo then
     Result := 1
  else
  if TBond(Item1).TelNo < TBond(Item2).TelNo then
     Result := -1
  else
     Result := 0;
end;


procedure TBondList.LoadFromFile (fn: string);
var
  Bond: TBond;
  Ini : TIniFile;
  Sections, Values: TStringList;
  tel: string[12];
  k, i: integer;
begin
  Ini := TIniFile.Create (fn);
  Sections := TStringList.Create;

  Try
    Ini.ReadSections (Sections);
    Values := TStringList.Create;

    for k := 0 to Sections.Count-1 do
    begin
         Ini.ReadSectionValues (Sections[k], Values);
         {$IFDEF DEBUG}
         {$IFNDEF GUI}
         writeln;
         writeln (Values.Count, ' read');
         {$ENDIF GUI}
         {$ENDIF DEBUG}
         for i := 0 to Values.Count-1 do
         begin
            tel := Values[i];
            System.delete (tel, 1, 1); { delete first '=' }
            Bond := TBond.Create (tel, GetCategoryIndex (Succ(k)));
            Self.Add (Bond);
         {$IFDEF DEBUG}
         {$IFNDEF GUI}
            writeln (tel);
         {$ENDIF GUI}
         {$ENDIF DEBUG}
         end;
         Values.Clear;
    end;
  Finally
    Values.Free;
    Sections.Free;
    Ini.Free;
  end;
end;


procedure TCallList.FreeItems;
var
     I: integer;
begin
     for i := 0 to Self.Count-1 do
          TCall(Self[i]).Free;
end;


procedure CP_Free;
var
  i: integer;
begin
  for i := 0 to CPList.Count-1 do
      TStringList(CPList.Items[i]).Free;
  CPList.Free;
end;


initialization

  CPList := TList.Create;
  //CallList := TCallList.Create;
  CPImported := TStringList.Create;

finalization

  CPImported.Free;
  //CallList.Free;
  CP_Free;

end.
