Here is a `README.md` file for your project, which outlines the setup process, usage instructions, and key details about the project.

```markdown
# Facture Project with EBMS Integration

This project is a Django-based application designed to handle invoice creation and confirmation, with integration to post invoice and stock data to EBMS Burundi. The application also generates and saves invoices as PDF files on the device.

## Prerequisites

- Python 3.x
- pip (Python package installer)
- Django
- Requests
- xhtml2pdf

## Installation

1. Clone the repository or navigate to your desired directory:

   ```bash
   git clone <repository_url>
   cd <repository_directory>
   ```

2. Install the required Python packages:

   ```bash
   pip install django requests xhtml2pdf
   ```

3. Run the setup script:

   ```bash
   chmod +x setup_facture.sh
   ./setup_facture.sh /path/to/your/directory
   ```

## Setup

1. After running the setup script, create a superuser for the Django admin interface:

   ```bash
   python manage.py createsuperuser
   ```

   Follow the prompts to set up your admin username and password.

2. Start the Django development server:

   ```bash
   python manage.py runserver
   ```

3. Access the application at `http://127.0.0.1:8000/`.

## Usage

### Creating an Invoice

1. Navigate to `http://127.0.0.1:8000/facture/create_invoice/`.
2. Fill out the invoice form and submit it.
3. Confirm the invoice at `http://127.0.0.1:8000/facture/confirm_invoice/<invoice_id>/`.

### Creating a Company

1. Navigate to `http://127.0.0.1:8000/facture/create_company/`.
2. Fill out the company form and submit it.

### Configuring EBMS

1. Navigate to `http://127.0.0.1:8000/facture/create_ebms_config/`.
2. Fill out the EBMS configuration form with the base URL, username, and password, then submit it.

## Features

- **Invoice Management:** Create and confirm invoices.
- **Company Management:** Manage company details.
- **EBMS Integration:** Post invoice and stock data to EBMS Burundi.
- **PDF Generation:** Generate and save invoice PDFs on the device.
- **Admin Interface:** Manage invoices, companies, and EBMS configurations through the Django admin interface.

## Project Structure

- `facture_project/` - Django project directory.
- `facture/` - Django app for managing invoices, companies, and EBMS configurations.
- `facture/templates/facture/` - HTML templates for the facture app.
- `facture/models.py` - Models for invoices, companies, EBMS configurations, and stock movements.
- `facture/forms.py` - Forms for creating and managing invoices, companies, and EBMS configurations.
- `facture/views.py` - Views for handling the business logic and rendering templates.
- `facture/urls.py` - URL configurations for the facture app.

## Contribution

Feel free to fork this project, create new features, or fix bugs. Pull requests are welcome.

## License

This project is licensed under the MIT License.

```

This `README.md` file provides a comprehensive overview of the project, including installation instructions, setup steps, usage guidelines, and other relevant information.
