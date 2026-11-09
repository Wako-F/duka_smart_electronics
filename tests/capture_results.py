"""Execute every numbered answer with psql and build honest HTML output viewers.

Usage: python tests/capture_results.py --psql /path/to/psql
Connection uses PGHOST/PGPORT/PGUSER/PGDATABASE (standard libpq settings).
No passwords are stored. HTML files show unmodified psql text, not a simulated SQL IDE.
"""
import argparse
import html
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--psql', default='psql')
    args = parser.parse_args()
    sql = (ROOT / 'queries.sql').read_text(encoding='utf-8-sig')
    sections = re.split(r'(?m)^-- Q(\d+)\b', sql)
    numbers = [int(sections[i]) for i in range(1, len(sections), 2)]
    assert numbers == list(range(1, 47)), numbers
    results = ROOT / 'results'
    results.mkdir(exist_ok=True)
    # Keep verification and source exports fresh for the independent checker.
    for filename, statement in [
        ('05_verify_data.txt', (ROOT / 'scripts/05_verify_data.sql').read_text(encoding='utf-8-sig')),
        ('orders.csv', 'SELECT * FROM orders ORDER BY order_id;'),
        ('customers.csv', 'SELECT * FROM customers ORDER BY customer_id;'),
    ]:
        command = [args.psql, '-X', '-v', 'ON_ERROR_STOP=1', '-P', 'pager=off']
        if filename.endswith('.csv'):
            command.append('--csv')
        proc = subprocess.run(command + ['-f', '-'], input=statement, text=True,
                              encoding='utf-8', capture_output=True)
        if proc.returncode:
            raise RuntimeError(f'{filename} failed:\n{proc.stderr}')
        (results / filename).write_text(proc.stdout, encoding='utf-8')
    for i in range(1, len(sections), 2):
        number, body = sections[i:i + 2]
        # Restore the section comment removed by splitting.
        query = '-- Q' + number + body
        proc = subprocess.run(
            [args.psql, '-X', '-v', 'ON_ERROR_STOP=1', '-P', 'pager=off', '-f', '-'],
            input=query, text=True, encoding='utf-8', capture_output=True,
        )
        if proc.returncode:
            raise RuntimeError(f'Q{number} failed:\n{proc.stderr}')
        (results / f'Q{int(number):02}.txt').write_text(proc.stdout, encoding='utf-8')
        print(f'Q{number}: executed successfully')
    selected = [
        ('05_verify_data', 'Database verification', 'scripts/05_verify_data.sql'),
        ('Q24', 'Ten highest-spending customers', 'queries.sql / Q24'),
        ('Q33', 'Category revenue, cost and gross profit', 'queries.sql / Q33'),
        ('Q40', 'Month-over-month revenue growth', 'queries.sql / Q40'),
        ('Q46', 'Management report', 'queries.sql / Q46'),
    ]
    for name, title, source in selected:
        output = (results / f'{name}.txt').read_text(encoding='utf-8-sig')
        page = '<!doctype html><html lang="en"><meta charset="utf-8">'
        page += '<title>' + html.escape(title) + '</title>'
        page += '''<style>
body {margin:0;background:#f1f5f9;color:#152238;font-family:Arial,sans-serif;}
main {margin:32px;padding:30px;background:white;border:1px solid #cbd5e1;border-radius:12px;}
.label {color:#2563eb;font-weight:bold;letter-spacing:1px;font-size:13px;}
h1 {font-size:28px;margin:12px 0;} .meta {color:#475569;font-size:14px;margin-bottom:22px;}
pre {font:15px/1.65 Consolas,'Courier New',monospace;background:#f8fafc;border:1px solid #dbe3ed;padding:20px;overflow:visible;white-space:pre;}
footer {font-size:13px;color:#475569;margin-top:20px;}
</style><main><div class="label">DUKA SMART ELECTRONICS / SQL EVIDENCE</div>'''
        page += '<h1>' + html.escape(title) + '</h1>'
        page += '<div class="meta">PostgreSQL 18.6 | retail_analytics | ' + html.escape(source) + '</div>'
        page += '<pre>' + html.escape(output) + '</pre>'
        page += '<footer>Actual psql output, displayed in a browser for capture. Financial amounts: KSh; Completed orders only. Order counts include every status.</footer></main></html>'
        (results / f'{name}.html').write_text(page, encoding='utf-8')
    print('46 answers executed; 5 browser evidence pages generated.')


if __name__ == '__main__':
    main()
