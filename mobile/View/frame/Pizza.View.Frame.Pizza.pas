﻿unit Pizza.View.Frame.Pizza;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Objects, Pizza.View.Frame.Sabor, FMX.Ani,
  FMX.Effects, FMX.Layouts, FMX.Gestures, Math, Pizza.View.Frame.Recheio;

type
  TPizzaOrientacao = (poX, poY);
  TPizzaAnimacao = (paPosicao, paTamanho);
  TPizzaAcao = (paRetornar, paAvancar, paInicial);
  TPizzaTamanho = (ptPequena, ptMedia, ptGrande, ptInicial);

  TArrayOfAnimacoes = Array of TPizzaAnimacao;
  TArrayOfInteger = Array of Integer;

  WebPizzaItens = record
    pizza_item_id: Integer;
    url: string;
    imagem: TBitmap;
  end;
  TArrayPizzaItens = Array of WebPizzaItens;

  WebPizzaRecheiosFrame = record
    item: TFormRecheio;
  end;
  TArrayOfWebPizzaRecheiosFrame = Array of WebPizzaRecheiosFrame;

  WebPizzaRecheios = record
    id: Integer;
    qtd_recheio: Integer;
    qtd_animacao: Integer;
    url: string;
    recheios: TArrayOfWebPizzaRecheiosFrame;
    processado: Boolean;
  end;
  TArrayOfWebPizzaRecheios = Array of WebPizzaRecheios;

  WebXY = record
    x: Integer;
    y: Integer;
  end;

  TFramePizza = class(TFrame)
    lytBgPizza: TLayout;
    lytBgFolhas: TLayout;
    imgFolha: TImage;
    lytPizza: TLayout;
    lytTabua: TLayout;
    imgTabua: TImage;
    ShadowEffect1: TShadowEffect;
    anmRotarTabua: TFloatAnimation;
    anmRotarTabuaExtra: TFloatAnimation;
    anmTabuaBottom: TFloatAnimation;
    anmTabuaBottomExtra: TFloatAnimation;
    anmTabuaTop: TFloatAnimation;
    anmTabuaTopExtra: TFloatAnimation;
    frameSabor: TFrameSabor;
    lytAdicionarRemover: TLayout;
    Layout4: TLayout;
    crcRemover: TCircle;
    btnPizzaEsquerda: TSpeedButton;
    crcAdicionar: TCircle;
    btnPizzaDireita: TSpeedButton;
    ShadowEffect3: TShadowEffect;
    GM: TGestureManager;
    anmFolhaRotar: TFloatAnimation;
    anmFolhaRotarExtra: TFloatAnimation;
    procedure btnPizzaDireitaClick(Sender: TObject);
    procedure anmTabuaBottomFinish(Sender: TObject);
    procedure anmRotarTabuaFinish(Sender: TObject);
    procedure btnPizzaEsquerdaClick(Sender: TObject);
    procedure FinalizadoAnimacao(Sender: TObject);
    procedure AndamentoAnimacao(Sender: TObject);
    procedure anmFolhaRotarFinish(Sender: TObject);
  private
    FItemId: Integer;
    FTamanhoPizzaSelecionadaAnterior: TPizzaTamanho;
    FTamanhoPizzaSelecionada: TPizzaTamanho;
    FPizzaItens: TArrayPizzaItens;
    FPizzaTela: TFrameSabor;
    FPizzaRecheios: TArrayOfWebPizzaRecheios;
    FPizzaRecheiosAnimacoes: TArrayOfAnimacoes;
    FMostrarAreaPizza: Boolean;

    procedure Organizar;
    procedure StartAnimacoesRecheios;
    procedure MoverPizza(acao: TPizzaAcao);
    procedure AnimarNovaPizza(acao: TPizzaAcao);
    function ProximoOuAnterior(id: Integer): TPizzaAcao;
    function AnimacaoAtiva(animacao: TPizzaAnimacao): Boolean;
    procedure ClearRecheio(parcial: Boolean = False);

    procedure SetTamanho(tamanho: TPizzaTamanho);
    function GetItem(id: Integer): WebPizzaItens;
    procedure SetItem(id: Integer; const Value: WebPizzaItens);
    function GetItemIndex: Integer;
    procedure SetItemIndex(const Value: Integer);
    function GetItemRecheio(id: Integer): WebPizzaRecheios;
    procedure SetItemRecheio(id: Integer; const Value: WebPizzaRecheios);
    function GetItemIndexProximo: Integer;
    function GetItemIndexAnterior: Integer;
    function GetQtdItensRecheio: Integer;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Proximo;
    procedure Anterior;
    procedure AtualizarAreaPizza;
    procedure LimparImagem;
    function MostrarAreaPizza: TFramePizza;
    function OcultarAreaPizza: TFramePizza;
    function EmExecucao(tamanho: TPizzaTamanho): Boolean;
    procedure RotacionarPizza(qtd: Integer; tempo: Double);
    function AddPizza(id: Integer; pizza_url: string; selecionar: Boolean = False): TFramePizza;

    // [pequena, media, grande]
    procedure AddRecheio(
      id: Integer;
      url: string;
      qtd: Integer;
      wid: Integer;
      hei: Integer;
      diminuir_raio_porc: TArrayOfInteger;
      animacoes: TArrayOfAnimacoes;
      primeiro_centro: Boolean;
      rotacionar: Boolean
    );

    property FrmSelecionado: TFrameSabor read FPizzaTela;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex;
    property ItemIndexProximo: Integer read GetItemIndexProximo;
    property ItemIndexAnterior: Integer read GetItemIndexAnterior;
    property Item[id: Integer]: WebPizzaItens read GetItem write SetItem;
    property ItemRecheio[id: Integer]: WebPizzaRecheios read GetItemRecheio write SetItemRecheio;
    property ItensRecheio: TArrayOfWebPizzaRecheios read FPizzaRecheios;
    property QtdItensRecheio: Integer read GetQtdItensRecheio;
    property TamanhoSelecionado: TPizzaTamanho read FTamanhoPizzaSelecionada write SetTamanho;
  end;

