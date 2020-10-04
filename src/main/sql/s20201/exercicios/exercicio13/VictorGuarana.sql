/**
 * Author:  Victor Hugo Corpas dos S. Guaraná
 * Created: 30 de set. de 2020
 * Task: Tabela de Campeonato
 */

drop table if exists campeonato cascade;

CREATE TABLE campeonato (
codigo text NOT NULL,
nome TEXT NOT NULL,
ano integer not null,
CONSTRAINT campeonato_pk PRIMARY KEY
(codigo));

drop table if exists time_ cascade;

CREATE TABLE time_ (
sigla text NOT NULL,
nome TEXT NOT NULL,
CONSTRAINT time_pk PRIMARY KEY
(sigla));

drop table if exists jogo cascade;

CREATE TABLE jogo (
campeonato text not null,
numero integer NOT NULL,
time1 text NOT NULL,
time2 text NOT NULL,
gols1 integer not null,
gols2 integer not null,
data_ date not null,
CONSTRAINT jogo_pk PRIMARY KEY
(campeonato,numero),
CONSTRAINT jogo_campeonato_fk FOREIGN KEY
(campeonato) REFERENCES campeonato
(codigo),
CONSTRAINT jogo_time_fk1 FOREIGN KEY
(time1) REFERENCES time_ (sigla),
CONSTRAINT jogo_time_fk2 FOREIGN KEY
(time2) REFERENCES time_ (sigla));


insert into time_ values ('VAS', 'Vasco da Gama');
insert into time_ values ('FLA', 'Flamengo');
insert into time_ values ('BOT', 'Botafogo');
insert into time_ values ('FLU', 'Fluminense');
insert into time_ values ('SAN', 'Santos');

insert into campeonato values ('1', 'Campeonato Brasileiro', 2020);

insert into jogo values ('1', 1, 'VAS', 'FLA', 2, 1, '01/09/2020');
insert into jogo values ('1', 2, 'VAS', 'FLU', 3, 2, '02/09/2020');
insert into jogo values ('1', 3, 'VAS', 'BOT', 2, 0, '03/09/2020');

insert into jogo values ('1', 4, 'FLA', 'VAS', 1, 1, '04/09/2020');
insert into jogo values ('1', 5, 'FLA', 'BOT', 1, 0, '05/09/2020');
insert into jogo values ('1', 6, 'FLA', 'FLU', 2, 1, '06/09/2020');

insert into jogo values ('1', 7, 'BOT', 'VAS', 1, 4, '07/09/2020');
insert into jogo values ('1', 8, 'BOT', 'FLA', 3, 1, '08/09/2020');
insert into jogo values ('1', 9, 'BOT', 'FLU', 0, 0, '09/09/2020');

insert into jogo values ('1', 10, 'FLU', 'VAS', 1, 2, '10/09/2020');
insert into jogo values ('1', 11, 'FLU', 'FLA', 3, 3, '11/09/2020');
insert into jogo values ('1', 12, 'FLU', 'BOT', 2, 1, '12/09/2020');


DROP FUNCTION if exists atualizar_preco();

CREATE OR REPLACE FUNCTION gerar_tabela(cod_camp varchar, pos_inicial int, pos_final int)
    RETURNS table (sigla varchar)
    AS $$
    DECLARE       
        clube record;
        clube2 record;
            
    BEGIN
        drop table if exists temp_tabela_campeonato;
        CREATE TEMPORARY TABLE temp_tabela_campeonato(
            nome varchar,
            pontos int,
            vitorias int);

        for clube in select distinct t.sigla from time_ t loop
            select t.nome,
                count(j.numero) filter (where (j.time1 = clube.sigla and j.gols1 > j.gols2) or (j.time2 = clube.sigla and j.gols1 < j.gols2)) as vitorias,
                count(j.numero) filter (where j.gols1 = j.gols2) as empates
                into clube2
                from time_ t inner join jogo j on t.sigla = j.time1 or t.sigla = j.time2 
                where clube.sigla = t.sigla and j.campeonato = cod_camp
                group by t.sigla;
                
            if clube2 is not null then 
                insert into temp_tabela_campeonato values(clube2.nome, clube2.vitorias*3 + clube2.empates, clube2.vitorias);
            end if;

        end loop;

        return query select t.nome from temp_tabela_campeonato t order by pontos desc, vitorias desc limit (pos_final - (pos_inicial-1)) offset (pos_inicial-1);
        
    END;
$$
LANGUAGE PLPGSQL; 

SELECT * from gerar_tabela('1', 1, 4);