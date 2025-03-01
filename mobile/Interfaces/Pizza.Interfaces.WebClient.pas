unit Pizza.Interfaces.WebClient;

interface

uses
  REST.Client,
  REST.Types,
  System.Classes,
  System.SysUtils,
  System.JSON,
  Pizza.Interfaces.WebClientType;

type
  TWebClient = class
  private
    FRestClient: TRESTClient;
    FRestRequest: TRESTRequest;
    FRequestMethod: TRESTRequestMethod;
    FUri: string;
    FBaseUrl: string;
    FPrefix: string;
    FEncodeAllParameters: TWebClientEncodeAllParameters;
    FAcceptCharset: string;
    FAcceptEncoding: string;
    FContentType: string;
    FRequestStatus: Integer;
    FErro: TWebClientErro;
    FPreResponseErro: string;

    procedure DefaultSettingWebClient;
    procedure SetUpPath;
    procedure CheckError;

    function GetStatusCode: Integer;
    function GetResponseStringJSON: string;
    function GetResponse: string;
    function GetResponseJSONObject: TJSONObject;
    function GetResponseJSONArray: TJSONArray;
    function GetParToken: string;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    property RestClient: TRESTClient read FRestClient write FRestClient;
    property RestRequest: TRESTRequest read FRestRequest write FRestRequest;
    property StatusCode: Integer read GetStatusCode;
    property Erro: TWebClientErro read FErro write FErro;

    property ParToken: string read GetParToken;

    property Response: string read GetResponse;
    property ResponseStringJSON: string read GetResponseStringJSON;
    property ResponseJSONObject: TJSONObject read GetResponseJSONObject;
    property ResponseJSONArray: TJSONArray read GetResponseJSONArray;

    function Delete(const caminho: string = ''): TWebClient;
    function Get(const caminho: string = ''): TWebClient;
    function Patch(const caminho: string = ''): TWebClient;
    function Post(const caminho: string = ''): TWebClient;
    function Put(const caminho: string = ''): TWebClient;

    function BaseUrl(const base_url: string): TWebClient;
    function Prefix(const prefixo_url: string): TWebClient;
    function Uri(const uri: string): TWebClient;
    function Resource(const resource: string): TWebClient;
    function PreResponseErro(const resposta_erro: string): TWebClient;

    function AcceptCharset(const accept_charset: string): TWebClient;
    function AcceptEncoding(const accept_encoding: string): TWebClient;
    function ContentType(const content_type: string): TWebClient;

    function Token(token: string): TWebClient;

    function EncodeAllParameters(tipo_encode: TWebClientEncodeAllParameters): TWebClient;

    function AddParameter(
      nome: string; valor: string;
      tipo_parametro: TWebClientRequestParameterKind;
      encodar_parametro: Boolean = True
    ): TWebClient;

    function AddQuery(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddCookie(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddHeader(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddBody(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddGetOrPost(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddFile(nome: string; valor: string; encodar: Boolean = True): TWebClient;
    function AddUrlSegment(nome: string; valor: string; encodar: Boolean = True): TWebClient;

    function ClearParameters: TWebClient;

    function Execute: TWebClientErro;
    function Send: TWebClientErro;
  end;

implementation

{ TWebClient }

function TWebClient.AcceptCharset(const accept_charset: string): TWebClient;
begin
  FAcceptCharset := accept_charset;
  Result := Self;
end;

function TWebClient.AcceptEncoding(const accept_encoding: string): TWebClient;
begin
  FAcceptEncoding := accept_encoding;
  Result := Self;
end;

function TWebClient.AddBody(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkREQUESTBODY, encodar);
  Result := Self;
end;

function TWebClient.AddCookie(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkCOOKIE, encodar);
  Result := Self;
end;

function TWebClient.AddFile(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkFILE, encodar);
  Result := Self;
end;

function TWebClient.AddGetOrPost(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkGETorPOST, encodar);
  Result := Self;
end;

function TWebClient.AddHeader(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkHTTPHEADER, encodar);
  Result := Self;
end;

function TWebClient.AddParameter(
  nome, valor: string;
  tipo_parametro: TWebClientRequestParameterKind;
  encodar_parametro: Boolean
): TWebClient;
  function EncodeOption(encodar: Boolean): TRESTRequestParameterOptions;
  begin
    Result := [];

    if FEncodeAllParameters <> eapDefault then begin
      if FEncodeAllParameters = eapNo then
        Result := [poDoNotEncode];
    end;

    if not encodar then
      Result := [poDoNotEncode]
    else
      Result := [];
  end;
begin
  with FRestRequest.Params.AddItem do begin
    kind := tipo_parametro;
    Name := nome;
    Value := valor;
    Options := EncodeOption(encodar_parametro);
  end;

  Result := Self;
end;

function TWebClient.AddQuery(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkQUERY, encodar);
  Result := Self;
end;

function TWebClient.AddUrlSegment(nome, valor: string; encodar: Boolean = True): TWebClient;
begin
  AddParameter(nome, valor, pkURLSEGMENT, encodar);
  Result := Self;
end;

function TWebClient.BaseUrl(const base_url: string): TWebClient;
begin
  FBaseUrl := Trim(base_url);
  Result := Self;
end;

procedure TWebClient.CheckError;
var
  obj: TJSONObject;
begin
  FErro := Default(TWebClientErro);
  try
    try
      obj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ResponseStringJSON), 0) as TJSONObject;
      FErro.error := obj.GetValue<string>('error');

      if (FErro.error = '') then
        Exit;

      FErro.has_error := True;
      FErro.title := obj.GetValue<string>('title');
      FErro.&unit := obj.GetValue<string>('unit');
      FErro.code :=  obj.GetValue<Integer>('code');
      FErro.status := THTTPStatus(StatusCode);
      FErro.&type := obj.GetValue<string>('type');
    except
    end;
  finally
    FreeAndNil(obj);
  end;
end;

function TWebClient.ClearParameters: TWebClient;
begin
  FRestRequest.Params.Clear;
  Result := Self;
end;

function TWebClient.ContentType(const content_type: string): TWebClient;
begin
  FContentType := content_type;
  Result := Self;
end;

constructor TWebClient.Create(AOwner: TComponent);
begin
  FRestClient := TRESTClient.Create(AOwner);
  FRestRequest := TRESTRequest.Create(AOwner);
  FRestRequest.Client := FRestClient;
  FRequestMethod := TRESTRequestMethod.rmGET;

  DefaultSettingWebClient;
end;

procedure TWebClient.DefaultSettingWebClient;
begin
  with FRestClient do begin
    {$IFDEF MSWINDOWS}
      BaseURL := 'http://10.4.5.101:9000/';
    {$ELSE}
      BaseURL := 'http://10.4.5.101:9000/';
    {$ENDIF}

    AcceptCharSet := 'utf-8, *; q=0.8';
    ContentType := 'application/json';
  end;

  FEncodeAllParameters := eapDefault;
  FRequestStatus := -1;
  FPreResponseErro := '';
end;

function TWebClient.Delete(const caminho: string): TWebClient;
begin
  FRequestMethod := rmDELETE;
  FUri := caminho;
  Result := Self;
end;

destructor TWebClient.Destroy;
begin
  FRestClient.Free;
  FRestRequest.Free;
end;

function TWebClient.EncodeAllParameters(tipo_encode: TWebClientEncodeAllParameters): TWebClient;
begin
  FEncodeAllParameters := tipo_encode;
  Result := Self;
end;

function TWebClient.Execute: TWebClientErro;
begin
  Result := Send;
end;

function TWebClient.Get(const caminho: string): TWebClient;
begin
  FRequestMethod := rmGET;
  FUri := caminho;
  Result := Self;
end;

function TWebClient.GetParToken: string;
var
  res: TJSONValue;
begin
  Result := '';
  res := nil;

  try
    res := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ResponseStringJSON), 0);

    if res <> nil then
      Result := res.GetValue<string>('token');
  finally
    res.Free;
  end;
end;

function TWebClient.GetResponseJSONArray: TJSONArray;
begin
  try
    Result := TJSONValue.ParseJSONValue(TEncoding.UTF8.GetBytes(ResponseStringJSON), 0) as TJSONArray;
  except
    Result := nil;
  end;
end;

function TWebClient.GetResponseJSONObject: TJSONObject;
var
  obj: TJSONObject;
begin
  obj := TJSONObject.Create;
  try
    Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ResponseStringJSON), 0) as TJSONObject;
  except
    Result := obj;
  end;
  obj.Free;
