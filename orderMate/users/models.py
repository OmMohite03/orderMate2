from django.db import models

class User(models.Model):
    """
    Represents a user with basic contact details.
    """
    username = models.CharField(max_length=100, unique=True)
    email_address = models.EmailField(unique=True)
    phone_number = models.CharField(max_length=15, unique=True)
    address = models.TextField()

    def __str__(self):
        return self.username
    