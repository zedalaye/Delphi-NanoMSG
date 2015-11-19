unit NanoMsg;

{$WARN SYMBOL_PLATFORM OFF}

interface

uses
  Windows;

type
  (*  Structure that is returned from nn_symbol  *)
  Pnn_symbol_properties = ^Tnn_symbol_properties;
  Tnn_symbol_properties = packed record
    (*  The constant value  *)
    value: NativeInt;

    (*  The constant name  *)
    name: PAnsiChar;

    (*  The constant namespace, or zero for namespaces themselves *)
    ns: NativeInt;

    (*  The option type for socket option constants  *)
    &type: NativeInt;

    (*  The unit for the option value for socket option constants  *)
    &unit: NativeInt;
  end;

 (******************************************************************************
  *  Socket definition.                                                        *
  ******************************************************************************)

  Pnn_iovec = ^Tnn_iovec;
  Tnn_iovec = packed record
    iov_base: Pointer;
    iov_len: size_t;
  end;

  Pnn_msghdr = ^Tnn_msghdr;
  Tnn_msghdr = packed record
    msg_iov: Pnn_iovec;
    msg_iovlen: NativeInt;
    msg_control: Pointer;
    msg_controllen: size_t;
  end;

  Pnn_cmsghdr = ^Tnn_cmsghdr;
  Tnn_cmsghdr = packed record
    cmsg_len: size_t;
    cmsg_level: NativeInt;
    cmsg_type: NativeInt;
  end;

 (******************************************************************************
  *  Socket mutliplexing support.                                              *
  ******************************************************************************)

  Pnn_pollfd = ^Tnn_pollfd;
  Tnn_pollfd = packed record
    fd: NativeInt;
    events: SmallInt;
    revents: SmallInt;
  end;

  Tnn_req_handle = packed record
  case Boolean of
    True: (i: NativeInt);
    False: (ptr: Pointer);
  end;

