USE AdventureWorks2012;
GO

CREATE OR ALTER VIEW [dbo].[vwCustoBruto]
AS
SELECT
    -- Produto
    CAST(ISNULL(pd.Name, 'NA') AS VARCHAR(120)) AS NomeProduto,
    CAST(ISNULL(pd.ProductNumber, '00000') AS VARCHAR(120)) AS NumeroProduto,
    CAST(ISNULL(pd.Color, 'Sem Cor') AS VARCHAR(120)) AS CorProduto,
    CAST(ISNULL(pd.StandardCost, 0) AS VARCHAR(120)) AS CustoPadrao,
    CAST(ISNULL(pd.Weight, 0) AS VARCHAR(120)) AS PesoProduto,
    CAST(ISNULL(pd.ProductLine, '-') AS VARCHAR(120)) AS LinhaProduto,

    -- Categoria Produto
    CAST(ISNULL(pc.Name, 'NA') AS VARCHAR(120)) AS CategoriaProduto,

    -- Fornecedor
    CAST(ISNULL(vd.AccountNumber, '0000') AS VARCHAR(120)) AS NumeroEmpresa,
    CAST(ISNULL(vd.Name, 'Desconhecido') AS VARCHAR(120)) AS NomeEmpresa,
    CAST(ISNULL(vd.CreditRating, 0) AS VARCHAR(120)) AS CreditoEmpresa,

    -- Método de Envio
    CAST(ISNULL(sm.Name, 'Desconhecido') AS VARCHAR(120)) AS MetodoEnvio,

    -- JUNK DIMENSION
    ph.OrderDate AS [Data],
    ph.TaxAmt AS Imposto,
    ph.Freight AS Frete,

    -- FATO
    po.OrderQty AS Quantidade,
    po.UnitPrice AS ValorUnitario,
    po.LineTotal AS ValorTotal,
    po.ReceivedQty AS QuantidadeRecebida,

    -- COMPROVANTE
    ph.PurchaseOrderID AS comprovante 
FROM
    -- FATO CENTRAL
    Purchasing.PurchaseOrderDetail po
JOIN
    -- DIM_PEDIDO
    Purchasing.PurchaseOrderHeader ph
    ON po.PurchaseOrderID = ph.PurchaseOrderID
JOIN
    -- DIM_FORNECEDOR
    Purchasing.Vendor vd
    ON ph.VendorID = vd.BusinessEntityID
JOIN
    -- DIM_PRODUTO
    Production.Product pd
    ON po.ProductID = pd.ProductID
LEFT JOIN
    -- Buscando Categoria do Produto (DIM_PRODUTO)
    Production.ProductSubcategory pb
    ON pd.ProductSubcategoryID = pb.ProductSubcategoryID
LEFT JOIN
    -- Buscando Categoria do Produto (DIM_PRODUTO)
    Production.ProductCategory pc
    ON pb.ProductCategoryID = pc.ProductCategoryID
JOIN
    -- Buscando nome do Envio (DIM_PEDIDO)
    Purchasing.ShipMethod sm
    ON ph.ShipMethodID = sm.ShipMethodID