# Setup Catalyst Action

This action sets up [Catalyst](https://github.com/PraveenGongada/catalyst) in your GitHub Actions workflow, allowing you to trigger GitHub Actions workflows with matrix configurations for mobile app deployments.

## Features

- 🚀 **Fast setup** - Downloads and installs Catalyst binary
- 🔧 **Cross-platform** - Supports Linux and macOS runners
- 📦 **Flexible versioning** - Install latest or specific version

## Usage

### Basic Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Setup Catalyst
    uses: PraveenGongada/setup-catalyst@v1

  - name: Trigger deployment
    run: |
      catalyst --extract=ios_prod
```

### Advanced Usage

```yaml
steps:
  - uses: actions/checkout@v4

  - name: Setup Catalyst
    uses: PraveenGongada/setup-catalyst@v1
    with:
      version: "v1.0.1"
      github-token: ${{ secrets.GITHUB_TOKEN }}

  - name: Extract matrices
    run: |
      catalyst --extract=android_debug --format=yaml > matrices.yaml

  - name: Use extracted matrices
    run: |
      cat matrices.yaml
```

## Requirements

- GitHub Actions runner (Linux or macOS)

## License

This action is distributed under the MIT License - see the [LICENSE](LICENSE) file for details.
