-- =========================================================================
-- PROJETO DE BANCO DE DADOS - MANAUSTECH (E-COMMERCE)
-- INSTITUIÇÃO: FUCAPI
-- FLUXO: LOGÍSTICA DE DISTRIBUIÇÃO E ESTOQUE
-- =========================================================================

CREATE DATABASE IF NOT EXISTS ManausTech;
USE ManausTech;

-- Limpeza preventiva para garantir execução limpa no GitHub/Produção
DROP TABLE IF EXISTS entregas, notas_fiscais, itens_pedido, pedidos, estoque, produtos, usuarios;

-- =========================================================================
-- TABELA 1: USUÁRIOS
-- RESPONSÁVEL: [Luis Vieira]
-- FUNÇÃO: Gerenciar clientes, vendedores e administradores da plataforma.
-- =========================================================================
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    senha VARCHAR(255) NOT NULL,
    tipo_usuario ENUM('cliente', 'vendedor', 'admin') DEFAULT 'cliente',
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- =========================================================================
-- TABELA 2: PRODUTOS
-- RESPONSÁVEL: [Misael]
-- FUNÇÃO: Catálogo de mercadorias vinculadas a um vendedor parceiro.
-- =========================================================================
CREATE TABLE produtos (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(150) NOT NULL,
    descricao TEXT,
    preco DECIMAL(10,2) NOT NULL,
    id_vendedor INT,
    FOREIGN KEY (id_vendedor) REFERENCES usuarios(id_usuario)
);

-- =========================================================================
-- TABELA 3: ESTOQUE
-- RESPONSÁVEL: [Kerisson]
-- FUNÇÃO: Controle de saldos e acionamento automático de reposição (Etapa do Fluxograma).
-- =========================================================================
CREATE TABLE estoque (
    id_estoque INT AUTO_INCREMENT PRIMARY KEY,
    id_produto INT UNIQUE,
    quantidade_disponivel INT NOT NULL DEFAULT 0,
    status_reposicao ENUM('OK', 'Solicitar Reposicao') DEFAULT 'OK',
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- =========================================================================
-- TABELA 4: PEDIDOS
-- RESPONSÁVEL: [Adrya]
-- FUNÇÃO: Registro inicial do carrinho ("Recebimento do Pedido" no Fluxograma).
-- =========================================================================
CREATE TABLE pedidos (
    id_pedido INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente INT,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status_pedido ENUM('Aguardando Estoque', 'Em Separacao', 'Embalado', 'Enviado', 'Entregue') DEFAULT 'Aguardando Estoque',
    FOREIGN KEY (id_cliente) REFERENCES usuarios(id_usuario)
);

-- =========================================================================
-- TABELA 5: ITENS DO PEDIDO
-- RESPONSÁVEL: [Anthony]
-- FUNÇÃO: Discriminação dos itens comprados ("Separação dos Produtos" no Fluxograma).
-- =========================================================================
CREATE TABLE itens_pedido (
    id_item INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT,
    id_produto INT,
    quantidade INT NOT NULL,
    preco_unitario DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido),
    FOREIGN KEY (id_produto) REFERENCES produtos(id_produto)
);

-- =========================================================================
-- TABELA 6: NOTAS FISCAIS
-- RESPONSÁVEL: [Eduardo]
-- FUNÇÃO: Registro fiscal obrigatório após o faturamento ("Emissão da Nota Fiscal").
-- =========================================================================
CREATE TABLE notas_fiscais (
    id_nf INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT UNIQUE,
    numero_nota VARCHAR(50) NOT NULL,
    chave_acesso VARCHAR(44) NOT NULL,
    data_emissao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- =========================================================================
-- TABELA 7: ENTREGAS
-- RESPONSÁVEL: [Nicolas]
-- FUNÇÃO: Rastreio logístico de envio e recepção ("Confirmação da Entrega").
-- =========================================================================
CREATE TABLE entregas (
    id_entrega INT AUTO_INCREMENT PRIMARY KEY,
    id_pedido INT UNIQUE,
    codigo_rastreio VARCHAR(50) NOT NULL,
    status_entrega ENUM('Em Transito', 'Saiu para Entrega', 'Entregue') DEFAULT 'Em Transito',
    data_atualizacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id_pedido)
);

-- =========================================================================
-- AUTOMATIZAÇÃO 1: TRIGGER DE ATUALIZAÇÃO E VERIFICAÇÃO DE ESTOQUE
-- RESPONSÁVEIS DE PROGRAMAÇÃO: [Nomes dos Alunos que apoiaram na lógica]
-- =========================================================================
DELIMITER //

CREATE TRIGGER tr_verificar_estoque_depois_venda
AFTER INSERT ON itens_pedido
FOR EACH ROW
BEGIN
    UPDATE estoque 
    SET quantidade_disponivel = quantidade_disponivel - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE estoque
    SET status_reposicao = 'Solicitar Reposicao'
    WHERE id_produto = NEW.id_produto AND quantidade_disponivel <= 0;
END //

DELIMITER ;

-- =========================================================================
-- AUTOMATIZAÇÃO 2: PROCEDURE DE ENTRADA DE PEDIDOS (RECEBIMENTO)
-- RESPONSÁVEIS DE PROGRAMAÇÃO: [Nomes dos Alunos que apoiaram na lógica]
-- =========================================================================
DELIMITER //

CREATE PROCEDURE RegistrarNovoPedido(
    IN p_id_cliente INT,
    IN p_id_produto INT,
    IN p_quantidade INT,
    IN p_preco_unitario DECIMAL(10,2)
)
BEGIN
    DECLARE v_id_pedido INT;
    DECLARE v_estoque_atual INT;

    SELECT quantidade_disponivel INTO v_estoque_atual 
    FROM estoque 
    WHERE id_produto = p_id_produto;

    IF v_estoque_atual >= p_quantidade THEN
        INSERT INTO pedidos (id_cliente, status_pedido) VALUES (p_id_cliente, 'Em Separacao');
        SET v_id_pedido = LAST_INSERT_ID();
        INSERT INTO itens_pedido (id_pedido, id_produto, quantidade, preco_unitario)
        VALUES (v_id_pedido, p_id_produto, p_quantidade, p_preco_unitario);
        SELECT 'Pedido recebido e enviado para Separação!' AS Resultado;
    ELSE
        INSERT INTO pedidos (id_cliente, status_pedido) VALUES (p_id_cliente, 'Aguardando Estoque');
        SELECT 'Estoque insuficiente! Pedido registrado como Aguardando Estoque.' AS Resultado;
    END IF;
END //

DELIMITER ;