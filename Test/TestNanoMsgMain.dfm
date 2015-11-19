object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'NanoMSG - Delphi Wrapper Test - '#169'2015 - PrY -'
  ClientHeight = 231
  ClientWidth = 390
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnPair: TButton
    Left = 8
    Top = 8
    Width = 75
    Height = 25
    Caption = 'Pair'
    TabOrder = 0
    OnClick = btnPairClick
  end
  object btnBus: TButton
    Left = 8
    Top = 39
    Width = 75
    Height = 25
    Caption = 'Bus'
    TabOrder = 1
    OnClick = btnBusClick
  end
  object btnBlock: TButton
    Left = 251
    Top = 70
    Width = 86
    Height = 25
    Caption = 'Block'
    TabOrder = 17
    OnClick = btnBlockClick
  end
  object btnAsyncShutdown: TButton
    Left = 251
    Top = 8
    Width = 86
    Height = 25
    Caption = 'AsyncShutdown'
    TabOrder = 15
    OnClick = btnAsyncShutdownClick
  end
  object btnDevice: TButton
    Left = 8
    Top = 194
    Width = 75
    Height = 25
    Caption = 'Device'
    TabOrder = 6
    OnClick = btnDeviceClick
  end
  object btnDomain: TButton
    Left = 251
    Top = 39
    Width = 86
    Height = 25
    Caption = 'Domain'
    TabOrder = 16
    OnClick = btnDomainClick
  end
  object btnEMFILE: TButton
    Left = 170
    Top = 8
    Width = 75
    Height = 25
    Caption = 'EMFILE'
    TabOrder = 11
    OnClick = btnEMFILEClick
  end
  object btnInProc: TButton
    Left = 89
    Top = 8
    Width = 75
    Height = 25
    Caption = 'InProc'
    TabOrder = 7
    OnClick = btnInProcClick
  end
  object btnCMSG: TButton
    Left = 170
    Top = 39
    Width = 75
    Height = 25
    Caption = 'CMSG'
    TabOrder = 12
    OnClick = btnCMSGClick
  end
  object btnIOVEC: TButton
    Left = 170
    Top = 70
    Width = 75
    Height = 25
    Caption = 'IOVEC'
    TabOrder = 13
    OnClick = btnIOVECClick
  end
  object btnIPC: TButton
    Left = 89
    Top = 39
    Width = 75
    Height = 25
    Caption = 'IPC'
    TabOrder = 8
    OnClick = btnIPCClick
  end
  object btnPipeline: TButton
    Left = 8
    Top = 101
    Width = 75
    Height = 25
    Caption = 'Pipeline'
    TabOrder = 3
    OnClick = btnPipelineClick
  end
  object btnSurvey: TButton
    Left = 8
    Top = 70
    Width = 75
    Height = 25
    Caption = 'Survey'
    TabOrder = 2
    OnClick = btnSurveyClick
  end
  object btnPubSub: TButton
    Left = 8
    Top = 132
    Width = 75
    Height = 25
    Caption = 'PubSub'
    TabOrder = 4
    OnClick = btnPubSubClick
  end
  object btnReqRep: TButton
    Left = 8
    Top = 163
    Width = 75
    Height = 25
    Caption = 'ReqRep'
    TabOrder = 5
    OnClick = btnReqRepClick
  end
  object btnShutdown: TButton
    Left = 251
    Top = 101
    Width = 86
    Height = 25
    Caption = 'Shutdown'
    TabOrder = 18
    OnClick = btnShutdownClick
  end
  object btnSymbol: TButton
    Left = 170
    Top = 101
    Width = 75
    Height = 25
    Caption = 'Symbol'
    TabOrder = 14
    OnClick = btnSymbolClick
  end
  object btnTerm: TButton
    Left = 251
    Top = 132
    Width = 86
    Height = 25
    Caption = 'Term'
    TabOrder = 19
    OnClick = btnTermClick
  end
  object btnTCP: TButton
    Left = 89
    Top = 70
    Width = 75
    Height = 25
    Caption = 'TCP'
    TabOrder = 9
    OnClick = btnTCPClick
  end
  object btnWS: TButton
    Left = 89
    Top = 101
    Width = 75
    Height = 25
    Caption = 'WebSocket'
    TabOrder = 10
    OnClick = btnWSClick
  end
  object btnZeroCopy: TButton
    Left = 170
    Top = 132
    Width = 75
    Height = 25
    Caption = 'ZeroCopy'
    TabOrder = 20
    OnClick = btnZeroCopyClick
  end
end
