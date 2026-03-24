-- Pipeline

USE DataWarehouse_Custos;
GO

CREATE OR ALTER PROCEDURE [dbo].[Carrega_Custo_ALL]
AS
BEGIN TRY
	
	PRINT '==========================================';
	PRINT 'INICIANDO PIPELINE DE CARGA!';
	PRINT '==========================================';

	-- 1° Carregar o BRUTO
	PRINT '1/4 -> Carregando Stage Bruta...';
	EXEC Stage_Custos..Carrega_Custo_Bruto

	-- 2° Carregar as DIM
	PRINT '2/4 -> Carregando Dimensões e Registros Default (ID 0)...';

	EXEC DataWarehouse_Custos..Carrega_DIM_DATA_DW

	EXEC Stage_Custos..Carrega_Custo_DIM_PRODUTO_STG
	EXEC DataWarehouse_Custos..Carrega_Custo_DIM_PRODUTO_DW

	EXEC Stage_Custos..Carrega_Custo_DIM_FORNECEDOR_STG
	EXEC DataWarehouse_Custos..Carrega_Custo_DIM_FORNECEDOR_DW

	EXEC Stage_Custos..Carrega_Custo_DIM_ENVIO_STG
	EXEC DataWarehouse_Custos..Carrega_Custo_DIM_ENVIO_DW

	-- 4° Carregar DadosFake
	EXEC DataWarehouse_Custos..Carrega_Custo_DadosFake_DIM_DW


	-- 5° Carregar FATO_CUSTO
	PRINT '3/4 -> Carregando Fato Custo (Granularidade: Pedido)...';
	EXEC Stage_Custos..Carrega_Custo_FATO_CUSTO_STG
	EXEC DataWarehouse_Custos..Carrega_Custo_FATO_CUSTO_DW

	-- 6° Carregar FATO_CUSTO_ITEM
	PRINT '4/4 -> Carregando Fatos Custo Item (Granularidade: Item)...';
	EXEC Stage_Custos..Carrega_Custo_FATO_CUSTO_ITEM_STG
	EXEC DataWarehouse_Custos..Carrega_Custo_FATO_ITEM_DW

END TRY

BEGIN CATCH
	PRINT '##### ERRO DETECTADO NO PIPELINE #####';
	PRINT 'INFORMAÇÕES DOS ERROS PRESENTE NA TABELA DE LOG --> log_CustoBruto_dw';
	THROW;
END CATCH