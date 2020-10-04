drop table if exists app_tag cascade;
create table app_tag (
    id serial primary key,
    query tsquery not null,
    present text not null
);

drop table if exists app_proposal cascade;
create table app_proposal (
    id serial primary key,
    author varchar(64),
    information jsonb not null
);

drop function if exists random_text(length int) cascade;
create or replace function random_text(length int)
    returns text
as $$
    declare
        output text := '';
        fl int := ceil(length::float / 32);
    begin
        for _ in 1..fl loop
            output := output || md5(random()::text);
        end loop;
        return upper(substring(output, 1, length));
    end;
$$ language plpgsql;

drop table if exists app_data_attachment cascade;
create table app_data_attachment (
    id serial primary key,
    data bytea
);

drop table if exists app_attachment cascade;
create table app_attachment (
    id serial primary key,
    filename varchar(64),
    data_id int references app_data_attachment(id) on delete set null,
    is_loaded bool default false not null,
    key varchar(12) default random_text(12),
    unique (key, filename)
);

drop table if exists app_proposal_tag cascade;
create table app_proposal_tag (
    id serial primary key,
    proposal_id int references app_proposal(id) on delete cascade not null,
    tag_id int references app_tag(id) on delete cascade
);

delete from app_tag where true;
insert into app_tag (query, present)
values (to_tsquery('russian', 'кошк | кот'), 'кошки'),
       (to_tsquery('russian', 'собак | псы | пёс'), 'собаки'),
       (to_tsquery('russian', 'голод | голода | голодаю'), 'истезание голодом'),
       (to_tsquery('russian', 'убийств | убит'), 'повлекло смерть');

create table app_question (
    id serial primary key,
    type_q varchar(16),
    initial bool default false,
    title text unique,
    data_q jsonb
);

insert into app_question (type_q, initial, title, data_q)
values ('choice', true, 'Укажите что случилось',
        '{"answers": ["Ранили животного", "Убили животного",
"издевались над животным", "мне скучно"]}'),
       ('choice', false, 'Что использовал нарушитель?',
        '{"answers": ["огнестрельное оружие", "холодное оружие",
"никаких дополнительных предметов", "окружающие предметы"]}');
insert into app_question (type_q, initial, title)
values ('file', true, 'Приложите файл'),
       ('location', true, 'Укажите местоположение');

create or replace function prepare_proposal(
    cur_prop_id int
) returns jsonb as $$
declare
    result jsonb;
    source jsonb;
begin
    select information from app_proposal p
    where p.id = cur_prop_id
    into source;

    return result;
end;
$$ language plpgsql;

select jsonb_insert('{}'::jsonb, '{"ads"}',
    '"new_value"');

create or replace function get_question_id(
    cur_title text
) returns int as $$
declare
    result text;
begin
    select q.id
    from app_question q
    where q.title = cur_title
    into result;
    return result;
end;
$$ language plpgsql;

create table app_edge (
    id serial primary key,
    from_q int references app_question(id) not null,
    from_qq int, --> encoded user's answer
    to_q int references app_question(id) not null
);


drop function link_qq(q1 text, q2 text, ch int);
create or replace function link_qq(
    q1 text, q2 text, ch int
) returns int as $$
begin
    insert into app_edge (from_q, to_q, from_qq)
    values (get_question_id(q1), get_question_id(q2), ch);
    return 0;
end;
$$ language plpgsql;


insert into app_question (type_q, initial, title, data_q)
values ('choice', true, 'Укажите, что случилось.',
        '{"answers": ["Ранили животное",
                      "Животное пострадало, но осталось в живых",
                      "У меня украли питомца",
                      "Из-за некачественных услуг ветклиники у меня погибло животное",
                      "Я хочу включить своего питомца в завещание, но не знаю как",
                      "У нас в городе появился контактный зоопарк (цирк, дельфинарий и т.п.), в котором животных содержат в ужасных условиях",
                      "Служба отлова работает с нарушениями"]}'),
       ('choice', false, 'Как ранили животное?',
        '{"answers":  ["Ранили из огнестрельного оружия",
                       "Ранили из другого оружия",
                       "Отравили"]}'),
       ('choice', false, 'Укажите вид оружия',
        '{"answers":  ["Нож", "Палка", "Другое"]}'),
       ('choice', false, 'Была ли это домашняя собака?',
        '{"answers":  ["Да", "Нет"]}'),
       ('choice', false, 'Была ли это породистая собака с документами?',
        '{"answers":  ["Да", "Нет"]}'),
       ('location', false, 'Прикрепите место преступления', null),
       ('string', true, 'Расскажите что случилось', null),
       ('choice', false, 'Хотите ли вы приложить файлы',
        '{"answers":  ["Да", "Нет"]}'),
       ('file', false, 'Добавьте файл', null);

insert into app_question (type_q, initial, title, data_q)
values ('choice', true, 'Хотите ли вы создать петицию из вашего заявления',
        '{"answers":  ["Да", "Нет"]}');

select link_qq('Укажите, что случилось.', 'Как ранили животное?', 0);
select link_qq('Как ранили животное?', 'Укажите вид оружия', 1);
select link_qq('Как ранили животное?', 'Была ли это домашняя собака?', 1);
select link_qq('Как ранили животное?', 'Прикрепите место преступления', 1);
select link_qq('Была ли это домашняя собака?', 'Была ли это породистая собака с документами?', 0);
select link_qq('Была ли это породистая собака с документами?', 'Хотите ли вы приложить файлы', 0);
select link_qq('Хотите ли вы приложить файлы', 'Добавьте файл', 0);
select *
from app_question;
select to_q from app_edge
where from_q = get_question_id('Укажите, что случилось.') and
      (from_qq is null or from_qq = 0);

select * from app_edge;

select e.to_q as q_id from app_question q
left join app_edge e on q.id = e.from_q
where e.to_q is not null;

drop table if exists app_tg_messages;
create table app_tg_messages (
    id serial primary key,
    author int8 not null,
    msg text not null,
    answered bool not null default false
);
