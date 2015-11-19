unit TestNanoMsgMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    btnPair: TButton;
    btnBus: TButton;
    btnBlock: TButton;
    btnAsyncShutdown: TButton;
    btnDevice: TButton;
    btnDomain: TButton;
    btnEMFILE: TButton;
    btnInProc: TButton;
    btnCMSG: TButton;
    btnIOVEC: TButton;
    btnIPC: TButton;
    btnPipeline: TButton;
    btnSurvey: TButton;
    btnPubSub: TButton;
    btnReqRep: TButton;
    btnShutdown: TButton;
    btnSymbol: TButton;
    btnTerm: TButton;
    btnTCP: TButton;
    btnWS: TButton;
    btnZeroCopy: TButton;
    procedure btnPairClick(Sender: TObject);
    procedure btnBusClick(Sender: TObject);
    procedure btnBlockClick(Sender: TObject);
    procedure btnAsyncShutdownClick(Sender: TObject);
    procedure btnDeviceClick(Sender: TObject);
    procedure btnDomainClick(Sender: TObject);
    procedure btnEMFILEClick(Sender: TObject);
    procedure btnInProcClick(Sender: TObject);
    procedure btnCMSGClick(Sender: TObject);
    procedure btnIOVECClick(Sender: TObject);
    procedure btnIPCClick(Sender: TObject);
    procedure btnPipelineClick(Sender: TObject);
    procedure btnSurveyClick(Sender: TObject);
    procedure btnPubSubClick(Sender: TObject);
    procedure btnReqRepClick(Sender: TObject);
    procedure btnShutdownClick(Sender: TObject);
    procedure btnSymbolClick(Sender: TObject);
    procedure btnTermClick(Sender: TObject);
    procedure btnTCPClick(Sender: TObject);
    procedure btnWSClick(Sender: TObject);
    procedure btnZeroCopyClick(Sender: TObject);
  private
    { Déclarations privées }
    procedure ThreadTerminate(Sender: TObject);
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

uses
  NanoMsg, NanoMsg.Errors, NanoMsg.TestHelpers;

{$R *.dfm}

procedure TForm1.ThreadTerminate(Sender: TObject);
begin
  OutputDebugString('END THREAD');
end;

procedure TForm1.btnPairClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://a';
var
  sb, sc: NativeInt;
begin
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  test_send(sc, 'ABC');
  test_recv(sb, 'ABC');
  test_send(sb, 'DEF');
  test_recv(sc, 'DEF');

  test_close(sc);
  test_close(sb);
end;

procedure TForm1.btnPipelineClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://a';
var
  push1, push2, pull1, pull2: NativeInt;
begin
  (*  Test fan-out. *)

  push1 := test_socket(AF_SP, NN_PUSH);
  test_bind(push1, SOCKET_ADDRESS);
  pull1 := test_socket (AF_SP, NN_PULL);
  test_connect(pull1, SOCKET_ADDRESS);
  pull2 := test_socket (AF_SP, NN_PULL);
  test_connect(pull2, SOCKET_ADDRESS);

  (*  Wait till both connections are established to get messages spread
      evenly between the two pull sockets. *)
  Sleep (10);

  test_send(push1, 'ABC');
  test_send(push1, 'DEF');

  test_recv(pull1, 'ABC');
  test_recv(pull2, 'DEF');

  test_close(push1);
  test_close(pull1);
  test_close(pull2);

  (*  Test fan-in. *)

  pull1 := test_socket(AF_SP, NN_PULL);
  test_bind(pull1, SOCKET_ADDRESS);
  push1 := test_socket(AF_SP, NN_PUSH);
  test_connect (push1, SOCKET_ADDRESS);
  push2 := test_socket(AF_SP, NN_PUSH);
  test_connect(push2, SOCKET_ADDRESS);

  test_send(push1, 'ABC');
  test_send(push2, 'DEF');

  test_recv(pull1, 'ABC');
  test_recv(pull1, 'DEF');

  test_close(pull1);
  test_close(push1);
  test_close(push2);
end;

procedure TForm1.btnPubSubClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://a';
var
  rc: NativeInt;
  pub1, pub2, sub1, sub2: NativeInt;
  buf: array[0..7] of AnsiChar;
  sz: size_t;
begin
  pub1 := test_socket(AF_SP, NN_PUB);
  test_bind(pub1, SOCKET_ADDRESS);
  sub1 := test_socket(AF_SP, NN_SUB);
  rc := nn_setsockopt(sub1, NN_SUB, NN_SUB_SUBSCRIBE, PAnsiChar(''), 0);
  Assert(rc = 0);
  sz := SizeOf(buf);
  rc := nn_getsockopt(sub1, NN_SUB, NN_SUB_SUBSCRIBE, @buf[0], sz);
  Assert((rc = -1) and (nn_errno = ENOPROTOOPT));
  test_connect(sub1, SOCKET_ADDRESS);
  sub2 := test_socket(AF_SP, NN_SUB);
  rc := nn_setsockopt(sub2, NN_SUB, NN_SUB_SUBSCRIBE, PAnsiChar(''), 0);
  Assert(rc = 0);
  test_connect(sub2, SOCKET_ADDRESS);

  (*  Wait till connections are established to prevent message loss. *)
  Sleep(10);

  test_send(pub1, '0123456789012345678901234567890123456789');
  test_recv(sub1, '0123456789012345678901234567890123456789');
  test_recv(sub2, '0123456789012345678901234567890123456789');

  test_close(pub1);
  test_close(sub1);
  test_close(sub2);

  (*  Check receiving messages from two publishers. *)

  sub1 := test_socket(AF_SP, NN_SUB);
  rc := nn_setsockopt(sub1, NN_SUB, NN_SUB_SUBSCRIBE, PAnsiChar(''), 0);
  Assert(rc = 0);
  test_bind(sub1, SOCKET_ADDRESS);
  pub1 := test_socket(AF_SP, NN_PUB);
  test_connect(pub1, SOCKET_ADDRESS);
  pub2 := test_socket(AF_SP, NN_PUB);
  test_connect(pub2, SOCKET_ADDRESS);
  Sleep(100);

  test_send(pub1, '0123456789012345678901234567890123456789');
  test_send(pub2, '0123456789012345678901234567890123456789');
  test_recv(sub1, '0123456789012345678901234567890123456789');
  test_recv(sub1, '0123456789012345678901234567890123456789');

  test_close(pub2);
  test_close(pub1);
  test_close(sub1);
end;

procedure TForm1.btnReqRepClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://test';
var
  rc: NativeInt;
  rep1, rep2, req1, req2: NativeInt;
  resend_ivl: NativeInt;
  buf: array[0..6] of Char;
  timeo: Integer;