end;

function TWebClient.GetResponse: string;
begin
  if FPreResponseErro <> '' then begin
    Result := FPreResponseErro;
    Exit;
  end;

  Result := FRestRequest.Response.Content;
end;

function TWebClient.GetResponseStringJSON: string;
begin
  if FPreResponseErro <> '' then begin
    Result := FPreResponseErro;
    Exit;
  end;

  Result := FRestRequest.Response.JSONText;
end;

function TWebClient.GetStatusCode: Integer;
begin
  if FPreResponseErro <> '' then begin
    Result := 200;
    Exit;
  end;

  Result := FRestRequest.Response.StatusCode;
end;

function TWebClient.Patch(const caminho: string): TWebClient;
begin
  FRequestMethod := rmPATCH;
  FUri := caminho;
  Result := Self;
end;

function TWebClient.Post(const caminho: string): TWebClient;
begin
  FRequestMethod := rmPOST;
  FUri := caminho;
  Result := Self;
end;

function TWebClient.Prefix(const prefixo_url: string): TWebClient;
begin
  FPrefix := Trim(prefixo_url);
  Result := Self;
end;

function TWebClient.PreResponseErro(const resposta_erro: string): TWebClient;
begin
  FPreResponseErro := resposta_erro;
  Result := Self;
end;

