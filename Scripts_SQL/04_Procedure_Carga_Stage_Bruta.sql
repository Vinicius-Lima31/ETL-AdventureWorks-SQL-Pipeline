USE Stage_Custo;

CREATE OR ALTER PROCEDURE Carrega_Custo_Bruto
AS
BEGIN
	-- Dados para LOG
	DECLARE @nome VARCHAR(100) = 'CARGA_TbImp_Custo_Bruto';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

BEGIN TRY
	-- Limpando STAGE
	TRUNCATE TABLE TbImp_Custo_Bruto;

	-- Carga de dados da Origem para Stage de Tratamento
	INSERT INTO TbImp_Custo_Bruto (
		nomeProduto,
		numeroProduto,
		corProduto,
		custoPadrao,
		pesoProduto,
		linhaProduto,
		categoriaProduto,
		numeroEmpresa,
		nomeEmpresa,
		creditoEmpresa,
		metodoEnvio,
		[data],
		imposto,
		frete,
		quantidade,
		valorUnitario,
		valorTotal,
		quantidadeRecebida
	)
	SELECT
		nomeProduto,
		numeroProduto,
		corProduto,
		custoPadrao,
		pesoProduto,
		linhaProduto,
		categoriaProduto,
		numeroEmpresa,
		nomeEmpresa,
		creditoEmpresa,
		metodoEnvio,
		[data],
		imposto,
		frete,
		quantidade,
		valorUnitario,
		valorTotal,
		quantidadeRecebida
		
	FROM AdventureWorks2012..vwCustoBruto

	-- Sucesso
	SET @linhas = @@ROWCOUNT;
	SET @mensagemSuceso = 'SUCESSO! Carga feita em TbImp_Custo_Bruto com exito!'
	SET @fim = GETDATE();

	-- Adicionando informações a LOG
	INSERT INTO log_CustoBruto_stg (
		nomeProcesso, dataHoraInicio ,dataHoraFim, [status], QtdLinhasAfetadas, duracao, detalheExecucao
	)
	VALUES (
		@nome, 
		@inicio,
		@fim,
		'SUCESSO',
		@linhas,
		DATEDIFF(SECOND, @inicio, @fim),
		@mensagemSuceso
	)
	
END TRY
BEGIN CATCH
	-- Falha
	SET @fim = GETDATE();
	SET @linhas = 0;
	SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	
	-- Adicionando informações a LOG
	INSERT INTO log_CustoBruto_stg (
		nomeProcesso, dataHoraInicio ,dataHoraFim, [status], QtdLinhasAfetadas, duracao, detalheExecucao
	)
	VALUES (
		@nome, 
		@inicio,
		@fim,
		'FALHA',
		@linhas,
		DATEDIFF(SECOND, @inicio, @fim),
		@erroMensagem
	);
	THROW
END CATCH

END

EXEC Carrega_Custo_Bruto