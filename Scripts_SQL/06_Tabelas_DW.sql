-- Criação das DIM e Fato (Data Warehouse)

USE DataWarehouse_Custos;

-- Produtos
CREATE TABLE DataWarehouse_Custos..[DIM_PRODUTO](
	-- PK
	[ident_Produto] [uniqueidentifier] NOT NULL,

	[numeroProduto] [varchar](30) NOT NULL,
	[nomeProduto] [varchar](150) NOT NULL,
	[corProduto] [varchar](30) NOT NULL,
	[custoPadrao] [money] NOT NULL,
	[pesoProduto] [decimal](8, 2) NOT NULL,
	[linhaProduto] [varchar](10) NOT NULL,
	[categoriaProduto] [varchar](50) NOT NULL,

	-- MetaDados
	[DataLinha] [datetime] NOT NULL,
	[LinhaOrigem] [varchar](60) NOT NULL,

	CONSTRAINT [PK_DIM_PRODUTO] PRIMARY KEY NONCLUSTERED ([ident_Produto])
)

-- Fornecedor
CREATE TABLE DataWarehouse_Custos..[DIM_FORNECEDOR](
	-- PK
	[ident_fornecedor] [uniqueidentifier] NOT NULL,

	[numeroEmpresa] [varchar](30) NOT NULL,
	[nomeEmpresa] [varchar](150) NOT NULL,
	[creditoEmpresa] [varchar](20) NOT NULL,

	-- Metadados
	[DataLinha] [datetime] NOT NULL,
	[LinhaOrigem] [varchar](60) NOT NULL,

	CONSTRAINT [PK_DIM_FORNECEDOR] PRIMARY KEY NONCLUSTERED ([ident_fornecedor])
)

-- Envio
CREATE TABLE DataWarehouse_Custos..[DIM_ENVIO](
	-- PK
	[ident_envio] [uniqueidentifier] NOT NULL,

	[metodoEnvio] [varchar](120) NOT NULL,

	-- MetaDados
	[DataLinha] [datetime] NOT NULL,
	[LinhaOrigem] [varchar](60) NOT NULL,

	CONSTRAINT [PK_DIM_ENVIO] PRIMARY KEY NONCLUSTERED ([ident_envio])
)

-- Data
CREATE TABLE DataWarehouse_Custos..[DIM_DATA](
	-- PK
	[SK_Data] [int] NOT NULL,

	[DataCompleta] [date] NOT NULL,
	[DescricaoLongaData] [varchar](100) NOT NULL,
	[DescricaoCurtaData] [varchar](30) NOT NULL,
	[NomeDiaSemana] [varchar](30) NOT NULL,
	[NomeDiaSemanaCurto] [varchar](10) NOT NULL,
	[NomeMes] [varchar](30) NOT NULL,
	[NomeMesCurto] [varchar](10) NOT NULL,
	[Dia] [int] NOT NULL,
	[NumeroDiaSemana] [int] NOT NULL,
	[MesNumero] [int] NOT NULL,
	[Ano] [int] NOT NULL,

	CONSTRAINT [PK_DIM_DATA] PRIMARY KEY NONCLUSTERED ([SK_Data])
)

-- Fato (Granularidade Maior)
CREATE TABLE DataWarehouse_Custos..[FATO_CUSTO](
	-- PK
	[comprovante] [int] NOT NULL,

	-- PK & FK
	[SK_ident_fornecedor] [uniqueidentifier] NOT NULL,
	[SK_ident_envio] [uniqueidentifier] NOT NULL,
	[SK_DATA] [int] NOT NULL,

	[imposto] [decimal](18, 4) NOT NULL,
	[frete] [decimal](18, 4) NOT NULL,

	-- MetaDados
	[DataLinha] [datetime] NOT NULL,
	[LinhaOrigem] [varchar](60) NOT NULL,

	CONSTRAINT [PK_FATO_CUSTO] PRIMARY KEY NONCLUSTERED (
		[comprovante] ASC,
		[SK_ident_fornecedor] ASC,
		[SK_ident_envio] ASC,
		[SK_DATA] ASC
		)
)

-- Fato (Granularidade Menor)
CREATE TABLE DataWarehouse_Custos..[FATO_CUSTO_ITEM](
	-- PK
	[comprovante] [int] NOT NULL,

	-- PK & FK
	[SK_ident_fornecedor] [uniqueidentifier] NOT NULL,
	[SK_ident_envio] [uniqueidentifier] NOT NULL,
	[SK_DATA] [int] NOT NULL,
	[SK_ident_Produto] [uniqueidentifier] NOT NULL,

	[quantidade] [int] NOT NULL,
	[valorUnitario] [decimal](18, 2) NOT NULL,
	[quantidadeRecebida] [decimal](18, 2) NOT NULL,

	-- MetaDados
	[DataLinha] [datetime] NOT NULL,
	[LinhaOrigem] [varchar](60) NOT NULL,

	CONSTRAINT [PK_FATO_CUSTO_ITEM] PRIMARY KEY NONCLUSTERED 
	(
	[comprovante] ASC,
	[SK_ident_fornecedor] ASC,
	[SK_ident_envio] ASC,
	[SK_DATA] ASC,
	[SK_ident_Produto] ASC
	)
)