implementation

{$R *.fmx}

uses Pizza.Librarys.Biblioteca;

function TFramePizza.AddPizza(id: Integer; pizza_url: string; selecionar: Boolean = False): TFramePizza;
var
  stream: TStream;
  i: Integer;
  posic_existente: Integer;
begin
  if pizza_url <> '' then begin
    posic_existente := -1;
    for i := Low(FPizzaItens) to High(FPizzaItens) do begin
      if FPizzaItens[i].pizza_item_id <> id then
        Continue;

      posic_existente := i;
      FPizzaItens[i].imagem.Free;
      Break;
    end;

    if posic_existente = -1 then begin
      SetLength(FPizzaItens, Length(FPizzaItens) + 1);
      posic_existente := High(FPizzaItens);
    end;

    FPizzaItens[posic_existente].pizza_item_id := id;
    FPizzaItens[posic_existente].url := pizza_url;

    stream := Pizza.Librarys.Biblioteca.CarregarStreamURL(pizza_url);
    if stream <> nil then begin
      FPizzaItens[posic_existente].imagem := TBitmap.Create;
      FPizzaItens[posic_existente].imagem.LoadFromStream(stream);
    end;
    stream.Free;

    if selecionar then
      ItemIndex := id;
  end;

  Result := Self;
end;

procedure TFramePizza.AndamentoAnimacao(Sender: TObject);
begin
  //AtualizarAreaPizza;
end;

function TFramePizza.AnimacaoAtiva(animacao: TPizzaAnimacao): Boolean;
var
  k: Integer;
begin
  Result := False;
  for k := Low(FPizzaRecheiosAnimacoes) to High(FPizzaRecheiosAnimacoes) do begin
    if FPizzaRecheiosAnimacoes[k] <> animacao then
      Continue;

    Result := True;
    Break;
  end;
end;

procedure TFramePizza.AnimarNovaPizza(acao: TPizzaAcao);
var
  nova_pizza: TFrameSabor;

  function GerarNomePizza: string;
  begin
    repeat
      Result := 'frmPizza' + IntToStr(Random(99));
    until Result <> FPizzaTela.Name;
  end;
