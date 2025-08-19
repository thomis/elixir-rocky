[![CI Build Status](https://github.com/thomis/elixir-rocky/actions/workflows/ci.yml/badge.svg)](https://github.com/thomis/elixir-rocky/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

# Elixir Development Stack on Rocky Linux

A production-ready Docker image combining Elixir, Phoenix Framework, Go, and Bun on Rocky Linux. Perfect for building scalable web applications, APIs, and microservices with a polyglot development stack.

## 📦 Container Registry

The Docker image is available on GitHub Container Registry (GHCR):

```bash
docker pull ghcr.io/thomis/elixir-rocky:latest
```

View all available tags: [ghcr.io/thomis/elixir-rocky](https://github.com/thomis/elixir-rocky/pkgs/container/elixir-rocky)

## 🚀 Quick Start

### Using the Pre-built Image

```bash
# Pull the latest image
docker pull ghcr.io/thomis/elixir-rocky:latest

# Run an interactive shell
docker run --rm -it ghcr.io/thomis/elixir-rocky:latest bash

# Run with your application mounted
docker run --rm -it -v $(pwd):/app -w /app ghcr.io/thomis/elixir-rocky:latest bash
```

### Building Locally

```bash
# Build and run the container for development
docker run --rm -it $(docker build -q .) bash

# Build with a specific tag
docker build -t my-elixir-rocky:dev .
```

## 🛠️ Included Software

This image includes the following development tools:

| Component | Description | Repository |
|-----------|-------------|------------|
| **Erlang/OTP** | High-performance runtime system | [erlang/otp](https://github.com/erlang/otp) |
| **Elixir** | Dynamic, functional programming language | [elixir-lang/elixir](https://github.com/elixir-lang/elixir) |
| **Phoenix Framework** | Productive web framework for Elixir | [phoenixframework/phoenix](https://github.com/phoenixframework/phoenix) |
| **Go** | Fast, statically typed compiled language | [golang/go](https://github.com/golang/go) |
| **Bun** | All-in-one JavaScript runtime & toolkit | [oven-sh/bun](https://github.com/oven-sh/bun) |

## 📋 Use Cases

This image is ideal for:

- **Phoenix Framework Applications** - Full-stack web applications with real-time features
- **Microservices** - Building distributed systems with Elixir and Go
- **API Development** - RESTful and GraphQL APIs
- **Full-Stack Development** - Combined backend (Elixir/Phoenix) and frontend (Bun) development
- **CI/CD Pipelines** - Consistent build environment for automated testing and deployment

## 🔧 Configuration

The image is based on Rocky Linux for enterprise-grade stability and includes:

- Latest stable versions of all included software
- Development headers and build tools
- Common system libraries
- UTF-8 locale configuration

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📞 Support

For issues, questions, or suggestions, please [open an issue](https://github.com/thomis/elixir-rocky/issues) on GitHub.