begin
  (*  Test req/rep with full socket types. *)
  rep1 := test_socket(AF_SP, NN_REP);
  test_bind(rep1, SOCKET_ADDRESS);
  req1 := test_socket(AF_SP, NN_REQ);
  test_connect(req1, SOCKET_ADDRESS);
  req2 := test_socket (AF_SP, NN_REQ);
  test_connect(req2, SOCKET_ADDRESS);

  (*  Check invalid sequence of sends and recvs. *)
  rc := nn_send(rep1, PAnsiChar('ABC'), 3, 0);
  Assert((rc = -1) and (nn_errno = EFSM));
  rc := nn_recv(req1, @buf[0], SizeOf(buf), 0);
  Assert((rc = -1) and (nn_errno = EFSM));

  (*  Check fair queueing the requests. *)
  test_send(req2, 'ABC');
  test_recv(rep1, 'ABC');
  test_send(rep1, 'ABC');
  test_recv(req2, 'ABC');

  test_send(req1, 'ABC');
  test_recv(rep1, 'ABC');
  test_send(rep1, 'ABC');
  test_recv(req1, 'ABC');

  test_close(rep1);
  test_close(req1);
  test_close(req2);

  (*  Check load-balancing of requests. *)
  req1 := test_socket(AF_SP, NN_REQ);
  test_bind(req1, SOCKET_ADDRESS);
  rep1 := test_socket(AF_SP, NN_REP);
  test_connect(rep1, SOCKET_ADDRESS);
  rep2 := test_socket(AF_SP, NN_REP);
  test_connect(rep2, SOCKET_ADDRESS);

  test_send(req1, 'ABC');
  test_recv(rep1, 'ABC');
  test_send(rep1, 'ABC');
  test_recv(req1, 'ABC');

  test_send(req1, 'ABC');
  test_recv(rep2, 'ABC');
  test_send(rep2, 'ABC');
  test_recv(req1, 'ABC');

  test_close(rep2);
  test_close(rep1);
  test_close(req1);

  (*  Test re-sending of the request. *)
  rep1 := test_socket(AF_SP, NN_REP);
  test_bind(rep1, SOCKET_ADDRESS);
  req1 := test_socket(AF_SP, NN_REQ);
  test_connect(req1, SOCKET_ADDRESS);
  resend_ivl := 100;
  rc := nn_setsockopt(req1, NN_REQ, NN_REQ_RESEND_IVL, @resend_ivl, SizeOf(resend_ivl));
  Assert(rc = 0);

  test_send(req1, 'ABC');
  test_recv(rep1, 'ABC');
  (*  The following waits for request to be resent  *)
  test_recv(rep1, 'ABC');

  test_close(req1);
  test_close(rep1);

  (*  Check sending a request when the peer is not available. (It should
      be sent immediatelly when the peer comes online rather than relying
      on the resend algorithm. *)
  req1 := test_socket(AF_SP, NN_REQ);
  test_connect(req1, SOCKET_ADDRESS);
  test_send(req1, 'ABC');

  rep1 := test_socket(AF_SP, NN_REP);
  test_bind(rep1, SOCKET_ADDRESS);
  timeo := 200;
  rc := nn_setsockopt (rep1, NN_SOL_SOCKET, NN_RCVTIMEO, @timeo, SizeOf(timeo));
  Assert(rc = 0);
  test_recv(rep1, 'ABC');

  test_close(req1);
  test_close(rep1);

  (*  Check removing socket request sent to (It should
      be sent immediatelly to other peer rather than relying
      on the resend algorithm). *)
  req1 := test_socket(AF_SP, NN_REQ);
  test_bind(req1, SOCKET_ADDRESS);
  rep1 := test_socket(AF_SP, NN_REP);
  test_connect(rep1, SOCKET_ADDRESS);
  rep2 := test_socket(AF_SP, NN_REP);
  test_connect(rep2, SOCKET_ADDRESS);

  timeo := 200;
  rc := nn_setsockopt(rep1, NN_SOL_SOCKET, NN_RCVTIMEO, @timeo, SizeOf(timeo));
  Assert(rc = 0);
  rc := nn_setsockopt(rep2, NN_SOL_SOCKET, NN_RCVTIMEO, @timeo, SizeOf(timeo));
  Assert(rc = 0);

  test_send(req1, 'ABC');
  (*  We got request through rep1  *)
  test_recv(rep1, 'ABC');
  (*  But instead replying we simulate crash  *)
  test_close(rep1);
  (*  The rep2 should get request immediately  *)
  test_recv(rep2, 'ABC');
  (*  Let's check it's delivered well  *)
  test_send(rep2, 'REPLY');
  test_recv(req1, 'REPLY');

  test_close(req1);
  test_close(rep2);

  (*  Test cancelling delayed request  *)

  req1 := test_socket(AF_SP, NN_REQ);
  test_connect(req1, SOCKET_ADDRESS);
  test_send(req1, 'ABC');
  test_send(req1, 'DEF');

  rep1 := test_socket(AF_SP, NN_REP);
  test_bind(rep1, SOCKET_ADDRESS);
  timeo := 100;
//  rc := nn_setsockopt(rep1, NN_SOL_SOCKET, NN_RCVTIMEO, @timeo, SizeOf(timeo));
//  Assert(rc = 0);
  test_recv(rep1, 'DEF');

  test_close(req1);
  test_close(rep1);
end;

procedure TForm1.btnShutdownClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'tcp://127.0.0.1:5590';
var
  s, rc, eid: NativeInt;
begin
  (*  Run endpoint shutdown and socket shutdown in parallel. *)
  s := test_socket(AF_SP, NN_REQ);
  eid := test_connect(s, SOCKET_ADDRESS);
  rc := nn_shutdown(s, eid);
  Assert(rc = 0);
  test_close(s);
end;

procedure TForm1.btnSurveyClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://test';
var
  rc, surveyor, respondent1, respondent2, respondent3: NativeInt;
  deadline: Integer;
  buf: array[0..6] of AnsiChar;
begin
  (*  Test a simple survey with three respondents. *)
  surveyor := test_socket(AF_SP, NN_SURVEYOR);
  deadline := 500;
  rc := nn_setsockopt(surveyor, NN_SURVEYOR, NN_SURVEYOR_DEADLINE, @deadline, SizeOf(deadline));
  Assert(rc = 0);
  test_bind(surveyor, SOCKET_ADDRESS);

  respondent1 := test_socket (AF_SP, NN_RESPONDENT);
  test_connect(respondent1, SOCKET_ADDRESS);
  respondent2 := test_socket (AF_SP, NN_RESPONDENT);
  test_connect(respondent2, SOCKET_ADDRESS);
  respondent3 := test_socket (AF_SP, NN_RESPONDENT);
  test_connect(respondent3, SOCKET_ADDRESS);

  (* Check that attempt to recv with no survey pending is EFSM. *)
  rc := nn_recv(surveyor, @buf[0], SizeOf(buf), 0);
  Assert((rc = -1) and (nn_errno = EFSM));

  (*  Send the survey. *)
  test_send(surveyor, 'ABC');

  (*  First respondent answers. *)
  test_recv(respondent1, 'ABC');
  test_send(respondent1, 'DEF');

  (*  Second respondent answers. *)
  test_recv(respondent2, 'ABC');
  test_send(respondent2, 'DEF');

  (*  Surveyor gets the responses. *)
  test_recv(surveyor, 'DEF');
  test_recv(surveyor, 'DEF');

  (*  There are no more responses. Surveyor hits the deadline. *)
  rc := nn_recv(surveyor, @buf[0], SizeOf(buf), 0);
  Assert((rc = -1) and (nn_errno = ETIMEDOUT));

  (*  Third respondent answers (it have already missed the deadline). *)
  test_recv(respondent3, 'ABC');
  test_send(respondent3, 'GHI');

  (*  Surveyor initiates new survey. *)
  test_send(surveyor, 'ABC');

  (*  Check that stale response from third respondent is not delivered. *)
  rc := nn_recv(surveyor, @buf[0], SizeOf(buf), 0);
  Assert((rc = -1) and (nn_errno = ETIMEDOUT));

  (* Check that subsequent attempt to recv with no survey pending is EFSM. *)
  rc := nn_recv(surveyor, @buf[0], SizeOf(buf), 0);
  Assert((rc = -1) and (nn_errno = EFSM));

  test_close(surveyor);
  test_close(respondent1);
  test_close(respondent2);
  test_close(respondent3);
end;

procedure TForm1.btnSymbolClick(Sender: TObject);
var
  I: Integer;
  sym: Tnn_symbol_properties;
  value: NativeInt;
  name: PAnsiChar;
begin
  Assert(nn_symbol(-1, nil) = nil);
  Assert(nn_errno = EINVAL);
  Assert(nn_symbol_info(-1, @sym, SizeOf(sym)) = 0);

  Assert(nn_symbol(2000, nil) = nil);
  Assert(nn_errno = EINVAL);
  Assert(nn_symbol_info(2000, @sym, SizeOf(sym)) = 0);

  Assert(nn_symbol(6, @value) <> nil);
  Assert(value <> 0);
  Assert(nn_symbol_info(6, @sym, SizeOf(sym)) = SizeOf(sym));

  I := 0;
  while True do
  begin
    name := nn_symbol(I, @value);
    if (name = nil) then
    begin
      Assert(nn_errno = EINVAL);
      Break;
    end;
    Inc(I);
  end;

  I := 0;
  while True do
  begin
    if (nn_symbol_info(I, @sym, SizeOf(sym)) = 0) then
      Break;
    Inc(I);
  end;
end;

procedure TForm1.btnTCPClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'tcp://127.0.0.1:5555';
var
  sc: NativeInt;
  rc, sb: NativeInt;
  I: Integer;
  opt: NativeInt;
  sz: size_t;
  s1, s2: NativeInt;
  dummy_buf: Pointer;
begin
  (*  Try closing bound but unconnected socket. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  test_close(sb);

  (*  Try closing a TCP socket while it not connected. At the same time
      test specifying the local address for the connection. *)
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, 'tcp://127.0.0.1;127.0.0.1:5555');
  test_close(sc);

  (*  Open the socket anew. *)
  sc := test_socket(AF_SP, NN_PAIR);

  (*  Check NODELAY socket option. *)
  sz := SizeOf(opt);
  rc := nn_getsockopt(sc, NN_TCP, NN_TCP_NODELAY, @opt, sz);
  Assert(rc = 0);
  Assert(sz = SizeOf(opt));
  Assert(opt = 0);
  opt := 2;
  rc := nn_setsockopt(sc, NN_TCP, NN_TCP_NODELAY, @opt, SizeOf(opt));
  Assert((rc < 0) and (nn_errno = EINVAL));
  opt := 1;
  rc := nn_setsockopt(sc, NN_TCP, NN_TCP_NODELAY, @opt, SizeOf(opt));
  Assert(rc = 0);
  sz := SizeOf(opt);
  rc := nn_getsockopt(sc, NN_TCP, NN_TCP_NODELAY, @opt, sz);
  Assert(rc = 0);
  Assert(sz = SizeOf(opt));
  Assert(opt = 1);

  (*  Try using invalid address strings. *)
  rc := nn_connect (sc, 'tcp://*:');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://*:1000000');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://*:some_port');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://eth10000;127.0.0.1:5555');
  Assert(rc < 0);
  Assert(nn_errno = ENODEV);
  rc := nn_connect (sc, 'tcp://127.0.0.1');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_bind (sc, 'tcp://127.0.0.1:');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_bind (sc, 'tcp://127.0.0.1:1000000');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_bind (sc, 'tcp://eth10000:5555');
  Assert(rc < 0);
  OutputDebugString(PChar(IntToStr(nn_errno())));
  Assert(nn_errno = ENODEV);
  rc := nn_connect (sc, 'tcp://:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://-hostname:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://abc.123.---.#:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://[::1]:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://abc.123.:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://abc...123:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'tcp://.123:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);

  (*  Connect correctly. Do so before binding the peer socket. *)
  test_connect (sc, SOCKET_ADDRESS);

  (*  Leave enough time for at least on re-connect attempt. *)
  Sleep (200);

  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);

  (*  Ping-pong test. *)
  for I := 0 to 100 do
  begin
    test_send(sc, 'ABC');
    test_recv(sb, 'ABC');

    test_send(sb, 'DEF');
    test_recv(sc, 'DEF');
  end;

  (*  Batch transfer test. *)
  for I := 0 to 100 do
    test_send(sc, '0123456789012345678901234567890123456789');
  for I := 0 to 100 do
    test_recv(sb, '0123456789012345678901234567890123456789');

  test_close(sc);
  test_close(sb);

  (*  Test whether connection rejection is handled decently. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_connect (s1, SOCKET_ADDRESS);
  s2 := test_socket(AF_SP, NN_PAIR);
  test_connect(s2, SOCKET_ADDRESS);
  Sleep(100);
  test_close(s2);
  test_close(s1);
  test_close(sb);

  (*  Test two sockets binding to the same address. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_bind(s1, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  Sleep(100);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sb);
  test_send(s1, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sc);
  test_close(s1);

  (*  Test NN_RCVMAXSIZE limit *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_connect(s1, SOCKET_ADDRESS);
  opt := 4;
  rc := nn_setsockopt(sb, NN_SOL_SOCKET, NN_RCVMAXSIZE, @opt, SizeOf(opt));
  Assert(rc = 0);
  Sleep(100);
  test_send(s1, 'ABC');
  test_recv(sb, 'ABC');
  test_send(s1, '0123456789012345678901234567890123456789');
  rc := nn_recv(sb, @dummy_buf, NN_MSG, NN_DONTWAIT);
  Assert(rc < 0);
  Assert(nn_errno = EAGAIN);
  test_close(sb);
  test_close(s1);

  (*  Test that NN_RCVMAXSIZE can be -1, but not lower *)
  sb := test_socket(AF_SP, NN_PAIR);
  opt := -1;
  rc := nn_setsockopt(sb, NN_SOL_SOCKET, NN_RCVMAXSIZE, @opt, SizeOf(opt));
  Assert (rc >= 0);
  opt := -2;
  rc := nn_setsockopt(sb, NN_SOL_SOCKET, NN_RCVMAXSIZE, @opt, SizeOf(opt));
  Assert(rc < 0);
  Assert (nn_errno = EINVAL);
  test_close(sb);

  (*  Test closing a socket that is waiting to bind. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  Sleep(100);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_bind(s1, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  Sleep (100);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(s1);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sb);
  test_close(sc);
end;

procedure TForm1.btnTermClick(Sender: TObject);
var
  rc, s: NativeInt;
  T: TThread;
begin
  (*  Close the socket with no associated endpoints. *)
  s := test_socket(AF_SP, NN_PAIR);
  test_close(s);

  T := TThread.CreateAnonymousThread(
    procedure
    var
      rc, s: NativeInt;
      buf: array[0..2] of AnsiChar;
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Test socket. *)
      s := test_socket(AF_SP, NN_PAIR);

      (*  Launch blocking function to check that it will be unblocked once
          nn_term() is called from the main thread. *)
      rc := nn_recv(s, @buf[0], SizeOf(buf), 0);
      Assert((rc = -1) and (nn_errno = ETERM));

      (*  Check that all subsequent operations fail in synchronous manner. *)
      rc := nn_recv (s, @buf[0], sizeof (buf), 0);
      Assert((rc = -1) and (nn_errno = ETERM));
      test_close (s);
    end
  );
  T.OnTerminate := ThreadTerminate;
  T.Start;

  (*  Test nn_term() before nn_close(). *)
  Sleep(100);
  nn_term();

  (*  Check that it's not possible to create new sockets after nn_term(). *)
  rc := nn_socket(AF_SP, NN_PAIR);
  Assert(rc = -1);
  Assert(nn_errno = ETERM);

  { Not in original sample }
  MessageDlg('NanoMSG Library is now terminated.' + #13#10 +
    '(You must reload this app if you want to use it again)',  mtWarning, [mbOK],
    0);
  Close;
end;

procedure TForm1.btnWSClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'ws://127.0.0.1:5555';

  (*  test_text() verifies that we drop messages properly when sending invalid
      UTF-8, but not when we send valid data. *)

  procedure test_text;
  var
    sb, sc: NativeInt;
    opt: NativeInt;
    bad: array[0..19] of AnsiChar;
  begin
    (*  Negative testing... bad UTF-8 data for text. *)
    sb := test_socket(AF_SP, NN_PAIR);
    sc := test_socket(AF_SP, NN_PAIR);

    (*  Wait for connects to establish. *)
    Sleep(200);

    opt := NN_WS_MSG_TYPE_TEXT;
    test_setsockopt(sb, NN_WS, NN_WS_MSG_TYPE, @opt, SizeOf(opt));
    opt := NN_WS_MSG_TYPE_TEXT;
    test_setsockopt(sc, NN_WS, NN_WS_MSG_TYPE, @opt, SizeOf(opt));
    opt := 500;
    test_setsockopt(sb, NN_SOL_SOCKET, NN_RCVTIMEO, @opt, SizeOf(opt));

    test_bind(sb, SOCKET_ADDRESS);
    test_connect(sc, SOCKET_ADDRESS);

    test_send(sc, 'GOOD');
    test_recv(sb, 'GOOD');

    (*  and the bad ... *)
    StrCopy(PAnsiChar(@bad[0]), 'BAD.');
    bad[2] := #$DD;
    test_send(sc, bad);

    (*  Make sure we dropped the frame. *)
    test_drop(sb, ETIMEDOUT);

    test_close(sc);
    test_close(sb);
  end;

var
  rc, sb, sc: NativeInt;
  opt: NativeInt;
  sz: size_t;
  I: Integer;
begin
  (*  Try closing bound but unconnected socket. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, 'ws://*:5555');
  test_close(sb);

  (*  Try closing a TCP socket while it not connected. At the same time
      test specifying the local address for the connection. *)
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, 'ws://127.0.0.1:5555');
  test_close(sc);

  (*  Open the socket anew. *)
  sc := test_socket(AF_SP, NN_PAIR);

  (*  Check socket options. *)
  sz := SizeOf(opt);
  rc := nn_getsockopt(sc, NN_WS, NN_WS_MSG_TYPE, @opt, sz);
  Assert(rc = 0);
  Assert(sz = SizeOf(opt));
  Assert(opt = NN_WS_MSG_TYPE_BINARY);

//  opt = 100;
//  sz = sizeof (opt);
//  rc = nn_getsockopt (sc, NN_WS, NN_WS_HANDSHAKE_TIMEOUT, &opt, &sz);
//  errno_assert (rc == 0);
//  nn_assert (sz == sizeof (opt));
//  nn_assert (opt == 100);

  (*  Default port 80 should be assumed if not explicitly declared. *)
  rc := nn_connect(sc, 'ws://127.0.0.1');
  Assert(rc >= 0);

  (*  Try using invalid address strings. *)
  rc := nn_connect(sc, 'ws://*:');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://*:1000000');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://*:some_port');
  Assert(rc < 0);
  rc := nn_connect (sc, 'ws://eth10000;127.0.0.1:5555');
  Assert(rc < 0);
  Assert(nn_errno = ENODEV);

  rc := nn_bind (sc, 'ws://127.0.0.1:');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_bind (sc, 'ws://127.0.0.1:1000000');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_bind (sc, 'ws://eth10000:5555');
  Assert(rc < 0);
  Assert(nn_errno = ENODEV);

  rc := nn_connect (sc, 'ws://:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://-hostname:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://abc.123.---.#:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://[::1]:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://abc.123.:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://abc...123:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);
  rc := nn_connect (sc, 'ws://.123:5555');
  Assert(rc < 0);
  Assert(nn_errno = EINVAL);

  test_close(sc);

  Sleep(200);

  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  (*  Leave enough time for connection establishment. *)
  Sleep(200);

  (*  Ping-pong test. *)
  for I := 0 to 100  do
  begin
    test_send(sc, 'ABC');
    test_recv(sb, 'ABC');

    test_send(sb, 'DEF');
    test_recv(sc, 'DEF');
  end;

  (*  Batch transfer test. *)
  for I := 0 to 100  do
    test_send(sc, '0123456789012345678901234567890123456789');
  for I := 0 to 100  do
    test_recv(sb, '0123456789012345678901234567890123456789');

  test_close(sc);
  test_close(sb);

  test_text;
end;

procedure TForm1.btnZeroCopyClick(Sender: TObject);

  procedure test_allocmsg_reqrep;
  var
    rc, req: NativeInt;
    p: Pointer;
    iov: Tnn_iovec;
    hdr: Tnn_msghdr;
  begin
    (*  Try to create an oversized message. *)
    p := nn_allocmsg(size_t(-1), 0);
    Assert((p = nil) and (nn_errno = ENOMEM));
    p := nn_allocmsg(size_t(-1000), 0);
    Assert((p = nil) and (nn_errno = ENOMEM));

    (*  Try to create a message of unknown type. *)
    p := nn_allocmsg(100, 333);
    Assert((p = nil) and (nn_errno = EINVAL));

    (*  Create a socket. *)
    req := test_socket(AF_SP_RAW, NN_REQ);

    (*  Make send fail and check whether the zero-copy buffer is left alone
        rather than deallocated. *)
    p := nn_allocmsg (100, 0);
    Assert(p <> nil);
    rc := nn_send(req, @p, NN_MSG, NN_DONTWAIT);
    Assert(rc < 0);
    Assert(nn_errno = EAGAIN);
    ZeroMemory(p, 100);
    rc := nn_freemsg(p);
    Assert(rc = 0);

    (*  Same thing with nn_sendmsg(). *)
    p := nn_allocmsg(100, 0);
    Assert(p <> nil);
    iov.iov_base := @p;
    iov.iov_len := NN_MSG;
    ZeroMemory(@hdr, SizeOf(hdr));
    hdr.msg_iov := @iov;
    hdr.msg_iovlen := 1;
    nn_sendmsg(req, @hdr, NN_DONTWAIT);
    Assert(nn_errno = EAGAIN);
    ZeroMemory(p, 100);
    rc := nn_freemsg(p);
    Assert(rc = 0);

    (*  Clean up. *)
    test_close(req);
  end;

  procedure test_reallocmsg_reqrep;
  var
    rc, req, rep: NativeInt;
    p{, p2}: Pointer;
  begin
    (*  Create sockets. *)
    req := nn_socket(AF_SP, NN_REQ);
    rep := nn_socket(AF_SP, NN_REP);
    rc := nn_bind(rep, 'inproc://test');
    Assert(rc >= 0);
    rc := nn_connect(req, 'inproc://test');
    Assert(rc >= 0);

    (*  Create message, make sure we handle overflow. *)
    p := nn_allocmsg(100, 0);
    Assert(p <> nil);
//    p2 := nn_reallocmsg(p, size_t(-1000));
//    Assert(nn_errno = ENOMEM);
//    Assert(p2 = nil);

    (*  Realloc to fit data size. *)
    StrCopy(PAnsiChar(p), PAnsiChar('Hello World!'));
    p := nn_reallocmsg(p, 12);
    Assert(p <> nil);
    rc := nn_send(req, @p, NN_MSG, 0);
    Assert(rc = 12);

    (*  Receive request and send response. *)
    rc := nn_recv(rep, @p, NN_MSG, 0);
    Assert(rc = 12);
    rc := nn_send(rep, @p, NN_MSG, 0);
    Assert(rc = 12);

    (*  Receive response and free message. *)
    rc := nn_recv(req, @p, NN_MSG, 0);
    Assert(rc = 12);
    Assert(CompareMem(p, PAnsiChar('Hello World!'), 12));
    rc := nn_freemsg(p);
    Assert(rc = 0);

    (*  Clean up. *)
    nn_close(req);
    nn_close(rep);
  end;

  procedure test_reallocmsg_pubsub;
  var
    rc, pub, sub1, sub2: NativeInt;
    p, p1, p2: Pointer;
  begin
    (*  Create sockets. *)
    pub := nn_socket(AF_SP, NN_PUB);
    sub1 := nn_socket(AF_SP, NN_SUB);
    sub2 := nn_socket(AF_SP, NN_SUB);
    rc := nn_bind (pub, 'inproc://test');
    Assert(rc >= 0);
    rc := nn_connect (sub1, 'inproc://test');
    Assert(rc >= 0);
    rc := nn_connect (sub2, 'inproc://test');
    Assert(rc >= 0);
    rc := nn_setsockopt(sub1, NN_SUB, NN_SUB_SUBSCRIBE, PAnsiChar(''), 0);
    Assert(rc = 0);
    rc := nn_setsockopt(sub2, NN_SUB, NN_SUB_SUBSCRIBE, PAnsiChar(''), 0);
    Assert(rc = 0);

    (*  Publish message. *)
    p := nn_allocmsg(12, 0);
    Assert(p <> nil);
    StrCopy(PAnsiChar(p), PAnsiChar('Hello World!'));
    rc := nn_send(pub, @p, NN_MSG, 0);
    Assert(rc = 12);

    (*  Receive messages, both messages are the same object with inproc. *)
    rc := nn_recv(sub1, @p1, NN_MSG, 0);
    Assert (rc = 12);
    rc := nn_recv(sub2, @p2, NN_MSG, 0);
    Assert(rc = 12);
    Assert(p1 = p2);
    Assert(CompareMem(p1, PAnsiChar('Hello World!'), 12));
    Assert(CompareMem(p2, PAnsiChar('Hello World!'), 12));

    (*  Reallocate one message, both messages shouldn't be the same object
        anymore. *)
    p1 := nn_reallocmsg(p1, 15);
    Assert(p1 <> nil);
    Assert(p1 <> p2);
    StrCopy(PAnsiChar(p1) + 12, PAnsiChar(' 42'));
    Assert(CompareMem(p1, PAnsiChar('Hello World! 42'), 15));

    (*  Release messages. *)
    rc := nn_freemsg(p1);
    Assert(rc = 0);
    rc := nn_freemsg(p2);
    Assert(rc = 0);

    (*  Clean up. *)
    nn_close(sub2);
    nn_close(sub1);
    nn_close(pub);
  end;
begin
  test_allocmsg_reqrep;
  test_reallocmsg_reqrep;
  test_reallocmsg_pubsub;
end;

procedure TForm1.btnAsyncShutdownClick(Sender: TObject);
const
  TEST_LOOPS = 10;
  SOCKET_ADDRESS = 'tcp://127.0.0.1:5557';
var
  I: Integer;
  sb: NativeInt;
  T: TThread;
begin
  for I := 0 to TEST_LOOPS - 1 do
  begin
    sb := test_socket(AF_SP, NN_PULL);
    test_bind(sb, SOCKET_ADDRESS);
    Sleep(100);

    T := TThread.CreateAnonymousThread(
      procedure
      var
        msg: NativeInt;
      begin
        OutputDebugString('BEGIN THREAD');

        (*  We don't expect to actually receive a message here;
        therefore, the datatype of 'msg' is irrelevant. *)
        nn_recv(sb, @msg, SizeOf(msg), 0);

        Assert(nn_errno = EBADF);
      end
    );
    T.OnTerminate := ThreadTerminate;
    T.Start;

    Sleep (100);
    OutputDebugString('CLOSE');
    test_close (sb);
  end;
end;

procedure TForm1.btnBlockClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://a';
var
  sb, sc: NativeInt;
  T: TThread;
begin
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  T := TThread.CreateAnonymousThread(
    procedure
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Wait 0.1 sec for the main thread to block. *)
      Sleep(100);
      OutputDebugString('SEND1');
      test_send(sc, 'ABC');

      (*  Wait 0.1 sec for the main thread to process the previous message
        and block once again. *)
      Sleep (100);
      OutputDebugString('SEND2');
      test_send (sc, 'ABC');
    end
  );

  T.OnTerminate := ThreadTerminate;
  T.Start;

  OutputDebugString('RECV1');
  test_recv(sb, 'ABC');

  OutputDebugString('RECV2');
  test_recv(sb, 'ABC');

  test_close (sc);
  test_close (sb);
end;

procedure TForm1.btnBusClick(Sender: TObject);
const
  SOCKET_ADDRESS_A = 'inproc://a';
  SOCKET_ADDRESS_B = 'inproc://b';
var
  rc: NativeInt;
  bus1, bus2, bus3: NativeInt;
  buf: array[1..3] of AnsiChar;
begin
  (*  Create a simple bus topology consisting of 3 nodes. *)
  bus1 := test_socket(AF_SP, NN_BUS);
  test_bind(bus1, SOCKET_ADDRESS_A);

  bus2 := test_socket(AF_SP, NN_BUS);
  test_bind(bus2, SOCKET_ADDRESS_B);
  test_connect(bus2, SOCKET_ADDRESS_A);

  bus3 := test_socket(AF_SP, NN_BUS);
  test_connect(bus3, SOCKET_ADDRESS_A);
  test_connect(bus3, SOCKET_ADDRESS_B);

  (*  Send a message from each node. *)
  test_send(bus1, 'A');
  test_send(bus2, 'BC');
  test_send(bus3, 'DEF');

  (*  Check that two messages arrived at each node. *)
  rc := nn_recv(bus1, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 2) or (rc = 3));
  rc := nn_recv (bus1, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 2) or (rc = 3));

  rc := nn_recv (bus2, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 1) or (rc = 3));
  rc := nn_recv (bus2, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 1) or (rc = 3));

  rc := nn_recv (bus3, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 1) or (rc = 2));
  rc := nn_recv (bus3, @buf[1], 3, 0);
  Assert(rc >= 0);
  Assert((rc = 1) or (rc = 2));

  (*  Wait till both connections are established. *)
  Sleep(10);

  test_close(bus3);
  test_close(bus2);
  test_close(bus1);
