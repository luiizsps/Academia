-- 1. Média de treinos por dia da semana
SELECT 
	treinos.dia_semana, 
	AVG(treinos.treinos_dia) AS media,
	COUNT(treinos.dia_semana) AS qtd_dias
FROM ( 
	SELECT 
		data_treino,
		DAYNAME(data_treino) AS dia_semana,
		COUNT(*) AS treinos_dia
	FROM ALUNO_TREINO 
	GROUP BY data_treino) AS treinos 
GROUP BY treinos.dia_semana 
ORDER BY FIELD(treinos.dia_semana, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');

-- 2. Ranqueamento dos treinos mais utilizados pelos alunos
SELECT 
	tipo AS tipo_treino, 
	COUNT(tipo) AS numero_treinos 
FROM ALUNO_TREINO 
GROUP BY tipo 
ORDER BY numero_treinos DESC;

-- 3. Quantidade de alunos em cada faixa de IMC no último mês
SELECT
	CASE
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) < 18.5 THEN 'Abaixo do peso' 
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) BETWEEN 18.5 AND 24.9 THEN 'Peso normal' 
        WHEN (ANAMINESE.peso / (ANAMINESE.altura * ANAMINESE.altura)) BETWEEN 25 AND 29.9 THEN 'Sobrepeso' 
        ELSE 'Obesidade'
    END AS faixa_imc,
    COUNT(ALUNO.matricula) AS qtd_alunos  
FROM ALUNO 
INNER JOIN ANAMINESE  ON ALUNO.matricula = ANAMINESE.matricula 
WHERE ANAMINESE.data_treino >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
GROUP BY faixa_imc;

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
	) OR (
	matricula_mensalidade.nome_plano = 'Trimestral' AND matricula_mensalidade.data_pagamento <= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
	) OR (
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

--8 - Implemente uma procedure que verifique a evolução do IMC de um aluno desde o ingresso até o último mês, e retorne o percentual evolução do mesmo;
DELIMITER //
DROP PROCEDURE IF EXISTS IMC_EVOLUCAO //
CREATE PROCEDURE IMC_EVOLUCAO(IN a_matricula VARCHAR(10),OUT percentual_evolucao DECIMAL(10,2))
BEGIN
    DECLARE imc_pri DECIMAL(10,2);
    DECLARE imc_ult DECIMAL(10,2);
    SELECT (peso / (altura * altura))
    INTO imc_pri
    FROM ANAMINESE
    WHERE matricula = a_matricula
    ORDER BY data_treino ASC
    LIMIT 1;

    SELECT (peso / (altura * altura))
    INTO imc_ult
    FROM ANAMINESE
    WHERE matricula = a_matricula
    ORDER BY data_treino DESC
    LIMIT 1;
    
    IF imc_pri IS NOT NULL AND imc_ult IS NOT NULL AND imc_pri != 0 THEN
        SET percentual_evolucao = ((imc_ult - imc_pri) / imc_pri) * 100;
    ELSE
        SET percentual_evolucao = NULL;
    END IF;

    SELECT 
        cod,
        data_treino,
        peso,
        altura,
        ROUND(peso / (altura * altura), 2) AS imc
    FROM ANAMINESE
    WHERE matricula = a_matricula
    ORDER BY data_treino;
END //
DELIMITER ;


-- 9-Faça um ranqueamento dos alunos com maiores evoluções do IMC no último ano;

SELECT a.matricula, ROUND(primeiro_imc.imc,2) AS primeiro_imc, ROUND(ultimo_imc.imc,2) AS ultimo_imc,
    CASE
        WHEN primeiro_imc.imc IS NULL OR primeiro_imc.imc = 0 THEN NULL
        ELSE ABS(ROUND(((ultimo_imc.imc - primeiro_imc.imc) / primeiro_imc.imc) * 100,2))
    END AS evolucao_percentual
FROM (SELECT DISTINCT matricula FROM ANAMINESE) AS a
LEFT JOIN
    (SELECT a1.matricula, a1.peso / (a1.altura * a1.altura) AS imc
	 FROM ANAMINESE a1
        JOIN ( SELECT matricula, MIN(data_treino) AS primeira_data_avaliacao
            FROM ANAMINESE
            WHERE YEAR(data_treino) >= YEAR(CURDATE())-1
            GROUP BY matricula
        ) AS t1 ON a1.matricula = t1.matricula AND a1.data_treino = t1.primeira_data_avaliacao
    ) AS primeiro_imc ON a.matricula = primeiro_imc.matricula
LEFT JOIN
    ( SELECT a2.matricula, a2.peso / (a2.altura * a2.altura) AS imc
        FROM ANAMINESE a2
        JOIN (
            SELECT matricula, MAX(data_treino) AS ultima_data_avaliacao
            FROM ANAMINESE
            GROUP BY matricula
        ) AS t2 ON a2.matricula = t2.matricula AND a2.data_treino = t2.ultima_data_avaliacao
    ) AS ultimo_imc ON a.matricula = ultimo_imc.matricula
ORDER BY
    evolucao_percentual DESC;
