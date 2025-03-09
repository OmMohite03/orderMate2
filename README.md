# OrderMate

OrderMate is a Django REST Framework (DRF) application that tracks orders, dispatches, and received items for a computer parts business. It provides a monthly summary of transactions and allows filtering data by specific months. The application includes both API endpoints and a simple frontend for visualization.

## Features
- **CRUD Operations** for Orders, Dispatches, and Received Items
- **REST API** built using Django REST Framework (DRF)
- **Monthly Summary API** to fetch order, dispatch, and received counts
- **Interactive Frontend** with filtering and sorting
- **PostgreSQL Database** Data seeding script to populate the database with random test data

## Tech Stack
- **Backend**:  Django, Django REST Framework (DRF)
- **Database** PostgreSQL
- **Monthly Summary API** to fetch order, dispatch, and received counts
- **Frontend**  HTML, JavaScript, Bootstrap
- **PostgreSQL Database** Data seeding script to populate the database with random test data


## Project Structure
```
orderMate/
│── users/                 # Manages user data
│── orders/                # Handles orders, dispatches, and received orders
│── templates/             # Contains HTML files (summary.html)
│── static/                # Static assets (CSS, JS, images)
│── populatedb.py          # Script to populate database with random data
│── requirements.txt       # Project dependencies
│── manage.py              # Django management script
└── README.md              # Project documentation
```

## Installation & Setup

### Prerequisites
- Python 3.8+
- PostgreSQL (or SQLite for development)
- Django 4+
- Django REST Framework
- pip (Python package manager)
- virtualenv (optional but recommended)

## requirements.txt
 ```bash
   Django>=4.0,<5.0
   djangorestframework>=3.12,<4.0
   psycopg2>=2.9,<3.0
 ```

### Steps to Run Locally
1. **Clone the Repository**
   ```bash
   git clone https://github.com/OmMohite03/orderMate.git
   cd orderMate
   ```

2. **Create a Virtual Environment & Install Dependencies**
   ```bash
   python -m venv env
   source env/bin/activate  # On Windows: env\Scripts\activate
   pip install -r requirements.txt
   ```
3. ** Install Dependencies **
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure Database (PostgreSQL)**
   Update `settings.py`:
   ```python
   DATABASES = {
       'default': {
           'ENGINE': 'django.db.backends.postgresql',
           'NAME': 'ordermate_db',
           'USER': 'yourusername',
           'PASSWORD': 'yourpassword',
           'HOST': 'localhost',
           'PORT': '5432',
       }
   }
   ```

5. **Run Migrations**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```
6. **Run the Development Server**
   ```bash
   python manage.py runserver
   ```
   Access the app at `http://127.0.0.1:8000`

6. **Populating Database with Test Data**
   ```bash
   python manage.py populatedb
   ```


## API Endpoints
| Method | Endpoint             | Description                   |
|--------|----------------------|-------------------------------|
| GET    | /api/orders/         | List all orders              |
| POST   | /api/orders/         | Create a new order           |
| GET    | /api/orders/{id}/    | Retrieve order by ID         |
| PUT    | /api/orders/{id}/    | Update an order              |
| DELETE | /api/orders/{id}/    | Delete an order              |
| GET    | /api/summary/        | Get monthly summary          |
| GET    | /api/summary/?month=January | Get summary for a specific month |

## Frontend (HTML UI)
- Located in `templates/summary.html`
- Uses **JavaScript Fetch API** to interact with the backend
- Provides **monthly filtering and sorting**

## Contributing
Pull requests are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature-name`)
3. Commit your changes (`git commit -m 'Add new feature'`)
4. Push to the branch (`git push origin feature-name`)
5. Open a pull request

