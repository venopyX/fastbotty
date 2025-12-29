# FastBotty Future Roadmap

Ideas and planned features for future versions.

## ✅ Reply Markup (IMPLEMENTED)
Support for reply keyboards and remove keyboard.

**Implemented in v1.x.x:**
- Reply keyboard markup with text buttons
- Special request buttons (contact, location, poll, web_app)
- Keyboard customization (resize, one_time, persistent)
- Input field placeholder support
- Force reply functionality
- Reply keyboard removal
- Template support for all reply markup types

Example usage:
```yaml
endpoints:
  - path: "/survey"
    reply_keyboard:
      keyboard:
        - ["👍 Good", "👎 Bad"]
        - ["📝 Feedback"]
      one_time_keyboard: true
      resize_keyboard: true
```

## Force Reply (IMPLEMENTED via Reply Markup)
Force users to reply to messages.

## ✅ Document Support (IMPLEMENTED)
Send files and documents.

**Implemented in v1.x.x:**
- Document sending with caption support
- Custom filename specification
- Field mapping for document URLs
- Reply markup support (inline and reply keyboards)
- Parse mode support for captions

Example usage:
```json
{
  "message": "Monthly report",
  "document_url": "https://example.com/report.pdf",
  "filename": "report_dec_2024.pdf"
}
```

## ✅ Video Support (IMPLEMENTED)
Send videos with thumbnails.

**Implemented in v1.x.x:**
- Video sending with caption
- Thumbnail support
- Metadata support (width, height, duration)
- Streaming support flag
- Field mapping for video URLs
- Reply markup support

Example usage:
```json
{
  "caption": "Product demo",
  "video_url": "https://example.com/demo.mp4",
  "thumbnail_url": "https://example.com/thumb.jpg"
}
```

## ✅ Audio/Voice Messages (IMPLEMENTED)

**Implemented in v1.x.x:**
- Audio file sending with metadata (title, performer, duration)
- Voice message sending
- Thumbnail support for audio
- Caption support for both audio and voice
- Field mapping support

Audio example:
```json
{
  "audio_url": "https://example.com/podcast.mp3",
  "title": "Episode 42",
  "performer": "TechTalk"
}
```

Voice example:
```json
{
  "voice_url": "https://example.com/voice.ogg",
  "duration": 30
}
```

## ✅ Location Sharing (IMPLEMENTED)

**Implemented in v1.x.x:**
- GPS coordinate sending (latitude, longitude)
- Live location tracking with duration
- Horizontal accuracy specification
- Heading/direction support
- Proximity alert radius
- Reply markup support

Example usage:
```json
{
  "message": "Order delivery location",
  "location": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "live_period": 3600,
    "horizontal_accuracy": 50.0
  }
}
```

## Message Editing
Edit previously sent messages.

```yaml
endpoints:
  - path: "/update"
    method: "edit"
```

## Message Queue Integration
Optional Redis/RabbitMQ queue for high-volume scenarios.

```yaml
queue:
  enabled: true
  backend: "redis"
  url: "redis://localhost:6379"
  retry_attempts: 5
  retry_delay: 60
```

## Batch Sending
Send to multiple chats in one request.

```json
{
  "message": "Broadcast announcement",
  "chat_ids": ["123", "456", "789"]
}
```

## Scheduled Messages
Schedule notifications for later delivery.

```json
{
  "message": "Reminder: Meeting in 1 hour",
  "schedule_at": "2024-12-26T10:00:00Z"
}
```

## Dead Letter Queue
Store failed messages for retry/inspection.

```yaml
dlq:
  enabled: true
  storage: "sqlite"
  retention_days: 7
```

## Prometheus Metrics
Built-in metrics endpoint.

```yaml
metrics:
  enabled: true
  path: "/metrics"
```

## Webhook Logging
Log all incoming webhooks for debugging.

```yaml
logging:
  level: "INFO"
  webhook_logging: true
  log_payloads: true
```

## Delivery Reports
Track message delivery status.

```yaml
tracking:
  enabled: true
  callback_url: "https://your-app.com/delivery-status"
```

## Slack Integration
Send to Slack alongside Telegram.

```yaml
channels:
  telegram:
    token: "${TELEGRAM_BOT_TOKEN}"
  slack:
    webhook_url: "${SLACK_WEBHOOK_URL}"

endpoints:
  - path: "/notify/critical"
    targets:
      - type: telegram
        chat_id: "8345389653"
      - type: slack
        channel: "#alerts"
```

## Discord Integration

```yaml
channels:
  discord:
    webhook_url: "${DISCORD_WEBHOOK_URL}"
```

## Email Fallback
Send email if Telegram fails.

```yaml
channels:
  email:
    smtp_host: "smtp.gmail.com"
    smtp_port: 587
    username: "${EMAIL_USER}"
    password: "${EMAIL_PASS}"

endpoints:
  - path: "/notify/important"
    targets:
      - type: telegram
        chat_id: "8345389653"
    fallback:
      - type: email
        to: "admin@example.com"
```