begin
  if FItemId = -1 then
    Exit;

  nova_pizza := TFrameSabor.Create(Application);
  nova_pizza.Name := GerarNomePizza;
  nova_pizza
    .SlidePizzaNova(TPizzaSaborAcao(acao), FPizzaTela)
    .Imagem(Item[FItemId].imagem)
    .Start;

  anmRotarTabua.StartValue := anmRotarTabua.StopValue;
  anmRotarTabua.StopValue := anmRotarTabua.StartValue + IIfInt(acao = paAvancar, 30, -30);
  anmRotarTabuaExtra.StartValue := anmRotarTabua.StopValue;
  anmRotarTabuaExtra.StopValue := anmRotarTabuaExtra.StartValue + IIfInt(acao = paAvancar, 5, -5);
  anmRotarTabua.Duration := 0.1;
  anmRotarTabua.Start;

  anmFolhaRotar.StartValue := anmFolhaRotar.StopValue;
  anmFolhaRotar.StopValue := anmFolhaRotar.StartValue + IIfInt(acao = paAvancar, 30, -30);
  anmFolhaRotarExtra.StartValue := anmFolhaRotar.StopValue;
  anmFolhaRotarExtra.StopValue := anmFolhaRotarExtra.StartValue + IIfInt(acao = paAvancar, 5, -5);
  anmFolhaRotar.Duration := 0.1;
  anmFolhaRotar.Start;

  FPizzaTela.SlidePizzaAnterior(TPizzaSaborAcao(acao)).Start;
  FPizzaTela := nova_pizza;

  FPizzaTela.rctSaborArea.Visible := FMostrarAreaPizza;

  SetTamanho(FTamanhoPizzaSelecionada);
end;

procedure TFramePizza.SetTamanho(tamanho: TPizzaTamanho);
var
  tamanho_tabua: Integer;
  tamanho_animacao: Integer;
  tamanho_sabor: Integer;
  tamanho_sabor_lateral: Integer;
begin
  anmTabuaTop.StartValue := anmTabuaBottom.StopValue;
  anmTabuaBottom.StartValue := anmTabuaBottom.StopValue;

  FPizzaTela.anmPizzaTop.StartValue := FPizzaTela.anmPizzaBottom.StopValue;
  FPizzaTela.anmPizzaBottom.StartValue := FPizzaTela.anmPizzaBottom.StopValue;

  if tamanho = ptPequena then begin
    tamanho_tabua := 40;
    tamanho_animacao := 32;
    tamanho_sabor := 35;
    tamanho_sabor_lateral := 70;
  end
  else if tamanho = ptMedia then begin
    tamanho_tabua := 20;
    tamanho_animacao := 15;
    tamanho_sabor := 18;
    tamanho_sabor_lateral := 35;
  end
  else begin
    tamanho_tabua := 0;
    tamanho_animacao := -2;
    tamanho_sabor := 0;
    tamanho_sabor_lateral := 0;
  end;

  FTamanhoPizzaSelecionadaAnterior := FTamanhoPizzaSelecionada;
  FTamanhoPizzaSelecionada := tamanho;

  anmTabuaTop.StopValue := tamanho_tabua;
  anmTabuaBottom.StopValue := tamanho_tabua;

  FPizzaTela.anmPizzaTop.StopValue := tamanho_animacao;
  FPizzaTela.anmPizzaBottom.StopValue := tamanho_animacao;

  FPizzaTela.anmSaborTop.StartValue := FPizzaTela.anmSaborTop.StopValue;
  FPizzaTela.anmSaborBottom.StartValue := FPizzaTela.anmSaborBottom.StopValue;
  FPizzaTela.anmSaborLeft.StartValue := FPizzaTela.anmSaborLeft.StopValue;
  FPizzaTela.anmSaborRight.StartValue := FPizzaTela.anmSaborRight.StopValue;

  FPizzaTela.anmSaborTop.StopValue := tamanho_sabor;
  FPizzaTela.anmSaborBottom.StopValue := tamanho_sabor;
  FPizzaTela.anmSaborLeft.StopValue := tamanho_sabor_lateral;
  FPizzaTela.anmSaborRight.StopValue := tamanho_sabor_lateral;

  anmTabuaTopExtra.StartValue := anmTabuaTop.StopValue;
  anmTabuaTopExtra.StopValue := anmTabuaTop.StopValue + IIfInt(FTamanhoPizzaSelecionada > FTamanhoPizzaSelecionadaAnterior, -2, 2);
  anmTabuaBottomExtra.StartValue := anmTabuaTopExtra.StartValue;
  anmTabuaBottomExtra.StopValue := anmTabuaTopExtra.StopValue;

  anmTabuaTopExtra.AutoReverse := True;
  anmTabuaBottomExtra.AutoReverse := True;

  FPizzaTela.anmSaborTop.Start;
  FPizzaTela.anmSaborBottom.Start;
  FPizzaTela.anmSaborLeft.Start;
  FPizzaTela.anmSaborRight.Start;

  if FTamanhoPizzaSelecionada <> FTamanhoPizzaSelecionadaAnterior then begin
    anmTabuaTop.Start;
    anmTabuaBottom.Start;
    FPizzaTela.anmPizzaTop.Start;
    FPizzaTela.anmPizzaBottom.Start;
  end;

  AtualizarAreaPizza;
