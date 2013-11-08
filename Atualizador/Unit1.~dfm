object Form1: TForm1
  Left = 362
  Top = 209
  Width = 316
  Height = 129
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Button1: TButton
    Left = 192
    Top = 32
    Width = 75
    Height = 25
    Caption = 'Atualizar'
    TabOrder = 0
    OnClick = Button1Click
  end
  object Edit1: TEdit
    Left = 24
    Top = 32
    Width = 153
    Height = 21
    TabOrder = 1
  end
  object ProgressBar1: TProgressBar
    Left = 24
    Top = 64
    Width = 150
    Height = 17
    TabOrder = 2
  end
  object DCP_rc4: TDCP_rc4
    Id = 19
    Algorithm = 'RC4'
    MaxKeySize = 2048
    Left = 64
    Top = 16
  end
  object SQLConnection1: TSQLConnection
    ConnectionName = 'cadastro'
    DriverName = 'MySQL'
    GetDriverFunc = 'getSQLDriverMYSQL'
    LibraryName = 'dbexpmysql.dll'
    LoginPrompt = False
    Params.Strings = (
      'DriverName=MySQL'
      'HostName=127.0.0.1'
      'Database=cadastro'
      'User_Name=root'
      'Password=root'
      'BlobSize=-1'
      'ErrorResourceFile='
      'LocaleCode=0000')
    TableScope = [tsTable]
    VendorLib = 'libmysql.dll'
    Left = 24
    Top = 16
  end
  object SQLDataSet: TSQLDataSet
    MaxBlobSize = -1
    Params = <>
    SQLConnection = SQLConnection1
    Left = 24
    Top = 48
  end
end
