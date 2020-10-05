import aiohttp.web
import aiohttp.helpers
import os
import aiopg.sa
from pathlib import Path
import aiohttp_jinja2
import jinja2
import threading
import sys

import aiohttp_plugin
from . import views


class P3Application(aiohttp.web.Application):
    db: 'aiopg.sa.engine.Engine'


class P3Request(aiohttp.web.Request):
    app: 'P3Application'
    user: str


def init_jinja2(app: aiohttp.web.Application) -> None:
    path = Path(__file__).parent
    print(str(path / 'templates'))
    aiohttp_jinja2.setup(
        app, loader=jinja2.FileSystemLoader(str(path / 'templates'))
    )


def start_other():
    e = sys.executable
    p = int(os.getenv('PORT', 9090)) + 1

    def start_django():
        return os.popen(f'{e} p3admin/manage.py runserver {p}')

    def start_bot():
        return os.popen(f'{e} p3back/tg_bot.py').read()

    threading.Thread(target=start_django).start()
    threading.Thread(target=start_bot).start()


def main():
    start_other()
    app = P3Application()
    init_jinja2(app)
    app.cleanup_ctx.append(aiohttp_plugin.database_cleanup)
    views.router.app_apply(app)
    aiohttp.web.run_app(app, port=os.getenv('PORT', 9090))
