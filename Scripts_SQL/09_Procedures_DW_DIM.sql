-- PROCEDURES de Carga | Data Warehouse
USE DataWarehouse_Custos;
GO

-- Produtos
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_PRODUTO_DW]
AS
BEGIN
	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_PRODUTO_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY
		INSERT INTO DataWarehouse_Custos..DIM_PRODUTO
		SELECT
			ident_Produto,
			numeroProduto,
			nomeProduto,
			corProduto,
			custoPadrao,
			pesoProduto,
			linhaProduto,
			categoriaProduto,
			DataLinha,
			LinhaOrigem
		FROM
			Stage_Custos..DIM_PRODUTO dp-- Pegando dados do STAGE (DIM_PRODUTO)
		WHERE NOT EXISTS (
			SELECT 1 FROM DataWarehouse_Custos..DIM_PRODUTO ddp
			WHERE ddp.numeroProduto = dp.numeroProduto
		)

		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_PRODUTO(DATAWAREHOUSE) com exito!'
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

-- Fornecedor
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_FORNECEDOR_DW]
AS
BEGIN
	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_FORNECEDOR_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY
		INSERT INTO DataWarehouse_Custos..DIM_FORNECEDOR(
			ident_fornecedor, numeroEmpresa, nomeEmpresa,
			creditoEmpresa ,DataLinha, LinhaOrigem
		)
		SELECT
			ident_fornecedor,
			numeroEmpresa,
			nomeEmpresa,
			creditoEmpresa,
			DataLinha,
			LinhaOrigem
		FROM
			Stage_Custos..DIM_FORNECEDOR df -- Pegando dados do STAGE (DIM_PRODUTO)
		WHERE NOT EXISTS (
			SELECT 1 FROM DataWarehouse_Custos..DIM_FORNECEDOR ddF
			WHERE df.numeroEmpresa = ddf.numeroEmpresa
		)

		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_FORNECEDOR(DATAWAREHOUSE) com exito!'
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

-- Envio
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_ENVIO_DW]
AS
BEGIN
	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_ENVIO_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY
	-- Usei template diferente!
		INSERT INTO DataWarehouse_Custos..DIM_ENVIO(
			ident_envio, metodoEnvio,
			DataLinha, LinhaOrigem
		)
		SELECT
			de.ident_envio,
			de.metodoEnvio,
			de.DataLinha,
			de.LinhaOrigem
		FROM
			Stage_Custos..DIM_ENVIO de
		LEFT JOIN
			DataWarehouse_Custos..DIM_ENVIO tb
		ON
			de.metodoEnvio = tb.metodoEnvio

		WHERE tb.metodoEnvio IS NULL

		-- Quantidade de linhas Inserida
		SET @linhas = @@ROWCOUNT;
		SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_ENVIO(DATAWAREHOUSE) com exito!'
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

-- Data
CREATE OR ALTER PROCEDURE [dbo].[Carrega_DIM_DATA_DW]
AS
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_DATA';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

BEGIN TRY
	-- Liberando permissão para mexer em arquivos
	EXEC sp_configure 'show advanced options', 1;
	RECONFIGURE;
	EXEC sp_configure 'xp_cmdshell', 1;
	RECONFIGURE;

	DECLARE @caminho VARCHAR(250) = 'C:\Projeto-Adventure-Work\Dados\dimdata.csv'
	DECLARE @arquivoExiste TABLE (
		FileExists INT, 
		IsDirectory INT, 
		ParentDirectoryExists INT
	);

	-- Conferir se existe

	INSERT @arquivoExiste 
	EXEC xp_fileexist @caminho

	IF (SELECT FileExists FROM @arquivoExiste) = 1
	BEGIN
		BULK INSERT DataWarehouse_Custos..DIM_DATA
		FROM 'C:\Projeto-Adventure-Work\Dados\dimdata.csv'
		WITH (
			FIELDTERMINATOR = ',',     
			ROWTERMINATOR = '0x0a',    
			FIRSTROW = 2,              
			MAXERRORS = 0,            -- Permite NENHUM ERRO
			CODEPAGE = '65001',        -- <--- CODEPAGE ESPECÍFICO PARA UTF-8 (resolve 'sábado')
			ERRORFILE = 'C:\Projeto-Adventure-Work\Dados\dim_data_erros.log'
		);

		SET @linhas = @@ROWCOUNT;

		-- Definindo mensagem de sucesso e o tempo final
		SET @fim = GETDATE();
		SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_DATA com exito!'

		-- Mover o arquivo de lugar, e renomear
		DECLARE @novoNome VARCHAR(200);
		SET @novoNome = (
			SELECT CAST(YEAR(GETDATE()) AS CHAR(4)) +
			RIGHT('00' + CAST(MONTH(GETDATE()) AS VARCHAR(2)), 2) +
			RIGHT('00' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2) +
			'_' +
			RIGHT('00' + CAST(DATEPART(HOUR, GETDATE()) AS VARCHAR(2)), 2) +
			RIGHT('00' + CAST(DATEPART(MINUTE, GETDATE()) AS VARCHAR(2)), 2) +
			RIGHT('00' + CAST(DATEPART(SECOND, GETDATE()) AS VARCHAR(2)), 2) +
			'_Historico.csv'
		)

		DECLARE @endereco VARCHAR(200);
		SET @endereco = ' MOVE C:\Projeto-Adventure-Work\Dados\dimdata.csv C:\Projeto-Adventure-Work\Dados\historico\' + @novoNome;

		EXEC xp_cmdshell @endereco

		-- Log de Sucesso
		IF @linhas > 0
		BEGIN
			INSERT INTO log_CustoBruto_dw (
			nomeProcesso, dataHoraInicio ,dataHoraFim, 
			[status], QtdLinhasAfetadas, duracao, detalheExecucao)
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

	END
	ELSE BEGIN
		SET @fim = GETDATE();
		SET @linhas = 0;
		SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);

		INSERT INTO log_CustoBruto_dw (
		nomeProcesso, dataHoraInicio ,dataHoraFim, 
		[status], QtdLinhasAfetadas, duracao, detalheExecucao)
		VALUES (
			@nome, 
			@inicio,
			@fim,
			'FALHA',
			@linhas,
			DATEDIFF(SECOND, @inicio, @fim),
			@ErroMensagem
			);
	END

