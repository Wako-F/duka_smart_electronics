# Duka Smart Electronics: Findings and Recommendations

The dataset has 150 customers and 800 orders from 1 January 2025 to 30 September 2026. I used 30 September 2026 as the reference date. All amounts are in Kenyan shillings (KSh). Only the 634 Completed orders count towards the financial results. Revenue is after discount, and cost is quantity multiplied by unit cost. 

## 1. Overall gross margin is positive but thin

Completed orders earned KSh 24,155,371.70 in revenue against KSh 21,264,450.00 in cost. This leaves KSh 2,890,921.70 in gross profit, a margin of 11.97%. In other words, about KSh 12 out of every KSh 100 of sales is left to pay for overheads, so high sales alone do not prove the business is doing well.

I recommend reviewing gross profit against overheads each month and checking the post-discount margin before approving any promotion. Margin floors should be set by product category instead of using one discount rate for everything.

Evidence: Q12, Q13, Q33, Q43

## 2. Accessories earn more profit than their sales suggest

Accessories brought in KSh 1,077,496.10 in revenue and KSh 456,746.10 in gross profit, a 42.39% margin. They make up only 4.46% of revenue but 15.80% of gross profit. They earn nearly as much profit as Home Appliances (KSh 458,034.05) from far lower sales. Mobile Phones lead in both revenue (KSh 6,942,060.65) and gross profit (KSh 728,760.65), but their margin is only 10.50%.

I recommend testing bundles of chargers, earbuds and mice with phones and laptops. The attachment rate, extra gross profit and returns should be measured before expanding, and the accessory margin should not be discounted away.

Evidence: Q16, Q33, Q42, Q46; `screenshots/Q33.png`.

## 3. Best-selling products are not always the most profitable

The iPhone 13 has the highest revenue (KSh 3,766,458.15) but only KSh 233,958.15 in gross profit, a 6.21% margin. The JBL Flip 6 Speaker made KSh 268,125.00 in gross profit on KSh 1,139,325.00 revenue, a 23.53% margin. The Hotpoint Refrigerator ranks third by revenue (KSh 2,386,956.60) but made only KSh 96,156.60 in gross profit, a 4.03% margin.

Ranking stock by sales value alone can favour products that tie up a lot of money for little profit. However, the data has no inventory or turnover figures, so return on stock investment cannot be measured.

I recommend reviewing refrigerator pricing, purchase cost and discount approvals first. Gross profit and sell-through should both be tracked when setting stock budgets. High-revenue phones should stay in stock, but revenue rank should not be the only basis for allocating stock.

Evidence: Q37, Q46, `screenshots/Q46.png`.

## 4. Top customers should be protected, but their profitability checked

The five largest customers by completed spending are:

| Customer | Completed spending (KSh) |
|---|---:|
| Brian Chebet | 848,118.75 |
| Peter Ndungu | 790,229.50 |
| Lucy Njoroge | 767,880.80 |
| Nancy Korir | 702,545.75 |
| Purity Ochieng | 698,921.60 |

Together they account for 15.76% of completed revenue. Spending rank does not match profit rank, though: Brian's gross margin is 7.75% while Nancy's is 14.37%. Losing a few big customers would reduce sales, but giving them deeper discounts could cut already-thin margins further.

I recommend offering these customers reliable fulfilment, stock notifications and personal follow-up. Gross profit should be checked, not just spending, before giving any account-specific discount. The Q45 value bands can be used to set priorities, but not as a prediction of lifetime value.

Evidence: Q24, Q35, Q45, Q46, `screenshots/Q24.png`.

## 5. Sales grew strongly, but the latest month fell

Revenue for January to September 2026 was KSh 12,832,085.00, compared with KSh 6,887,473.30 for the same months in 2025, an increase of 86.31%. However, September 2026 revenue (KSh 2,092,445.15) was 6.67% lower than August 2026 (KSh 2,242,033.90), which is the highest month in the dataset. January 2026 was the lowest at KSh 322,432.95.

Comparing part of 2026 with all of 2025 would be misleading, and one weaker month does not cancel out the increase. With only 21 months of data, recurring seasonality cannot be established.

I recommend comparing the same months or periods, as well as month-on-month change. September's order count, product mix, stock availability and cancellations should be investigated before changing the sales plan, and cash and stock budgets should be cautious around weaker months.

Evidence: Q31, Q38 to Q40, Q46. The comparable-period figure adds up the Q40 monthly revenue for January to September of each year; `screenshots/Q40.png`.

## 6. Lapsed buyers and non-buyers need different approaches

There are 47 customers whose last completed purchase was more than 90 days before 30 September 2026. Separately, 18 customers have no completed purchase. Of these, 12 have never placed an order and six have ordered but have no Completed order. Since electronics are bought infrequently, the 90-day rule gives a contact list, not proof that these customers are gone for good.

I recommend a small win-back test among the 47 lapsed buyers, starting with those who spent the most and who may need accessories or replacements. The six customers with unfinished orders should be contacted about payment or delivery problems, and the 12 who never ordered should get onboarding messages. Results should be compared with a holdout group.

Evidence: Q22, Q23, Q34.

## 7. Nairobi is the largest market, but not necessarily the best one to expand

Nairobi customers generate KSh 9,581,980.35, or 39.67% of revenue. Mombasa follows with KSh 3,161,889.60, and Machakos is lowest at KSh 745,099.90. A large share of sales therefore depends on Nairobi customers. However, the city field is the customer's city, not a branch or delivery location, and raw revenue also reflects different numbers of customers and different purchase mixes. It does not show local market potential.

I recommend keeping service reliable for Nairobi customers. Before investing in smaller towns, revenue per registered customer, acquisition cost, delivery cost and local demand should be compared.

Evidence: Q17, Q25.

## 8. Cancelled and pending orders need follow-up

Of the 800 orders, 90 were Cancelled (11.25%) and 76 were Pending (9.50%). These 166 orders are left out of revenue and profit. Counting them would overstate sales, but their status does not show the cause, age or chance of eventual payment, so their full value should not be called recoverable lost revenue.

I recommend adding cancellation-reason and pending-age reporting, checking recent pending orders for payment and stock problems, and measuring the completed-order conversion rate before and after any process change.

Evidence: Q12, Q20.

## Customer value bands (Q45)

The cutoffs are based on completed spending across all 150 customers, including those who spent nothing. The 25th percentile is KSh 17,373.25 and the 75th percentile is KSh 217,365.65.

- **High:** at least KSh 217,365.65 (38 customers)
- **Medium:** at least KSh 17,373.25 but below KSh 217,365.65 (75 customers)
- **Low:** below KSh 17,373.25 (37 customers)

Using the observed distribution avoids arbitrary amounts, and discrete percentiles keep the cutoffs at actual recorded customer totals. These are bands of past spending, not predicted lifetime value. They should be combined with recency (Q34) to prioritise retention, and the cutoffs refreshed when the reporting period changes.


## Management priorities

1. Protect gross margin by reviewing refrigerator and phone discounting and testing accessory cross-selling.
2. Keep high-spending customers, while checking their actual gross profit contribution.
3. Run separate campaigns for the 47 lapsed buyers, the six customers with unfinished orders and the 12 who never ordered.
4. Monitor monthly completed revenue, gross profit, cancellation rate and comparable-period growth together.

## Limitations

Each order row is one product or order record. There is no separate order-line table, and no data on overheads, refunds, inventory, marketing costs or customer contact permissions. The growth, margins and customer segments describe this period only, so recommendations should be tested before wider use.