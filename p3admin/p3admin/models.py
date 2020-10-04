from django.db import models


class TgMessage(models.Model):
    author = models.BigIntegerField()
    msg = models.TextField()
    answered = models.BooleanField()

    class Meta:
        db_table = 'app_tg_messages'


class Question(models.Model):
    """
    type_q varchar(16),
    initial bool default false,
    title text unique,
    data_q jsonb
    """
    type_q = models.CharField(max_length=16)
    initial = models.BooleanField()
    title = models.TextField(unique=True)
    data_q = models.JSONField()

    class Meta:
        db_table = 'app_question'