## Webhook Signature Verification
Verify incoming webhooks from known sources.

```yaml
endpoints:
  - path: "/webhook/github"
    signature:
      header: "X-Hub-Signature-256"
      secret: "${GITHUB_WEBHOOK_SECRET}"
      algorithm: "sha256"
```

## Rate Limiting
Per-endpoint rate limits.

```yaml
endpoints:
  - path: "/notify"
    rate_limit:
      requests: 100
      period: 60
```

## IP Allowlist
Restrict access by IP.

```yaml
security:
  ip_allowlist:
    - "192.168.1.0/24"
    - "10.0.0.0/8"
```

## JWT Authentication
Support JWT tokens alongside API keys.

```yaml
auth:
  jwt:
    secret: "${JWT_SECRET}"
    algorithm: "HS256"
```

## Web Dashboard
Simple web UI for viewing message history, testing endpoints, managing configuration, and monitoring health.

```yaml
dashboard:
  enabled: true
  path: "/admin"
  username: "admin"
  password: "${DASHBOARD_PASSWORD}"
```

## OpenAPI Schema
Auto-generated API documentation (already supported via FastAPI).

```yaml
docs:
  enabled: true
  path: "/docs"
```

## Config Hot Reload
Reload configuration without restart.

```bash
curl -X POST http://localhost:8000/admin/reload
```

## Plugin Marketplace
Community plugins repository.

```bash
fastbotty plugin install github-formatter
fastbotty plugin install shopify-orders
```

## Health & Readiness Probes
Kubernetes-ready health endpoints.

```yaml
health:
  enabled: true
  path: "/health"
  readiness_path: "/ready"
  include_details: true
```

## Graceful Shutdown
Clean shutdown with message draining.

```yaml
server:
  shutdown_timeout: 30
  drain_connections: true
```

## Request ID Tracking
Trace requests through the system.

```yaml
logging:
  request_id: true
  request_id_header: "X-Request-ID"
```

## Structured Logging
JSON logging for log aggregation systems.

```yaml
logging:
  format: "json"
  include_timestamp: true
  include_level: true
```

## Config Validation
Validate configuration before deployment.

```bash
fastbotty validate --strict
fastbotty validate --dry-run
```

## Config Diff
Show differences between configs.

```bash
fastbotty config diff config.yaml config.prod.yaml
```

## Environment Profiles
Multiple environment configurations.

```yaml
profiles:
  development:
    bot:
      test_mode: true
    logging:
      level: "DEBUG"
  production:
    bot:
      test_mode: false
    logging:
      level: "INFO"
    server:
      api_key: "${API_KEY}"
```

## Secret Management
Integrate with secret managers.

```yaml
secrets:
  provider: "aws-secrets-manager"
  prefix: "fastbotty/"

bot:
  token: "${secrets:bot-token}"
```

## Plugin Discovery
Auto-discover and load plugins.

```yaml
plugins:
  auto_discover: true
  paths:
    - "./plugins"
    - "/etc/fastbotty/plugins"
```

## Plugin Configuration Schema
Plugins define their own config schema.

```python
class MyPlugin(IPlugin):
    CONFIG_SCHEMA = {
        "api_key": {"type": "string", "required": True},
        "timeout": {"type": "integer", "default": 30}
    }
```

## Plugin Hooks
Lifecycle hooks for plugins.

```python
class MyPlugin(IPlugin):
    async def on_startup(self, app):
        pass

    async def on_shutdown(self, app):
        pass

    async def before_send(self, message, chat_id):
        return message

    async def after_send(self, result, chat_id):
        pass
```

## Event Bus
Publish events for external systems.

```yaml
events:
  enabled: true
  handlers:
    - type: "webhook"
      url: "https://your-system.com/events"
      events: ["message.sent", "message.failed"]
```

## Tenant Isolation
Support multiple tenants with isolated configs.

```yaml
tenants:
  enabled: true
  header: "X-Tenant-ID"

  configs:
    tenant_a:
      bot:
        token: "${TENANT_A_TOKEN}"
      endpoints:
        - path: "/notify"
          chat_id: "${TENANT_A_CHAT}"
```

## Per-Tenant Rate Limiting

```yaml
tenants:
  rate_limits:
    default:
      requests: 100
      period: 60
    premium:
      requests: 1000
      period: 60
```

## Conditional Routing
Route messages based on payload content.

```yaml
endpoints:
  - path: "/notify"
    routes:
      - condition: "severity == 'critical'"
        chat_id: "-1001234567890"
      - condition: "severity == 'info'"
        chat_id: "8345389653"
```

## Message Deduplication
Prevent duplicate messages within a time window.

```yaml
deduplication:
  enabled: true
  window: 300
  key_fields: ["order_id", "event_type"]
```

## Transformation Pipeline
Transform payload before formatting.

