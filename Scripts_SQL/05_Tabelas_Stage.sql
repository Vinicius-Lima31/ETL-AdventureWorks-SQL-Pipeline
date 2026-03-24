USE Stage_Custos;
-- Criar Tabelas para STAGE

CREATE TABLE Stage_Custos..[DIM_PRODUTO] (
	ident_Produto UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
	numeroProduto VARCHAR(30) NOT NULL,
	nomeProduto VARCHAR(150) NOT NULL,
	corProduto VARCHAR(30) NOT NULL,
	custoPadrao MONEY NOT NULL,
	pesoProduto DECIMAL(8, 2) NOT NULL,
	linhaProduto VARCHAR(10) NOT NULL,
	categoriaProduto VARCHAR(50) NOT NULL,

	-- MetaDados
	DataLinha DATETIME NOT NULL,
	LinhaOrigem VARCHAR(60) NOT NULL,
);

CREATE TABLE Stage_Custos..[DIM_FORNECEDOR] (
	ident_fornecedor UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
	numeroEmpresa VARCHAR(30) NOT NULL,
	nomeEmpresa VARCHAR(150) NOT NULL,
	creditoEmpresa TINYINT NOT NULL,

	DataLinha DATETIME NOT NULL,
	LinhaOrigem VARCHAR(60) NOT NULL,
);

CREATE TABLE Stage_Custos..[DIM_ENVIO] (
	ident_envio UNIQUEIDENTIFIER NOT NULL DEFAULT NEWID(),
	metodoEnvio VARCHAR(120) NOT NULL,

	-- MetaDados
	DataLinha DATETIME NOT NULL,
	LinhaOrigem VARCHAR(60) NOT NULL,

);

-- FATOS
CREATE TABLE Stage_Custos..FATO_CUSTO (
	-- FK das DIM | Exceção de Produtos
	comprovante INT NOT NULL,
	SK_ident_fornecedor UNIQUEIDENTIFIER NOT NULL,
	SK_ident_envio UNIQUEIDENTIFIER NOT NULL,
	SK_DATA INT NOT NULL,

	-- Dados de granularidade maior da FATO
	imposto DECIMAL(18, 4) NOT NULL,
	frete DECIMAL(18, 4) NOT NULL,

	-- MetaDados
	DataLinha DATETIME NOT NULL,
	LinhaOrigem VARCHAR(60) NOT NULL
	
);

CREATE TABLE Stage_Custos..FATO_CUSTO_ITEM (
	-- FK de todas DIM
	comprovante INT NOT NULL,
	SK_ident_fornecedor UNIQUEIDENTIFIER NOT NULL,
	SK_ident_envio UNIQUEIDENTIFIER NOT NULL,
	SK_DATA INT NOT NULL,
	SK_ident_Produto UNIQUEIDENTIFIER NOT NULL,

	-- Dados de granularidade menor da FATO
	quantidade INT NOT NULL,
	valorUnitario DECIMAL(18, 2) NOT NULL,
	quantidadeRecebida DECIMAL(18, 2) NOT NULL,

	-- MetaDados
	DataLinha DATETIME NOT NULL,
	LinhaOrigem VARCHAR(60) NOT NULL

);