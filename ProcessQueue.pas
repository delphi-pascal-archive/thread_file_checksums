unit ProcessQueue;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TProcessQueueForm = class(TForm)
    ListBox1: TListBox;
    procedure FormShow(Sender: TObject);
    procedure FormResize(Sender: TObject);
  private
    FOnFileQueued: TNotifyEvent;
    procedure DoUpdate;
    procedure SetOnFileQueued(const Value: TNotifyEvent);

  public
    procedure Queue(FileName: TFileName);
    function Pop: TFileName;
    function Count: Integer;
    property OnFileQueued: TNotifyEvent read FOnFileQueued write SetOnFileQueued;
  end;

var
  ProcessQueueForm: TProcessQueueForm;

implementation

{$R *.dfm}

{ TProcessQueueForm }

function TProcessQueueForm.Count: Integer;
begin
  result := listbox1.items.count;
end;

function TProcessQueueForm.Pop: TFileName;
begin
  if ListBox1.Items.count > 0 then
  begin
    result := listbox1.items[0];
    listbox1.Items.Delete(0);
    DoUpdate;
  end
  else
    result := '';
end;

procedure TProcessQueueForm.Queue(FileName: TFileName);
begin
  listbox1.Items.Add(FileName);
  DoUpdate;
  if assigned(FOnFileQueued) then
    FOnFileQueued(self);
end;

procedure TProcessQueueForm.DoUpdate;
begin
//  ProcessQueueForm.Visible := listbox1.items.count <> 0;
end;

procedure TProcessQueueForm.SetOnFileQueued(const Value: TNotifyEvent);
begin
  FOnFileQueued := Value;
end;

procedure TProcessQueueForm.FormShow(Sender: TObject);
begin
  listbox1.Refresh;
end;

procedure TProcessQueueForm.FormResize(Sender: TObject);
begin
  listbox1.Align := alClient;
end;

end.
