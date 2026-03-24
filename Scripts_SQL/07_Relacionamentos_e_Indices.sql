-- Criando os Relacionamentos
USE DataWarehouse_Custos;
GO
-- FATO_CUSTO ✓

-- FATO_CUSTO -> DIM_DATA ✓
ALTER TABLE DataWarehouse_Custos..FATO_CUSTO
WITH CHECK ADD CONSTRAINT [FK_FATO_CUSTO_DATA]
FOREIGN KEY (SK_DATA)
REFERENCES DataWarehouse_Custos..[DIM_DATA] (SK_DATA);

-- FATO_CUSTO -> DIM_FORNECEDOR ✓
ALTER TABLE DataWarehouse_Custos..FATO_CUSTO
WITH CHECK ADD CONSTRAINT [FK_FATO_CUSTO_DIM_FORNECEDOR]
FOREIGN KEY (SK_ident_fornecedor)
REFERENCES DataWarehouse_Custos..[DIM_FORNECEDOR] (ident_fornecedor);

-- FATO_CUSTO -> DIM_ENVIO ✓
ALTER TABLE DataWarehouse_Custos..FATO_CUSTO
WITH CHECK ADD CONSTRAINT [FK_FATO_CUSTO_DIM_ENVIO]
FOREIGN KEY (SK_ident_envio)
REFERENCES DataWarehouse_Custos..[DIM_ENVIO] (ident_envio);



-- FATO_CUSTO_ITEM
-- FATO_CUSTO_ITEM -> DIM_PRODUTO ✓
ALTER TABLE DataWarehouse_Custos..FATO_CUSTO_ITEM
WITH CHECK ADD CONSTRAINT [FK_FATO_CUSTO_ITEM_DIM_PRODUTO]
FOREIGN KEY (SK_ident_Produto)
REFERENCES DataWarehouse_Custos..[DIM_PRODUTO] (ident_Produto);

-- FATO_CUSTO_ITEM -> FATO_CUSTO ✓
ALTER TABLE DataWarehouse_Custos..FATO_CUSTO_ITEM
WITH CHECK ADD CONSTRAINT [FK_FATO_FATO]
FOREIGN KEY (
	comprovante, SK_ident_fornecedor, SK_ident_envio, SK_DATA 
)
REFERENCES DataWarehouse_Custos..[FATO_CUSTO] (
	comprovante, SK_ident_fornecedor, SK_ident_envio, SK_DATA
);

-- Indices - FATO_CUSTO
CREATE CLUSTERED INDEX IDX_FATO_CUSTO_DATA
ON DataWarehouse_Custos..FATO_CUSTO (SK_DATA);

CREATE NONCLUSTERED INDEX IDX_FATO_CUSTO_FORNECEDOR
ON DataWarehouse_Custos..FATO_CUSTO (SK_ident_Fornecedor);

CREATE NONCLUSTERED INDEX IDX_FATO_CUSTO_ENVIO
ON DataWarehouse_Custos..FATO_CUSTO (SK_ident_envio);

-- Indices - FATO_CUSTO_ITEM
CREATE CLUSTERED INDEX IDX_FATO_CUSTO_ITEM_DATA
ON DataWarehouse_Custos..FATO_CUSTO_ITEM (SK_DATA);

CREATE NONCLUSTERED INDEX IDX_FATO_CUSTO_ITEM_FORNECEDOR
ON DataWarehouse_Custos..FATO_CUSTO_ITEM (SK_ident_Fornecedor);

CREATE NONCLUSTERED INDEX IDX_FATO_CUSTO_ITEM_ENVIO
ON DataWarehouse_Custos..FATO_CUSTO_ITEM (SK_ident_envio);

CREATE NONCLUSTERED INDEX IDX_FATO_CUSTO_ITEM_PRODUTO
ON DataWarehouse_Custos..FATO_CUSTO_ITEM (SK_ident_produto);

-- Pedi a IA um INDICE diferente
CREATE NONCLUSTERED INDEX IDX_FATO_ITEM_CUSTO_TOTAL_COBERTO
ON DataWarehouse_Custos..FATO_CUSTO_ITEM (SK_ident_Produto) -- 🔑 Coluna de busca (Onde o WHERE vai)
INCLUDE (
    quantidade, 
    valorUnitario,  
	quantidadeRecebida,
    SK_ident_fornecedor,
    SK_DATA
)
WITH (
    FILLFACTOR = 90, -- Otimiza o disco para futuras inserções (ajuda a evitar fragmentação)
    SORT_IN_TEMPDB = ON -- Melhora a performance de criação do índice
);
GO