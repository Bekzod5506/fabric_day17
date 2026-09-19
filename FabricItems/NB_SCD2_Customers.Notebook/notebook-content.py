# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "262088fe-ff7f-490d-b2b8-9428900e759e",
# META       "default_lakehouse_name": "bronze_lakehouse",
# META       "default_lakehouse_workspace_id": "4031375f-1d22-4362-ab6f-14d47907152e",
# META       "known_lakehouses": [
# META         {
# META           "id": "262088fe-ff7f-490d-b2b8-9428900e759e"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

# Welcome to your new notebook
# Type here in the cell editor to add code!
df_initial = spark.read.format("csv") \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .load("Files/customers_initial.csv")

df_initial.show(5)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from pyspark.sql.functions import col, lit

df_scd2 = df_initial \
    .withColumn("effective_date", col("last_updated")) \
    .withColumn("expiry_date", lit("9999-12-31")) \
    .withColumn("is_current", lit(True))

df_scd2.show(5)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_scd2.write.format("delta").mode("overwrite").saveAsTable("dim_customer")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_delta = spark.read.format("csv") \
    .option("header", "true") \
    .option("inferSchema", "true") \
    .load("Files/customers_delta.csv")

df_delta.show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_current = spark.table("dim_customer").filter(col("is_current") == True)

df_compare = df_delta.alias("d").join(
    df_current.alias("c"),
    on="customer_id",
    how="inner"
).where(
    (col("d.loyalty_tier") != col("c.loyalty_tier")) |
    (col("d.credit_limit") != col("c.credit_limit")) |
    (col("d.city") != col("c.city")) |
    (col("d.country") != col("c.country"))
)

changed_ids = [row.customer_id for row in df_compare.select("d.customer_id").collect()]
print(changed_ids)
print(len(changed_ids))

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

from delta.tables import DeltaTable

dim_table = DeltaTable.forName(spark, "dim_customer")

dim_table.update(
    condition = col("customer_id").isin(changed_ids) & (col("is_current") == True),
    set = {
        "is_current": "false",
        "expiry_date": "'2025-06-08'"
    }
)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

df_new_versions = df_delta \
    .withColumn("effective_date", col("last_updated")) \
    .withColumn("expiry_date", lit("9999-12-31")) \
    .withColumn("is_current", lit(True))

df_new_versions.write.format("delta").mode("append").saveAsTable("dim_customer")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.sql("""
SELECT customer_id, loyalty_tier, credit_limit, effective_date, expiry_date, is_current
FROM dim_customer
WHERE customer_id = 'C004'
ORDER BY effective_date
""").show()

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }

# CELL ********************

spark.sql("""
SELECT customer_id, loyalty_tier
FROM dim_customer
WHERE effective_date <= '2025-06-05'
  AND expiry_date > '2025-06-05'
ORDER BY customer_id
""").show(50)

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
