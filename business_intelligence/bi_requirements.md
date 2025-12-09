# Business Intelligence Requirements
## Coffee Farmers Payment System

**Document Version:** 1.0  
**Date:** December 2025  
**Prepared by:** INEZA Agape (ID: 27464)  
**Stakeholders:** Station Management, Finance Team, Quality Controllers

---

## 🎯 Executive Summary

### Business Need
Coffee washing stations need real-time insights into delivery operations, farmer performance, financial tracking, and compliance monitoring to improve decision-making and operational efficiency.

### Solution Overview
Implement a comprehensive BI system that transforms transactional data into actionable insights through dashboards, reports, and analytical tools.

### Success Criteria
- Reduce payment processing time by 30%
- Increase premium grade (Grade A) deliveries by 15%
- Achieve 100% compliance with business rules
- Improve farmer satisfaction scores by 20%

---

## 👥 User Personas & Requirements

### 1. Station Manager
**Role:** Strategic decision-making, overall performance monitoring  
**Needs:**
- High-level KPIs and trends
- Revenue and growth metrics
- Operational efficiency indicators
- Compliance status

**Pain Points:**
- Manual report generation takes 3+ hours weekly
- No real-time visibility into operations
- Difficulty identifying top performers

### 2. Finance Officer
**Role:** Financial management, payment processing, cash flow  
**Needs:**
- Daily payment summaries
- Cash flow projections
- Farmer balance tracking
- Revenue analysis by quality

**Pain Points:**
- Payment discrepancies hard to track
- Manual payment calculations error-prone
- No forecasting capabilities

### 3. Quality Controller
**Role:** Quality assurance, grade assignment, standards maintenance  
**Needs:**
- Quality distribution analysis
- Weight anomaly detection
- Farmer quality trends
- Grade pricing impact

**Pain Points:**
- Quality trends not visible over time
- Anomaly detection reactive, not proactive
- No quality correlation with pricing

### 4. Station Clerk
**Role:** Daily operations, data entry, farmer interaction  
**Needs:**
- Daily delivery schedule
- Pending tasks alert
- Farmer information quick access
- Compliance reminders

**Pain Points:**
- Unclear which farmers due for payment
- Manual checking for business rule violations
- No alerts for abnormal deliveries

### 5. Compliance Officer
**Role:** Audit, compliance monitoring, business rule enforcement  
**Needs:**
- Real-time audit trail
- Violation tracking
- User activity monitoring
- Data integrity checks

**Pain Points:**
- Manual audit log review time-consuming
- No automated violation detection
- Hard to track patterns in violations

---

## 📈 Functional Requirements

