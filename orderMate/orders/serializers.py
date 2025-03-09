from rest_framework import serializers
from .models import Order, Dispatch, Received

class OrderSerializer(serializers.ModelSerializer):
    """Serializer for Order model."""
    class Meta:
        model = Order
        fields = '__all__'

class DispatchSerializer(serializers.ModelSerializer):
    """Serializer for Dispatch model."""
    class Meta:
        model = Dispatch
        fields = '__all__'

class ReceivedSerializer(serializers.ModelSerializer):
    """Serializer for Received model."""
    class Meta:
        model = Received
        fields = '__all__'
