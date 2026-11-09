"""Independent Decimal-based checks against captured psql output.
Run capture_results.py first. Uses only the Python standard library.
"""
import csv
from collections import Counter, defaultdict
from datetime import date
from decimal import Decimal as D, ROUND_HALF_UP
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
R = ROOT / 'results'


def rounded(n):
    return D(n).quantize(D('0.01'), rounding=ROUND_HALF_UP)


def tables(name):
    """Read psql aligned tables, preserving multi-result questions."""
    output = []
    rows = []
    headers = None
    for line in (R / f'{name}.txt').read_text(encoding='utf-8').splitlines():
        if '|' in line:
            cells = [cell.strip() for cell in line.split('|')]
            if headers is None:
                headers = cells
            else:
                rows.append(dict(zip(headers, cells)))
        elif line.strip().startswith('(') and 'row' in line:
            # One-column tables have no pipe; handled separately below.
            if headers is not None:
                output.append(rows)
            headers, rows = None, []
    return output


def scalar(q):
    lines = (R / f'Q{q:02}.txt').read_text().splitlines()
    return D(lines[2].strip())


def main():
    orders = list(csv.DictReader((R / 'orders.csv').open(encoding='utf-8-sig')))
    customers = list(csv.DictReader((R / 'customers.csv').open(encoding='utf-8-sig')))
    completed = [o for o in orders if o['order_status'] == 'Completed']
    revenue = lambda o: D(o['quantity']) * D(o['unit_price']) * (1 - D(o['discount']) / 100)
    cost = lambda o: D(o['quantity']) * D(o['cost_price'])
    total = sum(map(revenue, completed))
    assert scalar(11) == len(customers) == 150
    assert scalar(12) == len(orders) == 800
    assert scalar(13) == rounded(total)
    assert scalar(14) == rounded(total / len(completed))
    assert scalar(20) == rounded(D(sum(o['order_status'] == 'Cancelled' for o in orders)) * 100 / len(orders))
    customer_spend = {c['customer_id']: D(0) for c in customers}
    category = defaultdict(lambda: [D(0), D(0)])
    month = defaultdict(lambda: D(0))
    last = {}
    for o in completed:
        amount = revenue(o)
        customer_spend[o['customer_id']] += amount
        category[o['product_category']][0] += amount
        category[o['product_category']][1] += cost(o)
        month[o['order_date'][:7]] += amount
        last[o['customer_id']] = max(last.get(o['customer_id'], ''), o['order_date'])
    actual = tables('Q22')[0]
    assert len(actual) == 150
    for row in actual:
        assert D(row['completed_spending']) == rounded(customer_spend[row['customer_id']])
    top = sorted(customer_spend, key=lambda cid: (-customer_spend[cid], int(cid)))[:10]
    assert [row['customer_id'] for row in tables('Q24')[0]] == top
    for row in tables('Q33')[0]:
        rev, cst = category[row['product_category']]
        assert D(row['net_revenue']) == rounded(rev)
        assert D(row['cost']) == rounded(cst)
        assert D(row['gross_profit']) == rounded(rev - cst)
        assert D(row['gross_profit_margin_pct']) == rounded((rev - cst) * 100 / rev)
    today = date.fromisoformat(max(o['order_date'] for o in orders))
    lapsed = {cid for cid, day in last.items() if (today - date.fromisoformat(day)).days > 90}
    assert {row['customer_id'] for row in tables('Q34')[0]} == lapsed
    cumulative = D(0)
    for row in tables('Q38')[0]:
        cumulative += month[row['sales_month'][:7]]
        assert D(row['cumulative_completed_revenue']) == rounded(cumulative)
    previous = None
    for row in tables('Q40')[0]:
        current = month[row['sales_month'][:7]]
        expected = '' if previous is None else rounded((current - previous) * 100 / previous)
        assert row['month_over_month_growth_pct'] == str(expected)
        previous = current
    for row in tables('Q42')[0]:
        assert D(row['revenue_share_pct']) == rounded(category[row['product_category']][0] * 100 / total)
    quartiles = Counter(row['spending_quartile'] for row in tables('Q41')[0])
    assert sorted(quartiles.values()) == [37, 37, 38, 38]
    view = tables('Q43')[0]
    assert sum(int(row['all_status_orders']) for row in view) == 800
    assert sum(D(row['completed_net_revenue']) for row in view) == rounded(total)
    assert sum(D(row['completed_cost']) for row in view) == rounded(sum(map(cost, completed)))
    bands = tables('Q45')[0]
    assert len(bands) == 150
    for row in bands:
        spend = customer_spend[row['customer_id']]
        assert row['customer_value_segment'] == ('High' if spend >= D(row['medium_high_cutoff']) else 'Medium' if spend >= D(row['low_medium_cutoff']) else 'Low')
    reports = tables('Q46')
    assert len(reports) == 4
    assert [row['customer_id'] for row in reports[0]] == top[:5]
    winner = max(category, key=lambda key: category[key][0] - category[key][1])
    assert reports[2][0]['product_category'] == winner
    assert reports[3][0]['sales_month'][:7] == min(month, key=lambda key: month[key])
    print('Independent checks passed: row counts, revenue, average, cancellation rate, all customer totals, top customers, category financials, lapsed customers, cumulative sales, monthly growth, revenue shares, quartiles, view reconciliation, value bands and management report.')


if __name__ == '__main__':
    main()
