object MainForm: TMainForm
  Left = 224
  Top = 124
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Thread File Checksums'
  ClientHeight = 609
  ClientWidth = 890
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object Label1: TLabel
    Left = 480
    Top = 64
    Width = 58
    Height = 16
    Caption = 'Progress:'
  end
  object Label2: TLabel
    Left = 728
    Top = 40
    Width = 82
    Height = 16
    Caption = 'Max Threads:'
  end
  object Label3: TLabel
    Left = 8
    Top = 8
    Width = 105
    Height = 16
    Caption = 'Starting Directory:'
  end
  object Edit1: TEdit
    Left = 8
    Top = 32
    Width = 465
    Height = 24
    TabOrder = 2
    Text = 'c:\program files\borland\delphi7\bin'
  end
  object btnStart: TButton
    Left = 480
    Top = 32
    Width = 97
    Height = 25
    Caption = 'Start'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object BtnStop: TButton
    Left = 584
    Top = 32
    Width = 97
    Height = 25
    Caption = 'Stop'
    TabOrder = 1
    OnClick = BtnStopClick
  end
  object ScrollBox1: TScrollBox
    Left = 480
    Top = 88
    Width = 401
    Height = 513
    VertScrollBar.Smooth = True
    TabOrder = 3
  end
  object Edit2: TEdit
    Left = 819
    Top = 32
    Width = 38
    Height = 24
    ReadOnly = True
    TabOrder = 4
    Text = '10'
    OnChange = Edit2Change
  end
  object UpDown1: TUpDown
    Left = 857
    Top = 32
    Width = 19
    Height = 24
    Associate = Edit2
    Min = 2
    Max = 20
    Position = 10
    TabOrder = 5
  end
  object ListView1: TListView
    Left = 8
    Top = 64
    Width = 466
    Height = 537
    Columns = <
      item
        AutoSize = True
        Caption = 'File'
      end
      item
        Caption = 'Checksum'
        Width = 100
      end>
    TabOrder = 6
    ViewStyle = vsReport
  end
end