end;

procedure TFramePizza.anmFolhaRotarFinish(Sender: TObject);
begin
  anmFolhaRotarExtra.Start;
end;

procedure TFramePizza.anmRotarTabuaFinish(Sender: TObject);
begin
  anmRotarTabuaExtra.Start;
end;

procedure TFramePizza.anmTabuaBottomFinish(Sender: TObject);
begin
  anmTabuaTopExtra.Start;
  anmTabuaBottomExtra.Start;
end;

procedure TFramePizza.Anterior;
begin
  if FPizzaItens = nil then
    Exit;

  FItemId := ItemIndexAnterior;
end;

procedure TFramePizza.AtualizarAreaPizza;
begin
  Self.BeginUpdate;
  if Self.Width - 30 > FPizzaTela.Height then begin
    FPizzaTela.lytSabor.Width := FPizzaTela.Height;
    FPizzaTela.lytSabor.Height := FPizzaTela.Height;
  end
  else begin
    FPizzaTela.lytSabor.Width := Self.Width - 30;
    FPizzaTela.lytSabor.Height := Self.Width - 30;
  end;
  Self.EndUpdate;
end;

procedure TFramePizza.btnPizzaDireitaClick(Sender: TObject);
begin
  MoverPizza(paAvancar);
end;

procedure TFramePizza.btnPizzaEsquerdaClick(Sender: TObject);
begin
  MoverPizza(paRetornar);
end;

procedure TFramePizza.LimparImagem;
begin
  FPizzaTela.Imagem(nil);
end;

procedure TFramePizza.ClearRecheio(parcial: Boolean = False);
var
  i: Integer;
  k: Integer;
begin
  for i := Low(FPizzaRecheios) to High(FPizzaRecheios) do begin
    with FPizzaRecheios[i] do begin
      for k := Low(recheios) to High(recheios) do
        recheios[k].item.Free;

      SetLength(FPizzaRecheios[i].recheios, 0);
    end;
  end;

  if not parcial then
    FPizzaRecheios := nil;
end;

constructor TFramePizza.Create(AOwner: TComponent);
begin
  inherited;
  FPizzaRecheios := nil;
  FTamanhoPizzaSelecionada := ptInicial;
  FPizzaTela := frameSabor;
  FItemId := -1;
  FPizzaTela.Imagem(nil);
  frameSabor.imgPizza.Bitmap.Assign(nil);
  FMostrarAreaPizza := False;
end;

