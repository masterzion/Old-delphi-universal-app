object Form1: TForm1
  Left = 311
  Top = 187
  Width = 870
  Height = 640
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 242
    Width = 862
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object Memo1: TMemo
    Left = 0
    Top = 41
    Width = 862
    Height = 201
    Align = alTop
    TabOrder = 0
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 862
    Height = 41
    Align = alTop
    TabOrder = 1
    object Label1: TLabel
      Left = 424
      Top = 16
      Width = 29
      Height = 13
      Caption = 'Serial:'
    end
    object Button1: TButton
      Left = 184
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Codificar'
      TabOrder = 0
      OnClick = Button1Click
    end
    object Button2: TButton
      Tag = 1
      Left = 288
      Top = 8
      Width = 75
      Height = 25
      Caption = 'DesCodificar'
      TabOrder = 1
      OnClick = Button1Click
    end
    object Edit1: TEdit
      Left = 464
      Top = 8
      Width = 121
      Height = 21
      TabOrder = 2
    end
  end
  object Memo2: TMemo
    Left = 0
    Top = 245
    Width = 862
    Height = 361
    Align = alClient
    TabOrder = 2
  end
  object DCP_rc4: TDCP_rc4
    Id = 19
    Algorithm = 'RC4'
    MaxKeySize = 2048
    Left = 432
    Top = 72
  end
end
