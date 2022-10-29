unit TlsStat;

interface

uses Classes, TlsTypes;

var
     BondList: TList;


     CatHistTimes,
     CatMaxTimes,
     CatHistCalls: TCatHist;
     CallsTo,
     MaxCallDuration,
     TotalCallsDurationTo: word;
     CallsTotal: Longint;
     days, daystotal: word;
     SomeTel: Cardinal;


procedure InitTelStatistics (_Tel: Cardinal);
procedure InitCatStatistics (Fn: string);

procedure GetTelStatistics (List: TCallList);
procedure GetCatStatistics (List: TCallList);

procedure ShowTelStatistics (List: TCallList);
procedure ShowCatStatistics (List: TCallList);

procedure EndCatStatistics;

implementation
uses SysUtils, DateUtils, TlsFunc, tlscatrd;

var
     dDate: TDateTime;

procedure InitTelStatistics (_Tel: Cardinal);
begin
     days := 0;
     dDate := 0.0;

     SomeTel := _Tel;
     CallsTo := 0;
     MaxCallDuration := 0;
     TotalCallsDurationTo := 0;
end;

procedure InitCatStatistics (Fn: string);
begin
     days := 0;
     dDate := 0.0;

     BondList := ReadBonds (Fn);
     BondList.Pack;
     BondList.Sort (@CompareByTel);
     //ShowBondList (BondList);

     FillChar (CatHistCalls, SizeOf(CatMaxTimes), 0);
     FillChar (CatHistTimes, SizeOf(CatMaxTimes), 0);
     FillChar (CatMaxTimes,  SizeOf(CatMaxTimes), 0);
end;

procedure GetTelStatistics (List: TCallList);
var
     k: integer;
begin
     for k := 0 to Pred (List.Count) do
     with TCall(List[k]) do
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
       TCall(List[0]).date,
       TCall(List[Pred (List.Count)]).date
     );
end;

procedure GetCatStatistics (List: TCallList);
var
     k, iobj: integer;
     cat: TCategory;
begin
     for k := 0 to Pred (List.Count) do
     with TCall(List[k]) do
     begin
          if date <> dDate then
          begin
               dDate := date;
               inc(days);
          end;

          //, TelNo
          iobj := List.FindObject (BondList);
          if iobj >= 0 then
               cat := TBond(BondList[iobj]).Category
          else
               cat := Others;

          case Cat of
           Alliance:
            begin
               inc (CatHistCalls[Alliance]);
               inc (CatHistTimes[Alliance], time);
               if time > CatMaxTimes[Alliance] then
                    CatMaxTimes[Alliance] := time;
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
       TCall(List[0]).date,
       TCall(List[Pred (List.Count)]).date
     );
end;

procedure ShowTelStatistics (List: TCallList);
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
      [TotalCallsDurationTo/(List.Count*60.0)]));
     writeln (Format ('Maximum call duration: %5.1f',
      [MaxCallDuration/60.0]));
end;

procedure ShowCatStatistics (List: TCallList);
begin
     writeln;
     writeln (Format ('%d days of calls brutto of %d days total',
      [days, daystotal]));
     writeln (Format ('Average %1.1f calls per day',
      [List.Count/days]));

     writeln;
     writeln ('-- Calls quantity --');
     writeln (Format ('Alliance: %5d, %8.1f %%',
      [CatHistCalls[Alliance], CatHistCalls[Alliance]/List.Count*100.0]));
     writeln (Format ('Friends: %6d, %8.1f %%',
      [CatHistCalls[Friends], CatHistCalls[Friends]/List.Count*100.0]));
     writeln (Format ('Work: %9d, %8.1f %%',
      [CatHistCalls[Work], CatHistCalls[Work]/List.Count*100.0]));
     writeln (Format ('Others: %7d, %8.1f %%',
      [CatHistCalls[Others], CatHistCalls[Others]/List.Count*100.0]));
     writeln (Format ('  Total %7d',
      [List.Count]));

     CallsTotal :=
       CatHistTimes[Alliance] + CatHistTimes[Friends] +
       CatHistTimes[Work] + CatHistTimes[Others];

     writeln;
     writeln ('-- Total time of calls per category (in minutes) --');
     writeln (Format ('Alliance: %5.1f, %8.1f %%',
      [CatHistTimes[Alliance]/60.0, CatHistTimes[Alliance]/CallsTotal*100.0]));
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
     writeln (Format ('Alliance: %5.1f',
      [CatHistTimes[Alliance]/(CatHistCalls[Alliance]*60.0)]));
     writeln (Format ('Friends: %6.1f',
      [CatHistTimes[Friends]/(CatHistCalls[Friends]*60.0)]));
     writeln (Format ('Work: %9.1f',
      [CatHistTimes[Work]/(CatHistCalls[Work]*60.0)]));
     writeln (Format ('Others: %7.1f',
      [CatHistTimes[Others]/(CatHistCalls[Others]*60.0)]));

     writeln;
     writeln ('-- Maximum call duration per category (in minutes) --');
     writeln (Format ('Alliance: %5.1f',
      [CatMaxTimes[Alliance]/60.0]));
     writeln (Format ('Friends: %6.1f',
      [CatMaxTimes[Friends]/60.0]));
     writeln (Format ('Work: %9.1f',
      [CatMaxTimes[Work]/60.0]));
     writeln (Format ('Others: %7.1f',
      [CatMaxTimes[Others]/60.0]));
end;

procedure EndCatStatistics;
begin
     //FreeItems (BondList);
     BondList.Free;
end;

end.
