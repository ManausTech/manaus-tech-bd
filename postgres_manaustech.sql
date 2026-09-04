-- =========================================================================
-- TRADUÇÃO PARA POSTGRESQL - PROJETO MANAUSTECH (FUCAPI)
-- =========================================================================

-- 1️ TRADUÇÃO DA TRIGGER (Precisa de uma FUNCTION primeiro)
-- =========================================================================
-- RESPONSÁVEIS DE PROGRAMAÇÃO: [Luis, Misael, Adrya, Nicolas]
-- =========================================================================

-- Criando a função que executa a lógica do gatilho
CREATE OR REPLACE FUNCTION fn_verificar_estoque_depois_venda()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Diminui a quantidade do produto vendido no estoque
    UPDATE estoque 
    SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    -- 2. Altera o status para 'Solicitar Reposicao' se zerar
    UPDATE estoque
    SET status_reposicao = 'Solicitar Reposicao'
    WHERE id_produto = NEW.id_produto AND quantidade_disponivel <= 0;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Criando o gatilho que chama a função acima após uma venda
CREATE TRIGGER tr_verificar_estoque_depois_venda
AFTER INSERT ON itens_pedido
FOR EACH ROW
EXECUTE FUNCTION fn_verificar_estoque_depois_venda();


-- 2️ TRADUÇÃO DA PROCEDURE (No PostgreSQL não usa DELIMITER e usa parâmetros IN)
-- =========================================================================
-- RESPONSÁVEIS DE PROGRAMAÇÃO: [Kerisson, Eduardo, Anthony, Misael]
-- =========================================================================
CREATE OR REPLACE PROCEDURE RegistrarNovoPedido(
    p_id_cliente INT,
    p_id_produto INT,
    p_quantidade INT,
    p_preco_unitario DECIMAL(10,2)
)
AS $$
DECLARE 
    v_id_pedido INT;
    v_estoque_atual INT;
BEGIN
    -- 1. Verifica a quantidade atual disponível no estoque
    SELECT quantidade_disponivel INTO v_estoque_atual 
    FROM estoque 
    WHERE id_produto = p_id_produto;

    -- Se houver estoque suficiente (Fluxo do SIM)
    IF v_estoque_atual >= p_quantidade THEN
        
        -- Insere o registro principal do pedido
        INSERT INTO pedidos (id_cliente, status_pedido) 
        VALUES (p_id_cliente, 'Em Separacao')
        RETURNING id_pedido INTO v_id_pedido; -- Pega o ID gerado automaticamente no Postgres
        
        -- Insere os itens específicos do pedido
        INSERT INTO itens_pedido (id_pedido, id_produto, quantity, preco_unitario)
        VALUES (v_id_pedido, p_id_produto, p_quantidade, p_preco_unitario);
        
        RAISE NOTICE 'Pedido recebido e enviado para Separação!';

    ELSE
        -- Se não houver estoque (Fluxo do NÃO)
        INSERT INTO pedidos (id_cliente, status_pedido) 
        VALUES (p_id_cliente, 'Aguardando Estoque');
        
        RAISE NOTICE 'Estoque insuficiente! Pedido registrado como Aguardando Estoque.';
    END IF;
END;
$$ LANGUAGE plpgsql;