```yaml
endpoints:
  - path: "/webhook/raw"
    transform:
      - type: "jq"
        expression: "{order: .data.order_id, total: .data.amount}"
      - type: "enrich"
        lookup: "customers"
        key: "customer_id"
```

## A/B Testing
Test different message formats.

```yaml
endpoints:
  - path: "/notify"
    ab_test:
      - weight: 50
        formatter: "plain"
      - weight: 50
        formatter: "markdown"
```

## Enhanced Testing Infrastructure
Add integration tests with actual Telegram API, performance benchmarks, load testing scenarios, and improve test coverage to >80%.

## Better Error Messages
More descriptive validation errors in config loading, better error context in failed message sends, and user-friendly error messages in CLI commands.

## Configuration Validation Tool

```bash
fastbotty validate --strict
fastbotty validate --explain
```

## Dry-Run Mode

```bash
fastbotty run --dry-run
```

## Message Preview Feature

```bash
fastbotty preview config.yaml /notify/orders sample-payload.json
```

## Improved CLI Experience
Colorized output, progress bars for long-running operations, interactive configuration wizard, and better help text and examples.

## Advanced Template Features
Template inheritance and includes, custom Jinja2 filters, template testing utilities, and template validation on startup.

```yaml
templates:
  base: |
    {% block header %}Default Header{% endblock %}
    {% block content %}{% endblock %}

  order: |
    {% extends "base" %}
    {% block content %}
    Order #{{ order_id }}
    {% endblock %}
```

## Message Batching & Throttling
Configurable rate limiting per endpoint, automatic message batching for high-volume scenarios, queue-based message processing, and backpressure handling.

```yaml
endpoints:
  - path: "/notify/bulk"
    chat_id: "123"
    batching:
      enabled: true
      max_batch_size: 10
      flush_interval: 5
    rate_limit:
      max_per_minute: 20
```

## Message Persistence & Retry
SQLite-based message queue for reliability, configurable retry strategies, dead letter queue for failed messages, and message status tracking.

```yaml
persistence:
  enabled: true
  backend: "sqlite"
  db_path: "/var/lib/fastbotty/messages.db"
  retry:
    max_attempts: 5
    backoff: "exponential"
    initial_delay: 1
    max_delay: 3600
```

## Webhook Validation
HMAC signature verification for incoming webhooks, IP allowlisting, and request timestamp validation.

```yaml
endpoints:
  - path: "/webhook/github"
    signature:
      header: "X-Hub-Signature-256"
      secret: "${GITHUB_WEBHOOK_SECRET}"
      algorithm: "sha256"
    security:
      require_https: true
      allowed_ips:
        - "192.30.252.0/22"
```

## Metrics & Monitoring
Prometheus metrics endpoint, built-in health checks, performance metrics, and message delivery tracking.

```yaml
metrics:
  enabled: true
  path: "/metrics"
  include_labels: true
```

## Link Formatting Improvements
Added `format_link()` utility function for proper link formatting across different parse modes and `escape_html()` function for safe HTML entity escaping.

## Enterprise-Grade Automation
Enhanced Makefile with comprehensive developer commands, semantic version bumping, pre-release validation checks, security audit capabilities, and improved release automation with rollback support.

## Quick Win Features
- `--dry-run` flag: Test config without sending.
- Config reload signal: `SIGHUP` to reload config.
- Startup banner: Show config summary on start.
- Message preview: Preview formatted message.
- Retry status endpoint: Show retry queue status.
- Config export: Export config as JSON schema.
- Endpoint testing: `fastbotty test /path payload.json`.
- Message history: Store last N messages sent.
- Duplicate detection: Prevent duplicate sends.

## Integration Ideas
Pre-built integrations for CI/CD, monitoring, and e-commerce.

```yaml
integrations:
  github_actions:
    enabled: true
    events: ["workflow_run.completed"]
    template: "github_workflow"
```

## Two-Way Communication
Handle incoming messages from users.

```yaml
bot:
  token: "${TELEGRAM_BOT_TOKEN}"
  handlers:
    - command: "/start"
      response: "Welcome to notifications!"
    - command: "/subscribe"
      action: "subscribe_user"
```

## User Subscriptions
Let users subscribe/unsubscribe from notifications.

```python
# Auto-generated endpoints
POST /subscribe    # User subscribes
DELETE /subscribe  # User unsubscribes
GET /subscribers   # List subscribers
```

## Conversation Flows
Multi-step interactions.

```yaml
flows:
  feedback:
    - ask: "How would you rate our service?"
      options: ["⭐", "⭐⭐", "⭐⭐⭐", "⭐⭐⭐⭐", "⭐⭐⭐⭐⭐"]
      save_as: "rating"
    - ask: "Any comments?"
      save_as: "comment"
    - action: "save_feedback"
```

## Inline Queries
Respond to inline queries.

```yaml
inline:
  enabled: true
  handler: "search_products"
```
