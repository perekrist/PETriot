import aiohttp.web
from typing import List, Union, Callable, Awaitable
import functools

from .loglib import logger
from .misc import WebHandlerType


class Routing:
    def __init__(self):
        self.routes: List[aiohttp.web.RouteDef] = []

    def route(
            self, path: str,
            methods: Union[List[str], str] = 'POST',
            allow_all: bool = True,
    ):
        def decorator(handler: WebHandlerType) -> WebHandlerType:
            nonlocal methods

            @functools.wraps(handler)
            async def wrapper(
                    request: aiohttp.web.Request
            ) -> aiohttp.web.StreamResponse:
                logger.info('%s %s', path, request.method)
                resp = await handler(request)
                if allow_all:
                    resp.headers.add('Access-Control-Allow-Origin', '*')
                    resp.headers.add('Access-Control-Allow-Headers', '*')
                    resp.headers.add('Access-Control-Allow-Methods:', '*')
                return resp

            if isinstance(methods, str):
                methods = [methods]
            for m in methods:
                self.routes.append(
                    aiohttp.web.route(m, path, wrapper)
                )
            return wrapper
        return decorator

    get = functools.partialmethod(route, methods=['GET'])
    post = functools.partialmethod(route, methods=['POST'])

    def app_apply(self, app: aiohttp.web.Application):
        app.add_routes(self.routes)