end;

procedure TForm1.btnCMSGClick(Sender: TObject);
const
  SOCKET_ADDRESS =  'tcp://127.0.0.1:5555';
var
  rc, rep, req: NativeInt;
  hdr: Tnn_msghdr;
  iovec: Tnn_iovec;
  body: array[0..2] of Byte;
  ctrl: array[0..255] of Byte;
  cmsg: Pnn_cmsghdr;
  data: PByte;
  buf: Pointer;
begin
  rep := test_socket(AF_SP_RAW, NN_REP);
  test_bind(rep, SOCKET_ADDRESS);
  req := test_socket(AF_SP, NN_REQ);
  test_connect(req, SOCKET_ADDRESS);

  (* Test ancillary data in static buffer. *)

  ZeroMemory(@body[0], SizeOf(body));
  ZeroMemory(@ctrl[0], SizeOf(ctrl));

  test_send(req, 'ABC');

  iovec.iov_base := @body[0];
  iovec.iov_len := SizeOf(body);
  ZeroMemory(@hdr, SizeOf(hdr));
  hdr.msg_iov := @iovec;
  hdr.msg_iovlen := 1;
  hdr.msg_control := @ctrl[0];
  hdr.msg_controllen := SizeOf(ctrl);
  rc := nn_recvmsg(rep, @hdr, 0);
  Assert(rc = 3);

  cmsg := NN_CMSG_FIRSTHDR(@hdr);
  while True do
  begin
    Assert(cmsg <> nil);
    if (cmsg^.cmsg_level = PROTO_SP) and (cmsg^.cmsg_type = SP_HDR) then
      Break;
    cmsg := NN_CMSG_NXTHDR(@hdr, cmsg);
  end;

  Assert(cmsg^.cmsg_len = NN_CMSG_SPACE(8));
  data := NN_CMSG_DATA(cmsg);
  Assert(data[0] and $80 = 0);
  Assert(data[4] and $80 <> 0);

  rc := nn_sendmsg(rep, @hdr, 0);
  Assert(rc = 3);
  test_recv(req, 'ABC');

  (* Test ancillary data in dynamically allocated buffer (NN_MSG). *)

  ZeroMemory(@body[0], SizeOf(body));
  ZeroMemory(@ctrl[0], SizeOf(ctrl));
  buf := nil;

  test_send(req, 'ABC');

  iovec.iov_base := @body[0];
  iovec.iov_len := SizeOf(body);
  ZeroMemory(@hdr, SizeOf(hdr));
  hdr.msg_iov := @iovec;
  hdr.msg_iovlen := 1;
  hdr.msg_control := @buf;
  hdr.msg_controllen := NN_MSG;
  rc := nn_recvmsg(rep, @hdr, 0);
  Assert(rc = 3);

  cmsg := NN_CMSG_FIRSTHDR(@hdr);
  while True do
  begin
    Assert(cmsg <> nil);
    if (cmsg^.cmsg_level = PROTO_SP) and (cmsg^.cmsg_type = SP_HDR) then
      Break;
    cmsg := NN_CMSG_NXTHDR(@hdr, cmsg);
  end;

  Assert(cmsg^.cmsg_len = NN_CMSG_SPACE(8));
  data := NN_CMSG_DATA(cmsg);
  Assert(data[0] and $80 = 0);
  Assert(data[4] and $80 <> 0);

  rc := nn_sendmsg(rep, @hdr, 0);
  Assert(rc = 3);
  test_recv(req, 'ABC');

  test_close (req);
  test_close (rep);
