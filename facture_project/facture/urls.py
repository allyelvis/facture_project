from django.urls import path
from . import views

urlpatterns = [
    path('create_invoice/', views.create_invoice, name='create_invoice'),
    path('confirm_invoice/<int:invoice_id>/', views.confirm_invoice, name='confirm_invoice'),
    path('invoice_detail/<int:invoice_id>/', views.invoice_detail, name='invoice_detail'),
    path('create_company/', views.create_company, name='create_company'),
    path('create_ebms_config/', views.create_ebms_config, name='create_ebms_config'),
]
