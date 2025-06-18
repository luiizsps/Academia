INSERT INTO PROFESSOR_RESPONSAVEL (CREF, nome) VALUES
('123456GBA', 'João da Silva'),
('789012GBA', 'Maria Oliveira'),
('345678GBA', 'Carlos Pereira');

INSERT INTO PLANO (nome, valor) VALUES
('Mensal', '100.00'),
('Trimestral', '270.00'),
('Anual', '1000.00');

INSERT INTO GRUPO_MUSCULAR (nome_musculo) VALUES
('Peito'),
('Costas'),
('Perna'),
('Biceps'),
('Triceps'),
('Ombro');

INSERT INTO TREINO (tipo, qtd_sessoes) VALUES
('A', 12),
('B', 12),
('C', 12);

INSERT INTO TREINO_GRUPO (tipo, nome_musculo) VALUES
('A', 'Peito'),
('A', 'Triceps'),
('B', 'Costas'),
('B', 'Biceps'),
('C', 'Perna'),
('C', 'Ombro');

INSERT INTO EXERCICIO (nome_musculo, nome_exercicio, descricao) VALUES
('Peito', 'Supino', 'Deitado, barra ao peito'),
('Triceps', 'Polia', 'Em pé, puxar corda para baixo'),
('Costas', 'Puxada', 'Sentado, puxar barra à frente'),
('Biceps', 'Rosca', 'Em pé, halteres alternados'),
('Perna', 'Agachamento', 'Agachamento livre com barra'),
('Ombro', 'Elevação', 'Elevação lateral com halteres');

INSERT INTO TREINO_EXERCICIO (tipo, nome_musculo, nome_exercicio) VALUES
('A', 'Peito', 'Supino'),
('A', 'Triceps', 'Polia'),
('B', 'Costas', 'Puxada'),
('B', 'Biceps', 'Rosca'),
('C', 'Perna', 'Agachamento'),
('C', 'Ombro', 'Elevação');

INSERT INTO ALUNO (matricula, nome, data_nascimento, nome_plano, CREF) VALUES
('2025001', 'Ana Souza', '2000-05-15', 'Mensal', '123456GBA'),
('2025002', 'Bruno Costa', '1998-11-20', 'Anual', '789012GBA'),
('2025003', 'Carla Dias', '2002-02-10', 'Trimestral', '345678GBA');

INSERT INTO MENSALIDADE (data, matricula, status) VALUES
('2024-01-10', '2025002', TRUE),
('2024-03-08', '2025003', TRUE),
('2024-03-05', '2025001', TRUE),
('2024-04-05', '2025001', TRUE),
('2025-04-05', '2025001', TRUE),
('2025-05-05', '2025001', TRUE),
('2025-01-10', '2025002', TRUE),
('2025-05-20', '2025003', TRUE);

INSERT INTO MENSALIDADE_PLANO (data, matricula, nome_plano) VALUES
('2024-01-10', '2025002', 'Anual'),
('2024-03-08', '2025003', 'Trimestral'),
('2024-03-05', '2025001', 'Mensal'),
('2024-04-05', '2025001', 'Mensal'),
('2025-04-05', '2025001', 'Mensal'),
('2025-05-05', '2025001', 'Mensal'),
('2025-01-10', '2025002', 'Anual'),
('2025-05-20', '2025003', 'Trimestral');

INSERT INTO ALUNO_TREINO (matricula, tipo, data_treino, numero_sessao) VALUES
('2025001', 'A', '2025-05-07', 1),
('2025001', 'A', '2025-06-07', 1),
('2025002', 'B', '2025-06-07', 1),
('2025003', 'C', '2025-06-07', 1),
('2025001', 'A', '2025-06-08', 2),
('2025001', 'A', '2025-06-09', 3),
('2025001', 'A', '2025-06-10', 4),
('2025001', 'A', '2025-06-11', 5),
('2025001', 'A', '2025-06-12', 6),
('2025001', 'A', '2025-06-13', 7),
('2025001', 'A', '2025-06-14', 8),
('2025001', 'A', '2025-06-15', 9),
('2025001', 'A', '2025-06-16', 10),
('2025001', 'A', '2025-06-17', 11),
('2025001', 'A', '2025-06-18', 12),
('2025002', 'B', '2025-06-08', 2),
('2025002', 'B', '2025-06-09', 3),
('2025002', 'B', '2025-06-10', 4),
('2025002', 'B', '2025-06-11', 5),
('2025002', 'B', '2025-06-12', 6),
('2025002', 'B', '2025-06-13', 7),
('2025002', 'B', '2025-06-14', 8),
('2025002', 'B', '2025-06-15', 9),
('2025002', 'B', '2025-06-16', 10),
('2025002', 'B', '2025-06-17', 11),
('2025002', 'B', '2025-06-18', 12),
('2025003', 'C', '2025-06-08', 2),
('2025003', 'C', '2025-06-09', 3),
('2025003', 'C', '2025-06-10', 4),
('2025003', 'C', '2025-06-11', 5),
('2025003', 'C', '2025-06-12', 6),
('2025003', 'C', '2025-06-13', 7),
('2025003', 'C', '2025-06-14', 8),
('2025003', 'C', '2025-06-15', 9),
('2025003', 'C', '2025-06-16', 10),
('2025003', 'C', '2025-06-17', 11),
('2025002', 'B', '2025-06-20', 12),
('2025001', 'A', '2025-06-25', 11),
('2025003', 'C', '2025-05-18', 12),
('2025003', 'C', '2025-05-07', 10),
('2025003', 'C', '2025-05-19', 15),
('2025003', 'C', '2025-05-10', 20),
('2025001', 'A', '2025-05-05', 11);

INSERT INTO ANAMINESE (cod, peso, altura, gordura, massa, matricula, tipo, data_treino) VALUES
('ANM000', 90, 1.70, 22.5, 50.8, '2025001', 'A', '2025-05-07'),
('ANM001', 65.5, 1.70, 22.5, 50.8, '2025001', 'A', '2025-06-07'),
('ANM002', 80.0, 1.80, 18.0, 65.6, '2025002', 'B', '2025-06-07'),
('ANM003', 58.0, 1.65, 25.0, 43.5, '2025003', 'C', '2025-06-07');