end;

procedure TForm1.btnDeviceClick(Sender: TObject);
const
  SOCKET_ADDRESS_A = 'inproc://a';
  SOCKET_ADDRESS_B = 'inproc://b';
  SOCKET_ADDRESS_C = 'inproc://c';
  SOCKET_ADDRESS_D = 'inproc://d';
  SOCKET_ADDRESS_E = 'inproc://e';
  SOCKET_ADDRESS_F = 'tcp://127.0.0.1:5565';
  SOCKET_ADDRESS_G = 'tcp://127.0.0.1:5566';
var
  enda, endb, endc, endd, ende1, ende2, endf, endg: NativeInt;
  T1, T2, T3, T4: TThread;
  timeo: NativeInt;
begin
  (*  Test the bi-directional device. *)

  (*  Start the device. *)
  T1 := TThread.CreateAnonymousThread(
    procedure
    var
      rc: NativeInt;
      deva, devb: NativeInt;
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Intialise the device sockets. *)
      deva := test_socket(AF_SP_RAW, NN_PAIR);
      test_bind(deva, SOCKET_ADDRESS_A);
      devb := test_socket (AF_SP_RAW, NN_PAIR);
      test_bind(devb, SOCKET_ADDRESS_B);

      (*  Run the device. *)
      OutputDebugString('RUN DEVICE1');
      rc := nn_device (deva, devb);
      Assert((rc < 0) and ((nn_errno = ETERM) or (nn_errno = EBADF)));
      OutputDebugString('END DEVICE1');

      (*  Clean up. *)
      test_close (devb);
      test_close (deva);
    end
  );
  T1.OnTerminate := ThreadTerminate;
  T1.Start;

  (*  Create two sockets to connect to the device. *)
  enda := test_socket(AF_SP, NN_PAIR);
  test_connect(enda, SOCKET_ADDRESS_A);
  endb := test_socket (AF_SP, NN_PAIR);
  test_connect(endb, SOCKET_ADDRESS_B);

  (*  Pass a pair of messages between endpoints. *)
  test_send(enda, 'ABC');
  test_recv(endb, 'ABC');
  test_send(endb, 'ABC');
  test_recv(enda, 'ABC');

  (*  Clean up. *)
  test_close (endb);
  test_close (enda);

  (*  Test the uni-directional device. *)

  (*  Start the device. *)
  T2 := TThread.CreateAnonymousThread(
    procedure
    var
      rc: NativeInt;
      devc, devd: NativeInt;
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Intialise the device sockets. *)
      devc := test_socket(AF_SP_RAW, NN_PULL);
      test_bind(devc, SOCKET_ADDRESS_C);
      devd := test_socket (AF_SP_RAW, NN_PUSH);
      test_bind(devd, SOCKET_ADDRESS_D);

      (*  Run the device. *)
      OutputDebugString('RUN DEVICE2');
      rc := nn_device(devc, devd);
      Assert((rc < 0) and (nn_errno = ETERM));
      OutputDebugString('END DEVICE2');

      (*  Clean up. *)
      test_close(devd);
      test_close(devc);
    end
  );
  T2.OnTerminate := ThreadTerminate;
  T2.Start;

  (*  Create two sockets to connect to the device. *)
  endc := test_socket(AF_SP, NN_PUSH);
  test_connect(endc, SOCKET_ADDRESS_C);
  endd := test_socket(AF_SP, NN_PULL);
  test_connect(endd, SOCKET_ADDRESS_D);

  (*  Pass a message between endpoints. *)
  test_send (endc, 'XYZ');
  test_recv (endd, 'XYZ');

  (*  Clean up. *)
  test_close (endd);
  test_close (endc);

  (*  Test the loopback device. *)

  (*  Start the device. *)
  T3 := TThread.CreateAnonymousThread(
    procedure
    var
      rc: NativeInt;
      deve: NativeInt;
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Intialise the device socket. *)
      deve := test_socket(AF_SP_RAW, NN_BUS);
      test_bind(deve, SOCKET_ADDRESS_E);

      (*  Run the device. *)
      OutputDebugString('RUN DEVICE3');
      rc := nn_device (deve, -1);
      Assert(((rc < 0) and (nn_errno = ETERM)));
      OutputDebugString('END DEVICE3');

      (*  Clean up. *)
      test_close(deve);
    end
  );
  T3.OnTerminate := ThreadTerminate;
  T3.Start;

  (*  Create two sockets to connect to the device. *)
  ende1 := test_socket (AF_SP, NN_BUS);
  test_connect (ende1, SOCKET_ADDRESS_E);
  ende2 := test_socket (AF_SP, NN_BUS);
  test_connect (ende2, SOCKET_ADDRESS_E);

  (*  BUS is unreliable so wait a bit for connections to be established. *)
  Sleep(100);

  (*  Pass a message to the bus. *)
  test_send(ende1, 'KLM');
  test_recv(ende2, 'KLM');

  (*  Make sure that the message doesn't arrive at the socket it was
      originally sent to. *)
  timeo := 100;
  test_setsockopt(ende1, NN_SOL_SOCKET, NN_RCVTIMEO, @timeo, SizeOf(timeo));
  test_drop(ende1, ETIMEDOUT);

  (*  Clean up. *)
  test_close(ende2);
  test_close(ende1);

  (*  Test the loopback device. *)

  (*  Start the device. *)
  T4 := TThread.CreateAnonymousThread(
    procedure
    var
      rc: NativeInt;
      devf, devg: NativeInt;
    begin
      OutputDebugString('BEGIN THREAD');

      (*  Intialise the device sockets. *)
      devf := test_socket(AF_SP_RAW, NN_REP);
      test_bind (devf, SOCKET_ADDRESS_F);
      devg := test_socket(AF_SP_RAW, NN_REQ);
      test_bind(devg, SOCKET_ADDRESS_G);

      (*  Run the device. *)
      rc := nn_device(devf, devg);
      Assert((rc < 0) and ((nn_errno = ETERM) or (nn_errno = EBADF)));

      (*  Clean up. *)
      test_close(devg);
      test_close(devf);
    end
  );
  T4.OnTerminate := ThreadTerminate;
  T4.Start;

  (*  Create two sockets to connect to the device. *)
  endf := test_socket(AF_SP, NN_REQ);
  test_connect(endf, SOCKET_ADDRESS_F);
  endg := test_socket(AF_SP, NN_REP);
  test_connect(endg, SOCKET_ADDRESS_G);

  (*  Wait for TCP to establish. *)
  Sleep(100);

  (*  Pass a message between endpoints. *)
  test_send(endf, 'XYZ');
  test_recv(endg, 'XYZ');

  (* Now send a reply. *)
  test_send(endg, 'REPLYXYZ');
  test_recv(endf, 'REPLYXYZ');

  (*  Clean up. *)
  test_close (endg);
  test_close (endf);

  (*  Shut down the devices. *)
  nn_term();

  { Not in original sample }
  MessageDlg('NanoMSG Library is now terminated.' + #13#10 +
    '(You must reload this app if you want to use it again)',  mtWarning, [mbOK],
    0);
  Close;
