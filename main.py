import markdown
import os
from playwright.sync_api import sync_playwright


def convert_readme_to_pdf(readme_path='README.md', css_path='style.css'):
    output_path = os.environ.get("OUTPUT_PDF", "README.pdf")

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

    # Render PDF using Playwright (Chromium)
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page()
        page.set_content(html, wait_until='networkidle')
        # margins in Playwright use a dict; include background printing
        page.pdf(path=output_path, format='A4', margin={
            'top': '15mm',
            'right': '15mm',
            'bottom': '15mm',
            'left': '15mm'
        }, print_background=True)
        browser.close()

    print(f"✅ PDF generated: {output_path}")


if __name__ == "__main__":
    convert_readme_to_pdf()
