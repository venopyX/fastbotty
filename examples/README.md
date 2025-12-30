# FastBotty Configuration Examples

This directory contains example configuration files demonstrating various FastBotty features.

## Examples

### invoice_with_template.yaml

**NEW**: Demonstrates sending both a formatted message AND an invoice together. This is the solution to the common use case where you want to send order details as a message, followed by a payment invoice.

**Features demonstrated:**
- Sending template message FIRST, then invoice SECOND
- Dynamic invoice amounts using Jinja2 templates
- Real e-commerce order notification scenario
- Multiple inline buttons (pay, copy, URL buttons)
- Template rendering for all invoice fields

**Usage:**

1. Set environment variables:
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   export CHAT_ID="your_chat_id"
   ```

2. Run FastBotty:
   ```bash
   fastbotty run --config examples/invoice_with_template.yaml
   ```

3. Test with the provided script:
   ```bash
   bash examples/test_invoice.sh
   ```

**Expected behavior:** TWO messages are sent to Telegram:
1. **First message**: Formatted order details (from template)
2. **Second message**: Payment invoice with pay button

### invoice_only.yaml

Demonstrates sending ONLY an invoice without a preceding message.

**Features demonstrated:**
- Invoice-only endpoint (no template/formatter)
- Dynamic amounts using Jinja2
- Quick payment use case

### invoice_config.yaml

Comprehensive example showing how to configure invoices and payment processing with Telegram.

**Features demonstrated:**
- Telegram Stars payments (XTR currency)
- Traditional payment provider integration (USD, EUR, etc.)
- Multiple price items and discounts
- Donation with suggested tips
- Physical product with shipping address collection
- Dynamic pricing with Jinja2 templates
- Pay button text replacement (⭐️ and XTR → ⭐)

**Usage:**

1. Set required environment variables:
   ```bash
   export TELEGRAM_BOT_TOKEN="your_bot_token"
   export CHAT_ID="your_chat_id"
   export PAYMENT_PROVIDER_TOKEN="your_provider_token"  # Optional, for non-Stars payments
   export WEBHOOK_URL="https://your-app.onrender.com"
   export API_KEY="your_secret_key"
   ```

2. Run FastBotty with the example config:
   ```bash
   fastbotty run --config examples/invoice_config.yaml
   ```

3. Send payment requests:
   ```bash
   # Telegram Stars payment
   curl -X POST http://localhost:8000/payment/stars \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your_secret_key" \
     -d '{
       "product_name": "Premium Feature",
       "price": "10 Stars",
       "user_id": "123456",
       "timestamp": "1640995200"
     }'

   # USD payment with multiple items
   curl -X POST http://localhost:8000/payment/order \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your_secret_key" \
     -d '{
       "order_id": "12345",
       "product_name": "Awesome Product",
       "product_description": "A very cool product",
       "product_image_url": "https://example.com/product.jpg",
       "user_id": "789"
     }'

   # Donation with tips
   curl -X POST http://localhost:8000/payment/donation \
     -H "Content-Type: application/json" \
     -H "X-API-Key: your_secret_key" \
     -d '{
       "donation_id": "DON-001"
     }'
   ```

## Important Notes

### Invoice + Template Behavior

When an endpoint has BOTH `template`/`formatter` AND `invoice` configured:
1. **First**: The formatted message is sent (with order details, etc.)
2. **Second**: The invoice is sent as a separate message with the pay button

To send ONLY an invoice, omit the `template` and `formatter` fields.

### Jinja2 Template Support in Invoices

All invoice fields support Jinja2 templates:
- `title`: `"Order #{{ order_id }}"`
- `description`: `"Payment for {{ items|length }} items"`
- `payload`: `"order_{{ order_id }}_{{ timestamp }}"`
- `prices[].amount`: `"{{ total_price|int }}"` or `"{{ (price * 1.1)|int }}"`
- `max_tip_amount`: `"{{ (total * 0.2)|int }}"`
- `suggested_tip_amounts`: `["{{ tip1|int }}", "{{ tip2|int }}"]`

### Pay Button Requirements
- Pay buttons **must always be the first button in the first row**
- Text substrings `⭐️` and `XTR` are automatically replaced with the Telegram Star icon (⭐)
- Pay buttons can only be used in invoice messages

### Currency Codes
Use three-letter ISO 4217 currency codes:
- `XTR` - Telegram Stars
- `USD` - US Dollar
- `EUR` - Euro
- `GBP` - British Pound
- etc.

### Price Amounts
Specify prices in the smallest currency unit:
- USD: cents (100 = $1.00)
- EUR: cents (100 = €1.00)
- XTR: stars (1 = 1 star)

### Provider Tokens
- Use empty string `""` for Telegram Stars payments
- Use actual provider token for other payment methods
- Store provider tokens in environment variables, never commit them to code

## Additional Resources

- [FastBotty Documentation](https://github.com/venopyx/fastbotty)
- [Telegram Bot API - Payments](https://core.telegram.org/bots/api#payments)
- [USAGE.md - Invoices & Payments](../docs/USAGE.md#invoices--payments)
