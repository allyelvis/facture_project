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
