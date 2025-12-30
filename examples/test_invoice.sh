# Test Invoice with Template Message
# 
# This file contains sample curl commands to test the invoice functionality
# with the example configuration from invoice_with_template.yaml

# First, make sure your environment variables are set:
# export TELEGRAM_BOT_TOKEN="your-bot-token"
# export CHAT_ID="your-chat-id"

# Then run the FastBotty server:
# fastbotty run --config examples/invoice_with_template.yaml

# Test 1: Full order with all fields (like the problem statement example)
echo "=== Test 1: Full order with invoice and template ==="
curl -X POST http://localhost:8000/notify/order \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "F1C21CFB",
    "customer_name": "Gemechis Chala",
    "phone": "+251963333668",
    "telegram_username": "@scorpydev",
    "konami_email": "gladsonchala@gmail.com",
    "konami_password": "fvindfvidfnvip",
    "account_region": "global",
    "total_price": 3968,
    "total_coins": 0,
    "items": [
      {
        "name": "Telegram Premium 6 Months",
        "quantity": 1,
        "price": 1600,
        "category": "telegram"
      },
      {
        "name": "Netherlands +100",
        "quantity": 1,
        "price": 570,
        "category": "players"
      },
      {
        "name": "MANAGER +150",
        "quantity": 2,
        "price": 899,
        "category": "players"
      }
    ],
    "order_date": "2025-12-30T06:16:25.832Z",
    "timestamp": "1735537200",
    "savings": 1032
  }'

echo ""
echo ""

# Test 2: Simple order with minimal fields
echo "=== Test 2: Simple order with minimal fields ==="
curl -X POST http://localhost:8000/notify/order \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "ABC123",
    "customer_name": "John Doe",
    "phone": "+1234567890",
    "total_price": 1000,
    "items": [
      {
        "name": "Test Product",
        "quantity": 1,
        "price": 1000,
        "category": "test"
      }
    ],
    "order_date": "2025-12-30T10:00:00Z",
    "timestamp": "1735560000"
  }'

echo ""
echo ""

# Expected Behavior:
# For each test, TWO Telegram messages should be sent:
# 
# 1. FIRST MESSAGE: The formatted template with order details
#    - Shows order ID, customer info, items list, total, etc.
#    - No buttons on this message
# 
# 2. SECOND MESSAGE: The invoice
#    - Shows "Order #[order_id]" as title
#    - Shows "Payment for [item names]" as description
#    - Has the pay button and other buttons
#    - The amount is dynamically calculated from total_price
#
# This is the FIX for the reported issue where only the invoice was being sent.
