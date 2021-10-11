unit ThreadDemo;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  StdCtrls, ImgList, ComCtrls, dialogs, contnrs, ExtCtrls;

const
  UM_PROGRESS = WM_USER + 1;
  UM_SETTEXT = WM_USER + 2;
  UM_SETMAX = WM_USER + 3;

type
  TMainForm = class(TForm)
    btnStart: TButton;
    Label1: TLabel;
    BtnStop: TButton;
    Edit1: TEdit;
    ScrollBox1: TScrollBox;
    Label2: TLabel;
    Edit2: TEdit;
    UpDown1: TUpDown;
    ListView1: TListView;
    Label3: TLabel;
    procedure btnStartClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure Edit2Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnStopClick(Sender: TObject);
  private
    FMaxThreads: Integer;
    FThreads: TObjectList;
    FInUpdate: Boolean;
    procedure HandleThreadTerminate(Sender: TObject);
    procedure HandleFileQueued(Sender: TObject);
    procedure ToggleButtons;
    function GetThreadCount: integer;
  protected
    procedure UMProgress(var Message: TMessage); message UM_PROGRESS;
    procedure UMSetText(var Message: TWMSetText); message UM_SETTEXT;
    procedure UMSetMax(var Message: TMessage); message UM_SETMAX;
  public
    procedure Add(Filename: TFileName; CheckSum: String);
    property MaxThreads: integer read FMaxThreads;
    property ThreadCount: integer read GetThreadCount;
  end;

var
  MainForm: TMainForm;

implementation

uses CustomProgressBar, RecursiveSearchThread, WorkerThread, Gauges,
  ProcessQueue;

{$R *.dfm}

procedure TMainForm.btnStartClick(Sender: TObject);
var
  t: TRecursiveSearchThread;
begin
  if not DirectoryExists(edit1.text) then
  begin
    ShowMessage(format('Directory %s does not exist.',[edit1.text]));
    exit;
  end;

  ListView1.clear;
  processqueueform.listbox1.clear;
  t := TRecursiveSearchThread.Create(true);
  with t do
  begin
    Priority := tpLower;
    StartDir := edit1.text;
    FreeOnTerminate := true;
    OnTerminate := HandleThreadTerminate;
    FThreads.add(t);
    resume;
  end;
  ToggleButtons;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FMaxThreads := 6;
  FThreads := TObjectList.create(false);
end;

procedure TMainForm.HandleThreadTerminate(Sender: TObject);
var
  i: integer;
begin
  if sender is TWorkerThread then
    TWorkerThread(Sender).ProgressBar.Free;

  for i := 0 to FThreads.count-1 do
    if sender = FThreads[i] then
    begin
      FThreads.Delete(i);
      break;
    end;

  ToggleButtons;
end;

procedure TMainForm.ToggleButtons;
begin
  btnStart.enabled := FThreads.Count = 0;
  btnStop.enabled := not btnStart.enabled;
  if btnStop.enabled and not FInUpdate then
  begin
    Listview1.items.beginupdate;
    FInUpdate := true;
  end
  else
  begin
    listview1.items.endupdate;
    FInUpdate := false;
  end;
end;

procedure TMainForm.Edit2Change(Sender: TObject);
begin
  FMaxThreads := StrToInt(edit2.text);
  HandleFileQueued(self);
end;

procedure TMainForm.HandleFileQueued(Sender: TObject);
var
  t: TWorkerThread;
  p: TCustomProgressBar;
begin
  if FThreads.count > FMaxThreads then
    TThread(FThreads[FThreads.count-1]).Terminate;

  if (FThreads.Count < FMaxThreads)
    and (ProcessQueueForm.Count > 0) then
  begin
    t := TWorkerThread.create(true);
    with t do
    begin
      Priority := tpLowest;
      FreeOnTerminate := true;
      OnTerminate := HandleThreadTerminate;
      p := TCustomProgressBar.Create(nil);
      p.Parent := ScrollBox1;
      ProgressBar := p;
      FThreads.add(t);
      Resume;
    end;
  end;
end;

procedure TMainForm.Add(Filename: TFileName; CheckSum: String);
var
  li: TListItem;
begin
  li := Listview1.items.Add;
  li.Caption := Filename;
  li.SubItems.Add(CheckSum);
end;

procedure TMainForm.FormDestroy(Sender: TObject);
var i : integer;
begin
  try
    for i := FThreads.count -1 downto 0 do
    begin
      with TWorkerThread(FThreads[i]) do
      begin
        Priority := tpLower;
        OnTerminate := nil;
        ProgressBar.free;
        Terminate;
        WaitFor;
      end;
      FThreads.Delete(i);
    end;
  finally
    FThreads.Free;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  ProcessQueueForm.OnFileQueued := HandleFileQueued;
end;

procedure TMainForm.BtnStopClick(Sender: TObject);
var
  i: integer;
begin
  for i := FThreads.count -1 downto 0 do
    TThread(FThreads[i]).Terminate;
end;

procedure TMainForm.UMProgress(var Message: TMessage);
var
  pb: TCustomProgressBar;
  i: integer;
begin
  pb := TCustomProgressBar(Pointer(message.WParam));
  for i := 0 to FThreads.count -1 do
    if FThreads[i] is TWorkerThread then
      if TWorkerThread(FThreads[i]).ProgressBar = pb then
        pb.progress := message.lparam;
end;

procedure TMainForm.UMSetText(var Message: TWMSetText);
var
  pb: TCustomProgressBar;
  i: integer;
begin
  pb := TCustomProgressBar(pointer(message.Unused));
  for i := 0 to FThreads.count -1 do
    if FThreads[i] is TWorkerThread then
      if TWorkerThread(FThreads[i]).ProgressBar = pb then
      begin
        pb.Text := string(Message.Text);
        pb.progress := 0;
      end;
end;

procedure TMainForm.UMSetMax(var Message: TMessage);
var
  pb: TCustomProgressBar;
  i: integer;
begin
  pb := TCustomProgressBar(Pointer(message.WParam));
  for i := 0 to FThreads.count -1 do
    if FThreads[i] is TWorkerThread then
      if TWorkerThread(FThreads[i]).ProgressBar = pb then
        pb.MaxValue := Message.LParam;
end;

function TMainForm.GetThreadCount: integer;
begin
  result := FThreads.Count;
end;

end.