END TRY
	
BEGIN CATCH
	SET @fim = GETDATE();
	SET @linhas = 0;
	SET @ErroMensagem = 'Erro SQL: ' + ERROR_MESSAGE() + ' - Linha: ' + CAST(ERROR_LINE() AS VARCHAR);

	INSERT INTO log_CustoBruto_dw (
	nomeProcesso, dataHoraInicio ,dataHoraFim, 
	[status], QtdLinhasAfetadas, duracao, detalheExecucao)
	VALUES (
		@nome, 
		@inicio,
		@fim,
		'FALHA',
		@linhas,
		DATEDIFF(SECOND, @inicio, @fim),
		@ErroMensagem
		);

	THROW;
END CATCH
GO

-- Adição Dados Fakes
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DadosFake_DIM_DW]
AS
	-- Deixando o TRANSACTION mais forte
	SET XACT_ABORT ON;
	SET NOCOUNT ON; -- Evita mensagens extras, melhora performace

	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DADOSFAKE_DIM_DW_DATAWAREHOUSE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

BEGIN TRY
	
	BEGIN TRANSACTION;

	-- INSERT dados FAKE, para caso de erros

	IF NOT EXISTS(
		SELECT 1 FROM DataWarehouse_Custos..DIM_ENVIO 
		WHERE ident_envio = '00000000-0000-0000-0000-000000000000'
	)
	BEGIN
		INSERT INTO DataWarehouse_Custos..DIM_ENVIO (
			ident_envio, metodoEnvio, DataLinha, LinhaOrigem
			)
		VALUES (
			'00000000-0000-0000-0000-000000000000', 
			'NaoAplica', 
			GETDATE(), 
			'Registro padrão inserido manualmente'
		)
	END

	IF NOT EXISTS(
		SELECT 1 FROM DataWarehouse_Custos..DIM_FORNECEDOR
		WHERE ident_fornecedor = '00000000-0000-0000-0000-000000000000'
	)
	BEGIN
		INSERT INTO DataWarehouse_Custos..DIM_FORNECEDOR(
			ident_fornecedor, numeroEmpresa, nomeEmpresa, creditoEmpresa, DataLinha, LinhaOrigem
			)
		VALUES (
			'00000000-0000-0000-0000-000000000000',
			'0000000',
			'NaoAplica',
			'NA',
			GETDATE(),
			'Registro padrão inserido manualmente'
		)
	END

	IF NOT EXISTS(
		SELECT 1 FROM DataWarehouse_Custos..DIM_PRODUTO
		WHERE ident_Produto = '00000000-0000-0000-0000-000000000000'
	)
	BEGIN
		INSERT INTO DataWarehouse_Custos..DIM_PRODUTO (
			ident_Produto, numeroProduto, nomeProduto, corProduto, custoPadrao, 
			pesoProduto, linhaProduto,categoriaProduto, DataLinha, LinhaOrigem
		)
		VALUES (
			'00000000-0000-0000-0000-000000000000',
			'0000000',
			'NaoAplica',
			'NA',
			0,
			0,
			'NA',
			'NA',
			GETDATE(),
			'Registro padrão inserido manualmente'
		)
	END

	IF NOT EXISTS(
		SELECT 1 FROM DataWarehouse_Custos..DIM_DATA
		WHERE SK_Data = 0
	)
	BEGIN
		INSERT INTO DataWarehouse_Custos..DIM_DATA (
			SK_Data, DataCompleta, DescricaoLongaData, DescricaoCurtaData, NomeDiaSemana,
			NomeDiaSemanaCurto, NomeMes, NomeMesCurto, Dia, NumeroDiaSemana, MesNumero, Ano
		)
		VALUES (
			0,				-- SK_DATA
			'1900-01-01',	-- DataCompleta
			'NaoAplica',	-- DescricaoLongaData
			'NaoAplica',	-- DescricaoCurtaData
			'NaoAplica',	-- NomeDiaSemana
			'NaoAplica',	-- NomeDiaSemanaCurto
			'NaoAplica',	-- NomeMes
			'NaoAplica',	-- NomeMesCurto
			0,				-- Dia
			0,				-- NumeroDiaSemana
			0,				-- MesNumero
			0				-- Ano
		)
	END

	-- Se tem alguma transação pendente, então vamos de COMMIT
	IF @@TRANCOUNT > 0
		COMMIT TRANSACTION;

	-- Quantidade de linhas Inserida
	SET @linhas = @@ROWCOUNT;
	SET @mensagemSuceso = 'SUCESSO! Carga FAKE feita nas DIM(DATAWAREHOUSE) com exito!'
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
			SET @mensagemSuceso = 'SUCESSO! Os registros padrão já existem no banco. Nenhuma nova inserção foi necessária.'
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
END TRY
BEGIN CATCH
	-- Se entrarmos no CATCH e tem TRANSAÇÃO pendente, então vamos dar um ROLLBACK
	IF @@TRANCOUNT > 0
		ROLLBACK;
		
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

END CATCH;
GO