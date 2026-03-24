-- PROCEDURES de Carga FATOS | Stage
USE Stage_Custos;
GO

-- Fato (Granularidade Maior)
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_FATO_CUSTO_STG]
AS

BEGIN
	TRUNCATE TABLE Stage_Custos..FATO_CUSTO;

	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_FATO_CUSTO_STAGE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	-- Determinar os PK FAKE para evitar dados NULL
	DECLARE @SK_DATA_Manual INT = ( 						-- PK fake da DIM_DATA
	SELECT SK_Data FROM DataWarehouse_Custos..DIM_DATA
	WHERE SK_Data = 0
	)

	DECLARE @ident_envio_Manual UNIQUEIDENTIFIER = (		-- PK fake da DIM_ENVIO
	SELECT ident_envio FROM DataWarehouse_Custos..DIM_ENVIO
	WHERE ident_envio = '00000000-0000-0000-0000-000000000000'
	)

	DECLARE @ident_fornecedor_Manual UNIQUEIDENTIFIER = (	-- PK fake da DIM_FORNECEDOR
	SELECT ident_fornecedor FROM DataWarehouse_Custos..DIM_FORNECEDOR
	WHERE ident_fornecedor = '00000000-0000-0000-0000-000000000000'
	)


	BEGIN TRY
	
		TRUNCATE TABLE Stage_Custos..FATO_CUSTO

		INSERT INTO Stage_Custos..FATO_CUSTO
		SELECT DISTINCT
			ISNULL(tb.comprovante, 0) AS Comprovante,
			ISNULL(df.ident_fornecedor, @ident_fornecedor_Manual) AS SK_ident_fornecedor,
			ISNULL(de.ident_envio, @ident_envio_Manual) AS SK_ident_envio,
			ISNULL(dd.SK_Data, @SK_DATA_Manual) AS SK_ident_DATA,

			tb.imposto,
			tb.frete,
			GETDATE() AS DataLinha,
			'Carga FATO_CUSTO' AS LinhaOrigem
		FROM
			Stage_Custos..TbImp_Custo_Bruto tb
		LEFT JOIN
			DataWarehouse_Custos..DIM_FORNECEDOR df
			ON tb.numeroEmpresa = df.numeroEmpresa
		LEFT JOIN
			DataWarehouse_Custos..DIM_ENVIO de
			ON tb.metodoEnvio = de.metodoEnvio
		LEFT JOIN
			DataWarehouse_Custos..DIM_DATA dd
			ON tb.data = dd.DataCompleta
			
		
		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em FATO_CUSTO(STAGE) com exito!'
		SET @fim = GETDATE();

		-- Carga com Sucesso -> LOG
		IF @linhas > 0
			BEGIN
				INSERT INTO log_CustoBruto_stg (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
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
			END
			-- Caso nenhuma linha tenha sido inserida
			ELSE
			BEGIN
				SET @erroMensagem = 'FALHA! Nenhum dado INSERIDO!'
				INSERT INTO log_CustoBruto_stg (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
				)
				VALUES (
					@nome, 
					@inicio,
					@fim,
					'FALHA',
					@linhas,
					DATEDIFF(SECOND, @inicio, @fim),
					@erroMensagem
					)

			END
	END TRY

	BEGIN CATCH
		SET @fim = GETDATE();
		SET @linhas = 0;
		SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	
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
		THROW;
	END CATCH

END
GO

-- Fato (Granularidade Menor)
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_FATO_CUSTO_ITEM_STG]
AS

