unit crwzrd;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Buttons;

type

  { TCrWizard }

  TCrWizard = class(TForm)
    bbOk: TBitBtn;
    bbCancel: TBitBtn;
    bbNew: TBitBtn;
    lsGroups: TListBox;
    sText: TStaticText;
    procedure bbNewClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  CrWizard: TCrWizard;

implementation

uses cstypes;

{ TCrWizard }

procedure TCrWizard.bbNewClick(Sender: TObject);
var
  grpName: string;
begin
  grpName := InputBox('Group name:', 'Type group name here:', 'new group');
  if grpName <> '' then
  begin
    lsGroups.Items.Add(grpName);
    CPItems := TStringList.Create;
    CPList.Add(CPItems);
//    inc (nGroups);
  end;
end;

initialization
  {$I crwzrd.lrs}

end.

