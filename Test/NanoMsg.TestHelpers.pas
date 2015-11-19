unit NanoMsg.TestHelpers;

interface

uses
  Windows, SysUtils;

function test_socket(family, protocol: NativeInt): NativeInt;
function test_connect(sock: NativeInt; address: PAnsiChar): NativeInt;
function test_bind(sock: NativeInt; address: PAnsiChar): NativeInt;
function test_close(sock: NativeInt): NativeInt;
procedure test_send(s: NativeInt; const Data: PAnsiChar);
procedure test_recv(s: NativeInt; const Expected: AnsiString);
function test_setsockopt(sock, level, option: NativeInt; const optval: Pointer; optlen: size_t): NativeInt;
procedure test_drop(sock, err: NativeInt);

implementation

uses
  NanoMsg, NanoMsg.Errors;

function test_socket(family, protocol: NativeInt): NativeInt;
begin
  Result := nn_socket(family, protocol);
  if (Result = -1) then
    raise ENanoMsgError.Create('nn_socket failed');
end;

function test_connect(sock: NativeInt; address: PAnsiChar): NativeInt;
begin
  Result := nn_connect(sock, address);
  if (Result < 0) then
    raise ENanoMsgError.Create('nn_connect failed');
end;

function test_bind(sock: NativeInt; address: PAnsiChar): NativeInt;
begin
  Result := nn_bind(sock, address);
  if (Result < 0) then
    raise ENanoMsgError.Create('nn_bind failed');
end;

function test_close(sock: NativeInt): NativeInt;
begin
  Result := nn_close (sock);
  if ((Result <> 0) and (nn_errno <> EBADF) and (nn_errno <> ETERM)) then
    raise ENanoMsgError.Create('nn_close failed');
end;

function test_setsockopt(sock, level, option: NativeInt; const optval: Pointer; optlen: size_t): NativeInt;
begin
  Result := nn_setsockopt (sock, level, option, optval, optlen);
  if Result < 0 then
    raise ENanoMsgError.Create('nn_setsockopt failed');
end;

procedure test_send(s: NativeInt; const Data: PAnsiChar);
var
  rc: NativeInt;
begin
  rc := nn_send(s, Data, Length(Data), 0);
  if rc < 0 then
    raise ENanoMsgError.Create('nn_send failed')
  else if rc <> Length(Data) then
    raise ENanoMsgError.Create('data sent truncated !')
end;

procedure test_recv(s: NativeInt; const Expected: AnsiString);
var
  Buf: PAnsiChar;
  rc: NativeInt;
begin
  GetMem(Buf, Length(Expected) + 1);
  try
    rc := nn_recv(s, Buf, Length(Expected) + 1, 0);
    if rc < 0 then
      raise ENanoMsgError.Create('nn_recv failed')
    else if rc <> Length(Expected) then
      raise ENanoMsgError.Create('received data has wrong length')
    else if not CompareMem(PAnsiChar(Expected), Buf, Length(Expected)) then
      raise ENanoMsgError.Create('received data is corrupt');
  finally
    FreeMem(Buf);
  end;
end;

procedure test_drop(sock, err: NativeInt);
var
  rc: NativeInt;
  buf: array[0..1023] of AnsiChar;
begin
  rc := nn_recv(sock, @buf[0], SizeOf(buf), 0);
  if (rc < 0) and (err <> nn_errno) then
    raise ENanoMsgError.Create('got wrong err ')
  else if (rc >= 0) then
    raise ENanoMsgError.Create('did not drop message');
end;

end.
