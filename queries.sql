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

-- 4. Alunos inadimplentes
SELECT ALUNO.nome, ALUNO.matricula, ALUNO.CREF 
FROM ALUNO
JOIN
	(
	SELECT data, MENSALIDADE_PLANO.matricula, nome_plano, data_pagamento 
	FROM MENSALIDADE_PLANO
	JOIN 
		(
		SELECT matricula, MAX(data) AS data_pagamento FROM MENSALIDADE WHERE status = TRUE GROUP BY matricula
		) AS ultimo_pagamento
	ON MENSALIDADE_PLANO.matricula = ultimo_pagamento.matricula AND MENSALIDADE_PLANO.data = ultimo_pagamento.data_pagamento)
	AS matricula_mensalidade ON ALUNO.matricula = matricula_mensalidade.matricula
WHERE
	(
	matricula_mensalidade.nome_plano = 'Mensal' AND matricula_mensalidade.data_pagamento <= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
	)
	OR 
	(
	matricula_mensalidade.nome_plano = 'Trimestral' AND matricula_mensalidade.data_pagamento <= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
	)
	OR 
	(
	matricula_mensalidade.nome_plano = 'Anual' AND matricula_mensalidade.data_pagamento <= DATE_SUB(CURDATE(), INTERVAL 12 MONTH)
	);

-- 5. Total pago em mensalidades por mês no ano corrente
SELECT MONTH(data) AS mes, SUM(valor) AS total_mensalidades
FROM
	(
	SELECT nome_mensalidade.data, nome_mensalidade.matricula, nome_mensalidade.status, PLANO.nome, PLANO.valor
	FROM
		(
		SELECT MENSALIDADE.data, MENSALIDADE.matricula, MENSALIDADE.status, MENSALIDADE_PLANO.nome_plano 
		FROM MENSALIDADE 
		JOIN MENSALIDADE_PLANO ON MENSALIDADE.matricula = MENSALIDADE_PLANO.matricula AND MENSALIDADE.data = MENSALIDADE_PLANO.data
		) AS nome_mensalidade
	JOIN
		PLANO ON nome_mensalidade.nome_plano = PLANO.nome
	) AS valor_mensalidade
WHERE YEAR(data) = YEAR(CURDATE())
GROUP BY MONTH(data);

-- 6. Quantidade de alunos por professor no último ano
SELECT aluno_professor.nome_professor, COUNT(DISTINCT aluno_professor.matricula) AS numero_alunos
FROM
	(
	SELECT a.matricula, a.nome AS nome_aluno, pr.nome AS nome_professor  
	FROM ALUNO a
	JOIN PROFESSOR_RESPONSAVEL pr ON a.CREF = pr.CREF
	) AS aluno_professor
JOIN MENSALIDADE_PLANO mp ON aluno_professor.matricula = mp.matricula
WHERE 
	(YEAR(CURDATE()) - 1) = YEAR(mp.data)
	OR
	(
	(YEAR(CURDATE()) - 2) = YEAR(mp.data) AND MONTH(mp.data) >= 10 AND mp.nome_plano = 'Trimestral'
	)
	OR
	(
	(YEAR(CURDATE()) - 2) = YEAR(mp.data) AND mp.nome_plano = 'Anual'
	)
GROUP BY aluno_professor.nome_professor;

-- 7. Quantidade de alunos obesos por professor no último mês
SELECT pr.nome AS nome_professor, COUNT(DISTINCT anaminese_aluno.matricula) AS alunos_obesos
FROM 
(
	SELECT an.peso, an.altura, an.data_treino, a.matricula, a.CREF
	FROM ANAMINESE an 
	JOIN ALUNO a ON an.matricula = a.matricula
) AS anaminese_aluno
JOIN PROFESSOR_RESPONSAVEL pr ON anaminese_aluno.CREF = pr.CREF
WHERE 
	MONTH(anaminese_aluno.data_treino) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
	AND 
	YEAR(anaminese_aluno.data_treino) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
	AND
	(anaminese_aluno.peso / (anaminese_aluno.altura * anaminese_aluno.altura)) >= 30
GROUP BY pr.nome;
