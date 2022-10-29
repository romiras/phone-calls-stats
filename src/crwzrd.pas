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

{ TCrWizard }

procedure TCrWizard.bbNewClick(Sender: TObject);
var
  grpName: string;
begin
  grpName := InputBox('Group name:', 'Type group name here:', 'new group');
  ShowMessage ('"'+grpName+'"');
  if grpName <> '' then
     lsGroups.Items.Add(grpName);
end;

initialization
  {$I crwzrd.lrs}

end.