end;

procedure TForm1.btnDomainClick(Sender: TObject);
var
  s, rc, op: NativeInt;
  opsz: size_t;
begin
  s := test_socket(AF_SP, NN_PAIR);

  opsz := SizeOf(op);
  rc := nn_getsockopt(s, NN_SOL_SOCKET, NN_DOMAIN, @op, opsz);
  Assert(rc = 0);
  Assert(opsz = SizeOf(op));
  Assert(op = AF_SP);

  opsz := SizeOf(op);
  rc := nn_getsockopt(s, NN_SOL_SOCKET, NN_PROTOCOL, @op, opsz);
  Assert(rc = 0);
  Assert(opsz = SizeOf(op));
  Assert(op = NN_PAIR);

  test_close(s);
end;

procedure TForm1.btnEMFILEClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'tcp://127.0.0.1:5555';
  MAX_SOCKETS = 1000;
var
  rc: NativeInt;
  I: Integer;
  socks: array[0..MAX_SOCKETS] of NativeInt;
begin
  (*  First, just create as much SP sockets as possible. *)
  I := 0;
  while I < MAX_SOCKETS do
  begin
    socks[I] := nn_socket(AF_SP, NN_PAIR);
    if (socks[I] < 0) then
    begin
      OutputDebugString(PChar('DONE. Created ' + IntToStr(I) + ' sockets'));
      Assert(nn_errno = EMFILE);
      Break;
    end;
    Inc(I);
  end;

  while (I > 0) do
  begin
    Dec(I);
    rc := nn_close(socks[I]);
    Assert(rc = 0);
  end;
