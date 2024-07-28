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
