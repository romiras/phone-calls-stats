unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls, Menus, ComCtrls;

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
    StatusBar: TStatusBar;
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
uses crwzrd, cstypes, tlstypes, tlsconv;

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
Var
  Fin: TCallList;
  Call: TCall;
  fn, stmp: string;
  k, res: integer;
begin
  Fin := TCallList.Create;
  if OpenDialog.Execute then
  begin
     fn := OpenDialog.FileName;
     Try
          StatusBar.SimpleText := 'Importing into database';
          //ListBox1.BeginUpdateBounds;
          res := ReadCallList (fn, Fin);
          if res <> No_Errors then
          begin
               case res of
                Err_Unknown:
                  stmp := 'Unknown';
                Err_Not_Supported:
                  stmp := 'File type is not supported.';
                Err_Alloc:
                  stmp := 'Memory allocation failed.';
                Err_ListOp:
                  stmp := 'List operation.';
               end;
               ShowMessage ('An error occured while reading file: '+stmp);
               exit;
          end;
          
          //ShowMessage(IntToStr(CallList.Count));
          for k := 0 to Fin.Count-1 do
          begin
               //ShowMessage(inttostr(k));
               Call := TCall (Fin[k]);
               if Assigned (Call) then
               begin
                    {with Call do
                      ShowMessage(Format('%s %d %d', [DateToStr(Date), TelNo, Time]));}
                    ShowMessage('Before Find');
                    res := Fin.FindObject (Call);
                    ShowMessage(Format('CallList.Count: %d, Res: %d, Tel: %d',
                     [CallList.Count, res, Call.TelNo]));
                    if res < 0 then
                    begin
                         CallList.Add (Call);
                         ListBox1.Items.Add(TelStr(Call.TelNo));
                    end;
               end;
          end;
          CallList.Pack;
          //ListBox1.EndUpdateBounds;
          StatusBar.SimpleText := 'Importing done';
     Finally
          Fin.Free;
     end;
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
  CallList := TCallList.Create;

finalization

  CP_Free;
  //FreeItems (CallList);
  CallList.Free;

end.

