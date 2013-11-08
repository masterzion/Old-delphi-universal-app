object FLlistats: TFLlistats
  Left = 244
  Top = 209
  Width = 407
  Height = 173
  Caption = 'Listados'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object ELlistats: TListBox
    Left = 8
    Top = 4
    Width = 380
    Height = 97
    Anchors = [akLeft, akTop, akRight, akBottom]
    ItemHeight = 13
    Items.Strings = (
      'Resumen de trazabilidad'
      'Detalle de entradas'
      'Número de guia incorrecto')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 8
    Top = 112
    Width = 153
    Height = 25
    Caption = 'Ejecutar'
    TabOrder = 1
    OnClick = Button1Click
  end
  object RpAlias1: TRpAlias
    List = <>
    Connections = <
      item
        Alias = 'TRACABILITAT'
        LoadParams = True
        LoadDriverParams = True
        LoginPrompt = False
        Driver = rpdatabde
        ReportTable = 'REPMAN_REPORTS'
        ReportSearchField = 'REPORT_NAME'
        ReportField = 'REPORT'
        ReportGroupsTable = 'REPMAN_GROUPS'
        ADOConnectionString = ''
      end>
    Left = 56
    Top = 60
  end
  object llistat: TVCLReport
    ConnectionName = 'TRACABILITAT'
    ReportName = 'Errores'
    Title = 'Listado'
    AliasList = RpAlias1
    Left = 60
    Top = 100
  end
end