procedure TFramePizza.AddRecheio(
  id: Integer;
  url: string;
  qtd: Integer;
  wid: Integer;
  hei: Integer;
  diminuir_raio_porc: TArrayOfInteger;
  animacoes: TArrayOfAnimacoes;
  primeiro_centro: Boolean;
  rotacionar: Boolean
);
var
  i: Integer;
  recheio: TFormRecheio;
  aleatorioX: Integer;
  aleatorioY: Integer;
  raio_pizza: Integer;
  raio_pizza_: Integer;
  raio_recheio_x: Integer;
  raio_recheio_y: Integer;
  imagem: TStream;
  num_sorteado: Integer;
  valor_raio_diminuido: Integer;


  function SortearNumero(orientacao: TPizzaOrientacao): Integer;
  begin
    num_sorteado := Random(200);
    num_sorteado := num_sorteado + IIfInt(orientacao = poX, Round(Screen.Width), Round(Screen.Height));
    num_sorteado := num_sorteado * IIfInt(num_sorteado mod 2 = 0, -1, 1);
    Result := Round(num_sorteado);
  end;

  function PosicaoDentroDaPizza(baseX, baseY, novoX, novoY: Integer; raio: Integer): Boolean;
  begin
    Result := (Round(sqrt((Power(baseX - novoX, 2) + Power(baseY - novoY, 2)))) <= raio); // (x - xc)² + (y + yc)² - r²
  end;

  procedure SotearPosicaoXY;
  begin
    repeat
      aleatorioX := Random((raio_pizza * 2) - valor_raio_diminuido);
      aleatorioY := Random((raio_pizza * 2) - valor_raio_diminuido);
    until PosicaoDentroDaPizza((aleatorioX - raio_pizza_), (aleatorioY - raio_pizza_), 0, 0, raio_pizza_);
  end;

  procedure SalvarItemRecheio(item_recheio: TFormRecheio);
  var
    k: Integer;
    posic: Integer;
  begin
    posic := -1;
    for k := Low(FPizzaRecheios) to High(FPizzaRecheios) do begin
      if FPizzaRecheios[k].id <> id then
        Continue;

      posic := k;
      Break;
    end;

    if posic = -1 then begin
      SetLength(FPizzaRecheios, Length(FPizzaRecheios) + 1);
      posic := High(FPizzaRecheios);
      FPizzaRecheios[posic].qtd_recheio := FPizzaRecheios[posic].qtd_recheio + 1;
    end;

    FPizzaRecheios[posic].id := id;
    FPizzaRecheios[posic].qtd_animacao := qtd;
    FPizzaRecheios[posic].processado := false;
    FPizzaRecheios[posic].qtd_animacao := FPizzaRecheios[posic].qtd_animacao + qtd;

    with FPizzaRecheios[posic] do begin
      SetLength(recheios, Length(recheios) + 1);
      recheios[High(recheios)].item := item_recheio;
    end;
  end;

  function GerarNomeRecheio: string;
  var
    nome_gerado: string;
    y: Integer;
    z: Integer;
    nome_existente: Boolean;
  begin
    repeat
      nome_gerado := 'frmRecheio' + IntToStr(id) + IntToStr(Random(99999));

      nome_existente := False;
      for y := Low(FPizzaRecheios) to High(FPizzaRecheios) do begin
        if FPizzaRecheios[y].id <> id then
          Continue;

        with FPizzaRecheios[y] do begin
          for z := Low(recheios) to High(recheios) do begin
            if recheios[z].item.Name <> nome_gerado then
              Continue;

            nome_existente := True;
            Break
          end;
        end;
      end;

    until not nome_existente;

    Result := nome_gerado;
  end;
begin
  FPizzaRecheiosAnimacoes := animacoes;
  imagem := nil;

  raio_recheio_x := Round(Porcento(hei, Round(FPizzaTela.lytSaborBase.Height)) / 2);
  raio_recheio_y := Round(Porcento(wid, Round(FPizzaTela.lytSaborBase.Height)) / 2);

  raio_pizza := Round(FPizzaTela.lytSaborBase.Width / 2);
  valor_raio_diminuido := Porcento(diminuir_raio_porc[Integer(FTamanhoPizzaSelecionada)], raio_pizza);
  raio_pizza_ := raio_pizza - valor_raio_diminuido;

  for i := 1 to qtd do begin
    recheio := TFormRecheio.Create(Application);
    recheio.Name := GerarNomeRecheio;
    recheio.Parent := FPizzaTela.lytSaborBase;
    recheio.Align := TAlignLayout.Scale;
    SotearPosicaoXY;

    if primeiro_centro then begin
      aleatorioX := raio_pizza - raio_recheio_x;
      aleatorioY := raio_pizza - raio_recheio_y;
      primeiro_centro := False;
    end;

    recheio.Position.X := aleatorioX - raio_recheio_x + valor_raio_diminuido;
    recheio.Position.y := aleatorioY - raio_recheio_y + valor_raio_diminuido;
    recheio.Height := Porcento(hei, Round(FPizzaTela.lytSaborBase.Height));
    recheio.Width := Porcento(wid, Round(FPizzaTela.lytSaborBase.Height));

    if AnimacaoAtiva(paPosicao) then begin
      recheio.anmPosicaoX.StartValue  := SortearNumero(poX);
      recheio.anmPosicaoX.StopValue  := recheio.Position.X;
      recheio.anmPosicaoY.StartValue  := SortearNumero(poY);
      recheio.anmPosicaoY.StopValue  := recheio.Position.y;
      recheio.anmPosicaoX.OnFinish := FinalizadoAnimacao;
      recheio.anmPosicaoX.OnProcess := AndamentoAnimacao;
    end;

    if AnimacaoAtiva(paTamanho) then begin
      recheio.anmHeight.StopValue := hei;
      recheio.anmHeight.StartValue := Random(500) + hei;
      recheio.anmWidth.StopValue := wid;
      recheio.anmWidth.StartValue := Random(500) + wid;
    end;

    if imagem <> nil then
      recheio.imgRecheio.Bitmap.LoadFromStream(imagem)
    else begin
      imagem := CarregarStreamURL(url);

      if imagem.Size > 0 then begin
        imagem.Position := 0;
        recheio.imgRecheio.Bitmap.LoadFromStream(imagem);
      end;
    end;

    if rotacionar then
      recheio.imgRecheio.RotationAngle := Random(360);

    recheio.imgRecheio.Visible := animacoes = nil;

    Organizar;
    SalvarItemRecheio(recheio);

    if animacoes <> nil then
      StartAnimacoesRecheios;
  end;

  imagem.Free;
