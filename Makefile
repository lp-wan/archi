# Makefile for IETF draft generation using kramdown-rfc and xml2rfc

SOURCE_FILE = schc-architecture
MARKDOWN_FILE = $(SOURCE_FILE).md

# Extract draft base name from markdown metadata (e.g., draft-ietf-schc-architecture)
DRAFT_NAME = $(shell grep -E '^\s*docname:' $(MARKDOWN_FILE) | awk '{print $$2}')


# Output files
XML_FILE = $(DRAFT_NAME).xml
TXT_FILE = $(DRAFT_NAME).txt
HTML_FILE = $(DRAFT_NAME).html
PDF_FILE = $(DRAFT_NAME).pdf

# Default target
all: txt html xml pdf

# Generate all formats
complete: txt html xml pdf

# Individual targets
txt: $(TXT_FILE)
html: $(HTML_FILE)
xml: $(XML_FILE)
pdf: $(PDF_FILE)

# Build rules (kdrfc names outputs after the source file, so we rename)
$(TXT_FILE): $(MARKDOWN_FILE)
	@echo "Generating TXT file..."
	kdrfc --txt $(MARKDOWN_FILE)
	mv $(SOURCE_FILE).txt $(TXT_FILE)

$(HTML_FILE): $(MARKDOWN_FILE)
	@echo "Generating HTML file..."
	kdrfc --html $(MARKDOWN_FILE)
	mv $(SOURCE_FILE).html $(HTML_FILE)

$(XML_FILE): $(MARKDOWN_FILE)
	@echo "Generating XML file..."
	kdrfc --xml $(MARKDOWN_FILE)
	mv $(SOURCE_FILE).xml $(XML_FILE)

$(PDF_FILE): $(MARKDOWN_FILE)
	@echo "Generating PDF file using remote service..."
	kdrfc --pdf --remote $(MARKDOWN_FILE)
	mv $(SOURCE_FILE).pdf $(PDF_FILE)

# Clean generated files
clean:
	@echo "Cleaning generated files for $(DRAFT_NAME)..."
	rm -f $(XML_FILE) $(TXT_FILE) $(HTML_FILE) $(PDF_FILE)

# Check if required tools are installed
check-tools:
	@echo "Checking required tools..."
	@which kdrfc > /dev/null || (echo "ERROR: kdrfc not found. Install kramdown-rfc" && false)
	@which xml2rfc > /dev/null || (echo "ERROR: xml2rfc not found. Install xml2rfc" && false)
	@echo "All required tools are available."

# Validate the draft
validate: $(XML_FILE)
	@echo "Validating XML file..."
	xml2rfc --validate $(XML_FILE)

# Preview in browser (macOS specific)
preview: $(HTML_FILE)
	open $(HTML_FILE)

# Help target
help:
	@echo "Available targets:"
	@echo "  all       - Generate all formats (default)"
	@echo "  complete  - Generate all formats including PDF"
	@echo "  txt       - Generate TXT file only"
	@echo "  html      - Generate HTML file only"
	@echo "  xml       - Generate XML file only"
	@echo "  pdf       - Generate PDF file only"
	@echo "  clean     - Remove all generated files"
	@echo "  check-tools - Check if required tools are installed"
	@echo "  validate  - Validate the XML file"
	@echo "  preview   - Open HTML file in browser (macOS)"
	@echo "  help      - Show this help message"

.PHONY: all complete txt html xml pdf clean check-tools validate preview help
