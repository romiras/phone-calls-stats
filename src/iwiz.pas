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
    Label4: TLabel;
    Label42: TLabel;
    lbStatus1: TLabel;
    lbImported: TLabel;
    lboGroups: TListBox;
    lbStatus2: TLabel;
    lbStep1: TLabel;
    lbStep2: TLabel;
    lbStep3: TLabel;
    lbStep4: TLabel;
    lbWelcome: TLabel;
    lboImported: TListBox;
    lboCPall: TListBox;
    lboCPgroup: TListBox;
    lboPhones: TListBox;
    Memo1: TMemo;
    OpenDialog: TOpenDialog;
    pcWizard: TPageControl;
    rgType: TRadioGroup;
    tsSelect: TTabSheet;
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
    procedure rgTypeClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  WizardForm: TWizardForm;

implementation

uses TlsTypes, TlsStat;

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
           if lboGroups.Count = 0 then
           begin
              ShowMessage ('At least one group need to be created for classification!');
              Result := False;
           end;
         end;
{      3: begin
           if  then
           begin
              ShowMessage ('');
              Result := False;
           end;
         end;
}
      4: begin
           if lboPhones.ItemIndex < 0 then
           begin
              ShowMessage ('Select a phone number you want to get statistics about.');
              Result := False;
           end;
         end;
      else
        Result := True;
     end;
end;

procedure TWizardForm.rgTypeClick(Sender: TObject);
var
  TelNumber: string;
begin
  case rgType.ItemIndex of
   0: // By Groups
    begin
    end;
   1: // By Phone
    begin
         TelNumber := lboPhones.Items.Strings[lboPhones.ItemIndex];
         InitTelStatistics (TelNumber);
    end;
  end;
end;

procedure TWizardForm.bbNextClick(Sender: TObject);
begin
     with pcWizard do
     begin
          if ActivePageIndex = PageCount - 1 then
          begin
               { Save settings and exit from Wizard }
               { ... }
               close;
          end;

          if CheckStep (ActivePageIndex) then
             ActivePageIndex := ActivePageIndex + 1
          else
             Exit;

          if ActivePageIndex = PageCount -1 then
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
     lbStatus1.Caption := Format ('Importing done. Total %d phone numbers.' ,[lboImported.Items.Count]);
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
    lbStatus2.Caption := Format ('%d groups.' ,[lboGroups.Count]);
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
  begin
    lboCPgroup.Items := TStringList(CPList.Items[Selection]);
    bbAdd.Enabled := True;
    bbRemove.Enabled := True;
  end;
end;

initialization
  {$I iwiz.lrs}

  Selection := -1;

end.

