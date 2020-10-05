from django.db import models


class TgMessage(models.Model):
    author = models.BigIntegerField()
    msg = models.TextField()
    answered = models.BooleanField()

    def __str__(self):
        if len(self.msg) > 40:
            return f'{self.msg[:40]}... by {self.author}'
        else:
            return f'{self.msg} by {self.author}'

    class Meta:
        db_table = 'app_tg_messages'
        verbose_name_plural = 'Сообщения с телеграмма'


class Question(models.Model):
    type_q = models.CharField(max_length=16)
    initial = models.BooleanField()
    title = models.TextField(unique=True)
    data_q = models.JSONField()

    def __str__(self):
        return f'Q: {self.title}'

    class Meta:
        db_table = 'app_question'
        verbose_name_plural = 'Вопросы графа'


class Proposal(models.Model):
    author = models.CharField(max_length=64)
    information = models.JSONField()

    def __str__(self):
        return f'Proposal#{self.id} by {self.author}'

    class Meta:
        db_table = 'app_proposal'
        verbose_name_plural = 'Заявки'
