USE Stage_Custos;

CREATE TABLE Stage_Custos..[TbImp_Custo_Bruto](
	nomeProduto VARCHAR(120) NULL,
	numeroProduto VARCHAR(120) NULL,
	corProduto VARCHAR(120) NULL,
	custoPadrao VARCHAR(120) NULL,
	pesoProduto VARCHAR(120) NULL,
	linhaProduto VARCHAR(120) NULL,
	categoriaProduto VARCHAR(120) NULL,
	numeroEmpresa VARCHAR(120) NULL,
	nomeEmpresa VARCHAR(120) NULL,
	creditoEmpresa VARCHAR(120) NULL,
	metodoEnvio VARCHAR(120) NULL,
	[data] VARCHAR(120) NULL,
	imposto VARCHAR(120) NULL,
	frete VARCHAR(120) NULL,
	quantidade VARCHAR(120) NULL,
	valorUnitario VARCHAR(120) NULL,
	valorTotal VARCHAR(120) NULL,
	quantidadeRecebida VARCHAR(120) NULL,
	comprovante INT NULL
)