BEGIN
	TRUNCATE TABLE Stage_Custos..FATO_CUSTO_ITEM;

	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_FATO_CUSTO_ITEM_STAGE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	-- Determinar os PK FAKE para evitar dados NULL
	DECLARE @SK_DATA_Manual INT = ( 						-- PK fake da DIM_DATA
	SELECT SK_Data FROM DataWarehouse_Custos..DIM_DATA
	WHERE SK_Data = 0
	)

	DECLARE @ident_envio_Manual UNIQUEIDENTIFIER = (		-- PK fake da DIM_ENVIO
	SELECT ident_envio FROM DataWarehouse_Custos..DIM_ENVIO
	WHERE ident_envio = '00000000-0000-0000-0000-000000000000'
	)

	DECLARE @ident_fornecedor_Manual UNIQUEIDENTIFIER = (	-- PK fake da DIM_FORNECEDOR
	SELECT ident_fornecedor FROM DataWarehouse_Custos..DIM_FORNECEDOR
	WHERE ident_fornecedor = '00000000-0000-0000-0000-000000000000'
	)

	DECLARE @ident_produto_Manual UNIQUEIDENTIFIER = (	-- PK fake da DIM_FORNECEDOR
	SELECT ident_Produto FROM DataWarehouse_Custos..DIM_PRODUTO
	WHERE ident_Produto = '00000000-0000-0000-0000-000000000000'
	)


	BEGIN TRY
	
		INSERT INTO Stage_Custos..FATO_CUSTO_ITEM
		SELECT DISTINCT
			ISNULL(tb.comprovante, 0) AS Comprovante,
			ISNULL(df.ident_fornecedor, @ident_fornecedor_Manual) AS SK_ident_fornecedor,
			ISNULL(de.ident_envio, @ident_envio_Manual) AS SK_ident_envio,
			ISNULL(dd.SK_Data, @SK_DATA_Manual) AS SK_ident_DATA,
			ISNULL(dp.ident_produto, @ident_produto_Manual) AS SK_ident_produto_Manual,

			quantidade,
			valorUnitario,
			quantidadeRecebida,
			GETDATE() AS DataLinha,
			'Carga FATO_CUSTO' AS LinhaOrigem
		FROM
			Stage_Custos..TbImp_Custo_Bruto tb
		LEFT JOIN
			DataWarehouse_Custos..DIM_FORNECEDOR df
			ON tb.numeroEmpresa = df.numeroEmpresa
		LEFT JOIN
			DataWarehouse_Custos..DIM_ENVIO de
			ON tb.metodoEnvio = de.metodoEnvio
		LEFT JOIN
			DataWarehouse_Custos..DIM_DATA dd
			ON tb.data = dd.DataCompleta
		LEFT JOIN
			DataWarehouse_Custos..DIM_PRODUTO dp
			ON tb.numeroProduto = dp.numeroProduto
			
		
		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em FATO_CUSTO_ITEM(STAGE) com exito!'
		SET @fim = GETDATE();

		-- Carga com Sucesso -> LOG
		IF @linhas > 0
			BEGIN
				INSERT INTO log_CustoBruto_stg (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
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
			END
			-- Caso nenhuma linha tenha sido inserida
			ELSE
			BEGIN
				SET @erroMensagem = 'FALHA! Nenhum dado INSERIDO!'
				INSERT INTO log_CustoBruto_stg (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
				)
				VALUES (
					@nome, 
					@inicio,
					@fim,
					'FALHA',
					@linhas,
					DATEDIFF(SECOND, @inicio, @fim),
					@erroMensagem
					)

			END
	END TRY

	BEGIN CATCH
		SET @fim = GETDATE();
		SET @linhas = 0;
		SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	
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
		THROW;
	END CATCH

END
GO

-- PROCEDURES de Carga FATOS | Data Warehouse
USE DataWarehouse_Custos;
GO

-- Fato (Granularidade Maior)
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_FATO_CUSTO_DW]
AS
BEGIN
	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_FATO_CUSTO_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY


		INSERT INTO DataWarehouse_Custos..FATO_CUSTO
		SELECT 
			dfc.comprovante,
			dfc.SK_ident_fornecedor,
			dfc.SK_ident_envio,
			dfc.SK_DATA,
			dfc.imposto,
			dfc.frete,
			dfc.DataLinha,
			dfc.LinhaOrigem
		FROM
			Stage_Custos..FATO_CUSTO dfc
		WHERE NOT EXISTS (
			SELECT 1 FROM DataWarehouse_Custos..FATO_CUSTO sfc
			WHERE
				dfc.SK_ident_fornecedor = sfc.SK_ident_fornecedor AND
				dfc.SK_ident_envio = sfc.SK_ident_envio AND
				dfc.SK_DATA = sfc.SK_DATA AND
				dfc.comprovante = sfc.comprovante
		)
	

		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em FATO_CUSTO(DATAWAREHOUSE) com exito!'
		SET @fim = GETDATE();

		IF @linhas > 0
			BEGIN
				INSERT INTO log_CustoBruto_dw (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
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
			END

		ELSE 
			BEGIN
				SET @erroMensagem = 'FALHA! Nenhum dado INSERIDO!'
				INSERT INTO log_CustoBruto_dw (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
				)
				VALUES (
					@nome, 
					@inicio,
					@fim,
					'FALHA',
					@linhas,
					DATEDIFF(SECOND, @inicio, @fim),
					@erroMensagem
				)
			END

	END TRY

	BEGIN CATCH
		SET @fim = GETDATE();
		SET @linhas = 0;
		SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	
		INSERT INTO log_CustoBruto_dw (
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

		THROW;
	END CATCH
END
GO

-- Fato (Granularidade Menor)
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_FATO_ITEM_DW]
AS
BEGIN
	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_FATO_CUSTO_ITEM_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY


		INSERT INTO DataWarehouse_Custos..FATO_CUSTO_ITEM
		SELECT 
			dfc.comprovante,
			dfc.SK_ident_fornecedor,
			dfc.SK_ident_envio,
			dfc.SK_DATA,
			dfc.SK_ident_Produto,

			dfc.quantidade,
			dfc.valorUnitario,
			dfc.quantidadeRecebida,

			dfc.DataLinha,
			dfc.LinhaOrigem
		FROM
			Stage_Custos..FATO_CUSTO_ITEM dfc
		WHERE NOT EXISTS (
			SELECT 1 FROM DataWarehouse_Custos..FATO_CUSTO_ITEM sfc
			WHERE
				dfc.SK_ident_fornecedor = sfc.SK_ident_fornecedor AND
				dfc.SK_ident_envio = sfc.SK_ident_envio AND
				dfc.SK_DATA = sfc.SK_DATA AND
				dfc.comprovante = sfc.comprovante
		)
	

		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em FATO_CUSTO_ITEM(DATAWAREHOUSE) com exito!'
		SET @fim = GETDATE();

		IF @linhas > 0
			BEGIN
				INSERT INTO log_CustoBruto_dw (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
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
			END

		ELSE 
			BEGIN
				SET @erroMensagem = 'FALHA! Nenhum dado INSERIDO!'
				INSERT INTO log_CustoBruto_dw (
					nomeProcesso, dataHoraInicio ,dataHoraFim, 
					[status], QtdLinhasAfetadas, duracao, 
					detalheExecucao
				)
				VALUES (
					@nome, 
					@inicio,
					@fim,
					'FALHA',
					@linhas,
					DATEDIFF(SECOND, @inicio, @fim),
					@erroMensagem
				)
			END

	END TRY

	BEGIN CATCH
		SET @fim = GETDATE();
		SET @linhas = 0;
		SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);
	
		INSERT INTO log_CustoBruto_dw (
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

		THROW;
	END CATCH
END
GO