end;

function TFramePizza.OcultarAreaPizza: TFramePizza;
begin
  FMostrarAreaPizza := False;
  FPizzaTela.rctSaborArea.Visible := FMostrarAreaPizza;
  Result := Self;
end;

procedure TFramePizza.Organizar;
begin
  FPizzaTela.lytSabor.BringToFront;
  lytAdicionarRemover.BringToFront;
  FPizzaTela.SendToBack;
  lytTabua.SendToBack;
end;

destructor TFramePizza.Destroy;
var
  i: Integer;
begin
  for i := Low(FPizzaItens) to High(FPizzaItens) do
    FPizzaItens[i].imagem.Free;
  inherited;
end;

function TFramePizza.GetItem(id: Integer): WebPizzaItens;
var
  i: Integer;
begin
  Result := Default(WebPizzaItens);

  for i := Low(FPizzaItens) to High(FPizzaItens) do begin
    if FPizzaItens[i].pizza_item_id <> id then
      Continue;

    Result := FPizzaItens[i];
    Break;
  end;
end;

function TFramePizza.GetItemIndex: Integer;
begin
  Result := FItemId;
end;

function TFramePizza.GetItemIndexAnterior: Integer;
var
  i: Integer;
begin
  Result := -1;

  if FPizzaItens = nil then
    Exit;

  if FItemId = -1 then begin
    Result := FPizzaItens[Low(FPizzaItens)].pizza_item_id;
    Exit;
  end;

  for i := Low(FPizzaItens) to High(FPizzaItens) do begin
    if FPizzaItens[i].pizza_item_id <> FItemId then
      Continue;

    if i = Low(FPizzaItens) then
      Result := FPizzaItens[High(FPizzaItens)].pizza_item_id
    else
      Result := FPizzaItens[i - 1].pizza_item_id;

    Break;
  end;
end;

function TFramePizza.GetItemIndexProximo: Integer;
var
  i: Integer;
begin
  Result := -1;

  if FPizzaItens = nil then
    Exit;

  if FItemId = -1 then begin
    Result := FPizzaItens[Low(FPizzaItens)].pizza_item_id;
    Exit;
  end;

  for i := Low(FPizzaItens) to High(FPizzaItens) do begin
    if FPizzaItens[i].pizza_item_id <> FItemId then
      Continue;

    if i = High(FPizzaItens) then
      Result := FPizzaItens[Low(FPizzaItens)].pizza_item_id
    else
      Result := FPizzaItens[i + 1].pizza_item_id;

    Break;
  end;
end;

function TFramePizza.GetItemRecheio(id: Integer): WebPizzaRecheios;
var
  i: Integer;
begin
  Result := Default(WebPizzaRecheios);

  for i := Low(FPizzaRecheios) to High(FPizzaRecheios) do begin
    if FPizzaRecheios[i].id <> id then
      Continue;

    Result := FPizzaRecheios[i];
    Break;
  end;
end;

