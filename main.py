import markdown
import pdfkit
import os

def convert_readme_to_pdf(readme_path='README.md', css_path='style.css'):
    output_path = os.environ.get("OUTPUT_PDF", "README.pdf")
    config = pdfkit.configuration(wkhtmltopdf='/usr/local/bin/wkhtmltopdf')

    # Read Markdown
    with open(readme_path, 'r', encoding='utf-8') as f:
        md_text = f.read()

    # Read CSS
    with open(css_path, 'r', encoding='utf-8') as f:
        css = f.read()

    # Convert to HTML and wrap in full HTML
    html_content = markdown.markdown(md_text, output_format='html5')
    html = f"""
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <style>
        {css}
        </style>
    </head>
    <body>
    {html_content}
    </body>
    </html>
    """

    options = {
        'margin-top': '15mm',
        'margin-right': '15mm',
        'margin-bottom': '15mm',
        'margin-left': '15mm',
    }

    pdfkit.from_string(html, output_path, configuration=config, options=options)
    print(f"✅ PDF generated: {output_path}")

if __name__ == "__main__":
    convert_readme_to_pdf()