end;

procedure TForm1.btnInProcClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://test';
var
  rc: NativeInt;
  sb, sc: NativeInt;
  s1, s2: NativeInt;
  I: Integer;
  buf: array[0..255] of AnsiChar;
  val: Integer;
  hdr: Tnn_msghdr;
  iovec: Tnn_iovec;
  body: array[0..2] of Byte;
  control: Pointer;
  cmsg: Pnn_cmsghdr;
  data: PByte;
begin
  (*  Create a simple topology. *)
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);

  (*  Try a duplicate bind. It should fail. *)
  rc := nn_bind(sc, SOCKET_ADDRESS);
  Assert((rc < 0) and (nn_errno = EADDRINUSE));

  (*  Ping-pong test. *)
  for I := 0 to 100 do
  begin
    test_send(sc, 'ABC');
    test_recv(sb, 'ABC');
    test_send(sb, 'DEFG');
    test_recv(sc, 'DEFG');
  end;

  (*  Batch transfer test. *)
  for I := 0 to 100 do
    test_send(sc, 'XYZ');
  for I := 0 to 100 do
    test_recv(sb, 'XYZ');

  test_close(sc);
  test_close(sb);

  (*  Test whether queue limits are observed. *)
  sb := test_socket(AF_SP, NN_PAIR);
  val := 200;
  test_setsockopt(sb, NN_SOL_SOCKET, NN_RCVBUF, @val, SizeOf(val));
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  val := 200;
  test_setsockopt(sc, NN_SOL_SOCKET, NN_SNDTIMEO, @val, SizeOf(val));
  i := 0;
  while True do
  begin
    rc := nn_send(sc, PAnsiChar('0123456789'), 10, 0);
    if ((rc < 0) and (nn_errno = ETIMEDOUT)) then
      Break;
    Assert(rc >= 0);
    Assert(rc = 10);
    Inc(I);
  end;

  Assert(I = 20);
  test_recv(sb, '0123456789');
  test_send(sc, '0123456789');
  rc := nn_send(sc, PAnsiChar('0123456789'), 10, 0);
  Assert((rc < 0) and (nn_errno = ETIMEDOUT));
  for I := 0 to 20 - 1 do
    test_recv(sb, '0123456789');

  (*  Make sure that even a message that doesn't fit into the buffers
      gets across. *)
  for I := 0 to SizeOf(buf) - 1 do
    buf[I] := 'A';
  rc := nn_send(sc, @buf[0], 256, 0);
  Assert(rc >= 0);
  Assert(rc = 256);
  rc := nn_recv(sb, @buf[0], SizeOf(buf), 0);
  Assert(rc >= 0);
  Assert(rc = 256);

  test_close(sc);
  test_close(sb);