const
  (*  The current interface version. *)
  NN_VERSION_CURRENT = 3;

  (*  The latest revision of the current interface. *)
  NN_VERSION_REVISION = 0;

  (*  How many past interface versions are still supported. *)
  NN_VERSION_AGE = 0;

 (******************************************************************************
  *  Errors.                                                                   *
  ******************************************************************************)

 (*  A number random enough not to collide with different errno ranges on      *
  *  different OSes. The assumption is that error_t is at least 32-bit type.   *)
  NN_HAUSNUMERO   = 156384712;

  (*  On some platforms some standard POSIX errnos are not defined.    *)
  ENOTSUP         = 129; // NN_HAUSNUMERO + 1;
  EPROTONOSUPPORT = 135; // NN_HAUSNUMERO + 2;
  ENOBUFS         = 119; // NN_HAUSNUMERO + 3;
  ENETDOWN        = 116; // NN_HAUSNUMERO + 4;
  EADDRINUSE      = 100; // NN_HAUSNUMERO + 5;
  EADDRNOTAVAIL   = 101; // NN_HAUSNUMERO + 6;
  ECONNREFUSED    = 107; // NN_HAUSNUMERO + 7;
  EINPROGRESS     = 112; // NN_HAUSNUMERO + 8;
  ENOTSOCK        = 128; // NN_HAUSNUMERO + 9;
  EAFNOSUPPORT    = 102; // NN_HAUSNUMERO + 10;
  EPROTO          = 134; // NN_HAUSNUMERO + 11;
  EAGAIN          = 11;  // NN_HAUSNUMERO + 12;
  EBADF           = 9;   // NN_HAUSNUMERO + 13;
  EINVAL          = 22;  // NN_HAUSNUMERO + 14;
  EMFILE          = 24;  // NN_HAUSNUMERO + 15;
  EFAULT          = 14;  // NN_HAUSNUMERO + 16;
  EACCES          = 13;  // NN_HAUSNUMERO + 17;
  EACCESS         = EACCES; { Alias }
  ENETRESET       = 117; // NN_HAUSNUMERO + 18;
  ENETUNREACH     = 118; // NN_HAUSNUMERO + 19;
  EHOSTUNREACH    = 110; // NN_HAUSNUMERO + 20;
  ENOTCONN        = 126; // NN_HAUSNUMERO + 21;
  EMSGSIZE        = 115; // NN_HAUSNUMERO + 22;
  ETIMEDOUT       = 138; // NN_HAUSNUMERO + 23;
  ECONNABORTED    = 106; // NN_HAUSNUMERO + 24;
  ECONNRESET      = 108; // NN_HAUSNUMERO + 25;
  ENOPROTOOPT     = 123; // NN_HAUSNUMERO + 26;
  EISCONN         = 113; // NN_HAUSNUMERO + 27;

  (* Not defined by Win32 API *)
  ESOCKTNOSUPPORT = NN_HAUSNUMERO + 28;

  (* Defined by POSIX but not by NanoMSG *)
  ENOMEM          = 12;
  ENODEV          = 19;

  (*  Native nanomsg error codes. *)
  ETERM = NN_HAUSNUMERO + 53;
  EFSM  = NN_HAUSNUMERO + 54;

 (*  Constants that are returned in `ns` member of nn_symbol_properties        *)
  NN_NS_NAMESPACE        = 0;
  NN_NS_VERSION          = 1;
  NN_NS_DOMAIN           = 2;
  NN_NS_TRANSPORT        = 3;
  NN_NS_PROTOCOL         = 4;
  NN_NS_OPTION_LEVEL     = 5;
  NN_NS_SOCKET_OPTION    = 6;
  NN_NS_TRANSPORT_OPTION = 7;
  NN_NS_OPTION_TYPE      = 8;
  NN_NS_OPTION_UNIT      = 9;
  NN_NS_FLAG             = 10;
  NN_NS_ERROR            = 11;
  NN_NS_LIMIT            = 12;
  NN_NS_EVENT            = 13;

 (*  Constants that are returned in `type` member of nn_symbol_properties      *)
  NN_TYPE_NONE = 0;
  NN_TYPE_INT  = 1;
  NN_TYPE_STR  = 2;

 (*  Constants that are returned in the `unit` member of nn_symbol_properties  *)
  NN_UNIT_NONE         = 0;
  NN_UNIT_BYTES        = 1;
  NN_UNIT_MILLISECONDS = 2;
  NN_UNIT_PRIORITY     = 3;
  NN_UNIT_BOOLEAN      = 4;

 (*  SP address families.                                                      *)
  AF_SP     = 1;
  AF_SP_RAW = 2;

 (*  Max size of an SP address.                                                *)
  NN_SOCKADDR_MAX = 128;

 (*  Max size of any message *)
  NN_MSG = size_t(-1);

 (*  Socket option levels: Negative numbers are reserved for transports,
     positive for socket types.                                                *)
  NN_SOL_SOCKET = 0;

 (*  Generic socket options (NN_SOL_SOCKET level).                             *)
  NN_LINGER            = 1;
  NN_SNDBUF            = 2;
  NN_RCVBUF            = 3;
  NN_SNDTIMEO          = 4;
  NN_RCVTIMEO          = 5;
  NN_RECONNECT_IVL     = 6;
  NN_RECONNECT_IVL_MAX = 7;
  NN_SNDPRIO           = 8;
  NN_RCVPRIO           = 9;
  NN_SNDFD             = 10;
  NN_RCVFD             = 11;
  NN_DOMAIN            = 12;
  NN_PROTOCOL          = 13;
  NN_IPV4ONLY          = 14;
  NN_SOCKET_NAME       = 15;
  NN_RCVMAXSIZE        = 16;

 (*  Send/recv options.                                                        *)
  NN_DONTWAIT = 1;

 (*  Ancillary data.                                                           *)
  PROTO_SP = 1;
  SP_HDR   = 1;

 (* inproc.h *)
  NN_INPROC = -1;

 (* ipc.h *)
  NN_IPC = -2;

 (* tcp.h *)
  NN_TCP = -3;
  NN_TCP_NODELAY = 1;

  (* ws.h *)
  NN_WS = -4;

 (*  NN_WS level socket/cmsg options.  Note that only NN_WSMG_TYPE_TEXT and
     NN_WS_MSG_TYPE_BINARY messages are supported fully by this implementation.
     Attempting to set other message types is undefined.  *)
  NN_WS_MSG_TYPE = 1;

 (*  WebSocket opcode constants as per RFC 6455 5.2  *)
  NN_WS_MSG_TYPE_TEXT   = $1;
  NN_WS_MSG_TYPE_BINARY = $2;

  (* tcpmux.h *)
  NN_TCPMUX = -5;
  NN_TCPMUX_NODELAY = 1;

 (* pair.h *)
  NN_PROTO_PAIR = 1;
  NN_PAIR       = NN_PROTO_PAIR * 16 + 0;

 (* pubsub.h *)
  NN_PROTO_PUBSUB = 2;
  NN_PUB          = NN_PROTO_PUBSUB * 16 + 0;
  NN_SUB          = NN_PROTO_PUBSUB * 16 + 1;

  NN_SUB_SUBSCRIBE = 1;
  NN_SUB_UNSUBSCRIBE = 2;

 (* reqrep.h *)
  NN_PROTO_REQREP = 3;
  NN_REQ          = NN_PROTO_REQREP * 16 + 0;
  NN_REP          = NN_PROTO_REQREP * 16 + 1;

  NN_REQ_RESEND_IVL = 1;

 (* pipeline.h *)
  NN_PROTO_PIPELINE = 5;
  NN_PUSH           = NN_PROTO_PIPELINE * 16 + 0;
  NN_PULL           = NN_PROTO_PIPELINE * 16 + 1;

 (* survey.h *)
  NN_PROTO_SURVEY   = 6;

 (*  NB: Version 0 used 16 + 0/1.  That version lacked backtraces, and so
     is wire-incompatible with this version. *)

  NN_SURVEYOR       = NN_PROTO_SURVEY * 16 + 2;
  NN_RESPONDENT     = NN_PROTO_SURVEY * 16 + 3;

  NN_SURVEYOR_DEADLINE = 1;

 (* bus.h *)
  NN_PROTO_BUS = 7;
  NN_BUS       = NN_PROTO_BUS * 16 + 0;

 (******************************************************************************
  *  Socket mutliplexing support.                                              *
  ******************************************************************************)

  NN_POLLIN  = 1;
  NN_POLLOUT = 2;

  (*  Library name  *)
  NN_NAME = 'nanomsg.dll';

 (*  This function retrieves the errno as it is known to the library.          *
  *  The goal of this function is to make the code 100% portable, including    *
  *  where the library is compiled with certain CRT library (on Windows) and   *
  *  linked to an application that uses different CRT library.                 *)
  function nn_errno: NativeInt; cdecl;
    external NN_NAME name 'nn_errno' delayed;

 (*  Resolves system errors and native errors to human-readable string.        *)
  function nn_strerror(errnum: NativeInt): PAnsiChar; cdecl;
    external NN_NAME name 'nn_strerror' delayed;

 (*  Returns the symbol name (e.g. "NN_REQ") and value at a specified index.   *
  *  If the index is out-of-range, returns NULL and sets errno to EINVAL       *
  *  General usage is to start at i=0 and iterate until NULL is returned.      *)
  function nn_symbol(i: NativeInt; value: PNativeInt): PAnsiChar; cdecl;
    external NN_NAME name 'nn_symbol' delayed;

 (*  Fills in nn_symbol_properties structure and returns it's length           *
  *  If the index is out-of-range, returns 0                                   *
  *  General usage is to start at i=0 and iterate until zero is returned.      *)
  function nn_symbol_info(i: NativeInt; buf: Pnn_symbol_properties; buflen: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_symbol_info' delayed;

 (******************************************************************************
  *  Helper function for shutting down multi-threaded applications.            *
  ******************************************************************************)
  procedure nn_term; cdecl;
    external NN_NAME name 'nn_term' delayed;

 (******************************************************************************
  *  Zero-copy support.                                                        *
  ******************************************************************************)
  function nn_allocmsg(size: size_t; &type: NativeInt): Pointer; cdecl;
    external NN_NAME name 'nn_allocmsg' delayed;

  function nn_reallocmsg(msg: Pointer; size: size_t): Pointer; cdecl;
    external NN_NAME name 'nn_reallocmsg' delayed;

  function nn_freemsg(msg: Pointer): NativeInt; cdecl;
    external NN_NAME name 'nn_freemsg' delayed;

 (******************************************************************************
  *  Socket definition.                                                        *
  ******************************************************************************)

  function nn_socket(domain: NativeInt; protocol: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_socket' delayed;

  function nn_close(s: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_close' delayed;

  function nn_setsockopt(s: NativeInt; level: NativeInt; option: NativeInt;
    const optval: Pointer; optvallen: size_t): NativeInt; cdecl;
    external NN_NAME name 'nn_setsockopt' delayed;

  function nn_getsockopt(s: NativeInt; level: NativeInt; option: NativeInt;
    optval: Pointer; var optvallen: size_t): NativeInt; cdecl;
    external NN_NAME name 'nn_getsockopt' delayed;

  function nn_bind(s: NativeInt; const addr: PAnsiChar): Nativeint; cdecl;
    external NN_NAME name 'nn_bind' delayed;

  function nn_connect(s: NativeInt; const addr: PAnsiChar): NativeInt; cdecl;
    external NN_NAME name 'nn_connect' delayed;

  function nn_shutdown(s: NativeInt; how: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_shutdown' delayed;

  function nn_send(s: NativeInt; const buf: Pointer; len: size_t; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_send' delayed;

  function nn_recv(s: NativeInt; buf: Pointer; len: size_t; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_recv' delayed;

  function nn_sendmsg(s: NativeInt; const msghdr: Pnn_msghdr; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_sendmsg' delayed;

  function nn_recvmsg(s: NativeInt; msghdr: Pnn_msghdr; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_recvmsg' delayed;

 (******************************************************************************
  *  Socket mutliplexing support.                                              *
  ******************************************************************************)

  function nn_poll(fds: Pnn_pollfd; nfds: NativeInt; timeout: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_poll' delayed;

 (******************************************************************************
  *  Built-in support for devices.                                             *
  ******************************************************************************)

  function nn_device(s1: NativeInt; s2: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_device' delayed;

 (******************************************************************************
  *  Built-in support for multiplexers.                                        *
  ******************************************************************************)

  function nn_tcpmuxd(port: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_tcpmuxd' delayed;

  (* REQREP Specific *)

  function nn_req_send(s: NativeInt; hndl: Tnn_req_handle; const buf: Pointer; len: size_t; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_req_send' delayed;

  function nn_req_recv(s: NativeInt; var hndl: Tnn_req_handle; buf: Pointer; len: size_t; flags: NativeInt): NativeInt; cdecl;
    external NN_NAME name 'nn_req_recv' delayed;

  (* DEBUG / INTERNAL USE ONLY *)
  function nn_cmsg_nxthdr_ (const mhdr: Pnn_msghdr; const cmsg: Pnn_cmsghdr): Pnn_cmsghdr; cdecl;
    external NN_NAME name 'nn_cmsg_nxthdr_' delayed;

  function NN_CMSG_ALIGN_(len: size_t): size_t;
  function NN_CMSG_FIRSTHDR(mhdr: Pnn_msghdr): Pnn_cmsghdr;
  function NN_CMSG_NXTHDR(mhdr: Pnn_msghdr; cmsg: Pnn_cmsghdr): Pnn_cmsghdr;
  function NN_CMSG_DATA(cmsg: Pnn_cmsghdr): PByte;
  function NN_CMSG_SPACE(len: size_t): size_t;
  function NN_CMSG_LEN(len: size_t): size_t;

implementation

function NN_CMSG_ALIGN_(len: size_t): size_t; inline;
begin
{
  #define NN_CMSG_ALIGN_(len) \
    (((len) + sizeof (size_t) - 1) & (size_t) ~(sizeof (size_t) - 1))
}
  Result := (len + SizeOf(size_t) - 1) and size_t(not (SizeOf(size_t) - 1))
end;

function NN_CMSG_FIRSTHDR(mhdr: Pnn_msghdr): Pnn_cmsghdr; inline;
begin
  Result := nn_cmsg_nxthdr_(mhdr, nil);
end;

function NN_CMSG_NXTHDR(mhdr: Pnn_msghdr; cmsg: Pnn_cmsghdr): Pnn_cmsghdr; inline;
begin
  Result := nn_cmsg_nxthdr_(mhdr, cmsg);
end;

function NN_CMSG_DATA(cmsg: Pnn_cmsghdr): PByte; inline;
begin
  {$POINTERMATH ON}
  Result := PByte(cmsg + 1);
  {$POINTERMATH OFF}
end;

function NN_CMSG_SPACE(len: size_t): size_t; inline;
begin
  Result := NN_CMSG_ALIGN_(len) + NN_CMSG_ALIGN_(SizeOf(Tnn_cmsghdr));
end;

function NN_CMSG_LEN(len: size_t): size_t; inline;
begin
  Result := NN_CMSG_ALIGN_(SizeOf(Tnn_cmsghdr)) + len;
end;

end.
