# Retail-Demand-Forecasting-Inventory-Optimization-using-Machine-Learning

![image alt](https://github.com/Y7976/Retail-Demand-Forecasting-Inventory-Optimization-using-Machine-Learning/blob/85b0857bdf3e3a6873bfab2a67d9d05e714ecbd8/retail%20store%20image.png)

##  Project Overview

Retail businesses generate massive amounts of transactional data every day, making accurate demand forecasting essential for efficient inventory management. Poor demand estimation can lead to stock shortages, excess inventory, increased operational costs, and lost revenue.

This project presents an end-to-end Retail Demand Forecasting solution using SQL, Python, and Machine Learning. Historical sales data from Corporación Favorita was analyzed to uncover demand patterns, identify key business drivers, and build a predictive model capable of forecasting future product demand.

The solution helps retailers optimize inventory planning, improve replenishment strategies, reduce stockouts, and support data-driven business decisions.

##  Key Highlights

-  Performed Exploratory Data Analysis (EDA) on nearly **1 million retail sales records**
-  Solved **60+ business problems using SQL**
-  Cleaned and merged multiple datasets into a single analytical dataset
-  Engineered forecasting features such as Lag Features and Rolling Mean
-  Built a Random Forest Regression model for demand forecasting
-  Achieved an **R² Score of 0.7263**
-  Generated actionable business recommendations for inventory optimization


##  Business Problem

Retail businesses face significant challenges in accurately forecasting product demand. Fluctuating customer purchasing behavior, seasonal trends, promotional campaigns, holidays, and external factors make inventory planning complex.

Poor demand forecasting can result in:

-  Stock shortages and lost sales
-  Excess inventory and higher storage costs
-  Increased operational expenses
-  Poor customer satisfaction
-  Inefficient inventory planning

To address these challenges, this project develops a Machine Learning-based demand forecasting system that predicts future product sales using historical retail data and business-related features.


##  Project Objectives

The primary objectives of this project are:

- Analyze historical retail sales data.
- Clean and preprocess multiple datasets.
- Generate business insights using SQL.
- Perform Exploratory Data Analysis (EDA).
- Build meaningful forecasting features.
- Develop a Machine Learning model for demand prediction.
- Evaluate model performance using regression metrics.
- Generate actionable business recommendations for inventory optimization.


##  Dataset

**Dataset Name:** Favorita Grocery Sales Forecasting

This project uses the **Favorita Grocery Sales Forecasting** dataset, which contains historical sales transactions from **Corporación Favorita**, one of the largest supermarket chains in Ecuador.

The dataset consists of approximately **1 million sales records** and combines multiple business datasets to perform demand forecasting and retail sales analysis.


### Dataset Files

| Dataset | Description |
|----------|-------------|
| train.csv | Historical daily sales data |
| stores.csv | Store information |
| items.csv | Product details |
| transactions.csv | Daily transaction counts |
| holidays_events.csv | Holiday and event information |
| oil.csv | Daily oil prices |


##  Business Questions Answered

This project answers several real-world retail business questions, including:

- Which products have the highest demand?
- Which stores generate the highest sales?
- How do promotions impact product demand?
- What is the effect of holidays on sales?
- Which product categories contribute the most revenue?
- How does demand vary across weekdays and weekends?
- Which products experience seasonal demand?
- What factors influence future product sales?


##  Tech Stack

| Category | Technologies |
|----------|--------------|
| Programming Language | Python |
| Database | PostgreSQL |
| Data Analysis | Pandas, NumPy |
| Data Visualization | Matplotlib, Seaborn |
| Machine Learning | Scikit-learn (Random Forest Regressor) |
| SQL | PostgreSQL |
| Development Environment | Jupyter Notebook / Kaggle Notebook |
| Version Control | Git & GitHub |


##  Python Libraries Used

- Pandas
- NumPy
- Matplotlib
- Seaborn
- Scikit-learn


##  Project Workflow

```text
Business Understanding
        │
        ▼
Data Collection
        │
        ▼
Data Cleaning & Preprocessing
        │
        ▼
SQL Business Analysis
        │
        ▼
Exploratory Data Analysis (EDA)
        │
        ▼
Feature Engineering
        │
        ▼
Model Building (Random Forest)
        │
        ▼
Model Evaluation
        │
        ▼
Business Recommendations
```

##  Data Cleaning & Preprocessing

To ensure high-quality data for analysis and model training, the following preprocessing steps were performed:

- Removed duplicate records.
- Handled missing values using appropriate techniques.
- Merged multiple datasets into a single master dataset.
- Converted date columns into datetime format.
- Extracted Year, Month, Day of Week, and Weekend features.
- Filled missing oil prices using forward-fill and backward-fill methods.
- Removed unnecessary columns that were not useful for forecasting.
- Sorted the dataset by Store, Item, and Date for time-series feature engineering.

The final cleaned dataset was used for both SQL analysis and Machine Learning.

##  Exploratory Data Analysis (EDA)

Exploratory Data Analysis was performed to understand customer demand patterns, sales trends, and business behavior before building the forecasting model.

### Analysis Performed

- Daily Sales Trend
- Monthly Sales Trend
- Sales Distribution
- Promotion Impact on Sales
- Holiday vs Non-Holiday Sales
- Store-wise Sales Analysis
- Product Family Performance
- Transaction Analysis
- Oil Price Trend
- Correlation Analysis
- Feature Relationship Analysis

These analyses helped identify important factors affecting product demand and guided the feature engineering process.



##  SQL Business Insights

More than **60 business-oriented SQL queries** were developed to answer real-world retail business questions.

### Key Insights Generated

- Daily Sales Trend
- Monthly Sales Trend
- Yearly Sales Trend
- Top 10 Selling Products
- Bottom 10 Selling Products
- Top Performing Stores
- Product Family Performance
- Promotion Effectiveness
- Holiday Impact Analysis
- Rolling 7-Day Average Demand
- Seasonal Demand Analysis
- Demand by Day of Week
- Demand by Month
- High Demand Products
- Low Demand Products
- Store-Level Performance Comparison

These SQL analyses helped uncover business trends and supported inventory optimization decisions.



##  Key Business Insights

The analysis revealed several important business findings:

- Promotional campaigns significantly increased product demand.
- Weekends experienced higher sales compared to weekdays.
- Some product families consistently outperformed others throughout the year.
- Sales demand showed clear seasonal patterns.
- High-traffic stores generated substantially more sales than low-performing stores.
- Historical sales trends were the strongest predictors of future demand.
- Inventory planning should prioritize products with consistently high demand.

##  Feature Engineering

To improve the forecasting performance, several business-driven features were engineered from the historical sales data.

### Features Created

| Feature | Description |
|----------|-------------|
| Lag-1 Sales | Previous day's sales |
| Rolling Mean (3 Days) | Average sales over the last 3 days |
| Transactions | Number of customer transactions |
| Oil Price | Daily oil price |
| Promotion Flag | Indicates whether the product was on promotion |
| Holiday Flag | Indicates whether the day was a holiday |
| Month | Month extracted from the date |
| Day of Week | Day extracted from the date |
| Weekend Indicator | Indicates whether the day was a weekend |

These features capture historical demand patterns and improve the predictive performance of the Machine Learning model.


#  Machine Learning Model

A **Random Forest Regressor** was developed to forecast future product demand.

### Why Random Forest?

- Captures complex non-linear relationships.
- Handles large retail datasets efficiently.
- Less prone to overfitting.
- Provides feature importance for model interpretation.
- Performs well without extensive parameter tuning.

The model was trained using engineered demand forecasting features and evaluated on unseen test data.


##  Model Performance

The model was evaluated using standard regression metrics.

| Metric | Score |
|---------|-------:|
| Mean Absolute Error (MAE) | **4.89** |
| Root Mean Squared Error (RMSE) | **11.01** |
| R² Score | **0.7263** |

### Performance Summary

- The model explains approximately **73% of the variation** in product demand.
- Historical sales and recent demand patterns were the strongest predictors.
- The model provides reliable demand forecasts that can support inventory planning and replenishment decisions.

##  Feature Importance

The Random Forest model identified the following features as the most influential for predicting product demand:

- Lag-1 Sales
- Rolling Mean (3 Days)
- Transactions
- Promotion Flag
- Oil Price
- Month
- Holiday Flag

These features highlight that recent sales history and business events play a significant role in forecasting future demand.

##  Project Visualizations

The project includes the following visualizations:

- Sales Trend Analysis
- Monthly Demand Trend
- Promotion Impact Analysis
- Holiday Sales Analysis
- Correlation Heatmap
- Feature Importance
- Actual vs Predicted Sales
- Residual Distribution

 ##  Business Recommendations

Based on the analysis and demand forecasting results, the following business recommendations are proposed:

- Maintain higher inventory levels for products with consistently high demand.
- Increase stock availability before weekends and promotional campaigns.
- Use demand forecasts to improve replenishment planning and reduce stockouts.
- Optimize promotional strategies by targeting products with high demand potential.
- Monitor low-performing products to reduce excess inventory and storage costs.
- Allocate inventory based on store-level demand patterns.
- Continuously update the forecasting model using newly available sales data.
>
 ##  Business Impact

This solution can help retail businesses:

-  Reduce stock shortages
-  Minimize excess inventory costs
-  Improve demand forecasting accuracy
-  Enhance product availability
-  Support data-driven inventory planning
-  Improve operational efficiency
-  Optimize supply chain decisions

##  Future Enhancements

Future improvements for this project include:

- Implement advanced models such as XGBoost and LightGBM.
- Develop a real-time demand forecasting pipeline.
- Build an interactive Streamlit web application.
- Integrate Power BI dashboards for business users.
- Deploy the model using Flask or FastAPI.
- Automate daily sales prediction using scheduled pipelines.

##  How to Run the Project

### Clone the Repository

```bash
git clone https://github.com/your-username/Retail-Demand-Forecasting.git
```

### Install Required Libraries

```bash
pip install -r requirements.txt
```

### Open the Notebook

```bash
jupyter notebook
```

or

Open the notebook directly in **Kaggle Notebook**.

Run all cells in sequence to reproduce the analysis and model results.


##  Author

**Yasmin Bano**

B.Tech – Computer Science & Engineering

Aspiring Data Analyst


If you found this project useful, don't forget to  this repository.
