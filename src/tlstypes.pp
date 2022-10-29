{$mode objfpc}

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
     TCategory = (Alliance,Friends,Work,Others);
     TCatHist = array [TCategory] of word;
     
     TBond = class
       TelNo: Cardinal;
       Category: TCategory;
       constructor Create (Tel: string; Cat: TCategory);
     end;

     TCall = class (TObject)
       Date: TDateTime;
       TelNo: Cardinal;
       Time: word;
       constructor Create (dDate: TDateTime; cTelNo: Cardinal; wTime: word);
     end;

{     TCallList = class (TList)
       procedure LoadFromFile (FileName: string); virtual;
     end;}

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
     end;
     
     TCallList = class (TListSorted)
     public
        function Compare(Item1, Item2: Pointer): Integer; override;
     end;

     ImportFunc = function (_FilePath: string; var _List: TCallList): integer;

procedure FreeItems (myList: TList);
function GetCategoryName (Cat: TCategory): string;
function GetCategoryIndex (Ind: byte): TCategory;
function CompareByTel (Item1 : Pointer; Item2 : Pointer) : Integer;
function ReadCallList (_Fn: string; var _List: TCallList): integer;

var
     CallList: TCallList;

Implementation
Uses SysUtils, TlsConv, impcsv;

function GetCategoryName (Cat: TCategory): string;
begin
     case Cat of
     Alliance:
      Result := 'Alliance';
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
      Result := Alliance;
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
     Self.TelNo := DigiTel (Tel);
     Self.Category := Cat;
end;

constructor TCall.Create (dDate: TDateTime; cTelNo: Cardinal; wTime: word);
begin
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
   Duplicates := dupIgnore;
   inherited Create;
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

function TCallList.Compare (Item1, Item2: Pointer): Integer;
begin
  if TCall(Item1).TelNo > TCall(Item2).TelNo then
     Result := 1
  else
  if TCall(Item1).TelNo = TCall(Item2).TelNo then
     Result := 0
  else
     Result := -1;
end;

procedure FreeItems (myList: TList);
var
     I: integer;
begin
     for i := 0 to Pred (myList.Count) do
          TObject (myList[i]).Free;
end;

{procedure TCallList.LoadFromFile (FileName: string);
var
  res: integer;
begin
  //AbstractError
  res := ReadCallList (FileName, fList);
end;}

function ReadCallList (_Fn: string; var _List: TCallList): integer;
var
  Ext: string;
//  Func: ImportFunc;
begin
     Result := Err_Unknown;
     Ext := LowerCase (ExtractFileExt (_Fn));

     if Ext = '.csv' then
     begin
//       Func := @ReadCSV;
//       Result := Func (_Fn, _List);
       Result := ReadCSV (_Fn, _List);
     end
     else
       Result := Err_Not_Supported;
end;

end.
