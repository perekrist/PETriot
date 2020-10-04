import aiohttp.web
import json
import os
import aiopg.sa
import functools
from typing import Callable, Awaitable

from .loglib import logger

WebHandlerType = Callable[
    [aiohttp.web.Request],
    Awaitable[aiohttp.web.StreamResponse]
]


async def database_cleanup(app: aiohttp.web.Application):
    def get_dsn():
        if dsn := os.getenv('DATABASE_URL'):
            return dsn
        try:
            return json.loads(os.popen('heroku config -j').read())['DATABASE_URL']
        except (KeyError, json.JSONDecodeError):
            return input('db dsn: ')

    config = {'dsn': get_dsn()}
    db = await aiopg.sa.create_engine(**config)
    app.db = db
    yield
    db.close()
    await db.wait_closed()


def auth(target='user'):
    def decorator(handler: WebHandlerType) -> WebHandlerType:
        @functools.wraps(handler)
        async def wrapper(
                request: aiohttp.web.Request
        ) -> aiohttp.web.StreamResponse:
            key = request.headers.get('Authorization')
            if target == 'user' and key:
                request.user = f'user {key}'
            elif target == 'user':
                return aiohttp.web.HTTPUnauthorized()
            elif target == 'admin' and os.getenv('ADMIN_PWD', key) == key:
                request.user = 'admin'
            elif target == 'admin':
                return aiohttp.web.HTTPForbidden()
            else:
                logger.error(f'target for {handler} incorrect')
                return aiohttp.web.HTTPInternalServerError()
            return await handler(request)
        return wrapper
    return decorator
