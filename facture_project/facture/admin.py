from django.contrib import admin
from .models import Invoice, Company, EBMSConfig, StockMovement

admin.site.register(Invoice)
admin.site.register(Company)
admin.site.register(EBMSConfig)
admin.site.register(StockMovement)
