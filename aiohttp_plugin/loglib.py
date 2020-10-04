import logging

__all__ = 'logger',
logging.basicConfig(level='DEBUG',
                    format='%(module)s:%(levelno)s %(message)s')
logger = logging.getLogger('app')


class LevelHandler(logging.Handler):
    """ Colorize output logs """
    COLOR_MAP = {
        'DEBUG': ('Cyan', '0;36'),
        'INFO': ('Blue', '0;34'),
        'WARNING': ('Yellow', '1;33'),
        'ERROR': ('Red', '0;31'),
    }

    def emit(self, record: logging.LogRecord) -> None:
        color = self.COLOR_MAP.get(record.levelname)
        if color is not None:
            record.msg = ''.join(['\033[', color[1], 'm', record.msg, '\033[0m'])


logger.addHandler(LevelHandler())
