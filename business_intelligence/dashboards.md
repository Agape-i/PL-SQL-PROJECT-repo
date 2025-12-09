# Dashboard Designs & Specifications
## Coffee Farmers Payment System


## 🎨 Design Principles

### 1. Visual Design Guidelines
- **Color Scheme:** Rwanda-inspired (green, yellow, blue)
- **Typography:** Open Sans for readability
- **Spacing:** Consistent 16px grid system
- **Icons:** Material Design Icons for consistency
- **Accessibility:** WCAG 2.1 AA compliance

### 2. Layout Templates


DESKTOP (1440px width)
┌─────────────────────────────────────────────────────┐
│ Header: Logo, User, Notifications, Date │
├─────────────────────────────────────────────────────┤
│ Navigation: Dashboard Tabs │
├─────────────────────────────────────────────────────┤
│ Content Area: Dynamic based on dashboard │
└─────────────────────────────────────────────────────┘

TABLET (768px width)
┌─────────────────────────────────────┐
│ Header (collapsed) │
├─────────────────────────────────────┤
│ Hamburger Menu → Navigation Drawer │
├─────────────────────────────────────┤
│ Single-column layout │
└─────────────────────────────────────┘


---

## 📊 1. EXECUTIVE DASHBOARD

### Purpose
High-level overview for station management and directors.

### Layout Structure
┌─────────────┬─────────────┬─────────────┬─────────────┐
│ KPI 1 │ KPI 2 │ KPI 3 │ KPI 4 │
│ Farmers │ Deliveries │ Weight │ Revenue │
├─────────────┴─────────────┴─────────────┴─────────────┤
│ Revenue Trend │
│ (Line Chart - Last 12 Months) │
├─────────────┬─────────────────────────────────────────┤
│ Quality │ Top Performers │
│ Mix │ (Leaderboard Table) │
│ (Donut) │ │
└─────────────┴─────────────────────────────────────────┘
 
### Component Details

#### A. KPI Cards (Top Row)
**Card 1: Total Farmers**

