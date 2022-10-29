{$mode ObjFPC}

unit TlsStat;

interface

uses Classes, TlsTypes;

var
     BondList: TBondList;


     CatHistTimes,
     CatMaxTimes,
     CatHistCalls: TCatHist;
     CallsTo,
     MaxCallDuration,
     TotalCallsDurationTo: word;
     CallsTotal: Longint;
     days, daystotal: word;
     SomeTel: Cardinal;

Type
     TTelStatistics = class (TBaseStatistics)
        constructor Create (Param: string; SrcDB: TCallList);
        procedure   Calc;
        procedure   Show;
     end;

     TCatStatistics = class (TBaseStatistics)
        constructor Create (Param: string; SrcDB: TCallList);
        procedure   Calc;
        procedure   Show;
        Destructor  Destroy; override;
     end;

implementation
uses SysUtils, DateUtils, TlsFunc, tlscatrd;

var
     dDate: TDateTime;

constructor TTelStatistics.Create (Param: string; SrcDB: TCallList);
begin
     Inherited Create(SrcDB);

     days := 0;
     dDate := 0.0;

     SomeTel := DigiTel(Param);
     CallsTo := 0;
     MaxCallDuration := 0;
     TotalCallsDurationTo := 0;
end;


procedure TTelStatistics.Calc;
var
     k: integer;
begin
     for k := 0 to SourceDB.Count-1 do
     with TCall(SourceDB[k]) do
     begin
          if date <> dDate then
          begin
               dDate := date;
               inc(days);
          end;

          if TelNo = SomeTel then
          begin
               if Time > MaxCallDuration then
                    MaxCallDuration := time;
               inc (TotalCallsDurationTo, Time);
               inc (CallsTo);
          end;
     end;

     daystotal := DaysBetween (
       TCall(SourceDB[0]).date,
       TCall(SourceDB[SourceDB.Count-1]).date
     );
end;


procedure TTelStatistics.Show;
begin
     writeln;
     writeln (Format ('%d days of calls brutto of %d days total',
      [days, daystotal]));

     writeln;
     writeln (Format ('-- Calls statistics for #%s --',
      [TelStr (SomeTel)]));

     writeln;
     writeln (Format ('Calls quantity: %12d',
      [CallsTo]));
     writeln (Format ('Average calls per day: %5.1f',
      [CallsTo/days]));
     writeln (Format ('Average call duration: %5.1f',
      [TotalCallsDurationTo/(SourceDB.Count*60.0)]));
     writeln (Format ('Maximum call duration: %5.1f',
      [MaxCallDuration/60.0]));
end;


constructor TCatStatistics.Create (Param: string; SrcDB: TCallList);
begin
     Inherited Create(SrcDB);
     days := 0;
     dDate := 0.0;

     BondList.LoadFromFile (Param); //:= ReadBonds (Param);
     BondList.Pack;
     BondList.Sort (@CompareByTel);
     //ShowBondList (BondList);

     FillChar (CatHistCalls, SizeOf(CatMaxTimes), 0);
     FillChar (CatHistTimes, SizeOf(CatMaxTimes), 0);
     FillChar (CatMaxTimes,  SizeOf(CatMaxTimes), 0);
end;


procedure TCatStatistics.Calc;
var
     k, iobj: integer;
     cat: TCategory;
begin
     for k := 0 to Pred (SourceDB.Count) do
     with TCall(SourceDB[k]) do
     begin
          if date <> dDate then
          begin
               dDate := date;
               inc(days);
          end;

          //, TelNo
          iobj := SourceDB.FindObject (BondList);
          if iobj >= 0 then
               cat := TBond(BondList[iobj]).Category
          else
               cat := Others;

          case Cat of
           Relatives:
            begin
               inc (CatHistCalls[Relatives]);
               inc (CatHistTimes[Relatives], time);
               if time > CatMaxTimes[Relatives] then
                    CatMaxTimes[Relatives] := time;
            end;
           Friends:
            begin
               inc (CatHistCalls[Friends]);
               inc (CatHistTimes[Friends], time);
               if time > CatMaxTimes[Friends] then
                    CatMaxTimes[Friends] := time;
            end;
           Work:
            begin
               inc (CatHistCalls[Work]);
               inc (CatHistTimes[Work], time);
               if time > CatMaxTimes[Work] then
                    CatMaxTimes[Work] := time;
            end;
           else
            begin
               inc (CatHistCalls[Others]);
               inc (CatHistTimes[Others], time);
               if time > CatMaxTimes[Others] then
                    CatMaxTimes[Others] := time;
            end;
          end; //case
     end; // with

     daystotal := DaysBetween (
       TCall(SourceDB[0]).date,
       TCall(SourceDB[Pred (SourceDB.Count)]).date
     );
