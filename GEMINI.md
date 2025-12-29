# FastBotty Project Overview

FastBotty is a powerful Python-based framework designed for sending notifications(currently supports only Telegram) efficiently via HTTP webhooks. It serves as a versatile tool for various notification needs, including alerts, order updates, monitoring, and CI/CD pipeline notifications, by forwarding incoming HTTP requests as formatted Telegram messages.

## Key Features

-   **Simple & Fast Setup**: Get started with FastBotty in under 5 minutes.
-   **Plugin System**: Extensible architecture supporting custom formatters without modifying core code.
-   **Versatile Chat Support**: Send notifications to private chats, groups, supergroups, and channels (currently supports only Telegram).
-   **Broadcast Capabilities**: Send messages to multiple chats simultaneously.
-   **Rich Media**: Support for single images and photo galleries (up to 10 images).
-   **Interactive Elements**: Inline keyboards with dynamic templates and command handlers (e.g., `/start`, `/help`).
-   **Configuration Flexibility**: Universal `${VAR}` support for environment variables in all configuration fields.
-   **Data Mapping**: Custom labels for fields and dot-notation field mapping for nested JSON structures.
-   **Templating**: Utilizes Jinja2 for advanced message templating, including conditionals, loops, and filters.
-   **Built-in Formatters**: Provides plain text and Markdown formatters, with options for custom plugins.
-   **Security**: API key authentication for incoming webhooks.
-   **CORS Ready**: Configurable CORS settings for web frontends.
-   **Reliability**: Automatic retries with exponential backoff for sending messages.
-   **Docker Support**: Easy containerized deployment.
-   **CLI Tools**: Command-line interface for project initialization, running the server, and webhook management.

## Project Architecture

The FastBotty project is structured to ensure modularity and extensibility:

-   **`fastbotty/cli/`**: Contains the command-line interface commands powered by `Click`, enabling users to initialize projects (`init`), run the server (`run`), validate configurations (`validate`), and manage Telegram webhooks (`webhook`).
-   **`fastbotty/core/`**: Houses the core logic of the application:
    -   `bot.py`: Implements the `TelegramBot` class, managing all interactions with the Telegram Bot API for sending messages, photos, media groups, and webhook management, including robust retry mechanisms using `aiohttp`.
    -   `config.py`: Defines Pydantic models for the entire application configuration, including `AppConfig`, `BotConfig`, `EndpointConfig`, `ServerConfig`, `LoggingConfig`, `CallbackConfig`, and `CommandConfig`. It also handles environment variable resolution.
    -   `interfaces.py`: Defines the `IFormatter` and `IPlugin` abstract base classes, providing standard interfaces for creating custom message formatters and plugins.
    -   `registry.py`: Manages the discovery, registration, and retrieval of custom formatters and plugins, allowing for dynamic extension of FastBotty's functionality.
-   **`fastbotty/formatters/`**: Contains concrete implementations of message formatters:
    -   `base.py`: Provides a `BaseFormatter` class that offers basic functionality for converting dictionary payloads to string representations, handling labels, and recursive data structures.
    -   `plain.py`: A simple formatter that converts payloads to plain text.
    -   `markdown.py`: A formatter that converts payloads to Telegram-compatible MarkdownV2 format, with proper escaping and support for basic styling.
-   **`fastbotty/server/`**: Manages the web server component:
    -   `app.py`: The FastAPI application factory function (`create_app`) responsible for initializing the FastAPI app, loading configuration, setting up logging, configuring CORS, initializing the `TelegramBot` and `PluginRegistry`, and storing them in the app state. It also defines root and health check endpoints.
    -   `routes.py`: Dynamically registers API endpoints based on the `EndpointConfig` in the application configuration. It handles incoming webhook requests, including authentication, message formatting (using registered formatters or Jinja2 templates), media handling, inline keyboard construction, and dispatching messages via the `TelegramBot`. It also sets up handlers for Telegram webhook updates (callback queries and bot commands).