function TFramePizza.GetQtdItensRecheio: Integer;
var
  i: Integer;
begin
  Result := 0;
  for i := Low(FPizzaRecheios) to High(FPizzaRecheios) do
    Result := Result + 1;
end;

function TFramePizza.MostrarAreaPizza: TFramePizza;
begin
  FMostrarAreaPizza := True;
  FPizzaTela.rctSaborArea.Visible := FMostrarAreaPizza;
  Result := Self;
end;

procedure TFramePizza.MoverPizza(acao: TPizzaAcao);
begin
  ClearRecheio;

  if not FPizzaTela.AnimacaoAtiva then begin
    if acao = TPizzaAcao.paRetornar then
      Anterior
    else if acao = TPizzaAcao.paAvancar then
      Proximo;

    AnimarNovaPizza(acao);
  end;
end;

procedure TFramePizza.Proximo;
begin
  if FPizzaItens = nil then
    Exit;

  FItemId := ItemIndexProximo;
end;

function TFramePizza.ProximoOuAnterior(id: Integer): TPizzaAcao;
begin
  if id < FItemId then
    Result := paRetornar
  else
    Result := paAvancar;

  FItemId := id;
end;

procedure TFramePizza.StartAnimacoesRecheios;
var
  i: Integer;
  z: Integer;
begin
  for i := Low(FPizzaRecheios) to High(FPizzaRecheios) do begin
    if FPizzaRecheios[i].processado then
      Continue;

    with FPizzaRecheios[i] do begin
      for z := Low(recheios) to High(recheios) do begin
        with recheios[z].item do begin
          if AnimacaoAtiva(paPosicao) then begin
            anmPosicaoX.Start;
            anmPosicaoY.Start;
          end;

          if AnimacaoAtiva(paTamanho) then begin
            anmHeight.Start;
            anmWidth.Start;
          end;

          imgRecheio.Visible := True;
        end;
      end;
    end;
  end;
end;

procedure TFramePizza.RotacionarPizza(qtd: Integer; tempo: Double);
begin
  anmRotarTabua.StartValue := imgTabua.RotationAngle;
  anmRotarTabua.StopValue := imgTabua.RotationAngle + qtd;
  anmRotarTabuaExtra.StartValue := anmRotarTabua.StopValue;
  anmRotarTabuaExtra.StopValue := anmRotarTabua.StopValue;
  anmRotarTabua.Duration := tempo;

  FPizzaTela.anmPizzaRotar.StartValue := FPizzaTela.imgPizza.RotationAngle;
  FPizzaTela.anmPizzaRotar.StopValue := FPizzaTela.imgPizza.RotationAngle + qtd;
  FPizzaTela.anmPizzaRotar.Duration := tempo;

  anmRotarTabua.Start;
  FPizzaTela.anmPizzaRotar.Start;
end;

procedure TFramePizza.SetItem(id: Integer; const Value: WebPizzaItens);
begin
  FPizzaItens[id] := Value;
end;

procedure TFramePizza.SetItemIndex(const Value: Integer);
begin
  if FPizzaItens = nil then
    Exit;

  AnimarNovaPizza(ProximoOuAnterior(Value));
end;

procedure TFramePizza.SetItemRecheio(id: Integer; const Value: WebPizzaRecheios);
begin
  FPizzaRecheios[id] := Value;
end;

function TFramePizza.EmExecucao(tamanho: TPizzaTamanho): Boolean;
begin
  Result :=
    (FTamanhoPizzaSelecionada = tamanho) or
    (anmTabuaTopExtra.Running) or
    (anmTabuaTop.Running) or
    (anmTabuaBottom.Running) or
    (anmTabuaBottomExtra.Running);
end;

procedure TFramePizza.FinalizadoAnimacao(Sender: TObject);
var
  bmp: TBitmap;
  visivel_area_recheio: Boolean;
begin
  visivel_area_recheio := FPizzaTela.rctSaborArea.Visible;
  FPizzaTela.rctSaborArea.Visible := False;

  bmp := TBitmap(FPizzaTela.lytSaborBase.MakeScreenshot);
  FPizzaTela.imgSabor.Bitmap.Assign(bmp);
  bmp.Free;

  FPizzaTela.rctSaborArea.Visible := visivel_area_recheio;
  ClearRecheio(True);
end;

end.