//#if 0
//  (*  Test whether connection rejection is handled decently. *)
//  sb := test_socket(AF_SP, NN_PAIR);
//  test_bind(sb, SOCKET_ADDRESS);
//  s1 := test_socket(AF_SP, NN_PAIR);
//  test_connect(s1, SOCKET_ADDRESS);
//  s2 := test_socket(AF_SP, NN_PAIR);
//  test_connect(s2, SOCKET_ADDRESS);
//  Sleep(100);
//  test_close(s2);
//  test_close(s1);
//  test_close(sb);
//#endif

  (* Check whether SP message header is transferred correctly. *)
  sb := test_socket(AF_SP_RAW, NN_REP);
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_REQ);
  test_connect(sc, SOCKET_ADDRESS);

  test_send(sc, 'ABC');

  iovec.iov_base := @body[0];
  iovec.iov_len := SizeOf(body);
  hdr.msg_iov := @iovec;
  hdr.msg_iovlen := 1;
  hdr.msg_control := @control;
  hdr.msg_controllen := NN_MSG;
  rc := nn_recvmsg(sb, @hdr, 0);
  Assert(rc = 3);

  cmsg := NN_CMSG_FIRSTHDR(@hdr);
  while True do
  begin
    Assert(cmsg <> nil);
    if (cmsg^.cmsg_level = PROTO_SP) and (cmsg^.cmsg_type = SP_HDR) then
      Break;
    cmsg := NN_CMSG_NXTHDR(@hdr, cmsg);
  end;

  Assert(cmsg^.cmsg_len = NN_CMSG_SPACE(8));
  data := NN_CMSG_DATA(cmsg);
  Assert(data[0] and $80 = 0);
  Assert(data[4] and $80 <> 0);

  nn_freemsg(control);

  test_close(sc);
  test_close(sb);

  (* Test binding a new socket after originally bound socket shuts down. *)
  sb := test_socket(AF_SP, NN_BUS);
  test_bind(sb, SOCKET_ADDRESS);

  sc := test_socket(AF_SP, NN_BUS);
  test_connect(sc, SOCKET_ADDRESS);

  s1 := test_socket(AF_SP, NN_BUS);
  test_connect(s1, SOCKET_ADDRESS);

  (* Close bound socket, leaving connected sockets connect. *)
  test_close (sb);

  Sleep(100);

  (* Rebind a new socket to the address to which our connected sockets are listening. *)
  s2 := test_socket(AF_SP, NN_BUS);
  test_bind(s2, SOCKET_ADDRESS);

  (*  Ping-pong test. *)
  for I := 0 to 100 do
  begin
    test_send(sc, 'ABC');
    test_send(s1, 'QRS');
    test_recv(s2, 'ABC');
    test_recv(s2, 'QRS');
    test_send(s2, 'DEFG');
    test_recv(sc, 'DEFG');
    test_recv(s1, 'DEFG');
  end;

  (*  Batch transfer test. *)
  for I := 0 to 100 do
    test_send(sc, 'XYZ');
  for I := 0 to 100 do
    test_recv(s2, 'XYZ');
  for I := 0 to 100 do
    test_send(s1, 'MNO');
  for I := 0 to  100 do
    test_recv(s2, 'MNO');

  test_close(s1);
  test_close(sc);
  test_close(s2);
