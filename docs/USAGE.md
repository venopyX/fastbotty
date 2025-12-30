# FastBotty Usage Guide

Complete guide for using FastBotty in your projects.

## Table of Contents

- [Installation](#installation)
- [Configuration](#configuration)
- [Message Templates](#message-templates)
- [Sending Notifications](#sending-notifications)
- [Inline Keyboards](#inline-keyboards)
- [Webhooks & Commands](#webhooks--commands)
- [Formatters](#formatters)
- [Custom Plugins](#custom-plugins)
- [Field Mapping](#field-mapping)
- [Authentication](#authentication)
- [Deployment](#deployment)

---

## Installation

### From PyPI

```bash
pip install fastbotty
```

### From Source

```bash
git clone https://github.com/venopyx/fastbotty.git
cd fastbotty
pip install -e .
```

### Create a New Project

```bash
fastbotty init my_notifier
cd my_notifier
```

This creates:
```
my_notifier/
├── config.yaml          # Main configuration
├── main.py              # Entry point
├── plugins/             # Custom plugins directory
│   └── example_formatter.py
├── requirements.txt
└── README.md
```

---

## Configuration

### Basic Configuration

```yaml
bot:
  token: "123456:ABC-DEF..."    # Your bot token from @BotFather

endpoints:
  - path: "/notify"
    chat_id: "8345389653"       # Your Telegram user/group/channel ID
    formatter: "plain"
```

### Environment Variables

Use `${VAR_NAME}` syntax for sensitive values:

```yaml
bot:
  token: "${TELEGRAM_BOT_TOKEN}"

server:
  api_key: "${API_KEY}"
```

Then set them:
```bash
export TELEGRAM_BOT_TOKEN="your-token"
export API_KEY="your-secret-key"
```

### Full Configuration Example

```yaml
bot:
  token: "${TELEGRAM_BOT_TOKEN}"
  test_mode: false

templates:
  order_received: |
    🛒 *New Order \#{order_id}*
    
    👤 Customer: {customer}
    💰 Total: {total}
    📦 Items: {items_count}
  
  alert: |
    ⚠️ *{title}*
    {message}

endpoints:
  # Simple text notifications
  - path: "/notify/alerts"
    chat_id: "8345389653"
    formatter: "plain"

  # Using template
  - path: "/webhook/orders"
    chat_id: "-1001234567890"
    template: "order_received"
    parse_mode: "MarkdownV2"

  # Formatted with labels
  - path: "/webhook/products"
    chat_id: "-1001234567890"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    labels:
      order_id: "🆔 Order"
      customer: "👤 Customer"
      total: "💰 Total"
      status: "📦 Status"
    field_map:
      image_url: "product.thumbnail"
      image_urls: "product.images"

  # Custom plugin formatter
  - path: "/webhook/github"
    chat_id: "8345389653"
    formatter: "github_formatter"
    plugin_config:
      show_commits: true
      max_commits: 5

server:
  host: "0.0.0.0"
  port: 8000
  api_key: "${API_KEY}"

logging:
  level: "INFO"
```

---

## Sending Notifications

### Basic Text Message

```bash
curl -X POST http://localhost:8000/notify/alerts \
  -H "Content-Type: application/json" \
  -d '{"message": "Server is back online!"}'
```

### With Multiple Fields

```bash
curl -X POST http://localhost:8000/webhook/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": 12345,
    "customer": "John Doe",
    "total": "$99.99",
    "status": "Processing"
  }'
```

Output with labels:
```
🆔 Order: 12345
👤 Customer: John Doe
💰 Total: $99.99
📦 Status: Processing
```

### With Single Image

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "New product added!",
    "image_url": "https://example.com/product.jpg"
  }'
```

### With Multiple Images (Gallery)

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Product gallery",
    "image_urls": [
      "https://example.com/photo1.jpg",
      "https://example.com/photo2.jpg",
      "https://example.com/photo3.jpg"
    ]
  }'
```

### With Authentication

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-secret-key" \
  -d '{"message": "Authenticated notification"}'
```

### Override Chat ID Per Request

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Send to different chat",
    "chat_id": "987654321"
  }'
```

---

## Message Templates

Define reusable message templates with Jinja2 syntax.

### Configuration

```yaml
templates:
  order_received: |
    🛒 *New Order \#{{ order_id }}*
    
    👤 Customer: {{ customer }}
    💰 Total: {{ total }}
    
    {% if items %}📦 Items:
    {% for item in items %}• {{ item }}
    {% endfor %}{% endif %}

endpoints:
  - path: "/orders"
    chat_id: "8345389653"
    template: "order_received"
    parse_mode: "MarkdownV2"
```

### Sending

```bash
curl -X POST http://localhost:8000/orders \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "12345",
    "customer": "John Doe",
    "total": "$99.99",
    "items": ["T-Shirt (x2)", "Jeans (x1)"]
  }'
```

### Output

```
🛒 New Order #12345

👤 Customer: John Doe
💰 Total: $99.99

📦 Items:
• T-Shirt (x2)
• Jeans (x1)
```

### Jinja2 Features

- Variables: `{{ variable }}`
- Conditionals: `{% if condition %}...{% endif %}`
- Loops: `{% for item in items %}...{% endfor %}`
- Filters: `{{ name|upper }}`, `{{ price|default('N/A') }}`

**Note:** When using `parse_mode: "MarkdownV2"`, variable values are automatically escaped.

---

## Inline Keyboards

Add interactive buttons to your messages. FastBotty supports all Telegram inline keyboard button types.

### Basic Button Types

#### URL Button
Opens a URL when clicked:

```yaml
buttons:
  - - text: "🔗 Visit Website"
      url: "https://example.com"
```

#### Callback Data Button
Sends a callback query to your bot:

```yaml
buttons:
  - - text: "✅ Approve"
      callback_data: "approve_123"
```

### Advanced Button Types

#### Web App Button
Launches a Telegram Web App:

```yaml
buttons:
  - - text: "🚀 Open App"
      web_app:
        url: "https://app.example.com"
```

#### Login URL Button
Auto-authorization via Telegram Login:

```yaml
buttons:
  - - text: "🔐 Login"
      login_url:
        url: "https://example.com/login"
        forward_text: "Login to Example"
        bot_username: "my_bot"
        request_write_access: true
```

#### Switch Inline Query Button
Prompts user to select a chat and insert an inline query:

```yaml
buttons:
  - - text: "🔍 Search Everywhere"
      switch_inline_query: "search term"
```

#### Switch Inline Query Current Chat Button
Inserts an inline query in the current chat:

```yaml
buttons:
  - - text: "🔍 Search Here"
      switch_inline_query_current_chat: "search term"
```

#### Switch Inline Query Chosen Chat Button
Prompts user to select a specific type of chat:

```yaml
buttons:
  - - text: "📤 Share"
      switch_inline_query_chosen_chat:
        query: "Check out this product"
        allow_user_chats: true
        allow_bot_chats: false
        allow_group_chats: true
        allow_channel_chats: false
```

#### Copy Text Button (Bot API 8.0+)
Copies text to clipboard when clicked:

```yaml
buttons:
  - - text: "📋 Copy Code"
      copy_text:
        text: "PROMO-CODE-2024"
```

#### Pay Button
Payment button (must be first button in first row):

```yaml
buttons:
  - - text: "💳 Pay $10.00"
      pay: true
```

#### Callback Game Button
For games (must be first button in first row):

```yaml
buttons:
  - - text: "🎮 Play Game"
      callback_game: true
```

### Static Buttons Example

```yaml
endpoints:
  - path: "/notify/approval"
    chat_id: "8345389653"
    formatter: "plain"
    buttons:
      # Row 1: Two buttons
      - - text: "✅ Approve"
          callback_data: "approve"
        - text: "❌ Reject"
          callback_data: "reject"
      # Row 2: URL button
      - - text: "🔗 View Details"
          url: "https://example.com/details"
```

### Dynamic Buttons (with Jinja2)

Button text, URL, and most string fields support Jinja2 templates:

```yaml
endpoints:
  - path: "/notify/order"
    chat_id: "8345389653"
    formatter: "plain"
    buttons:
      - - text: "📦 Track Order #{{ order_id }}"
          url: "https://example.com/track/{{ order_id }}"
      - - text: "📋 Copy Order ID"
          copy_text:
            text: "{{ order_id }}"
      - - text: "✅ Confirm"
          callback_data: "confirm_{{ order_id }}"
        - text: "❌ Cancel"
          callback_data: "cancel_{{ order_id }}"
```

**Request:**
```json
{
  "message": "New order received",
  "order_id": "12345"
}
```

**Result:** Buttons render with actual values from payload.

### Handling Button Clicks

Define callback handlers in config:

```yaml
callbacks:
  - data: "approve"
    response: "✅ Approved!"
  - data: "reject"
    response: "❌ Rejected!"
    url: "https://your-api.com/rejected"  # Optional: forward to your API
```

---

## Invoices & Payments

Send payment invoices with the pay button. The pay button **must always be the first button in the first row** of an inline keyboard.

### Important Notes

- **Pay Button Position**: The pay button must be the first button in the first row
- **Star Icon Replacement**: Substrings `⭐️` and `XTR` in the button text are automatically replaced with the Telegram Star icon (⭐)
- **Provider Token**: Use an empty string `""` for Telegram Stars payment
- **Currency**: Use three-letter ISO 4217 currency codes (USD, EUR, etc.)
- **Amounts**: Specify prices in smallest currency units (cents for USD, pence for GBP, etc.)
- **Template Support**: Invoice fields (title, description, payload, amounts, etc.) support Jinja2 templating
- **Message + Invoice**: When both a template/formatter AND invoice are configured, FastBotty sends the formatted message first, then the invoice as a separate message

### Basic Invoice Configuration

```yaml
endpoints:
  - path: "/payment/product"
    chat_id: "123456789"
    formatter: "plain"
    buttons:
      - - text: "Pay 10 XTR"  # XTR automatically replaced with ⭐
          pay: true
    invoice:
      title: "Premium Subscription"
      description: "Monthly premium access to all features"
      payload: "premium_monthly_{{ user_id }}"  # Bot-defined payload (supports templates)
      currency: "XTR"  # Use XTR for Telegram Stars or USD, EUR, etc.
      provider_token: ""  # Empty string for Telegram Stars
      prices:
        - label: "Subscription"
          amount: 1000  # 10.00 in smallest units (e.g., cents)
```

### Invoice with Dynamic Amounts (Jinja2 Templates)

All invoice fields support Jinja2 templating, including price amounts:

```yaml
templates:
  order_details: |
    🛒 *Order \#{{ order_id }}*
    
    👤 Customer: {{ customer_name }}
    📦 Items: {{ items|length }}
    💰 Total: {{ total_price }} XTR

endpoints:
  - path: "/payment/order"
    chat_id: "123456789"
    template: "order_details"  # This message is sent FIRST
    parse_mode: "MarkdownV2"
    buttons:
      - - text: "Pay {{ total_price }} XTR"  # Dynamic button text
          pay: true
    invoice:
      title: "Order #{{ order_id }}"  # Dynamic title
      description: "Payment for {{ items|map(attribute='name')|join(', ') }}"  # Dynamic description
      payload: "order_{{ order_id }}_{{ timestamp }}"
      currency: "XTR"
      provider_token: ""
      prices:
        - label: "Order Total"
          amount: "{{ total_price|int }}"  # Dynamic amount using template
        - label: "Service Fee"
          amount: "{{ (total_price * 0.1)|int }}"  # Calculated amount
      max_tip_amount: "{{ (total_price * 0.2)|int }}"  # 20% max tip
      suggested_tip_amounts:
        - "{{ (total_price * 0.05)|int }}"  # 5% tip
        - "{{ (total_price * 0.10)|int }}"  # 10% tip
        - "{{ (total_price * 0.15)|int }}"  # 15% tip
```

**Sending:**

```bash
curl -X POST http://localhost:8000/payment/order \
  -H "Content-Type: application/json" \
  -d '{
    "order_id": "ABC123",
    "customer_name": "John Doe",
    "total_price": 1000,
    "timestamp": "1735537200",
    "items": [
      {"name": "Product A", "price": 600},
      {"name": "Product B", "price": 400}
    ]
  }'
```

**Result:** Two separate Telegram messages:
1. First message: The formatted template with order details
2. Second message: The invoice with the pay button

### Invoice with Multiple Price Items

```yaml
endpoints:
  - path: "/payment/order"
    chat_id: "123456789"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    buttons:
      - - text: "💳 Pay $25.00"
          pay: true
    invoice:
      title: "Order #{{ order_id }}"
      description: "Your order from {{ shop_name }}"
      payload: "order_{{ order_id }}_{{ timestamp }}"
      currency: "USD"
      provider_token: "${PAYMENT_PROVIDER_TOKEN}"  # Your payment provider token
      prices:
        - label: "Product"
          amount: 2000  # $20.00
        - label: "Shipping"
          amount: 500   # $5.00
        - label: "Discount"
          amount: -200  # -$2.00 (negative for discounts)
      photo_url: "https://example.com/product.jpg"
      photo_width: 800
      photo_height: 600
```

### Invoice with Tips

```yaml
endpoints:
  - path: "/payment/donation"
    chat_id: "123456789"
    formatter: "plain"
    buttons:
      - - text: "💰 Donate ⭐️"  # ⭐️ replaced with ⭐
          pay: true
    invoice:
      title: "Support Our Project"
      description: "Help us continue our work"
      payload: "donation_{{ donation_id }}"
      currency: "USD"
      provider_token: "${PAYMENT_PROVIDER_TOKEN}"
      prices:
        - label: "Donation"
          amount: 1000  # $10.00
      max_tip_amount: 5000  # Maximum tip: $50.00
      suggested_tip_amounts: [500, 1000, 2000, 5000]  # Suggest: $5, $10, $20, $50
```

### Invoice with User Information Collection

```yaml
endpoints:
  - path: "/payment/product"
    chat_id: "123456789"
    formatter: "plain"
    buttons:
      - - text: "Pay 100 XTR"
          pay: true
    invoice:
      title: "Physical Product"
      description: "Requires shipping information"
      payload: "product_{{ product_id }}"
      currency: "USD"
      provider_token: "${PAYMENT_PROVIDER_TOKEN}"
      prices:
        - label: "Product"
          amount: 5000  # $50.00
      need_name: true             # Request user's full name
      need_email: true            # Request user's email
      need_phone_number: true     # Request user's phone number
      need_shipping_address: true # Request shipping address
      is_flexible: false          # Set true if price depends on delivery method
```

### Sending Invoice Request

```bash
curl -X POST http://localhost:8000/payment/product \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-api-key" \
  -d '{
    "order_id": "12345",
    "user_id": "user_789",
    "shop_name": "My Shop"
  }'
```

### Using Telegram Stars

For Telegram Stars payments, use an empty provider_token:

```yaml
invoice:
  title: "Premium Feature"
  description: "Unlock premium features"
  payload: "stars_{{ feature_id }}"
  currency: "XTR"  # Telegram Stars
  provider_token: ""  # Empty for Telegram Stars
  prices:
    - label: "Premium Access"
      amount: 100  # 100 Telegram Stars
```

### Invoice-Only Endpoint (No Message)

If you want to send ONLY an invoice without a preceding message, simply don't configure a `template` or `formatter`, or send an empty message field:

```yaml
endpoints:
  - path: "/payment/quick"
    chat_id: "123456789"
    # No template or formatter configured
    buttons:
      - - text: "Pay 50 XTR"
          pay: true
    invoice:
      title: "Quick Payment"
      description: "Fast checkout"
      payload: "quick_{{ transaction_id }}"
      currency: "XTR"
      provider_token: ""
      prices:
        - label: "Amount"
          amount: 50
```

---

## Webhooks & Commands

### Setting Up Webhooks

Webhooks allow Telegram to send updates (button clicks, commands) to your server.

**1. Configure webhook URL:**

```yaml
bot:
  token: "${TELEGRAM_BOT_TOKEN}"
  webhook_url: "https://your-app.onrender.com"  # Your public URL
  webhook_path: "/bot/webhook"  # Default path
```

**2. Register webhook with Telegram:**

```bash
fastbotty webhook setup
```

**3. Verify webhook:**

```bash
fastbotty webhook info
```

**4. Remove webhook (if needed):**

```bash
fastbotty webhook delete
```

### Command Handlers

Respond to bot commands like `/start`, `/help`:

```yaml
commands:
  - command: "/start"
    response: |
      👋 Welcome {{ first_name }}!
      
      I'm FastBotty bot. I send notifications from your apps.
    buttons:
      - - text: "📚 Documentation"
          url: "https://github.com/venopyx/fastbotty"

  - command: "/help"
    response: |
      📖 *Available Commands*
      
      /start \- Welcome message
      /help \- Show this help
      /status \- Check bot status
    parse_mode: "MarkdownV2"

  - command: "/status"
    response: "✅ Bot is running!"
```

### Available Context Variables

In command responses, you can use:

| Variable | Description |
|----------|-------------|
| `{{ first_name }}` | User's first name |
| `{{ username }}` | User's @username |
| `{{ chat_id }}` | Chat ID |
| `{{ user }}` | Full user object |
| `{{ command }}` | Command that was triggered |

---

## Formatters

### Plain Formatter (Default)

Converts payload to simple `key: value` format.

```json
{"user": "John", "action": "login"}
```
→
```
user: John
action: login
```

### Markdown Formatter

Formats with Telegram Markdown. Keys named `title`, `heading`, or `header` become bold headers.

```json
{"title": "Alert!", "message": "CPU usage high", "value": "95%"}
```
→
```
*Alert!*
message: CPU usage high
value: 95%
```

**Note:** Use `parse_mode: "MarkdownV2"` in config for proper rendering.

---

## Custom Plugins

### Creating a Plugin

Create `plugins/my_formatter.py`:

```python
from typing import Any
from fastbotty import IPlugin


class GitHubFormatter(IPlugin):
    """Format GitHub webhook payloads"""

    @property
    def name(self) -> str:
        return "github_formatter"

    def format(self, payload: dict[str, Any], config: dict[str, Any]) -> str:
        event = payload.get("action", "unknown")
        repo = payload.get("repository", {}).get("full_name", "unknown")
        sender = payload.get("sender", {}).get("login", "unknown")

        lines = [
            f"🔔 GitHub: {event}",
            f"📁 Repo: {repo}",
            f"👤 By: {sender}",
        ]

        # Use plugin config
        if config.get("show_commits") and "commits" in payload:
            max_commits = config.get("max_commits", 3)
            lines.append("\n📝 Commits:")
            for commit in payload["commits"][:max_commits]:
                msg = commit["message"].split("\n")[0][:50]
                lines.append(f"  • {msg}")

        return "\n".join(lines)
```

### Using the Plugin

```yaml
endpoints:
  - path: "/webhook/github"
    chat_id: "8345389653"
    formatter: "github_formatter"
    plugin_config:
      show_commits: true
      max_commits: 5
```

### Simple Formatter (IFormatter)

For plugins without config:

```python
from fastbotty import IFormatter


class SimpleFormatter(IFormatter):
    def format(self, payload: dict) -> str:
        return f"Received: {payload}"
```

---

## Field Mapping

Map incoming payload fields to FastBotty's expected fields using dot notation for nested objects.

### Configuration

```yaml
endpoints:
  - path: "/webhook/shopify"
    chat_id: "8345389653"
    formatter: "plain"
    field_map:
      image_url: "product.featured_image"
      image_urls: "product.images"
      chat_id: "meta.notify_target"
```

### Example Payload

```json
{
  "order_id": 123,
  "product": {
    "name": "T-Shirt",
    "featured_image": "https://example.com/main.jpg",
    "images": [
      "https://example.com/1.jpg",
      "https://example.com/2.jpg"
    ]
  },
  "meta": {
    "notify_target": "8345389653"
  }
}
```

FastBotty automatically:
- Uses `product.featured_image` as the image
- Uses `product.images` for gallery
- Sends to `meta.notify_target` chat ID

---

## Authentication

### Enable API Key

```yaml
server:
  api_key: "${API_KEY}"
```

### Making Authenticated Requests

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -H "X-API-Key: your-secret-key" \
  -d '{"message": "Hello"}'
```

### Response Codes

- `200` - Success
- `401` - Invalid or missing API key
- `500` - Server error (check logs)

---

## Deployment

### Running Locally

```bash
# Development with auto-reload
fastbotty run --reload

# Production
fastbotty run --host 0.0.0.0 --port 8000
```

### Using Python Directly

```python
# main.py
from fastbotty import create_app

if __name__ == "__main__":
    import uvicorn
    app = create_app("config.yaml")
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### Docker

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["fastbotty", "run"]
```

```bash
docker build -t my-notifier .
docker run -p 8000:8000 \
  -e TELEGRAM_BOT_TOKEN="your-token" \
  -v $(pwd)/config.yaml:/app/config.yaml \
  my-notifier
```

### Docker Compose

```yaml
version: "3.8"
services:
  fastbotty:
    build: .
    ports:
      - "8000:8000"
    environment:
      - TELEGRAM_BOT_TOKEN=${TELEGRAM_BOT_TOKEN}
      - API_KEY=${API_KEY}
    volumes:
      - ./config.yaml:/app/config.yaml
      - ./plugins:/app/plugins
    restart: unless-stopped
```

### Systemd Service

```ini
# /etc/systemd/system/fastbotty.service
[Unit]
Description=FastBotty Notification Service
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/fastbotty
Environment=TELEGRAM_BOT_TOKEN=your-token
ExecStart=/usr/local/bin/fastbotty run
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable fastbotty
sudo systemctl start fastbotty
```

### Cloud Platforms

**Render.com:**
1. Connect GitHub repo
2. Set environment variables
3. Start command: `fastbotty run --host 0.0.0.0 --port $PORT`

**Railway.app:**
1. Connect repo
2. Add environment variables
3. Deploy automatically

**Fly.io:**
```bash
fly launch
fly secrets set TELEGRAM_BOT_TOKEN=your-token
fly deploy
```

---

## Health Check

```bash
curl http://localhost:8000/health
```

Response:
```json
{
  "status": "healthy",
  "endpoints": 2,
  "formatters": ["plain", "markdown", "github_formatter"]
}
```

---

## Troubleshooting

### Bot not sending messages

1. Check bot token is correct
2. Ensure bot is added to the chat/group
3. For channels, bot must be admin
4. Check `fastbotty validate` output

### Invalid chat_id

- User ID: positive number (`8345389653`)
- Group ID: negative number (`-123456789`)
- Supergroup/Channel: starts with `-100` (`-1001234567890`)
- Channel username: `@channel_name`

### Markdown parsing errors

Use `parse_mode: "MarkdownV2"` and ensure special characters are escaped. The markdown formatter handles this automatically.

### Rate limiting

FastBotty automatically retries with exponential backoff when rate limited. For high-volume use, consider:
- Multiple bot tokens
- Message queuing
- Batching notifications

---

## Examples

### CI/CD Pipeline Notification

```bash
# In your CI script
curl -X POST https://your-server.com/notify/ci \
  -H "Content-Type: application/json" \
  -H "X-API-Key: $NOTIFY_KEY" \
  -d "{
    \"title\": \"Build ${BUILD_STATUS}\",
    \"project\": \"${PROJECT_NAME}\",
    \"branch\": \"${BRANCH}\",
    \"commit\": \"${COMMIT_SHA:0:7}\",
    \"author\": \"${AUTHOR}\"
  }"
```

### E-commerce Order Notification

```yaml
# config.yaml
endpoints:
  - path: "/webhook/orders"
    chat_id: "-1001234567890"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    labels:
      id: "🆔 Order"
      customer_name: "👤 Customer"
      total_price: "💰 Total"
      items_count: "📦 Items"
    field_map:
      image_url: "line_items.0.image_url"
```

### Server Monitoring Alert

```python
import requests

def send_alert(metric, value, threshold):
    requests.post("http://localhost:8000/notify/alerts", json={
        "title": "⚠️ Alert",
        "metric": metric,
        "value": f"{value}%",
        "threshold": f"{threshold}%",
        "status": "CRITICAL" if value > threshold else "WARNING"
    })

# Usage
send_alert("CPU Usage", 95, 80)
```

---

## Reply Keyboards

Reply keyboards replace the user's standard keyboard with custom buttons. Perfect for creating bot menus and collecting user input.

### Basic Reply Keyboard

```yaml
endpoints:
  - path: "/survey"
    chat_id: "123456789"
    formatter: "plain"
    reply_keyboard:
      keyboard:
        - ["👍 Good", "👎 Bad"]
        - ["📝 Feedback"]
      resize_keyboard: true
      one_time_keyboard: true
      input_field_placeholder: "How was your experience?"
```

**Sending:**

```bash
curl -X POST http://localhost:8000/survey \
  -H "Content-Type: application/json" \
  -d '{"message": "Please rate our service"}'
```

### Request Contact or Location

Use special keyboard buttons to request user information:

```yaml
endpoints:
  - path: "/register"
    chat_id: "123456789"
    formatter: "plain"
    reply_keyboard:
      keyboard:
        - - text: "📞 Share Contact"
            request_contact: true
        - - text: "📍 Share Location"
            request_location: true
      resize_keyboard: true
```

### Web App Button in Reply Keyboard

```yaml
endpoints:
  - path: "/open-app"
    chat_id: "123456789"
    formatter: "plain"
    reply_keyboard:
      keyboard:
        - - text: "🚀 Open Dashboard"
            web_app:
              url: "https://app.example.com"
      resize_keyboard: true
```

### Dynamic Reply Keyboard with Templates

```yaml
endpoints:
  - path: "/order-actions"
    chat_id: "123456789"
    formatter: "plain"
    reply_keyboard:
      keyboard:
        - ["Confirm Order #{{ order_id }}", "Cancel Order #{{ order_id }}"]
        - ["View Details"]
      resize_keyboard: true
      one_time_keyboard: true
```

**Sending:**

```bash
curl -X POST http://localhost:8000/order-actions \
  -H "Content-Type: application/json" \
  -d '{"message": "Order ready", "order_id": "12345"}'
```

### Removing Reply Keyboard

```yaml
endpoints:
  - path: "/complete"
    chat_id: "123456789"
    formatter: "plain"
    reply_keyboard_remove:
      remove_keyboard: true
```

### Force Reply

Force users to reply to a message:

```yaml
endpoints:
  - path: "/ask-question"
    chat_id: "123456789"
    formatter: "plain"
    force_reply:
      force_reply: true
      input_field_placeholder: "Type your answer..."
```

---

## Sending Documents

Send PDF files, documents, and other file types:

### Basic Document

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Monthly report attached",
    "document_url": "https://example.com/report.pdf",
    "filename": "report_december_2024.pdf"
  }'
```

### Document with Custom Filename

```yaml
# config.yaml
endpoints:
  - path: "/send-report"
    chat_id: "123456789"
    formatter: "plain"
    parse_mode: "MarkdownV2"
```

**Sending:**

```bash
curl -X POST http://localhost:8000/send-report \
  -H "Content-Type: application/json" \
  -d '{
    "message": "*Monthly Report*\n\nGenerated on 2024-12-28",
    "document_url": "https://api.example.com/files/report.pdf",
    "filename": "Monthly_Report_Dec_2024.pdf"
  }'
```

### Field Mapping for Documents

```yaml
endpoints:
  - path: "/webhook/documents"
    chat_id: "123456789"
    formatter: "plain"
    field_map:
      document_url: "attachments.0.url"
      filename: "attachments.0.name"
```

---

## Sending Videos

Send videos with optional thumbnails and metadata:

### Basic Video

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Product demo video",
    "video_url": "https://example.com/demo.mp4",
    "thumbnail_url": "https://example.com/thumb.jpg"
  }'
```

### Video with Full Metadata

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Tutorial: Getting Started",
    "video_url": "https://example.com/tutorial.mp4",
    "thumbnail_url": "https://example.com/thumb.jpg",
    "width": 1920,
    "height": 1080,
    "duration": 300,
    "supports_streaming": true
  }'
```

### Configuration with Field Mapping

```yaml
endpoints:
  - path: "/webhook/videos"
    chat_id: "123456789"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    field_map:
      video_url: "media.video.url"
      thumbnail_url: "media.video.thumbnail"
      duration: "media.video.length"
```

---

## Sending Audio

Send audio files (music) with metadata:

### Audio with Full Details

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "New episode released!",
    "audio_url": "https://example.com/podcast-ep42.mp3",
    "title": "Episode 42: FastBotty Framework",
    "performer": "TechTalk Podcast",
    "duration": 3600,
    "thumbnail_url": "https://example.com/podcast-cover.jpg"
  }'
```

### Audio Configuration

```yaml
endpoints:
  - path: "/webhook/podcasts"
    chat_id: "-1001234567890"
    formatter: "plain"
    field_map:
      audio_url: "episode.audio_url"
      title: "episode.title"
      performer: "podcast.name"
      duration: "episode.duration_seconds"
      thumbnail_url: "podcast.cover_image"
```

---

## Sending Voice Messages

Send voice messages (like voice notes):

### Basic Voice Message

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Voice message from customer support",
    "voice_url": "https://example.com/voice-note.ogg",
    "duration": 45
  }'
```

### Voice with Field Mapping

```yaml
endpoints:
  - path: "/webhook/voice-notes"
    chat_id: "123456789"
    formatter: "plain"
    field_map:
      voice_url: "recording.url"
      duration: "recording.length"
```

---

## Location Sharing

Send GPS coordinates with optional live location tracking:

### Basic Location

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Order delivery location",
    "location": {
      "latitude": 40.7128,
      "longitude": -74.0060
    }
  }'
```

### Live Location with Options

```bash
curl -X POST http://localhost:8000/notify \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Driver location (live tracking)",
    "location": {
      "latitude": 40.7128,
      "longitude": -74.0060,
      "horizontal_accuracy": 50.0,
      "live_period": 3600,
      "heading": 90,
      "proximity_alert_radius": 100
    }
  }'
```

**Parameters:**
- `horizontal_accuracy`: Location accuracy in meters (0-1500)
- `live_period`: Time in seconds for live location updates (60-86400)
- `heading`: Direction of movement (1-360 degrees)
- `proximity_alert_radius`: Alert radius in meters (1-100000)

### Location with Field Mapping

```yaml
endpoints:
  - path: "/webhook/deliveries"
    chat_id: "123456789"
    formatter: "plain"
    field_map:
      location: "delivery.coordinates"
```

**Incoming payload:**

```json
{
  "order_id": "12345",
  "delivery": {
    "coordinates": {
      "latitude": 40.7128,
      "longitude": -74.0060
    },
    "status": "in_transit"
  }
}
```

### Location with Inline Buttons

```yaml
endpoints:
  - path: "/share-location"
    chat_id: "123456789"
    formatter: "plain"
    buttons:
      - - text: "🗺️ Open in Google Maps"
          url: "https://maps.google.com/?q={{ location.latitude }},{{ location.longitude }}"
      - - text: "📍 Get Directions"
          url: "https://www.google.com/maps/dir/?api=1&destination={{ location.latitude }},{{ location.longitude }}"
```

---

## Combined Examples

### Complete Media Notification System

```yaml
# config.yaml
endpoints:
  # Documents
  - path: "/notify/documents"
    chat_id: "123456789"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    field_map:
      document_url: "file.url"
      filename: "file.name"

  # Videos
  - path: "/notify/videos"
    chat_id: "123456789"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    field_map:
      video_url: "media.url"
      thumbnail_url: "media.thumbnail"

  # Audio
  - path: "/notify/audio"
    chat_id: "123456789"
    formatter: "plain"
    field_map:
      audio_url: "track.url"
      title: "track.name"
      performer: "track.artist"

  # Location
  - path: "/notify/location"
    chat_id: "123456789"
    formatter: "plain"
    buttons:
      - - text: "🗺️ View on Map"
          url: "https://maps.google.com/?q={{ location.latitude }},{{ location.longitude }}"
```

### Delivery Notification with Location and Reply Keyboard

```yaml
endpoints:
  - path: "/delivery/update"
    chat_id: "123456789"
    formatter: "markdown"
    parse_mode: "MarkdownV2"
    field_map:
      location: "driver.current_location"
    reply_keyboard:
      keyboard:
        - ["📍 Track Driver", "📞 Call Driver"]
        - ["✅ Confirm Delivery", "❌ Report Issue"]
      resize_keyboard: true
      one_time_keyboard: true
```

**Usage:**

```bash
curl -X POST http://localhost:8000/delivery/update \
  -H "Content-Type: application/json" \
  -d '{
    "message": "*Delivery Update*\n\nYour order is on the way!",
    "order_id": "12345",
    "driver": {
      "name": "John Doe",
      "phone": "+1234567890",
      "current_location": {
        "latitude": 40.7128,
        "longitude": -74.0060,
        "live_period": 1800,
        "heading": 45
      }
    }
  }'
```
