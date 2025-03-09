
import json
from rest_framework import viewsets
from orders.models import Order, Dispatch, Received
from orders.serializers import OrderSerializer, DispatchSerializer, ReceivedSerializer
from django.shortcuts import render
from django.http import JsonResponse
from collections import defaultdict
from django.http import JsonResponse
from django.db.models import Count
from django.db.models.functions import TruncMonth
from datetime import datetime

# API ViewSets
class OrderViewSet(viewsets.ModelViewSet):
    queryset = Order.objects.all()
    serializer_class = OrderSerializer

class DispatchViewSet(viewsets.ModelViewSet):
    queryset = Dispatch.objects.all()
    serializer_class = DispatchSerializer

class ReceivedViewSet(viewsets.ModelViewSet):
    queryset = Received.objects.all()
    serializer_class = ReceivedSerializer



def monthly_summary(request):
    """
    Returns a summarized list of orders, dispatches, and received records.
    Accepts:
      - `months=YYYY-MM,YYYY-MM,...` for specific month-year values.
      - `month=MM` for data of a specific month across all years.
      - `year=YYYY` for all months of a specific year.
    """
    selected_months = request.GET.get("months")  # Example: "2025-01,2025-02"
    selected_month = request.GET.get("month")  # Example: "03"
    selected_year = request.GET.get("year")  # Example: "2024"

    month_list = []

    try:
        if selected_months:
            month_list = [datetime.strptime(m.strip(), "%Y-%m") for m in selected_months.split(",")]

        elif selected_month and selected_year:
            month_list = [datetime.strptime(f"{selected_year}-{selected_month.strip()}", "%Y-%m")]

        elif selected_month:
            # Get all years for the given month
            years = Order.objects.dates("order_date_time", "year")
            month_list = [datetime(y.year, int(selected_month), 1) for y in years]

        elif selected_year:
            year = int(selected_year)
            month_list = [datetime(year, m, 1) for m in range(1, 13)]

        else:
            return JsonResponse({"error": "No valid filter provided"}, status=400)

    except ValueError as e:
        return JsonResponse({"error": f"Invalid date format: {str(e)}"}, status=400)

    if not month_list:
        return JsonResponse({"error": "No valid months found"}, status=400)

    # Query data
    orders_summary = (
        Order.objects.filter(
            order_date_time__month__in=[m.month for m in month_list],
            order_date_time__year__in=[m.year for m in month_list]
        )
        .annotate(month=TruncMonth("order_date_time"))
        .values("month")
        .annotate(order_count=Count("order_id"))
    )

    dispatches_summary = (
        Dispatch.objects.filter(
            dispatch_date_time__month__in=[m.month for m in month_list],
            dispatch_date_time__year__in=[m.year for m in month_list]
        )
        .annotate(month=TruncMonth("dispatch_date_time"))
        .values("month")
        .annotate(dispatch_count=Count("dispatch_id"))
    )

    received_summary = (
        Received.objects.filter(
            received_date_time__month__in=[m.month for m in month_list],
            received_date_time__year__in=[m.year for m in month_list]
        )
        .annotate(month=TruncMonth("received_date_time"))
        .values("month")
        .annotate(received_count=Count("received_id"))
    )

    # Convert to dictionary for easy lookup
    orders_dict = {entry["month"].strftime("%Y-%m"): entry["order_count"] for entry in orders_summary}
    dispatches_dict = {entry["month"].strftime("%Y-%m"): entry["dispatch_count"] for entry in dispatches_summary}
    received_dict = {entry["month"].strftime("%Y-%m"): entry["received_count"] for entry in received_summary}

    # Generate final structured output
    final_output = []
    for m in month_list:
        month_str = m.strftime("%B %Y")  # "March 2024" format
        final_output.append([
            month_str,
            orders_dict.get(m.strftime("%Y-%m"), 0),
            dispatches_dict.get(m.strftime("%Y-%m"), 0),
            received_dict.get(m.strftime("%Y-%m"), 0),
        ])

    print("final_output: ", final_output)

    return JsonResponse(final_output, safe=False)


# HTML Page for Monthly Summary
def monthly_summary_page(request):
    """
    Renders the monthly summary page by fetching data from the summary API.
    """
    response = monthly_summary(request)
    data = json.loads(response.content.decode('utf-8'))

    return render(request, "orders/summary.html", {"data": data})