┌─────────────────┐
│ 👥 152 │
│ Total Farmers │
│ ▲ 5% this month │
└─────────────────┘
- **Metric:** COUNT(DISTINCT farmer_id)
- **Comparison:** Month-over-month change
- **Color:** Green (#4CAF50)
- **Icon:** 👥

**Card 2: Today's Deliveries**

┌─────────────────┐
│ 🚚 8 │
│ Today's │
│ Deliveries │
│ ▲ 2 vs yesterday│
└─────────────────┘
- **Metric:** COUNT(delivery_id) WHERE delivery_date = TODAY
- **Comparison:** Yesterday's count
- **Color:** Blue (#2196F3)
- **Icon:** 🚚

**Card 3: Total Weight**

┌─────────────────┐
│ ⚖️ 2,450 kg │
│ This Month │
│ ▲ 15% vs last │
└─────────────────┘

- **Metric:** SUM(weight_kg) WHERE month = CURRENT_MONTH
- **Comparison:** Previous month
- **Color:** Orange (#FF9800)
- **Icon:** ⚖️

**Card 4: Total Payments**
┌─────────────────┐
│ 💰 12,500 RWF │
│ This Month │
│ ▲ 18% vs last │
└─────────────────┘
- **Metric:** SUM(amount_paid) WHERE month = CURRENT_MONTH
- **Comparison:** Previous month
- **Color:** Purple (#9C27B0)
- **Icon:** 💰

#### B. Revenue Trend Chart
**Type:** Multi-line chart
**Lines:**
1. Monthly Revenue (primary, thick line)
2. 3-month moving average (dashed line)
3. Revenue target (horizontal dotted line)

**Data Query:**
SELECT 
    TO_CHAR(payment_date, 'YYYY-MM') AS month,
    SUM(amount_paid) AS revenue,
    AVG(SUM(amount_paid)) OVER (ORDER BY TO_CHAR(payment_date, 'YYYY-MM') 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM payments
WHERE payment_date >= ADD_MONTHS(SYSDATE, -12)
GROUP BY TO_CHAR(payment_date, 'YYYY-MM')
ORDER BY month;

Chart Options:

X-axis: Months (MMM YYYY format)

Y-axis: Revenue in RWF (thousands format)

Tooltip: Exact amount, % change from previous

Interactive: Click to drill to monthly detail

C. Quality Mix Donut Chart
Type: Donut chart with 3 segments
Segments:

Grade A: 40% (#4CAF50)

Grade B: 45% (#FFC107)

Grade C: 15% (#F44336)

Center Text:
Grade A
40%

Hover Details:

Grade: Count, Percentage, Total Weight

Revenue Contribution: RWF amount

Avg Price/kg: Calculated

D. Top Performers Leaderboard
Columns:

Rank (medal icons: 🥇🥈🥉)

Farmer Name

Deliveries (count)

Total Weight (kg)

Total Revenue (RWF)

Quality Score (0-100)

Query:
SELECT 
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS rank,
    f.full_name,
    COUNT(d.delivery_id) AS deliveries,
    SUM(d.weight_kg) AS total_weight,
    SUM(p.amount_paid) AS total_revenue,
    calculate_farmer_score(f.farmer_id) AS quality_score
FROM farmers f
JOIN deliveries d ON f.farmer_id = d.farmer_id
JOIN payments p ON d.delivery_id = p.delivery_id
WHERE d.delivery_date >= TRUNC(SYSDATE, 'MM')
GROUP BY f.farmer_id, f.full_name
ORDER BY total_revenue DESC
FETCH FIRST 10 ROWS ONLY;
SELECT 
    RANK() OVER (ORDER BY SUM(p.amount_paid) DESC) AS rank,
    f.full_name,
    COUNT(d.delivery_id) AS deliveries,
    SUM(d.weight_kg) AS total_weight,
    SUM(p.amount_paid) AS total_revenue,
    calculate_farmer_score(f.farmer_id) AS quality_score
FROM farmers f
JOIN deliveries d ON f.farmer_id = d.farmer_id
JOIN payments p ON d.delivery_id = p.delivery_id
WHERE d.delivery_date >= TRUNC(SYSDATE, 'MM')
GROUP BY f.farmer_id, f.full_name
ORDER BY total_revenue DESC
FETCH FIRST 10 ROWS ONLY;
┌─────────────┬─────────────┬─────────────┐
│ Daily Stats │  Live       │ Compliance  │
│   Cards     │  Stream     │   Monitor   │
├─────────────┼─────────────┼─────────────┤
│   Quality   │ Delivery    │   Alert     │
│   Control   │  Trends     │   Center    │
└─────────────┴─────────────┴─────────────┘
Component Details
A. Daily Statistics Cards
Card 1: Deliveries Today

Value: Current count

Trend: vs. same day last week

Action: Click to view details

Card 2: Avg Weight Today

Value: AVG(weight_kg) for today

Trend: vs. monthly average

Threshold: Green if 50-80kg, Yellow if outside

Card 3: Pending Payments

Value: COUNT(payments) WHERE payment_date IS NULL

Action: Click to process batch

Card 4: Anomaly Rate

Value: (anomalies today)/(deliveries today) × 100

Threshold: Red if > 5%

B. Live Delivery Stream
Type: Auto-refreshing table (every 2 minutes)
Columns:

Time (HH:MM)

Farmer (with photo/avatar)

Weight (kg) with color coding

Quality (with grade color)

Status (✅ Paid / ⏳ Pending)

Filters:

Time range (Today, Last 24h, Custom)

Quality grade (All, A, B, C)

Status (All, Paid, Pending)

C. Compliance Monitor
Type: Gauge chart
Metrics:

Weekday Rule Compliance: 100% target

Holiday Rule Compliance: 100% target

Data Entry Accuracy: 98%+ target

Violations Today:

List of violations with timestamps

User who attempted

Action taken

D. Quality Control Matrix
Type: Heatmap grid
Rows: Farmers (top 20)
Columns: Quality grades (A, B, C)
Cells: Count of deliveries in that grade
Color: Gradient from light (few) to dark (many)

E. Delivery Trends
Type: Multi-view charts

Weight Distribution: Histogram of delivery weights

Time Pattern: Deliveries by hour of day

Frequency: Days between deliveries per farmer

F. Alert Center
Type: Priority-based alert list
Priority Levels:

🔴 Critical: Immediate action needed

🟡 Warning: Review required

🔵 Informational: For awareness

Alert Types:

Weight Anomaly (>50% deviation)

Duplicate Detection

Missing Payment

Data Quality Issue

System Warning

💰 3. FINANCE DASHBOARD
Purpose
Financial management and cash flow monitoring.

Layout Structure
text
┌─────────────┬─────────────┬─────────────┐
│ Payment     │ Revenue by  │ Cash Flow   │
│ Summary     │  Quality    │ Forecast    │
├─────────────┼─────────────┼─────────────┤
│  Farmer     │ Monthly     │  Payment    │
│ Balances    │ Statements  │ Efficiency  │
└─────────────┴─────────────┴─────────────┘
Component Details
A. Payment Summary Cards
Card 1: Total Paid This Month

Value: SUM(amount_paid) for current month

Breakdown: By week (sparkline)

Card 2: Pending Payments

Value: SUM(calculated_amount - paid_amount)

Age analysis: <7 days, 7-30 days, >30 days

Card 3: Avg Payment Amount

Value: AVG(amount_paid) this month

Trend: vs. last month

Card 4: Processing Time

Value: AVG(payment_date - delivery_date) in days

Target: < 2 days

B. Revenue by Quality Chart
Type: Stacked bar chart
X-axis: Months (last 6)
Stacks: Grade A, B, C revenue
Total Line: Total revenue line overlay

Insights:

Grade contribution percentage

Revenue growth by grade

Price impact analysis

C. Cash Flow Forecast
Type: Waterfall chart
Elements:

Opening Balance

Expected Payments (next 7 days)

Expected Expenses

= Projected Balance

Data Source: Historical patterns + scheduled payments

D. Farmer Balances Table
Columns:

Farmer Name

Total Balance (RWF)

Last Payment Date

Average Payment (RWF)

Credit Score

Action (Pay Now button)

Color Coding:

Green: Balance < 10,000

Yellow: Balance 10,000-50,000

Red: Balance > 50,000

E. Monthly Statements
Type: Comparative bar chart
Compare: Current month vs. Previous month vs. Same month last year
Metrics:

Total Revenue

Total Weight

Avg Price/kg

Number of Farmers

Number of Deliveries

F. Payment Efficiency Gauge
Type: Speedometer gauge
Zones:

Red: < 80% payments within 48h

Yellow: 80-95%

Green: > 95%

Drill-down: List of late payments with reasons

🌟 4. QUALITY DASHBOARD
Purpose
Quality monitoring and improvement tracking.

Layout Structure
text
┌─────────────┬─────────────┬─────────────┐
│ Grade       │ Anomaly     │  Quality    │
│ Distribution│ Detection   │   Trends    │
├─────────────┼─────────────┼─────────────┤
│  Farmer     │ Seasonal    │  Rejection  │
│  Rankings   │ Analysis    │    Rate     │
└─────────────┴─────────────┴─────────────┘
Component Details
A. Grade Distribution Over Time
Type: Area chart
Layers: Grade A, B, C percentages over time
Time Scale: Last 12 months (monthly aggregation)

Goal Lines:

Grade A: ≥ 35% target line

Grade C: ≤ 20% limit line

B. Anomaly Detection Analysis
Type: Scatter plot
X-axis: Delivery Date
Y-axis: Weight (kg)
Points: Color-coded by anomaly status

Green: Normal (±20% from farmer avg)

Yellow: Warning (±20-50%)

Red: Anomaly (>±50%)

Trend Line: Farmer's average weight

C. Quality Trends
Type: Sparkline grid
Rows: Top 20 farmers
Columns:

Farmer Name

Current Grade Mix (A/B/C %)

Trend (12-month sparkline)

Quality Score (0-100)

Improvement (↑/↓ arrow)

D. Farmer Rankings
Type: Leaderboard with quality focus
Ranking Criteria:

Grade A Percentage (40% weight)

Consistency Score (30% weight)

Weight Stability (20% weight)

Timeliness (10% weight)

Badges:

🏆 Quality Champion (top 3)

📈 Most Improved

⭐ Consistency Star

E. Seasonal Analysis
Type: Radial chart
Segments: Months of year
Metrics per segment:

Avg Grade A %

Total Weight

Avg Price/kg

Number of Farmers

Pattern Detection: Highlight peak quality seasons

F. Rejection Rate Monitor
Type: Bullet chart
Current: Actual rejection rate
Target: < 2% target
Ranges:

Good: 0-1% (green)

Acceptable: 1-2% (yellow)

Poor: > 2% (red)

Drill-down: Reasons for rejection

🛡️ 5. COMPLIANCE DASHBOARD
Purpose
Audit, monitoring, and compliance verification.

Layout Structure
text
┌─────────────┬─────────────┬─────────────┐
│ Audit Trail │ Rule        │  Data       │
│    Log      │ Compliance  │ Integrity   │
├─────────────┼─────────────┼─────────────┤
│ User        │ Violation   │  System     │
│ Activity    │ Heatmap     │  Health     │
└─────────────┴─────────────┴─────────────┘
Component Details
A. Audit Trail Log Viewer
Type: Filterable, searchable table
Columns:

Timestamp

User

Operation (with icon)

Object

Status (with color)

Reason (truncated)

Details (expandable)

Filters:

Date range

User

Operation type

Status

Object type

Actions:

Export to CSV/PDF

Mark for review

Add comment

B. Rule Compliance Metrics
Type: Scorecard with gauges
Metrics:

Weekday Rule: % compliance

Holiday Rule: % compliance

Data Validation: % success

Audit Completeness: % coverage

Trend: 30-day trend line for each

C. Data Integrity Dashboard
Type: Status matrix
Checks:

✅ Foreign Key Integrity

✅ Unique Constraint Validity

✅ Not Null Compliance

✅ Check Constraint Validation

🔄 Data Freshness (last update)

⚠️ Orphaned Records Check

Last Run: Timestamp of last integrity check
Issues Found: Count with severity

D. User Activity Timeline
Type: Gantt-style timeline
Rows: Users
Columns: Time of day
Blocks: Activity sessions (color by activity type)

Insights:

Busiest times

User patterns

Unusual activity detection

E. Violation Heatmap
Type: Calendar heatmap
X-axis: Days of week
Y-axis: Hours of day
Cells: Number of violations (color intensity)

Pattern Detection:

Highlight high-violation periods

Suggest rule adjustments

F. System Health Monitor
Type: Status panel with metrics
Database Health:

Connection count

Active sessions

Cache hit ratio

Disk usage

Application Health:

API response time

Error rate

Queue length

Backup status

Alerts: System warnings and errors

📱 Mobile Dashboard Design
Responsive Layout
text
MOBILE PORTRAIT
┌─────────────────┐
│ Header          │
│ (Collapsed)     │
├─────────────────┤
│ KPI Carousel    │
│ (Swipeable)     │
├─────────────────┤
│ Primary Chart   │
│ (Current Tab)   │
├─────────────────┤
│ Quick Actions   │
│ (Bottom Bar)    │
└─────────────────┘
Mobile-Specific Components
1. KPI Carousel
Swipe horizontally between KPIs

Tap KPI for detailed view

Pull to refresh data

2. Bottom Navigation
Home (Executive view)

Operations (current deliveries)

Finance (payments)

Quality (grading)

More (hamburger menu)

3. Quick Actions
New Delivery (camera icon)

Record Payment (💰 icon)

Check Farmer (👥 icon)

Report Issue (⚠️ icon)

4. Offline Mode
Cached data display

Queue for sync

Local validation

Progress indicator

🎯 Dashboard Interactions
1. Drill-Down Patterns
Level 1: Summary → Level 2: Detail → Level 3: Transaction

text
Monthly Revenue → May 2025 → Delivery on May 15 → Farmer Details
2. Filter Propagation
Global date filter affects all charts

Farmer selection filters relevant data

Quality grade filter cascades

3. Export Options
Chart as PNG/SVG

Data as CSV/Excel

Dashboard as PDF

Schedule email reports

4. Alert Actions
Acknowledge (mark as read)

Assign (to team member)

Escalate (to manager)

Resolve (with comment)

🛠 Implementation Notes
1. Chart Library Recommendations
Oracle APEX Charts: For basic needs

Chart.js: Lightweight, responsive

D3.js: For complex visualizations

AnyChart: Commercial but feature-rich

2. Performance Optimizations
Materialized views for aggregated data

Query result caching

Pagination for large datasets

Lazy loading for charts

3. Accessibility Features
Screen reader support

Keyboard navigation

High contrast mode

Text size adjustment

4. Browser Support
Chrome 80+ (primary)

Firefox 75+

Safari 13+

Edge 80+

✅ Dashboard Validation Checklist
Design Validation
Color scheme consistent with brand

All text readable at 100% zoom

Charts have clear labels and legends

Mobile responsive tested on 3+ devices

Loading states implemented for all components

Data Validation
All calculations match source data

Null/empty data handled gracefully

Time zones handled correctly

Data refresh working as expected

Export functionality tested

User Experience
Navigation intuitive for new users

Drill-down paths clear and logical

Filter states visible and clear

Error messages helpful and actionable

Performance acceptable on slow connections

Security Validation
Role-based access working correctly

Data privacy maintained per user role

Audit trail records dashboard access

Session timeout working

No data leakage between users
