from django.contrib import admin
from p3admin.models import TgMessage, Question, Proposal


@admin.register(TgMessage)
class TgMessageAdmin(admin.ModelAdmin):
    pass


@admin.register(Question)
class QuestionAdmin(admin.ModelAdmin):
    pass


@admin.register(Proposal)
class ProposalAdmin(admin.ModelAdmin):
    pass
