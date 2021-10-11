unit RecursiveSearchThread;

interface

uses
  Classes, ComCtrls, sysutils;

type
  TRecursiveSearchThread = class(TThread)
  private
    FStartDir: string;
    FFile: TFileName;
    procedure ProcessDirectory(dir: string);
    procedure FileFound;
  protected
    procedure Execute; override;
  public
    property StartDir: string read FStartDir write FStartDir;
  end;

implementation

uses ProcessQueue;

{ TRecursiveSearchThread }

procedure TRecursiveSearchThread.Execute;
begin
  inherited;
  ProcessDirectory(IncludeTrailingPathDelimiter(StartDir));
end;

procedure TRecursiveSearchThread.FileFound;
begin
  ProcessQueueForm.Queue(FFile);
end;

procedure TRecursiveSearchThread.ProcessDirectory(dir: string);
var
  sr: TSearchRec;
begin
  if not Terminated then
  begin
    if FindFirst(dir + '*.*',faReadOnly + faArchive + faDirectory , sr) = 0 then
    begin
      repeat
        if (sr.Attr and faDirectory) = faDirectory then
        begin
          if (sr.name <> '.') and (sr.name <> '..') then
            ProcessDirectory(IncludeTrailingPathDelimiter(dir + sr.Name));
        end
        else
        begin
          FFile := dir + sr.name;
          Synchronize(FileFound);
        end;
      until (FindNext(sr) <> 0) or terminated;
      FindClose(sr);
    end;
  end;
end;

end.
