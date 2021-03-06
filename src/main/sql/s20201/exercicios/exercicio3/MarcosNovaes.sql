DROP TABLE IF EXISTS matriz1;

DROP TABLE IF EXISTS matriz2;

DROP TABLE IF EXISTS matriz3;

CREATE TABLE matriz1
(
    content float[][]
);
CREATE TABLE matriz2
(
    content float[][]
);
CREATE TABLE matriz3
(
    content float[][]
);

INSERT INTO matriz1 (content) VALUES (ARRAY[[1, 2, 3],[4, 5, 6],[7, 8, 9]]); 
INSERT INTO matriz2 (content) VALUES (ARRAY[[1],[2], [3]]);
INSERT INTO matriz3(content) VALUES (ARRAY[[-100, -100], [100,100]]);

CREATE OR REPLACE FUNCTION multiplicaMatrizes (matriz1 float[][], matriz2 float[][])
    RETURNS float[][]
    AS $$
    DECLARE
        numLinhasMatriz1 integer; /*num linhas matriz 1*/
        numColunasMatriz1 integer; /*num colunas matriz 1*/
        numLinhasMatriz2 integer; /*num linhas matriz 2*/
        numColunasMatriz2 integer; /*num colunas matriz 2*/
        matrizResultante float[][]; /*matriz resposta*/
    BEGIN
        SELECT array_length(matriz1, 1) INTO numLinhasMatriz1;
        RAISE NOTICE 'linhas matriz 1: %', numLinhasMatriz1;
        SELECT array_length(matriz1, 2) INTO numColunasMatriz1;
        RAISE NOTICE 'colunas matriz 1: %', numColunasMatriz1;
        SELECT array_length(matriz2, 1) INTO numLinhasMatriz2;
        RAISE NOTICE 'linhas matriz 2: %', numLinhasMatriz2;
        SELECT array_length(matriz2, 2) INTO numColunasMatriz2;
        RAISE NOTICE 'colunas matriz 2: %', numColunasMatriz2;
        SELECT array_fill(0, ARRAY[numLinhasMatriz1, numColunasMatriz2]) INTO matrizResultante;
        IF numColunasMatriz1 != numLinhasMatriz2 THEN
            RAISE EXCEPTION 'não é possivel realizar essa multiplicaçao';
        END IF;
        FOR i IN 1..numLinhasMatriz1 LOOP
            FOR j IN 1..numColunasMatriz2 LOOP
                FOR k IN 1..numLinhasMatriz2 LOOP
                    matrizResultante[i][j] := matrizResultante[i][j] + matriz1[i][k] * matriz2[k][j];
                END LOOP;
            END LOOP;
        END LOOP;
        RETURN matrizResultante;
    END;
$$
LANGUAGE PLPGSQL;

-- vai dar certo 
SELECT multiplicaMatrizes(matriz1.content, matriz2.content) FROM matriz1, matriz2;

-- vai disparar exceçao
SELECT multiplicaMatrizes(matriz1.content, matriz3.content) FROM matriz1, matriz3;