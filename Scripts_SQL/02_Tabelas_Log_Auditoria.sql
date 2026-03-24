-- Criação de Tabelas LOG

-- Tabela Stage
USE Stage_Custos;

CREATE TABLE log_CustoBruto_stg (
	logId UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NONCLUSTERED, -- GUID

	nomeProcesso VARCHAR(100) NOT NULL, -- Nome da Tabela que esta sendo mexida
	dataHoraInicio DATETIME NOT NULL DEFAULT GETDATE(), -- Momento em que começou a operação
	dataHoraFim DATETIME NULL, -- Momento em que finalizou

	[status] VARCHAR(20) NOT NULL, -- Sucesso ou Falha
	QtdLinhasAfetadas INT NULL, -- Contagem de linhas
	duracao DECIMAL(10, 2) NULL, -- Tempo de execução

	detalheExecucao VARCHAR(MAX) NULL, -- Mensagem de um possivel erro
	usuarioExecucao VARCHAR(50) DEFAULT SUSER_SNAME() -- Usuario que executou

)

-- Tabela Data Warehouse
USE DataWarehouse_Custos;

CREATE TABLE log_CustoBruto_dw (
	logId UNIQUEIDENTIFIER DEFAULT NEWID() PRIMARY KEY NONCLUSTERED, -- GUID

	nomeProcesso VARCHAR(100) NOT NULL, -- Nome da Tabela que esta sendo mexida
	dataHoraInicio DATETIME NOT NULL DEFAULT GETDATE(), -- Momento em que começou a operação
	dataHoraFim DATETIME NULL, -- Momento em que finalizou

	[status] VARCHAR(20) NOT NULL, -- Sucesso ou Falha
	QtdLinhasAfetadas INT NULL, -- Contagem de linhas
	duracao DECIMAL(10, 2) NULL, -- Tempo de execução

	detalheExecucao VARCHAR(MAX) NULL, -- Mensagem de um possivel erro
	usuarioExecucao VARCHAR(50) DEFAULT SUSER_SNAME() -- Usuario que executou

)