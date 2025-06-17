-- 1. Média de treinos por dia da semana
SELECT treinos.dia_semana, AVG(treinos.treinos_dia) AS media, COUNT(treinos.dia_semana) AS qtd_dias
FROM ( SELECT data_treino, DAYNAME(data_treino) AS dia_semana, COUNT(*) AS treinos_dia  FROM ALUNO_TREINO GROUP BY data_treino) AS treinos 
GROUP BY treinos.dia_semana ORDER BY FIELD(treinos.dia_semana, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

-- 2. Ranqueamento dos treinos mais utilizados pelos alunos
SELECT tipo AS tipo_treino, COUNT(tipo) AS numero_treinos FROM ALUNO_TREINO GROUP BY tipo ORDER BY numero_treinos DESC;

-- 3. Quantidade de alunos em cada faixa de IMC no último mês
SELECT
    ALUNO.matricula, 
    ALUNO.nome, 
    (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) AS imc, 
    CASE
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) < 18.5 THEN 'Abaixo do peso' 
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) BETWEEN 18.5 AND 24.9 THEN 'Peso normal' 
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) BETWEEN 25 AND 29.9 THEN 'Sobrepeso' 
        ELSE 'Obesidade'
    END AS faixa_imc
FROM ALUNO 
INNER JOIN ANAMINESE  ON ALUNO.matricula = ANAMINESE.matricula 
WHERE ANAMINESE.data_treino >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH);