### 1. Executive Dashboard
**FR-001:** Display real-time KPIs (Total Farmers, Today's Deliveries, Total Weight, Total Payments)  
**FR-002:** Show monthly revenue trend for last 12 months  
**FR-003:** Display quality grade distribution (Pie/Donut chart)  
**FR-004:** Show top 10 farmers by revenue/weight  
**FR-005:** Alert badge for unresolved anomalies  
**FR-006:** Compliance status indicator

### 2. Operations Dashboard
**FR-007:** Real-time delivery stream (last 24 hours)  
**FR-008:** Daily delivery statistics with comparison to previous day  
**FR-009:** Weight distribution histogram  
**FR-010:** Delivery frequency analysis  
**FR-011:** Active alerts panel with severity levels  
**FR-012:** Pending payments list

### 3. Finance Dashboard
**FR-013:** Monthly revenue breakdown by quality grade  
**FR-014:** Payment processing efficiency metrics  
**FR-015:** Cash flow forecast (next 7, 30 days)  
**FR-016:** Farmer balance aging report  
**FR-017:** Revenue vs. weight correlation analysis  
**FR-018:** Price per kg trends

### 4. Quality Dashboard
**FR-019:** Quality grade distribution over time  
**FR-020:** Weight anomaly detection analysis  
**FR-021:** Farmer quality score ranking  
**FR-022:** Quality vs. season correlation  
**FR-023:** Rejection rate tracking  
**FR-024:** Grade A percentage trend

### 5. Compliance Dashboard
**FR-025:** Real-time audit log with filtering  
**FR-026:** Violation heatmap by day of week  
**FR-027:** User activity timeline  
**FR-028:** Business rule compliance rate  
**FR-029:** Data integrity status indicators  
**FR-030:** Export capability for audit reports

---

## 🔧 Technical Requirements

### 1. Data Requirements
**TR-001:** Real-time data refresh for operational dashboards (< 5 minute latency)  
**TR-002:** Daily batch refresh for analytical dashboards (overnight)  
**TR-003:** 3 years historical data retention  
**TR-004:** Data aggregation at multiple levels (daily, weekly, monthly, yearly)  
**TR-005:** Support for 10,000+ farmers scalability  
**TR-006:** Data export in CSV, Excel, PDF formats

### 2. Performance Requirements
**TR-007:** Dashboard load time < 3 seconds  
**TR-008:** Support 50+ concurrent users  
**TR-009:** Handle 1,000+ daily deliveries  
**TR-010:** 99.5% system availability  
**TR-011:** Query response time < 2 seconds for 90% of queries

### 3. Security Requirements
**TR-012:** Role-based access control (RBAC)  
**TR-013:** Data encryption at rest and in transit  
**TR-014:** Audit trail for all data access  
**TR-015:** IP restriction for admin access  
**TR-016:** Session timeout after 15 minutes inactivity  
**TR-017:** Password policy enforcement

### 4. Integration Requirements
**TR-018:** REST API for external system integration  
**TR-019:** Webhook support for alert notifications  
**TR-020:** Email/SMS integration for critical alerts  
**TR-021:** Export to common BI tools (Power BI, Tableau)  
**TR-022:** Mobile-responsive design

---

## 📊 Reporting Requirements

### 1. Standard Reports
| Report | Frequency | Delivery | Audience |
|--------|-----------|----------|----------|
| Daily Delivery Summary | Daily | 8:00 AM | Operations Team |
| Weekly Financial Report | Weekly (Monday) | 9:00 AM | Finance Team |
| Monthly Performance | Monthly (5th) | 10:00 AM | Management |
| Quarterly Compliance | Quarterly | 15th of quarter | Compliance Team |
| Annual Farmer Analysis | Annually | January 31st | All Stakeholders |

### 2. Ad-hoc Reports
**AR-001:** Custom date range delivery analysis  
**AR-002:** Farmer-specific performance report  
**AR-003:** Quality trend analysis by season  
**AR-004:** Revenue forecast based on historical data  
**AR-005:** Anomaly pattern detection report

### 3. Alert Reports
**AL-001:** Real-time weight anomaly alerts  
**AL-002:** Daily compliance violation summary  
**AL-003:** Payment processing exceptions  
**AL-004:** Data quality issues  
**AL-005:** System performance alerts

---

## 🎨 User Interface Requirements

### 1. Dashboard Design
**UI-001:** Clean, intuitive interface with Rwanda color theme  
**UI-002:** Responsive design for desktop, tablet, mobile  
**UI-003:** Red/Amber/Green status indicators  
**UI-004:** Drill-down capability from summary to detail  
**UI-005:** Customizable dashboard layouts  
**UI-006:** Dark/Light mode toggle

### 2. Chart Types Required
- Line charts (trends over time)
- Bar charts (comparisons)
- Pie/Donut charts (distributions)
- Heat maps (violations by time)
- Gauge charts (KPI status)
- Scatter plots (correlations)
- Histograms (distributions)

### 3. Navigation & Interaction
**NAV-001:** Tab-based dashboard navigation  
**NAV-002:** Breadcrumb navigation for drill-downs  
**NAV-003:** Filter panel (date, farmer, quality, sector)  
**NAV-004:** Export button on every chart/table  
**NAV-005:** Tooltips with detailed information  
**NAV-006:** Keyboard shortcuts for power users

---

## 🔄 Data Flow & Processing

### 1. Data Pipeline Architecture
   Transactional Data → Staging Area → Data Warehouse → BI Layer → Dashboards
(Oracle) (Views) (Materialized (APEX/ (HTML/
Views) REST API) JavaScript)




### 2. ETL Processes
**Process 1:** Daily Delivery Data Refresh
- Source: DELIVERIES, PAYMENTS tables
- Frequency: Hourly (real-time)
- Transformation: Aggregation, calculation
- Load: Operational data mart

**Process 2:** Analytical Data Refresh
- Source: All business tables
- Frequency: Nightly (batch)
- Transformation: Historical aggregation, trend calculation
- Load: Analytical data warehouse

### 3. Data Quality Checks
**DQ-001:** Data completeness validation  
**DQ-002:** Referential integrity checks  
**DQ-003:** Business rule validation  
**DQ-004:** Anomaly detection in source data  
**DQ-005:** Timeliness of data updates

---

## 📱 Mobile Requirements

### 1. Mobile Dashboard
**M-001:** Simplified dashboard for mobile view  
**M-002:** Touch-friendly interface  
**M-003:** Offline capability for essential data  
**M-004:** Push notifications for critical alerts  
**M-005:** Mobile-optimized charts and tables

### 2. Mobile Features
**M-006:** Barcode scanning for farmer ID  
**M-007:** Photo capture for quality documentation  
**M-008:** GPS location tracking for deliveries  
**M-009:** Offline data collection with sync  
**M-010:** Mobile payment confirmation

---

## 🚀 Implementation Phases

### Phase 1: Foundation (Weeks 1-4)
**Deliverables:**
- Executive Dashboard (KPI summary)
- Basic operational reports
- Data warehouse structure
- Security framework

### Phase 2: Operations & Finance (Weeks 5-8)
**Deliverables:**
- Operations Dashboard
- Finance Dashboard
- Standard reports
- Alert system

### Phase 3: Quality & Compliance (Weeks 9-12)
**Deliverables:**
- Quality Dashboard
- Compliance Dashboard
- Advanced analytics
- Mobile interface

### Phase 4: Enhancement (Weeks 13-16)
**Deliverables:**
- Predictive analytics
- Advanced reporting
- Integration capabilities
- Performance optimization

---

## 📋 Success Metrics

### Quantitative Metrics
1. **Dashboard Usage:** > 80% of users access daily
2. **Report Generation Time:** Reduced from 3 hours to 15 minutes
3. **Decision Speed:** 50% faster decisions with data insights
4. **Error Reduction:** 75% reduction in payment errors
5. **Farmer Satisfaction:** Increase from 75% to 90%

### Qualitative Metrics
1. **User Satisfaction:** > 4.5/5 rating in user surveys
2. **Stakeholder Feedback:** Positive feedback from all user groups
3. **Data-Driven Culture:** Evidence of data use in decision meetings
4. **Compliance Confidence:** Management confidence in compliance status
5. **Operational Transparency:** Clear visibility into all operations

---

## 🛠 Technology Stack Recommendations

### Backend
- **Database:** Oracle 21c XE (current), Enterprise for production
- **ETL:** Oracle Materialized Views, PL/SQL packages
- **API Layer:** Oracle REST Data Services (ORDS)
- **Scheduling:** Oracle Scheduler, DBMS_JOB

### Frontend
- **Dashboard Framework:** Oracle APEX (included) or Power BI
- **Charts:** AnyChart, Chart.js, or native Oracle charts
- **Mobile:** Progressive Web App (PWA) approach

### Infrastructure
- **Server:** Oracle Cloud Infrastructure (OCI) recommended
- **Storage:** Block storage for database, object storage for archives
- **Backup:** Oracle RMAN with automated backups
- **Monitoring:** Oracle Enterprise Manager, custom dashboards

---

## ⚠️ Risks & Mitigation

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Data quality issues | High | Medium | Data validation rules, regular audits |
| Performance degradation | High | Low | Query optimization, indexing strategy |
| User adoption resistance | Medium | Medium | Training, phased rollout, user involvement |
| Security breaches | High | Low | Regular security audits, access controls |
| Integration failures | Medium | Medium | API testing, fallback mechanisms |
| Scope creep | Medium | High | Change control process, prioritized backlog |

---

## ✅ Acceptance Criteria

### Must Have (Phase 1)
1. Executive dashboard with 5+ KPIs
2. Daily delivery summary report
3. Basic security and access control
4. Data export capability
5. Mobile-responsive design

### Should Have (Phase 2)
1. Operations and finance dashboards
2. Real-time alert system
3. Advanced filtering and drill-down
4. Scheduled report delivery
5. API for external access

### Could Have (Phase 3)
1. Predictive analytics
2. Advanced visualization
3. Mobile app
4. Integration with external systems
5. Custom report builder

### Won't Have (Out of Scope)
1. AI/ML integration (future phase)
2. Multi-language support
3. Complex workflow automation
4. Social media integration
5. Advanced predictive modeling

---

**Approval Signatures:**

- **Business Owner:** _________________________
- **Project Sponsor:** _________________________
- **Technical Lead:** _________________________
- **End User Representative:** _________________________

**Date Approved:** _________________________