end;


procedure TCatStatistics.Show;
begin
     writeln;
     writeln (Format ('%d days of calls brutto of %d days total',
      [days, daystotal]));
     writeln (Format ('Average %1.1f calls per day',
      [SourceDB.Count/days]));

     writeln;
     writeln ('-- Calls quantity --');
     writeln (Format ('Relatives: %5d, %8.1f %%',
      [CatHistCalls[Relatives], CatHistCalls[Relatives]/SourceDB.Count*100.0]));
     writeln (Format ('Friends: %6d, %8.1f %%',
      [CatHistCalls[Friends], CatHistCalls[Friends]/SourceDB.Count*100.0]));
     writeln (Format ('Work: %9d, %8.1f %%',
      [CatHistCalls[Work], CatHistCalls[Work]/SourceDB.Count*100.0]));
     writeln (Format ('Others: %7d, %8.1f %%',
      [CatHistCalls[Others], CatHistCalls[Others]/SourceDB.Count*100.0]));
     writeln (Format ('  Total %7d',
      [SourceDB.Count]));

     CallsTotal :=
       CatHistTimes[Relatives] + CatHistTimes[Friends] +
       CatHistTimes[Work] + CatHistTimes[Others];

     writeln;
     writeln ('-- Total time of calls per category (in minutes) --');
     writeln (Format ('Relatives: %5.1f, %8.1f %%',
      [CatHistTimes[Relatives]/60.0, CatHistTimes[Relatives]/CallsTotal*100.0]));
     writeln (Format ('Friends: %6.1f, %8.1f %%',
      [CatHistTimes[Friends]/60.0, CatHistTimes[Friends]/CallsTotal*100.0]));
     writeln (Format ('Work: %9.1f, %8.1f %%',
      [CatHistTimes[Work]/60.0, CatHistTimes[Work]/CallsTotal*100.0]));
     writeln (Format ('Others: %7.1f, %8.1f %%',
      [CatHistTimes[Others]/60.0, CatHistTimes[Others]/CallsTotal*100.0]));
     writeln (Format ('  Total %7.1f',
      [CallsTotal/60.0]));

     writeln;
     writeln ('-- Average call duration per category (in minutes) --');
     writeln (Format ('Relatives: %5.1f',
      [CatHistTimes[Relatives]/(CatHistCalls[Relatives]*60.0)]));
     writeln (Format ('Friends: %6.1f',
      [CatHistTimes[Friends]/(CatHistCalls[Friends]*60.0)]));
     writeln (Format ('Work: %9.1f',
      [CatHistTimes[Work]/(CatHistCalls[Work]*60.0)]));
     writeln (Format ('Others: %7.1f',
      [CatHistTimes[Others]/(CatHistCalls[Others]*60.0)]));

     writeln;
     writeln ('-- Maximum call duration per category (in minutes) --');
     writeln (Format ('Relatives: %5.1f',
      [CatMaxTimes[Relatives]/60.0]));
     writeln (Format ('Friends: %6.1f',
      [CatMaxTimes[Friends]/60.0]));
     writeln (Format ('Work: %9.1f',
      [CatMaxTimes[Work]/60.0]));
     writeln (Format ('Others: %7.1f',
      [CatMaxTimes[Others]/60.0]));
end;


Destructor TCatStatistics.Destroy;
begin
     //FreeItems (BondList);
     BondList.Free;
end;


end.
