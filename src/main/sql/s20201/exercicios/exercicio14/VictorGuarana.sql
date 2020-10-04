/**
 * Author:  Victor Hugo Corpas dos S. Guaraná
 * Created: 03 de out. de 2020
 * Task: Tabela de Campeonato
 */

drop table if exists bairro cascade;
drop table if exists municipio cascade;
drop table if exists antena cascade;
drop table if exists ligacao cascade;


CREATE TABLE bairro (
bairro_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT bairro_pk PRIMARY KEY
(bairro_id));

CREATE TABLE municipio (
municipio_id integer NOT NULL,
nome character varying NOT NULL,
CONSTRAINT municipio_pk PRIMARY KEY
(municipio_id));

CREATE TABLE antena (
antena_id integer NOT NULL,
bairro_id integer NOT NULL,
municipio_id integer NOT NULL,
CONSTRAINT antena_pk PRIMARY KEY
(antena_id),
CONSTRAINT bairro_fk FOREIGN KEY
(bairro_id) REFERENCES bairro
(bairro_id),
CONSTRAINT municipio_fk FOREIGN KEY
(municipio_id) REFERENCES municipio
(municipio_id));

CREATE TABLE ligacao (
ligacao_id bigint NOT NULL,
numero_orig integer NOT NULL,
numero_dest integer NOT NULL,
antena_orig integer NOT NULL,
antena_dest integer NOT NULL,
inicio timestamp NOT NULL,
fim timestamp NOT NULL,
CONSTRAINT ligacao_pk PRIMARY KEY
(ligacao_id),
CONSTRAINT antena_orig_fk FOREIGN KEY
(antena_orig) REFERENCES antena
(antena_id),
CONSTRAINT antena_dest_fk FOREIGN KEY
(antena_dest) REFERENCES antena
(antena_id));

insert into bairro values (1, 'Bairro 1');
insert into bairro values (2, 'Bairro 2');
insert into bairro values (3, 'Bairro 3');
insert into bairro values (4, 'Bairro 4');

insert into municipio values (1, 'Municipio 1');
insert into municipio values (2, 'Municipio 2');

insert into antena values (1, 1, 1);
insert into antena values (2, 2, 1);
insert into antena values (3, 3, 2);
insert into antena values (4, 4, 2);

insert into ligacao values (1, 991234567, 991234568, 1, 2, '01/01/2020 00:00:00', '01/01/2020 02:00:00');
insert into ligacao values (2, 991234567, 991234568, 1, 2, '03/01/2020 01:00:00', '03/01/2020 02:00:00');
insert into ligacao values (3, 991234567, 991234568, 1, 2, '02/01/2020 08:00:00', '02/01/2020 10:00:00');
insert into ligacao values (4, 991234567, 991234568, 1, 2, '05/01/2020 12:00:00', '05/01/2020 15:00:00');

insert into ligacao values (5, 991234567, 991234568, 2, 4, '01/01/2020 00:30:00', '01/01/2020 02:00:00');
insert into ligacao values (6, 991234567, 991234568, 2, 4, '03/01/2020 01:00:00', '03/01/2020 02:45:00');
insert into ligacao values (7, 991234567, 991234568, 2, 4, '02/01/2020 08:00:00', '02/01/2020 10:15:00');
insert into ligacao values (8, 991234567, 991234568, 2, 4, '05/01/2020 12:45:00', '05/01/2020 15:00:00');

insert into ligacao values (9, 991234567, 991234568, 1, 3, '01/01/2020 00:15:00', '01/01/2020 02:30:00');
insert into ligacao values (10, 991234567, 991234568, 1, 3, '03/01/2020 01:15:00', '03/01/2020 02:45:00');
insert into ligacao values (11, 991234567, 991234568, 1, 3, '02/01/2020 08:00:00', '02/01/2020 10:45:00');
insert into ligacao values (12, 991234567, 991234568, 1, 3, '05/01/2020 12:15:00', '05/01/2020 15:00:00');

insert into ligacao values (13, 991234567, 991234568, 3, 2, '01/01/2020 00:45:00', '01/01/2020 02:15:00');
insert into ligacao values (14, 991234567, 991234568, 3, 2, '03/01/2020 01:45:00', '03/01/2020 02:00:00');
insert into ligacao values (15, 991234567, 991234568, 3, 2, '02/01/2020 08:30:00', '02/01/2020 10:30:00');
insert into ligacao values (16, 991234567, 991234568, 3, 2, '05/01/2020 12:30:00', '05/01/2020 15:00:00');

insert into ligacao values (17, 991234567, 991234568, 4, 2, '01/01/2020 00:15:00', '01/01/2020 02:00:00');
insert into ligacao values (18, 991234567, 991234568, 4, 2, '03/01/2020 01:15:00', '03/01/2020 02:45:00');
insert into ligacao values (19, 991234567, 991234568, 4, 2, '02/01/2020 08:30:00', '02/01/2020 10:00:00');
insert into ligacao values (20, 991234567, 991234568, 4, 2, '05/01/2020 12:00:00', '05/01/2020 15:45:00');

drop function if exists ligacao_tempo_medio;

CREATE OR REPLACE FUNCTION ligacao_tempo_medio(param_inciio timestamp, param_final timestamp)
    RETURNS table (
        "Duração media (minutos)" time,
        "Bairro de origem" varchar,
        "Municipio de origem" varchar,
        "Bairro de destino" varchar,
        "Municipio de destino" varchar
        )
    AS $$
    DECLARE       
            
    BEGIN

        return query with table_media as (select (fim - inicio)::time as duracao, antena_orig, antena_dest from ligacao
            where inicio between param_inciio and param_final and fim between param_inciio and param_final)
        select avg(tm.duracao)::time, bar_orig.nome, mun_orig.nome, bar_dest.nome, mun_dest.nome
            from table_media tm 
            inner join antena a_orig on tm.antena_orig = a_orig.antena_id
            inner join antena a_dest on tm.antena_dest = a_dest.antena_id
            inner join municipio mun_orig on a_orig.municipio_id = mun_orig.municipio_id
            inner join municipio mun_dest on a_dest.municipio_id = mun_dest.municipio_id
            inner join bairro bar_orig on a_orig.bairro_id = bar_orig.bairro_id
            inner join bairro bar_dest on a_dest.bairro_id = bar_dest.bairro_id
            group by bar_orig.nome, mun_orig.nome, bar_dest.nome, mun_dest.nome 
            order by avg(tm.duracao) desc;
        
    END;
$$
LANGUAGE PLPGSQL; 

SELECT * from ligacao_tempo_medio('01/01/2020 00:00:00', '02/01/2020 02:00:00');

SELECT * from ligacao_tempo_medio('01/01/2020 00:00:00', '01/02/2020 02:00:00');