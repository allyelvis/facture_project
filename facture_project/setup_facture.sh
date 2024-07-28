#!/bin/bash

# Check if a directory is provided, otherwise use the current directory
DIR=${1:-$(pwd)}

# Function to create Django project
create_django_project() {
    echo "Creating Django project in $DIR/facture_project..."
    cd "$DIR"
    django-admin startproject facture_project
    cd facture_project
}

# Function to create app
create_app() {
    echo "Creating facture app..."
    python manage.py startapp facture
}

# Function to create models
create_models() {
    echo "Creating models in facture/models.py..."
    cat <<EOL > facture/models.py
from django.db import models

class Company(models.Model):
    name = models.CharField(max_length=100)
    nif = models.CharField(max_length=50)
    vat_subject = models.BooleanField(default=False)
    address = models.TextField()

class EBMSConfig(models.Model):
    base_url = models.URLField()
    username = models.CharField(max_length=100)
    password = models.CharField(max_length=100)
    token = models.CharField(max_length=255, blank=True, null=True)

class Invoice(models.Model):
    number = models.CharField(max_length=50, unique=True)
    date = models.DateTimeField(auto_now_add=True)
    company = models.ForeignKey(Company, on_delete=models.CASCADE)
    total_amount = models.DecimalField(max_digits=10, decimal_places=2)
    confirmed = models.BooleanField(default=False)
    pdf_file = models.FileField(upload_to='invoices/', null=True, blank=True)
    ebms_response = models.TextField(null=True, blank=True)

class StockMovement(models.Model):
    invoice = models.ForeignKey(Invoice, on_delete=models.CASCADE)
    product_name = models.CharField(max_length=100)
    quantity = models.IntegerField()
    movement_type = models.CharField(max_length=50)
EOL
}

# Function to create forms
create_forms() {
    echo "Creating forms in facture/forms.py..."
    cat <<EOL > facture/forms.py
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
EOL
}

# Function to create views
create_views() {
    echo "Creating views in facture/views.py..."
    cat <<EOL > facture/views.py
import requests
from django.shortcuts import render, redirect
from .models import Invoice, Company, EBMSConfig, StockMovement
from .forms import InvoiceForm, CompanyForm, EBMSConfigForm
from django.http import HttpResponse
from io import BytesIO
from django.template.loader import get_template
from xhtml2pdf import pisa

def create_invoice(request):
    if request.method == 'POST':
        form = InvoiceForm(request.POST)
        if form.is_valid():
            invoice = form.save()
            return redirect('confirm_invoice', invoice_id=invoice.id)
    else:
        form = InvoiceForm()
    return render(request, 'facture/create_invoice.html', {'form': form})

def confirm_invoice(request, invoice_id):
    invoice = Invoice.objects.get(id=invoice_id)
    if request.method == 'POST':
        invoice.confirmed = True
        invoice.save()

        # Post to EBMS
        ebms_config = EBMSConfig.objects.first()
        headers = {'Authorization': f'Bearer {ebms_config.token}'}
        invoice_data = {
            'invoice_number': invoice.number,
            'date': invoice.date,
            'total_amount': invoice.total_amount,
            'company': {
                'name': invoice.company.name,
                'nif': invoice.company.nif,
                'vat_subject': invoice.company.vat_subject,
                'address': invoice.company.address
            }
        }
        response = requests.post(f'{ebms_config.base_url}/addInvoice', json=invoice_data, headers=headers)
        invoice.ebms_response = response.text
        invoice.save()

        # Generate PDF
        pdf_file = generate_pdf('facture/invoice_template.html', {'invoice': invoice})
        invoice.pdf_file.save(f'invoice_{invoice.number}.pdf', pdf_file)
        invoice.save()

        return redirect('invoice_detail', invoice_id=invoice.id)
    return render(request, 'facture/confirm_invoice.html', {'invoice': invoice})

def generate_pdf(template_src, context_dict):
    template = get_template(template_src)
    html = template.render(context_dict)
    result = BytesIO()
    pdf = pisa.pisaDocument(BytesIO(html.encode("UTF-8")), result)
    if not pdf.err:
        return result
    return None

def invoice_detail(request, invoice_id):
    invoice = Invoice.objects.get(id=invoice_id)
    return render(request, 'facture/invoice_detail.html', {'invoice': invoice})

def create_company(request):
    if request.method == 'POST':
        form = CompanyForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('company_list')
    else:
        form = CompanyForm()
    return render(request, 'facture/create_company.html', {'form': form})

def create_ebms_config(request):
    if request.method == 'POST':
        form = EBMSConfigForm(request.POST)
        if form.is_valid():
            form.save()
            return redirect('ebms_config_detail')
    else:
        form = EBMSConfigForm()
    return render(request, 'facture/create_ebms_config.html', {'form': form})
EOL
}

