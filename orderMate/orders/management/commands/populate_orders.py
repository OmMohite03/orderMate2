from django.core.management.base import BaseCommand
from orders.models import Order, Dispatch, Received
from users.models import User
from django.utils import timezone
import random

class Command(BaseCommand):
    help = "Populate database with test data"

    def handle(self, *args, **kwargs):
        # Ensure at least 5 users exist
        for i in range(5):
            User.objects.get_or_create(
                username=f"user{i}",
                defaults={
                    "email_address": f"user{i}@example.com",
                    "phone_number": f"12345678{i}",
                    "address": f"Street {i}, City"
                }
            )

        users = list(User.objects.all())

        # Get the latest dispatch_id and received_id to prevent duplicate keys
        max_dispatch_id = Dispatch.objects.order_by('-dispatch_id').first()
        max_dispatch_id = max_dispatch_id.dispatch_id if max_dispatch_id else 1000

        max_received_id = Received.objects.order_by('-received_id').first()
        max_received_id = max_received_id.received_id if max_received_id else 5000

        # Insert 10 new random orders, dispatches, and received entries
        for i in range(10):
            # Spread order dates randomly across the last 12 months
            days_ago = random.randint(0, 365)
            order_date = timezone.now() - timezone.timedelta(days=days_ago)

            # Ensure order_date is **naive** before making it aware
            if order_date.tzinfo is not None:
                order_date = timezone.make_naive(order_date)  # Convert to naive

            order_date = timezone.make_aware(order_date)  # Convert back to aware

            order = Order.objects.create(
                user_id=random.choice(users).id,
                order_date_time=order_date,
                model_no=f"Model-{random.randint(100, 999)}",
                qty=random.randint(1, 10)
            )

            dispatch_date = order_date + timezone.timedelta(days=random.randint(1, 10))

            if dispatch_date.tzinfo is not None:
                dispatch_date = timezone.make_naive(dispatch_date)

            dispatch_date = timezone.make_aware(dispatch_date)

            Dispatch.objects.create(
                order_id=order.order_id,
                dispatch_id=max_dispatch_id + 1,  # Incrementing to prevent conflict
                dispatch_person=f"Person-{i}",
                dispatch_date_time=dispatch_date
            )
            max_dispatch_id += 1

            if random.choice([True, False]):
                received_date = dispatch_date + timezone.timedelta(days=random.randint(1, 10))

                if received_date.tzinfo is not None:
                    received_date = timezone.make_naive(received_date)

                received_date = timezone.make_aware(received_date)

                Received.objects.create(
                    order_id=order.order_id,
                    received_id=max_received_id + 1,  # Incrementing to prevent conflict
                    received_date_time=received_date,
                    received_person=f"Receiver-{i}"
                )
                max_received_id += 1

        self.stdout.write(self.style.SUCCESS("✅ Test data inserted successfully!"))
