# SynWatch

**SynWatch** is an open-source API monitoring and testing platform focused on simplicity, visibility, and developer ergonomics.

Define endpoints, attach tests, run them against different environments, and keep track of failures — all without writing custom scripts.

---

## ✨ Features

- 🔍 **Endpoint monitoring**  
  Define HTTP endpoints with method, base URL, and path.

- 🧪 **Test definitions**  
  Attach tests to endpoints with expected HTTP status codes, headers, and payloads.

- 🌍 **Environment support**  
  Run tests against multiple environments (e.g. staging, production) with environment-specific variables.

- 🔁 **Variables**  
  Reuse values across requests using variables.

- 🔐 **Secrets**  
  Secure, encrypted secrets resolved only at runtime.

- 📊 **Test run history**  
  Track passed, failed, and errored test runs with timing and response details.

- ⚡ **Concurrent execution**  
  Run multiple tests in parallel.

- 🔑 **GitHub authentication**  
  Simple sign-in via GitHub OAuth.

---

## 🏗️ Tech Stack

- **Elixir** & **Phoenix**
- **Phoenix LiveView**
- **Ecto** & **PostgreSQL**
- **Tailwind CSS**
- **Finch** (HTTP client)

---

## 🚀 Getting Started

### Prerequisites

- Elixir `~> 1.15`
- Erlang / OTP `~> 26`
- PostgreSQL
- Node.js (for assets)

### Setup

**Clone repository**

```bash
git clone git@github.com:SynTools/synwatch.git
cd synwatch
```

**Add environment variables**

```bash
touch .env
```

```
GITHUB_CLIENT_ID=<YOUR_GITHUB_CLIENT_ID>
GITHUB_CLIENT_SECRET=<YOUR_GITHUB_CLIENT_SECRET>

CLOAK_KEY=<Random 32 Bit String>
```

**Start development server**

```bash
mix phx.server
```

The app will be available at  
👉 http://localhost:4000

---

## 🔧 Configuration

### Database

Configure your database in `config/dev.exs`:

```elixir
config :synwatch, Synwatch.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "synwatch_dev"
```
---

## 🧩 Placeholders & Variables

SynWatch supports placeholders inside request URLs, headers, and bodies.

### Variables

```text
${{var:BASE_URL}}
${{var:API_VERSION}}
```

Variables are resolved per environment at runtime.

### Secrets

```text
${{secret:API_TOKEN}}
```

Secrets are stored encrypted and never rendered in plaintext in the UI.

---

## 🧪 Running Tests

Tests can be executed:

- Manually via the UI
- In bulk using concurrent execution
- Per environment

Each run creates a **TestRun** record containing:
- request metadata
- response status & body
- duration
- error details (if any)

---

## 🗺️ Roadmap

- ⏱️ Scheduled test runs
- 🔔 Notifications (Slack, Webhooks, Email)
- 🔐 Encrypted secrets using Cloak
- 📈 Basic analytics & trends
- 🌙 Dark mode
- 🧩 Configure endpoints and tests via YAML

---

## 🤝 Contributing

Contributions are very welcome!

Typical ways to contribute:
- Bug reports
- Feature requests
- Documentation improvements
- Code contributions

Please open an issue before submitting larger changes.

---

## 📄 License

This project is licensed under the **MIT License**.

---

## 💡 Philosophy

SynWatch is built with a simple idea:

> Monitoring and testing APIs should be **visible, explicit, and boring** —  
> because surprises belong in production incidents, not in your tooling.

---

## 🧠 Name

**SynWatch** stands for:
- **Syn** → system, synchronization, signal
- **Watch** → observe, monitor, keep an eye on

---

If you have questions or ideas, feel free to open an issue or start a discussion.