# Function to create templates
create_templates() {
    echo "Creating templates in facture/templates/facture/..."
    mkdir -p facture/templates/facture

    cat <<EOL > facture/templates/facture/create_invoice.html
<h1>Create Invoice</h1>
<form method="post">
    {% csrf_token %}
    {{ form.as_p }}
    <button type="submit">Create</button>
</form>
EOL

    cat <<EOL > facture/templates/facture/confirm_invoice.html
<h1>Confirm Invoice</h1>
<p>Invoice Number: {{ invoice.number }}</p>
<p>Total Amount: {{ invoice.total_amount }}</p>
<form method="post">
    {% csrf_token %}
    <button type="submit">Confirm</button>
</form>
EOL

    cat <<EOL > facture/templates/facture/invoice_detail.html
<h1>Invoice Details</h1>
<p>Invoice Number: {{ invoice.number }}</p>
<p>Total Amount: {{ invoice.total_amount }}</p>
<p>EBMS Response: {{ invoice.ebms_response }}</p>
<a href="{{ invoice.pdf_file.url }}">Download PDF</a>
EOL

    cat <<EOL > facture/templates/facture/invoice_template.html
<h1>Invoice {{ invoice.number }}</h1>
<p>Date: {{ invoice.date }}</p>
<p>Company: {{ invoice.company.name }}</p>
<p>Total Amount: {{ invoice.total_amount }}</p>
<p>EBMS Response: {{ invoice.ebms_response }}</p>
EOL
}

# Function to create URLs
create_urls() {
    echo "Creating URL patterns in facture/urls.py..."
    cat <<EOL > facture/urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('create_invoice/', views.create_invoice, name='create_invoice'),
    path('confirm_invoice/<int:invoice_id>/', views.confirm_invoice, name='confirm_invoice'),
    path('invoice_detail/<int:invoice_id>/', views.invoice_detail, name='invoice_detail'),
    path('create_company/', views.create_company, name='create_company'),
    path('create_ebms_config/', views.create_ebms_config, name='create_ebms_config'),
]
EOL
}

# Function to update project URL config
update_project_urls() {
    echo "Updating project URL configuration in facture_project/urls.py..."
    sed -i "s|from django.contrib import admin|from django.contrib import admin\nfrom django.urls import path, include|" facture_project/urls.py
    sed -i "s|urlpatterns = \[|urlpatterns = [\n    path('facture/', include('facture.urls')),\n|" facture_project/urls.py
}

# Function to configure admin site
configure_admin() {
    echo "Configuring admin site in facture/admin.py..."
    cat <<EOL > facture/admin.py
from django.contrib import admin
from .models import Invoice, Company, EBMSConfig, StockMovement

admin.site.register(Invoice)
admin.site.register(Company)
admin.site.register(EBMSConfig)
admin.site.register(StockMovement)
EOL
}

# Function to run migrations
run_migrations() {
    echo "Running database migrations..."
    python manage.py makemigrations
    python manage.py migrate
}

# Function to create superuser
create_superuser() {
    echo "Creating superuser..."
    python manage.py createsuperuser --noinput --username admin --email admin@example.com
}

# Function to run the server
run_server() {
    echo "Starting Django development server..."
    python manage.py runserver
}

# Main script execution
create_django_project
create_app
create_models
create_forms
create_views
create_templates
create_urls
update_project_urls
configure_admin
run_migrations

# Instructions for superuser creation (interactive)
echo "Please run the following command to create a superuser:"
echo "python manage.py createsuperuser"

# Completion message
echo "Setup complete. You can now run the Django server using 'python manage.py runserver'"

# Optional: Start the server automatically (commented out by default)
# run_server