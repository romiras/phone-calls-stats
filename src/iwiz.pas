unit iwiz;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ComCtrls, ExtCtrls;

type

  { TWizardForm }

  TWizardForm = class(TForm)
    bbCancel: TBitBtn;
    bbPrev: TBitBtn;
    bbNext: TBitBtn;
    bbBrowse: TBitBtn;
    bbAdd: TBitBtn;
    bbRemove: TBitBtn;
    bbNew: TBitBtn;
    Bevel1: TBevel;
    Bevel2: TBevel;
    cobGoupSelector: TComboBox;
    edPath: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    lbStatus: TLabel;
    lbImported: TLabel;
    lboGroups: TListBox;
    lbStep1: TLabel;
    lbStep2: TLabel;
    lbStep3: TLabel;
    lbWelcome: TLabel;
    lboImported: TListBox;
    lboCPall: TListBox;
    lboCPgroup: TListBox;
    Memo1: TMemo;
    OpenDialog: TOpenDialog;
    pcWizard: TPageControl;
    tsCreateGrp: TTabSheet;
    tsClassify: TTabSheet;
    tsImport: TTabSheet;
    tsWelcome: TTabSheet;
    procedure bbAddClick(Sender: TObject);
    procedure bbBrowseClick(Sender: TObject);
    procedure bbNewClick(Sender: TObject);
    procedure bbNextClick(Sender: TObject);
    procedure bbPrevClick(Sender: TObject);
    procedure bbRemoveClick(Sender: TObject);
    procedure cobGoupSelectorCloseUp(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    function CheckStep (Step: integer): boolean;
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  WizardForm: TWizardForm;

implementation

uses TlsTypes;

var
   Selection: integer; // cobGoupSelector.ItemIndex

{ TWizardForm }

procedure TWizardForm.FormCreate(Sender: TObject);
var pg: integer;
begin
     with pcWizard do
     begin
          for pg := 0 to Pred (PageCount) do
          begin
              Pages[pg].TabVisible := false;
              Pages[pg].Visible := true;
          end;
          ActivePageIndex := 0;
     end;
end;

function TWizardForm.CheckStep (Step: integer): boolean;
begin
     case Step of
      1: begin
           if CPImported.Count = 0 then
           begin
              ShowMessage ('You need to import data first!');
              Result := False;
           end
           else
              lboCPall.Items.Assign(CPImported);
         end;
      2: begin
           cobGoupSelector.Items.AddStrings(lboGroups.Items);
           if
         end;
      else
        Result := True;
     end;
end;

procedure TWizardForm.bbNextClick(Sender: TObject);
begin
     with pcWizard do
     begin
          if ActivePageIndex = Pred (PageCount) then
          begin
               { Save settings and exit from Wizard }
               { ... }
               close;
          end;

          if CheckStep (ActivePageIndex) then
             ActivePageIndex := ActivePageIndex + 1
          else
             Exit;

          if ActivePageIndex = Pred (PageCount) then
          begin
               bbNext.Caption := 'Finish';
               //bbCancel.Enabled := false;
          end
          else
          begin
               bbCancel.Enabled := true;
               bbPrev.Enabled := true;
          end;
     end;
end;

procedure TWizardForm.bbBrowseClick(Sender: TObject);
Var
  fn, msg: string;
  res: integer;
begin
  if OpenDialog.Execute then
  begin
     fn := OpenDialog.FileName;
     edPath.Text := fn;
     //StatusBar.SimpleText := 'Importing into database';
     res := No_Errors;
     ImportDB (fn, CPImported, res);
     if res <> No_Errors then
     begin
          case res of
           Err_Unknown:
             msg := 'Unknown';
           Err_Not_Supported:
             msg := 'File type is not supported.';
           Err_Alloc:
             msg := 'Memory allocation failed.';
           Err_ListOp:
             msg := 'List operation.';
          end;
          ShowMessage ('An error occured while reading file: ' + msg);
          exit;
     end;
     //lboImported.BeginUpdateBounds;
     lboImported.Items.Assign(CPImported);
     //lboImported.EndUpdateBounds;
     //StatusBar.SimpleText := Format ('Importing done. Total %d phone numbers.' ,[lboImported.Items.Count]);
     lbStatus.Caption := Format ('Importing done. Total %d phone numbers.' ,[lboImported.Items.Count]);
  end;
end;

procedure TWizardForm.bbNewClick(Sender: TObject);
var
  grpName: string;
begin
  grpName := InputBox('Setting group name:', 'Type group name here:', 'new group');
  if grpName <> '' then
  begin
    lboGroups.Items.Add(grpName);
    CPItems := TStringList.Create;
    CPList.Add(CPItems);
  end;
end;

procedure TWizardForm.bbPrevClick(Sender: TObject);
begin
     with pcWizard do
     begin
          ActivePageIndex := ActivePageIndex - 1;
          if ActivePageIndex > 0 then
          begin
               bbPrev.Enabled := true;
               bbNext.Caption := 'Next >';
               bbCancel.Enabled := true;
          end
          else
               bbPrev.Enabled := false;
     end;
end;

procedure TWizardForm.bbAddClick(Sender: TObject);
var
  i: integer;
begin
  for i := lboCPall.Count-1 downto 0 do
  begin
    if lboCPall.Selected[i] then
    begin
      lboCPgroup.Items.Add(lboCPall.Items.Strings[i]);
      TStringList(CPList.Items[Selection]).Add(lboCPall.Items.Strings[i]);
      lboCPall.Items.Delete(i);
    end;
  end;
end;

procedure TWizardForm.bbRemoveClick(Sender: TObject);
var
  i: integer;
begin
  for i := lboCPgroup.Count-1 downto 0 do
  begin
    if lboCPgroup.Selected[i] then
    begin
      lboCPall.Items.Add(lboCPgroup.Items.Strings[i]);
      lboCPgroup.Items.Delete(i);
      TStringList(CPList.Items[Selection]).Delete(i);
    end;
  end;
end;

procedure TWizardForm.cobGoupSelectorCloseUp(Sender: TObject);
begin
  Selection := cobGoupSelector.ItemIndex;
  if Selection >= 0 then
    lboCPgroup.Items := TStringList(CPList.Items[Selection]);
end;

initialization
  {$I iwiz.lrs}

  Selection := -1;

end.

