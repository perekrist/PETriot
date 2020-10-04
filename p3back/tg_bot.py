import logging
import os
import requests
import json

from telegram import ReplyKeyboardRemove
from telegram.ext import (Updater, CommandHandler, MessageHandler, Filters,
                          ConversationHandler)

# Enable logging
logging.basicConfig(format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
                    level=logging.INFO)

logger = logging.getLogger(__name__)

ASK = 0


def start(update, context):
    update.message.reply_text(
        'здрасте введите ваш вопрос'
    )
    return ASK


def ask_handler(update, context):
    user = update.message.from_user
    logger.info("After ask of %s: %s", user.first_name, update.message.text)
    # бот должен быть запущен на той же машине что и сервер
    resp = requests.post(
        f'http://localhost:{os.getenv("PORT", 9090)}/apt/tg/new',
        json={
            'msg': update.message.text,
            'usr': update.message.from_user.id,
        }, headers={'HTTP_AUTHORIZATION': os.getenv('AUTH_TG_TOKEN')}
    )
    if resp.status_code != 201:
        update.message.reply_text('Произошла ошибка попробуйте повторить операцию позже')
        return ASK
    resp = requests.get(
        f'http://localhost:{os.getenv("PORT", 9090)}/api/tag/generate',
        params={'q': update.message.text},
    )
    tags = None
    try:
        tags = json.loads(resp.content)
        if len(tags):
            msg = 'К вашему сообщению прикреплены следующие теги: ' + \
                  ', '.join([t['present'] for t in tags]) + '. '
        else:
            msg = ''
    except (json.JSONDecodeError, KeyError, TypeError) as e:
        logger.warning('%s (%s) tags=%s', e.__class__, e, tags)
        msg = ''
    update.message.reply_text(f'Спасибо вам за вопрос. {msg}Я отправлю это'
                              ' сообщение экспертам и напишу вам когда они ответят')
    return ASK


def before_ask_handler(update, context):
    user = update.message.from_user
    logger.info("Before ask of %s: %s", user.first_name, update.message.text)
    update.message.reply_text('вы можете писать прямо мне я отошлю'
                              ' вам сообщение эксперта')
    return ASK


def cancel(update, context):
    user = update.message.from_user
    logger.info("User %s canceled the conversation.", user.first_name)
    update.message.reply_text('Досвидания, оч приятно было с вами пообщаться',
                              reply_markup=ReplyKeyboardRemove())
    return ConversationHandler.END


def main():
    # t.me/PETrion_support_bot
    updater = Updater(os.getenv("TG_TOKEN"), use_context=True)
    dp = updater.dispatcher
    conv_handler = ConversationHandler(
        entry_points=[CommandHandler('start', start),
                      CommandHandler('ask', before_ask_handler)],
        states={
            ASK: [MessageHandler(Filters.text, ask_handler)]
        },
        fallbacks=[CommandHandler('cancel', cancel)]
    )
    dp.add_handler(conv_handler)
    updater.start_polling()
    updater.idle()


if __name__ == '__main__':
    main()
