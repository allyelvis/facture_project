from django import forms
from .models import Invoice, Company, EBMSConfig

class InvoiceForm(forms.ModelForm):
    class Meta:
        model = Invoice
        fields = ['number', 'company', 'total_amount']

class CompanyForm(forms.ModelForm):
    class Meta:
        model = Company
        fields = ['name', 'nif', 'vat_subject', 'address']

class EBMSConfigForm(forms.ModelForm):
    class Meta:
        model = EBMSConfig
        fields = ['base_url', 'username', 'password']
