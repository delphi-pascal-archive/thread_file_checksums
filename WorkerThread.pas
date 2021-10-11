unit WorkerThread;
{$define use_FileStreams}
interface

uses classes, SysUtils, windows, CustomProgressBar, messages;

const
  RecSize = 2048;

type
  TWorkerThread = class(TThread)
  private
    FFile: TFileName;
    FMaxValue: Integer;
    FProgress: Integer;
    FCheckSum: String;
    FProgressBar: TCustomProgressBar;
    procedure DoPop;
    procedure DoAdd;
  protected
    procedure Execute; override;
    procedure CheckSum;
    procedure FileStreamCheckSum;
  public
    property Progress: Integer read FProgress write FProgress;
    property MaxValue: Integer read FMaxValue write FMaxValue;
    property ProcessFile: TFilename read FFile write FFile;
    property ProgressBar: TCustomProgressBar
      read FProgressBar write FProgressBar;
  end;

implementation

uses ProcessQueue, ThreadDemo;

{ TWorkerThread }

procedure TWorkerThread.CheckSum;
var
  i, bytesread: integer;
  f: File;
  buf: array[0..RecSize-1] of byte;
  sum: Longword; // 4 bytes
begin
{$I-}
  assignfile(f,FFile);
  FileMode := 0; {Set file access to read only }
  Reset(f,1{RecSize});
{$I+}
  if IOResult <> 0 then
  begin
    // some kind of error
    FCheckSum := 'Err '+ inttostr(IOResult);
    Synchronize(DoAdd);
    exit;
  end;

  FMaxValue := FileSize(f) div recsize;
  FProgress := 0;
  postmessage(MainForm.Handle, UM_SetMax, integer(pointer(FProgressBar)), FMaxValue);
  sum := 0;
  repeat
    BlockRead(f,buf,recsize,bytesread);
    for i := 0 to bytesread-1 do
      sum := sum + (buf[i] shl ((i mod 4)*8));
    inc(FProgress);
    if FProgress mod 5 = 0 then
      postmessage(MainForm.Handle, UM_Progress,
        integer(pointer(FProgressBar)), FProgress);
  until eof(f) or (bytesread = 0);
  FCheckSum := IntToHex(sum,8);
  Synchronize(DoAdd);
  Closefile(f);
end;

procedure TWorkerThread.DoAdd;
begin
  MainForm.Add(FFile, FCheckSum);
end;

procedure TWorkerThread.DoPop;
begin
  FFile := ProcessQueueForm.Pop;
end;

procedure TWorkerThread.Execute;
begin
  inherited;

  while not Terminated do
  begin
    Synchronize(DoPop);
    if FFile = '' then
      break;
    PostMessage(MainForm.Handle,UM_SETTEXT,
      integer(pointer(FProgressBar)),Integer(pchar(FFile)));

    {$ifdef use_FileStreams}
      FileStreamCheckSum;
    {$else}
      CheckSum;
    {$endif}

    if MainForm.ThreadCount > MainForm.MaxThreads then
      terminate;
  end;
end;

procedure TWorkerThread.FileStreamCheckSum;
var
  i, bytesread: integer;
  fs: TFileStream;
  buf: array[0..RecSize-1] of byte; // recsize = 2048
  sum: Longword; // 4 bytes
begin
  try
    fs := TFileStream.Create(FFile, fmShareDenyNone or fmOpenRead);

    FMaxValue := fs.Size;
    FProgress := 0;
    postmessage(MainForm.Handle, UM_SetMax, integer(pointer(FProgressBar)),
      FMaxValue div sizeof(buf));
    sum := 0;

    repeat
      BytesRead := fs.Read(buf, sizeof(buf));
      for i := 0 to bytesread-1 do
        sum := sum + (buf[i] shl ((i mod 4)*8));
      inc(FProgress);
      if (FProgress mod 5 = 0) or (FProgress < 5) then
        postmessage(MainForm.Handle, UM_Progress,
          integer(pointer(FProgressBar)), FProgress);
    until bytesread <> sizeof(buf);

    FCheckSum := IntToHex(sum,8);
    Synchronize(DoAdd);
    fs.Free;
  except
    FCheckSum := 'Error';
    Synchronize(DoAdd);
  end;
end;

end.
