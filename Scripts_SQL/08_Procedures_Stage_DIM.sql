-- PROCEDURES de Carga | STAGE
USE Stage_Custos;
GO

-- Produto
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_PRODUTO_STG]
AS
BEGIN
	TRUNCATE TABLE Stage_Custos..DIM_PRODUTO

		-- Variaveis
		DECLARE @nome VARCHAR(100) = 'CARGA_DIM_PRODUTO_STAGE';
		DECLARE @inicio DATETIME = GETDATE();
		DECLARE @fim DATETIME;
		DECLARE @linhas INT = 0;
		DECLARE @mensagemSuceso VARCHAR(MAX);
		DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY

		-- CARGA EM DIM_PRODUTO
		INSERT INTO Stage_Custos..DIM_PRODUTO(
			numeroProduto, nomeProduto, corProduto, 
			custoPadrao, pesoProduto, linhaProduto,
			categoriaProduto, DataLinha, LinhaOrigem
		)
			SELECT DISTINCT 
				numeroProduto,
				nomeProduto,
	
				-- Converter corProduto para Português
				CASE
					WHEN corProduto = 'Silver' THEN 'Prata'
					WHEN corProduto = 'Black' THEN 'Preto'
					WHEN corProduto = 'Blue' THEN 'Azul'
					WHEN corProduto = 'Silver/Black' THEN 'Prata/Preto'
					WHEN corProduto = 'White' THEN 'Branco'
					WHEN corProduto = 'Yellow' THEN 'Amarelo'
					WHEN corProduto = 'Grey' THEN 'Cinza'
					WHEN corProduto = 'Red' THEN 'Vermelho'
					WHEN corProduto = 'Multi' THEN 'Multicor'
					ELSE 'Sem Cor'
				END AS corProduto, 

				custoPadrao,
				pesoProduto,
		
				-- Vamos converter linhaProduto da sua sigla para seu nome original (EX: M = Mountain)
				CASE
					WHEN linhaProduto = 'R' THEN 'Estrada'
					WHEN linhaProduto = 'M' THEN 'Montanha'
					WHEN linhaProduto = 'T' THEN 'Turismo'
					WHEN linhaProduto = 'S' THEN 'Padrão'
					ELSE '-'
				END AS linhaProduto,

				-- Converter categoriaProduto para Português
				CASE
					WHEN categoriaProduto = 'Accessories' THEN 'Acessórios'
					WHEN categoriaProduto = 'Clothing' THEN 'Roupas'
					WHEN categoriaProduto = 'Components' THEN 'Componentes'
					ELSE 'Sem Categoria'
				END AS categoriaProduto,

				GETDATE() AS DataLinha,
				'Carga DIM_PRODUTO'

			FROM 
				Stage_Custos..TbImp_Custo_Bruto

			-- Quantidade de linhas Inserida
			SET @linhas = @@ROWCOUNT;
			SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_PRODUTO(STAGE) com exito!'
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

-- Fornecedor
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_FORNECEDOR_STG]
AS
BEGIN
	TRUNCATE TABLE Stage_Custos..DIM_FORNECEDOR

	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_FORNECEDOR_STAGE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY

		TRUNCATE TABLE Stage_Custos..DIM_FORNECEDOR;

		-- Carga em DIM_FORNECEDOR
		INSERT INTO Stage_Custos..DIM_FORNECEDOR(
			numeroEmpresa, nomeEmpresa, creditoEmpresa,
			DataLinha, LinhaOrigem
		)
		SELECT DISTINCT 
			 numeroEmpresa,
			 nomeEmpresa,

			 -- Alterando CreditoEmpresa para um texto
			 CASE
				WHEN creditoEmpresa = 1 THEN 'Excelente'
				WHEN creditoEmpresa = 2 THEN 'Muito Bom'
				WHEN creditoEmpresa = 3 THEN 'Acima da Média'
				WHEN creditoEmpresa = 4 THEN 'Regular'
				WHEN creditoEmpresa = 5 THEN 'Ruim'
				ELSE 'Invalido'
			 END AS creditoEmpresa,

			 GETDATE() AS DataLinha,
			 'Carga DIM_FORNECEDOR' AS LinhaOrigem
		FROM 
			Stage_Custos..TbImp_Custo_Bruto

			-- Quantidade de linhas Inserida
			SET @linhas = @@ROWCOUNT;
			SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_FORNECEDOR(STAGE) com exito!'
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

-- Envio
CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_DIM_ENVIO_STG]
AS
BEGIN
	TRUNCATE TABLE Stage_Custos..DIM_ENVIO

	-- Variaveis
	DECLARE @nome VARCHAR(100) = 'CARGA_DIM_ENVIO_STAGE';
	DECLARE @inicio DATETIME = GETDATE();
	DECLARE @fim DATETIME;
	DECLARE @linhas INT = 0;
	DECLARE @mensagemSuceso VARCHAR(MAX);
	DECLARE @erroMensagem VARCHAR(MAX);

	BEGIN TRY

		TRUNCATE TABLE Stage_Custos..DIM_ENVIO;

		-- Carga em DIM_ENVIO
		INSERT INTO Stage_Custos..DIM_ENVIO(
			metodoEnvio, DataLinha, LinhaOrigem
		)
		SELECT DISTINCT 
			metodoEnvio,
			GETDATE() AS DataLinha,
			'Carga DIM_ENVIO' AS LinhaOrigem
		FROM 
			Stage_Custos..TbImp_Custo_Bruto

			-- Quantidade de linhas Inserida
			SET @linhas = @@ROWCOUNT;
			SET @mensagemSuceso = 'SUCESSO! Carga feita em DIM_ENVIO(STAGE) com exito!'
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