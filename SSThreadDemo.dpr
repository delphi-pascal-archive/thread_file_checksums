program SSThreadDemo;

uses
  Forms,
  ThreadDemo in 'ThreadDemo.pas' {MainForm},
  ProcessQueue in 'ProcessQueue.pas' {ProcessQueueForm},
  CustomProgressBar in 'CustomProgressBar.pas',
  RecursiveSearchThread in 'RecursiveSearchThread.pas',
  WorkerThread in 'WorkerThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(TProcessQueueForm, ProcessQueueForm);
  Application.Run;
end.
