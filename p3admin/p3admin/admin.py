from django.contrib import admin
from p3admin.models import TgMessage, Question


@admin.register(TgMessage)
class TgMessageAdmin(admin.ModelAdmin):
    class Meta:
        verbose_name_plural = 'Сообщения с телеграмма'


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    class Meta:
        verbose_name_plural = 'Вопросы графа'
