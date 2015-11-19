unit NanoMsg.Errors;

interface

uses
 SysUtils, NanoMsg;

type
  ENanoMsgError = class(Exception)
  public
    constructor Create(const Msg: string);
  end;

implementation

{ ENanoMsgError }

constructor ENanoMsgError.Create(const Msg: string);
begin
  inherited Create(Msg + sLineBreak + string(nn_strerror(nn_errno)));
end;

end.
