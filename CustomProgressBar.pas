unit CustomProgressBar;

interface

uses
  Classes, Graphics, Controls, Gauges;

type
  TCustomProgressBar = class(TGauge)
  private
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Text;
  end;

implementation

{ TCustomProgressBar }

constructor TCustomProgressBar.Create(AOwner: TComponent);
begin
  inherited;
  height := 16;
  forecolor := clBlue;
  Text := '';
  align := alTop;
  showtext := false;
end;

procedure TCustomProgressBar.Paint;
begin
  inherited;
  with canvas do
  begin
    Brush.Style := bsClear;
    pen.color := clBlack;
    TextOut((Width div 2) - (TextWidth(text) div 2),1,text);
  end;
end;

end.
