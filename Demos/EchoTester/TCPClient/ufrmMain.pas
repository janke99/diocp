unit ufrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, 
  ExtCtrls, Sockets;

type
  TfrmMain = class(TForm)
    edtIP: TEdit;
    btnC_01: TButton;
    btnSendJSonStreamObject: TButton;
    btnCloseSocket: TButton;
    edtPort: TEdit;
    mmoLog: TMemo;
    btnEchoTester: TButton;
    edtCount: TEdit;
    btnStopEcho: TButton;
    btnSend100: TButton;
    lblEchoINfo: TLabel;
    tmrEchoTester: TTimer;
    btnConnect: TButton;
    edtConnectCounter: TEdit;
    TcpClient: TTcpClient;
    procedure btnCloseSocketClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnC_01Click(Sender: TObject);
    procedure btnEchoTesterClick(Sender: TObject);
    procedure btnKasiClick(Sender: TObject);
    procedure btnSend100Click(Sender: TObject);
    procedure btnSendJSonStreamObjectClick(Sender: TObject);
    procedure btnStopEchoClick(Sender: TObject);
    procedure tmrEchoTesterTimer(Sender: TObject);
  private
    { Private declarations }
    FTesterList: TList;
    procedure ClearTester;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  ComObj, superobject, uMemoLogger,
  uEchoTester, uSocketTools, JSonStream, IdGlobal, uNetworkTools,
  uTcpClientJSonStreamCoder;

{$R *.dfm}

constructor TfrmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FTesterList := TList.Create();

end;

destructor TfrmMain.Destroy;
begin
  ClearTester;
  FreeAndNil(FTesterList);
  inherited Destroy;
end;

procedure TfrmMain.btnCloseSocketClick(Sender: TObject);
begin
  TcpClient.Disconnect;
end;

procedure TfrmMain.btnConnectClick(Sender: TObject);
var
  lvTCPClient:TTCPClient;
  i:Integer;
begin
  for i := 0 to StrToInt(edtConnectCounter.Text) - 1 do
  begin
    lvTCPClient := TTCPClient.Create(Self);
    lvTCPClient.RemoteHost := edtIP.Text;
    lvTCPClient.RemotePort := edtPort.Text;
    lvTCPClient.Connect;
  end;

  ;
end;

procedure TfrmMain.btnC_01Click(Sender: TObject);
begin
  TcpClient.Disconnect;
  TcpClient.RemoteHost := edtIP.Text;
  TcpClient.RemotePort := edtPort.Text;
  TcpClient.Connect;
end;

procedure TfrmMain.btnEchoTesterClick(Sender: TObject);
var
  lvEchoTester:TEchoTester;
  i:Integer;
begin
  __tester_terminate := 0;
  for I := 1 to StrToInt(edtCount.Text) do
  begin
    lvEchoTester := TEchoTester.Create;
    lvEchoTester.EchoCode := IntToStr(i);
    lvEchoTester.Client.RemoteHost := edtIP.Text;
    lvEchoTester.Client.RemotePort := edtPort.Text;
    lvEchoTester.Resume;
    FTesterList.Add(lvEchoTester);
  end;

end;

procedure TfrmMain.btnKasiClick(Sender: TObject);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:String;
  l, j, x:Integer;
begin
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 2000;   //卡死逻辑
    lvJSonStream.JSon.S['data'] := '测试发送打包数据';
    lvJSonStream.JSon.S['key'] := CreateClassID;


    TTcpClientJSonStreamCoder.Encode(self.TcpClient, lvJSonStream);

    TMemoLogger.infoMsg('数据发送成功！', mmoLog.Lines);
    lvRecvObject := TJsonStream.Create;
    try
      // TMemoLogger.infoMsg('数据接收成功！', mmoLog.Lines);
      TTcpClientJSonStreamCoder.Decode(self.TcpClient, lvRecvObject);
      
      TMemoLogger.infoMsg('==============================================' + sLineBreak
        + lvRecvObject.JSon.AsJSon(True)
        , mmoLog.Lines);
    finally
       lvRecvObject.Free;
    end;
  finally
    lvJSonStream.Free;
  end;

end;

procedure TfrmMain.btnSend100Click(Sender: TObject);
var
  i:Integer;
begin
  for i := 0 to 100 - 1 do
  begin
    btnSendJSonStreamObject.Click;
  end;
    
end;

procedure TfrmMain.btnSendJSonStreamObjectClick(Sender: TObject);
var
  lvJSonStream, lvRecvObject:TJsonStream;
  lvStream:TStream;
  lvData:String;
  l, j, x:Integer;
begin
  lvJSonStream := TJsonStream.Create;
  try
    lvJSonStream.JSon := SO();
    lvJSonStream.JSon.I['cmdIndex'] := 1000;   //echo 数据测试
    lvJSonStream.JSon.S['data'] := '测试发送打包数据';
    lvJSonStream.JSon.S['key'] := CreateClassID;
    lvStream := lvJSonStream.Stream;

    SetLength(lvData, 1024 * 1);
    FillChar(lvData[1], 1024 * 1, Ord('1'));
    lvStream.WriteBuffer(lvData[1], Length(lvData));

    TTcpClientJSonStreamCoder.Encode(self.TCPClient, lvJSonStream);

    TMemoLogger.infoMsg('数据发送成功！', mmoLog.Lines);
    lvRecvObject := TJsonStream.Create;
    try
      // TMemoLogger.infoMsg('数据接收成功！', mmoLog.Lines);
      TTcpClientJSonStreamCoder.Decode(self.TCPClient, lvRecvObject);
      
      TMemoLogger.infoMsg('==============================================' + sLineBreak
        + lvRecvObject.JSon.AsJSon(True)
        , mmoLog.Lines);
    finally
       lvRecvObject.Free;
    end;
  finally
    lvJSonStream.Free;
  end;   
end;

procedure TfrmMain.btnStopEchoClick(Sender: TObject);
begin
  ClearTester;
end;

procedure TfrmMain.ClearTester;
var
  i:Integer;
begin
  __tester_terminate := 1;
  for i := 0 to FTesterList.Count - 1 do
  begin
    TEchoTester(FTesterList[i]).Terminate;
    TEchoTester(FTesterList[i]).WaitFor;
    TEchoTester(FTesterList[i]).Free;
  end;
  FTesterList.Clear;
end;

procedure TfrmMain.tmrEchoTesterTimer(Sender: TObject);
begin
  lblEchoINfo.Caption :=
                         Format('发送次数:%d', [__sendCount]) + sLineBreak +
                         Format('接收次数:%d', [__recvCount]) + sLineBreak +
                         Format('接收错误次数:%d', [__recvErrCount]) + sLineBreak +
                         Format('工作线程数:%d', [__threadCount]) + sLineBreak +
                         Format('最大Echo时间:%d ms', [__maxTime]) + sLineBreak


//                         Format('接收/发送对象个数:%d/%d', [__recvObjectCount, __sendObjectCount]) + sLineBreak +
//                         Format('接收/发送字节数:%d/%d', [__recvbytes_size, __sendbytes_size]) + sLineBreak
                         ;

end;

end.