-   **`fastbotty/utils/`**: Contains utility functions:
    -   `escape.py`: Provides functions for safely escaping special characters in message text for various Telegram parse modes (MarkdownV2, Markdown, HTML) to prevent rendering issues and vulnerabilities.
    -   `validators.py`: Offers helper functions for validating Telegram chat IDs, parse modes, and sanitizing dictionary payloads by removing `None` or empty string values.
-   **`templates/`**: Stores template files used by the `fastbotty init` command to scaffold new projects, including `config.yaml.template`, `main.py.template`, `README.md.template`, and `plugins/example_formatter.py.template`.

## Building and Running

### Installation

```bash
pip install fastbotty
```

### Creating a New Project

```bash
fastbotty init my_notifier
cd my_notifier
```

### Configuration

Edit `config.yaml` to define your bot token, endpoints, and other settings. Environment variables (`${VAR}`) are supported.

Example `config.yaml`:

```yaml
bot:
  token: "${TELEGRAM_BOT_TOKEN}" # Telegram bot token
  test_mode: false # Log instead of sending for testing
  webhook_url: "${WEBHOOK_URL}" # Public URL for receiving updates
  webhook_path: "/bot/webhook" # Webhook endpoint path

endpoints:
  - path: "/notify/orders" # HTTP endpoint path
    chat_id: "${CHAT_ID}" # Single chat ID or @username
    formatter: "plain" # plain, markdown, or plugin name
    # template: "order_received" # Use a defined template
    # parse_mode: "MarkdownV2" # Telegram parse mode
    # labels: # Custom display labels
    #   order_id: "🆔 Order"
    # field_map: # Map incoming JSON fields
    #   image_url: "product.photo"
    # buttons: # Inline keyboard buttons
    #   - text: "View Order"
    #     url: "https://example.com/orders/{{ order_id }}"

templates:
  # Define Jinja2 templates for messages
  # order_received: |
  #   🛒 *New Order \#{{ order_id }}*
  #   Customer: {{ customer }}
  #   Total: {{ total }}

server:
  host: "0.0.0.0"
  port: "${PORT:-8000}" # Use PORT env var or default to 8000
  api_key: "${API_KEY}" # Optional authentication
  cors_origins: ["*"] # CORS allowed origins

logging:
  level: "INFO" # DEBUG, INFO, WARNING, ERROR

# Define callback handlers for inline button presses
callbacks:
  # - data: "confirm_order"
  #   response: "Order confirmed!"
  #   url: "http://myapi.com/confirm_order"

# Define command handlers for bot commands (e.g., /start)
commands:
  # - command: "/start"
  #   response: "Hello there! How can I help you today?"
  #   parse_mode: "MarkdownV2"
  #   buttons:
  #     - text: "Help"
  #       callback_data: "show_help"
```

### Running the Server

Ensure `TELEGRAM_BOT_TOKEN` and any other required environment variables are set (e.g., in a `.env` file or exported).

```bash
export TELEGRAM_BOT_TOKEN="your_bot_token"
fastbotty run
```

For development with automatic reloading:

```bash
fastbotty run --reload
```

### CLI Commands

-   `fastbotty init <project_name>`: Initializes a new FastBotty project.
-   `fastbotty run`: Starts the FastBotty server.
-   `fastbotty validate`: Validates the `config.yaml` file.
-   `fastbotty webhook setup [--url <webhook_url>]`: Registers the webhook with Telegram.
-   `fastbotty webhook info`: Shows the current webhook status.
-   `fastbotty webhook delete`: Removes the registered webhook.
-   `fastbotty --version`: Displays the installed FastBotty version.

### Building from Source

```bash
# Create virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install dependencies
pip install -r requirements-dev.txt

# Build
python -m build
```

### Testing

```bash
# Activate virtual environment
source .venv/bin/activate

# Run tests
python -m pytest
```

## Development Conventions

-   **Code Formatting**: `black` with a line length of 100 characters, targeting Python 3.10.
-   **Linting**: `ruff` is used for linting.
-   **Type Checking**: `mypy` is configured for strict type checking on Python 3.10.
-   **Testing Framework**: `pytest` is used for unit and integration tests, with `pytest-asyncio` for asynchronous test cases.
