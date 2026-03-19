# sHC Minimal Architecture

This repository contains the IETF draft for the SCHC Architecture, which defines a minimal architecture for deploying the Static Context Header Compression and fragmentation (SCHC) framework. The draft is intended to provide guidance for implementers and operators on the essential components and their interactions required for effective SCHC operation.

## Abstract

Static Context Header Compression and fragmentation (SCHC) framework provides both a header compression mechanism and an optional fragmentation mechanism. This document defines a minimal architecture for SCHC deployments, providing guidance for implementers and operators on the essential components and their interactions required for effective SCHC operation.

## Building the Draft

This draft uses [kramdown-rfc](https://github.com/cabo/kramdown-rfc) and [xml2rfc](https://github.com/ietf-tools/xml2rfc) for generating the various output formats.

### Prerequisites

Make sure you have the following tools installed:

```bash
# Install kramdown-rfc (Ruby gem)
gem install kramdown-rfc

# Install xml2rfc (Python package)
# Using uv (recommended)
uv tool install xml2rfc

# Or using pip
pip install xml2rfc
```

### Building

Use the provided Makefile to build the draft:

```bash
# Generate TXT, HTML, and XML files
make

# Generate all formats including PDF
make complete

# Generate specific format
make txt
make html
make xml
make pdf

# Check if tools are installed
make check-tools

# Validate the XML
make validate

# Clean generated files
make clean

# Show help
make help
```

### Manual Generation

You can also generate the files manually:

```bash
# Generate TXT file
kdrfc draft-lampin-schc-minimal-architecture-00.md

# Generate HTML file
kdrfc --html draft-lampin-schc-minimal-architecture-00.md

# Generate XML file
kdrfc --xml draft-lampin-schc-minimal-architecture-00.md

# Generate PDF file
kdrfc --pdf draft-lampin-schc-minimal-architecture-00.md
```

## Files

- `schc-revised-architecture.md` - Main draft source in Markdown format
- `Makefile` - Build automation
- `README.md` - This file
- `.gitignore` - Git ignore rules

## Contributing

This is an IETF draft. Please follow the standard IETF process for contributions.

## License

This document is subject to the rights, licenses and restrictions contained in BCP 78, and except as set forth therein, the authors retain all their rights.
