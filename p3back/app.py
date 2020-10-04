import aiohttp.web
import aiohttp.helpers
import os
import aiopg.sa
from pathlib import Path
import aiohttp_jinja2
import jinja2
import subprocess
import sys

import aiohttp_plugin
from . import views

django_proc = None


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


def start_django():
    global django_proc
    e = sys.executable
    p = int(os.getenv('PORT', 9090)) + 1
    django_proc = subprocess.Popen([e, 'p3admin/manage.py', 'runserver', str(p)])


def main():
    start_django()
    app = P3Application()
    init_jinja2(app)
    app.cleanup_ctx.append(aiohttp_plugin.database_cleanup)
    views.router.app_apply(app)
    aiohttp.web.run_app(app, port=os.getenv('PORT', 9090))
