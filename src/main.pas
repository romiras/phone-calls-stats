unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus;

type

  { TMainForm }

  TMainForm = class(TForm)
    btAdd: TButton;
    btRemove: TButton;
    btCreate: TButton;
    cobGoupSelector: TComboBox;
    lbGroup: TLabel;
    lbCallList: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    MainMenu: TMainMenu;
    mnAbout: TMenuItem;
    mnHelp: TMenuItem;
    mnSpace1: TMenuItem;
    mnExit: TMenuItem;
    mnFile: TMenuItem;
    mnFileImport: TMenuItem;
    OpenDialog: TOpenDialog;
    procedure btAddClick(Sender: TObject);
    procedure btRemoveClick(Sender: TObject);
    procedure btCreateClick(Sender: TObject);
    procedure cobGoupSelectorCloseUp(Sender: TObject);
    procedure mnAboutClick(Sender: TObject);
    procedure mnExitClick(Sender: TObject);
    procedure mnFileImportClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MainForm: TMainForm;

implementation
uses crwzrd, cstypes;

var
   Selection: integer; // cobGoupSelector.ItemIndex

{ TMainForm }

procedure TMainForm.mnAboutClick(Sender: TObject);
begin
  ShowMessage ('Some About-dialog need to place here');
end;

procedure TMainForm.mnExitClick(Sender: TObject);
begin
  close
end;

procedure TMainForm.mnFileImportClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    ListBox1.Items.LoadFromFile(OpenDialog.FileName);
  end;
end;

procedure TMainForm.btAddClick(Sender: TObject);
var
  i: integer;
begin
  for i := ListBox1.Count-1 downto 0 do
  begin
    if ListBox1.Selected[i] then
    begin
      ListBox2.Items.Add(ListBox1.Items.Strings[i]);
      TStringList(CPList.Items[Selection]).Add(ListBox1.Items.Strings[i]);
      ListBox1.Items.Delete(i);
    end;
  end;
end;

procedure TMainForm.btRemoveClick(Sender: TObject);
var
  i: integer;
begin
  for i := ListBox2.Count-1 downto 0 do
  begin
    if ListBox2.Selected[i] then
    begin
      ListBox1.Items.Add(ListBox2.Items.Strings[i]);
      ListBox2.Items.Delete(i);
      TStringList(CPList.Items[Selection]).Delete(i);
    end;
  end;
end;

procedure CP_Free;
var
  i: integer;
begin
  for i := 0 to nGroups-1 do
      TStringList(CPList.Items[i]).Free;
  CPList.Free;
end;

procedure TMainForm.btCreateClick(Sender: TObject);
begin
  if CrWizard.ShowModal = mrOk then
  begin
    ListBox2.Enabled:=True;
    btAdd.Enabled:=True;
    btRemove.Enabled:=True;
    inc (nGroups);
    cobGoupSelector.Items.AddStrings(CrWizard.lsGroups.Items);
    CPItems := TStringList.Create;
    CPList.Add(CPItems);
  end;
end;

procedure TMainForm.cobGoupSelectorCloseUp(Sender: TObject);
begin
  Selection := cobGoupSelector.ItemIndex;
  if Selection >= 0 then
     ListBox2.Items := TStringList(CPList.Items[Selection]);
end;

initialization
  {$I main.lrs}

  nGroups := 0;
  CPList := TList.Create;

finalization

  CP_Free;

end.

