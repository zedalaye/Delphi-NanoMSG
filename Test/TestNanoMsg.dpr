program TestNanoMsg;

uses
  madExcept,
  Vcl.Forms,
  TestNanoMsgMain in 'TestNanoMsgMain.pas' {Form1},
  NanoMsg in '..\NanoMsg.pas',
  NanoMsg.Errors in '..\NanoMsg.Errors.pas',
  NanoMsg.TestHelpers in 'NanoMsg.TestHelpers.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
