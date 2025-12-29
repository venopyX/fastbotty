# FastBotty Configuration Examples

This directory contains example configuration files demonstrating various FastBotty features.

## Examples

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