function TWebClient.Put(const caminho: string): TWebClient;
begin
  FRequestMethod := rmPUT;
  FUri := caminho;
  Result := Self;
end;

function TWebClient.Resource(const resource: string): TWebClient;
begin
  Result := Uri(resource);
end;

function TWebClient.Send: TWebClientErro;
  procedure AddErro(
    titulo_erro: string;
    mensagem_erro: string;
    &unit: string;
    codigo_erro: Integer;
    status_code: Integer;
    &type: string
  );
  begin
    FErro.has_error := True;
    FErro.error := mensagem_erro;
    FErro.title := titulo_erro;
    FErro.&unit := &unit;
    FErro.code := codigo_erro;
    FErro.status := THTTPStatus(status_code);
    FErro.&type := &type;

    Result := FErro;
  end;
begin
  Result := Default(TWebClientErro);

  try
    SetUpPath;
    FRestRequest.Execute;

    if (StatusCode < 200) or (StatusCode > 299) then begin
      CheckError;
      Result := FErro;
    end;
  except on e: Exception do
    begin
      // Como � um projeto teste... s� pra garanti que mesmo sem o server a aplica��o funcione
      if FPreResponseErro <> '' then begin
         Result := Default(TWebClientErro);
         Exit;
      end;

      AddErro('Internal', e.Message, '', -1, StatusCode, '');
    end;
  end;
end;

procedure TWebClient.SetUpPath;
begin
  FRestClient.BaseURL := FBaseUrl;
  FRestRequest.Method := FRequestMethod;
  FRestRequest.Resource := FPrefix + FUri;
end;

function TWebClient.Token(token: string): TWebClient;
begin
  AddQuery('Authorization', 'Bearer ' + token, false);
  Result := Self;
end;

function TWebClient.Uri(const uri: string): TWebClient;
begin
  FUri := Trim(uri);
  Result := Self;
end;

end.
