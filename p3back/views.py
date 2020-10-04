import aiohttp
import aiohttp.web
import aiohttp.helpers
import asyncio
import os
import json
import traceback
import functools
import copy
import datetime
import aiohttp_jinja2
from typing import TYPE_CHECKING

import aiohttp_plugin
from .models import Proposal

if TYPE_CHECKING:
    from .app import P3Request

__all__ = 'router',
router = aiohttp_plugin.Routing()
logger = aiohttp_plugin.logger
json_dumps = functools.partial(json.dumps, indent=4,
                               ensure_ascii=False)


@router.post('/shutdown')
@aiohttp_plugin.auth('admin')
async def shutdown_app(request: 'P3Request'):
    async def shutdown_soon():
        await asyncio.sleep(5)
        await request.app.shutdown()

    asyncio.ensure_future(shutdown_soon())
    return aiohttp.web.Response(status=202)


@router.get('/api/tag/generate')
async def generate_tags_by_text(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    search_q = request.query['q']
    async with request.app.db.acquire() as conn:
        r = await conn.execute('''
            select id, present from app_tag t
            where to_tsvector('russian', %s) @@ t.query;
        ''', (search_q,))
        res = [dict(d) for d in await r.fetchall()]
    return aiohttp.web.json_response(res, dumps=json_dumps)


@router.get('/doc')
async def documentation(request) -> aiohttp.web.Response:
    _m, _ = os.path.split(__file__)
    with open(_m + '/api.html') as doc:
        body = doc.read()
    return aiohttp.web.Response(
        body=body, content_type='text/html'
    )


@router.get('/static/api.yaml')
async def api_yaml(request):
    _m, _ = os.path.split(__file__)
    with open(_m + '/api.yaml') as doc:
        body = doc.read()
    return aiohttp.web.Response(
        body=body, content_type='plain/text',
    )


@router.post('/change_file')
@aiohttp_plugin.auth('admin')
async def change_file(request: 'P3Request'):
    _m, _ = os.path.split(__file__)
    reader = await request.multipart()
    with open(_m + request.query['name'], 'wb') as fl:
        while not reader.at_eof():
            bdrd = await reader.next()
            while bdrd and not bdrd.at_eof():
                fl.write(await bdrd.read())
    return aiohttp.web.Response(status=201)


@router.post('/api/upload')
async def upload_attachment(request: 'P3Request'):
    # check permissions
    try:
        key = (d := request.query)['key']
        filename = d['filename']
        logger.info('upload %s with key=%s', filename, key)
    except KeyError as e:
        logger.warning(f'incomplete data {request.query} {e}')
        return aiohttp.web.HTTPBadRequest(body=f'not found `{e}`')

    async with request.app.db.acquire() as conn:
        # check appropriate attachment
        if (at_id := await (await conn.execute('''
            select a.id from app_attachment a
            where (a.key=%s) and (a.filename=%s) and (a.is_loaded=false)
        ''', (key, filename))).fetchone()) is None:
            logger.warning('not found appropriate attachment %s', d)
            return aiohttp.web.HTTPNotFound(body=f'not found attachment ({d})')

        # read user's file
        reader = await request.multipart()
        at_body = b''
        while not reader.at_eof():
            bdrd = await reader.next()
            while bdrd and not bdrd.at_eof():
                at_body = at_body + await bdrd.read()

        # write to db
        logger.debug(str(len(at_body)))
        await conn.execute('''
            with new_data as (
                insert into app_data_attachment (data)
                values (%s)
                returning id
            )
            update app_attachment
            set data_id = new_data.id, is_loaded = true
            from new_data
            where app_attachment.id = %s
        ''', (at_body, at_id['id']))
    return aiohttp.web.Response(status=201)


@router.get('/api/proposal')
@aiohttp_plugin.auth('user')
async def get_my_proposals(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    async with request.app.db.acquire() as conn:
        res = await (await conn.execute('''
            select p.id from app_proposal p
            where p.author = %s;
        ''', (request.user,))).fetchall()
        return aiohttp.web.json_response({
            'result': [dict(r) for r in res]
        })


@router.get('/api/petition')
@aiohttp_plugin.auth('user')
async def get_all_petition(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    result = []
    async with request.app.db.acquire() as conn:
        from_db = await (await conn.execute('''
            select p.id, p.information as inf from app_proposal p
        ''')).fetchall()
        # todo: о можно сделать sql запросом
        for prop in from_db:
            logger.info(f'{prop=}')
            steps = prop['inf']
            is_petition = False
            for s in steps:
                if s['question'] == 'Хотите ли вы создать петицию из вашего заявления'\
                        and s['answer'] == [0]:
                    is_petition = True
            if is_petition:
                result.append(int(prop['id']))
        return aiohttp.web.json_response({
            'result': result
        })


@router.get(r'/api/tag/{tag_id:\d+}')
@aiohttp_plugin.auth('user')
async def get_tag_by_id(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    async with request.app.db.acquire() as conn:
        res = await (await conn.execute('''
            select t.id, t.present
            from app_tag t
            where t.id = %s
        ''', (int(request.match_info['tag_id']),))).fetchone()
        return aiohttp.web.json_response(dict(res))


@router.get(r'/api/demand/attachment')
async def get_attachment_data(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    try:
        at_id = int(request.query['attachment_id'])
    except (TypeError, KeyError) as e:
        logger.warning(str(e))
        return aiohttp.web.HTTPBadRequest(body=str(e))

    async with request.app.db.acquire() as conn:
        mview = (await (await conn.execute('''
            select d.data
            from app_attachment a
            left join app_data_attachment d on d.id = a.data_id
            where a.id = %s
        ''', (at_id,))).fetchone())['data']
        if mview is None:
            return aiohttp.web.HTTPNotFound()
        return aiohttp.web.Response(body=bytes(mview))


@router.get('/ws')
@aiohttp_plugin.auth('user')
async def do_ws(request: 'P3Request') -> aiohttp.web.StreamResponse:
    try:
        return await _do_ws(request)
    except Exception:  # noqa: full trace given by traceback
        logger.error(traceback.format_exc())
        return aiohttp.web.HTTPInternalServerError()


async def _do_ws(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    ws = aiohttp.web.WebSocketResponse()
    await ws.prepare(request)
    closed = False

    async def hold_connection():
        while not ws.closed and not closed:
            await ws.ping()
            await asyncio.sleep(3)

    task = asyncio.ensure_future(hold_connection())

    async with request.app.db.acquire() as conn:
        queue = set([d['id'] for d in (await (await conn.execute('''
            select id from app_question
            where initial=true
        ''')).fetchall())])

    async def send_next_question():
        try:
            id_q = queue.pop()
        except KeyError:
            async with request.app.db.acquire() as conn_:
                from_db_ = await (await conn_.execute('''
                    insert into app_proposal (information, author)
                    values (%s, %s)
                    returning id;
                ''', (json.dumps(history), request.user))).fetchone()
            await ws.send_json({
                'cmd': 'end',
                'id': from_db_['id'],
            })
            return False
        async with request.app.db.acquire() as conn:
            logger.debug(f'{id_q=}')
            data = await (await conn.execute('''
                select q.title, q.data_q, q.type_q, q.id
                from app_question q
                where q.id=%s
            ''', (id_q,))).fetchone()
            to_send = {
                'question': data['title'],
                'id': data['id'],
                'type': data['type_q'],
            }
            if data['type_q'] == 'choice':
                to_send.update(data['data_q'])
            history.append(copy.deepcopy(to_send))
            to_send['cmd'] = 'question'
            logger.info('sent: %s', to_send)
            await ws.send_json(to_send)
            return True

    async def add_relative_questions(q_id, qq):
        nonlocal queue, already_was
        logger.warning('%s %s', q_id, qq)
        already_was |= {q_id}
        async with request.app.db.acquire() as conn:
            to_add = set([int(d['to_q']) for d in (await (await conn.execute('''
                select to_q from app_edge
                where from_q = %s and (from_qq is null or from_qq = %s);
            ''', (q_id, qq))).fetchall())])
            queue |= to_add
            queue -= already_was

    history = []
    already_was = set()
    await send_next_question()
    async for msg in ws:  # type: aiohttp.WSMessage
        if msg.type == aiohttp.WSMsgType.PING:
            logger.debug('on ping')
            await ws.pong()
            continue
        if msg.type == aiohttp.WSMsgType.PONG:
            logger.debug('on pong')
            continue
        if msg.type == aiohttp.WSMsgType.CLOSE:
            logger.debug('on close')
            break
        logger.info(f'>>> {msg.data}')
        response = {}
        try:
            assert len(history) != 0, 'server error'
            j_data = json.loads(msg.data)
            assert j_data['id'] == history[-1]['id'], 'incorrect id'
            if j_data['cmd'] == 'answer':
                if history[-1]['type'] == 'choice':
                    assert isinstance(j_data['answer'], list), 'expect `answer` is int[]'
                    assert all(map(lambda x: isinstance(x, int),
                                   j_data['answer']))
                    history[-1]['answer'] = j_data['answer']
                elif history[-1]['type'] == 'file':
                    assert 'filename' in j_data, 'expect field `filename`'
                    async with request.app.db.acquire() as conn:
                        from_db = await (await conn.execute('''
                            insert into app_attachment (filename)
                            values (%s)
                            returning key;
                        ''', (j_data['filename'],))).fetchone()
                        response = {
                            'cmd': 'need_upload',
                            'key': from_db['key'],
                        }
                        history[-1]['answer'] = {
                            'key': from_db['key'],
                            'filename': from_db['filename'],
                        }
                elif history[-1]['type'] in ['string', 'int', 'location']:
                    history[-1]['answer'] = j_data['answer']
                    response = None
                else:
                    logger.warning('incorrect type: msg=%s', msg.data)
                    assert False, 'incorrect type, report it please'
            elif j_data['cmd'] == 'uploaded':
                response = None
            else:
                logger.warning('cmd not found %s', j_data)
                response = {'cmd': 'debug', 'e': 'cmd is not matched'}
        except json.JSONDecodeError as e:
            logger.debug('invalid json (%s)', msg.data)
            response = {'cmd': 'debug', 'explain': 'invalid json', 'e': str(e)}
        except AssertionError as e:
            logger.debug('AssertionError (%s) %s', msg.data, str(e))
            response = {'cmd': 'debug', 'e': str(e)}
        finally:
            logger.info(f'>>> %s\n<<< %s', msg.data, response)

            last = None
            if history[-1]['type'] == 'choice':
                if 'answer' in history[-1]:
                    last = history[-1]['answer'][0]
            await add_relative_questions(history[-1]['id'], last)

            if response:
                logger.debug('answered on %s', history[-1]['id'])
                await ws.send_json(response)
            elif not await send_next_question():
                task.cancel()
                break
    await ws.close()
    closed = True
    return ws


@router.get(r'/view/{prop_id:\d+}')
async def view_handler(
        request: 'P3Request'
) -> aiohttp.web.StreamResponse:
    async with request.app.db.acquire() as conn:
        inf = (await (await conn.execute('''
            select p.information from app_proposal p
            where p.id=%s
        ''', (request.match_info['prop_id'], ))).fetchone())['information']
    steps = {}
    for i in inf:
        steps[i['question']] = copy.deepcopy(i)
    """
    Здесь на основании данных заявки можно выбирать определенный шаблон
        Пока есть лишь один шаблон поэтому используем basic.html
    """
    template_name = 'basic.html'

    o_format = request.get('format', 'html')
    if o_format == 'html':
        return aiohttp_jinja2.render_template(
            template_name,
            request,
            {'meta': {
                'author': request.headers.get('AUTHORIZATION', 'Иванов И.И.'),
                'date': str(datetime.datetime.now().date()),
            }, 'steps': steps}
        )
    else:
        # пока не реализовано, но, кажется, html гораздо удобенее -
        #  браузер пользователя может преобразовать в любой другой формат
        return aiohttp.web.HTTPInternalServerError(body='unsupported format')


@router.post('/apt/tg/new')
async def tg_new_msg(request: 'P3Request') -> aiohttp.web.StreamResponse:
    if os.getenv('AUTH_TG_TOKEN') != request.headers.get('AUTHORIZATION'):
        return aiohttp.web.HTTPForbidden()
    data = await request.json()
    async with request.app.db.acquire() as conn:
        await conn.execute('''
            insert into app_tg_messages (author, msg)
            values (%s, %s)
        ''', (data['usr'], data['msg']))
    return aiohttp.web.HTTPCreated()


@router.route('/admin/{q:.*}', '*')
@router.route('/static/{q:.*}', '*')
async def django_proxy_handler(request: 'P3Request'):
    logger.warning(' '.join([f'{request.query=}', f'{request.raw_path=}'
                             f'{request.rel_url=}']))
    async with aiohttp.ClientSession(headers=request.headers) as session:
        p = int(os.getenv('PORT', 9090)) + 1
        async with session.request(
            request.method,
            f'http://localhost:{p}{request.raw_path}',
            data=await request.read()
        ) as resp:
            return aiohttp.web.Response(
                status=resp.status,
                body=await resp.read(),
                headers=resp.headers,
            )