end;

procedure TForm1.btnIOVECClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'inproc://a';
var
  rc, sb, sc: NativeInt;
  iov: array[0..1] of Tnn_iovec;
  hdr: Tnn_msghdr;
  buf: array[0..5] of AnsiChar;
begin
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  iov[0].iov_base := PAnsiChar('AB');
  iov[0].iov_len := 2;
  iov[1].iov_base := PAnsiChar('CDEF');
  iov[1].iov_len := 4;

  ZeroMemory(@hdr, SizeOf(hdr));
  hdr.msg_iov := @iov[0];
  hdr.msg_iovlen := 2;
  rc := nn_sendmsg(sc, @hdr, 0);
  Assert(rc >= 0);
  Assert(rc = 6);

  iov[0].iov_base := @buf[0];
  iov[0].iov_len := 4;
  iov[1].iov_base := @buf[4];
  iov[1].iov_len := 2;

  ZeroMemory(@hdr, SizeOf(hdr));
  hdr.msg_iov := @iov[0];
  hdr.msg_iovlen := 2;
  rc := nn_recvmsg(sb, @hdr, 0);
  Assert(rc >= 0);
  Assert(rc = 6);
  Assert(CompareMem(@buf[0], PAnsiChar('ABCDEF'), 6));

  test_close (sc);
  test_close (sb);
end;

procedure TForm1.btnIPCClick(Sender: TObject);
const
  SOCKET_ADDRESS = 'ipc://test.ipc';
var
  sb, sc: NativeInt;
  I: Integer;
  s1, s2: NativeInt;
  Size: Integer;
  buf: PAnsiChar;
begin
  (*  Try closing a IPC socket while it not connected. *)
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  test_close(sc);

  (*  Open the socket anew. *)
  sc := test_socket (AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);

  (*  Leave enough time for at least one re-connect attempt. *)
  Sleep (200);

  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);

  (*  Ping-pong test. *)
  for I := 0 to 1 do
  begin
    test_send(sc, '0123456789012345678901234567890123456789');
    test_recv(sb, '0123456789012345678901234567890123456789');
    test_send(sb, '0123456789012345678901234567890123456789');
    test_recv(sc, '0123456789012345678901234567890123456789');
  end;

  (*  Batch transfer test. *)
  for I := 0 to 100 do
    test_send(sc, 'XYZ');
  for I := 0 to 100 do
    test_recv(sb, 'XYZ');

  (*  Send something large enough to trigger overlapped I/O on Windows. *)
  Size := 10000;
  GetMem(buf, Size);
  for I := 0 to Size - 2 do
    buf[I] := AnsiChar(48 + (i mod 10));

  buf[Size-1] := #0;
  test_send(sc, buf);
  test_recv(sb, buf);
  FreeMem(buf);

  test_close(sc);
  test_close(sb);

  (*  Test whether connection rejection is handled decently. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_connect(s1, SOCKET_ADDRESS);
  s2 := test_socket(AF_SP, NN_PAIR);
  test_connect (s2, SOCKET_ADDRESS);

  Sleep(100);

  test_close(s2);
  test_close(s1);
  test_close(sb);

  (*  Test two sockets binding to the same address. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  s1 := test_socket(AF_SP, NN_PAIR);
  test_bind(s1, SOCKET_ADDRESS);
  sc := test_socket(AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  Sleep(100);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sb);
  test_send(s1, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sc);
  test_close(s1);

  (*  Test closing a socket that is waiting to bind. *)
  sb := test_socket(AF_SP, NN_PAIR);
  test_bind(sb, SOCKET_ADDRESS);
  Sleep (100);
  s1 := test_socket (AF_SP, NN_PAIR);
  test_bind(s1, SOCKET_ADDRESS);
  sc := test_socket (AF_SP, NN_PAIR);
  test_connect(sc, SOCKET_ADDRESS);
  Sleep (100);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(s1);
  test_send(sb, 'ABC');
  test_recv(sc, 'ABC');
  test_close(sb);
  test_close(sc);
end;

end.
