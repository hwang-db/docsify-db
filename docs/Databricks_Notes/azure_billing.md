### How to interpret Azure Databricks Cost Exported data

There are 2 types of costs incurred by using Azure Databricks:
1. DBU (Databricks Unit), and for different sku, DBU costs are different, e.g. standard vs. premium workspaces.
2. Underlying infrastructure cost: vm, storage, IO, NIC... the major cost of infra comes from VM.

In Azure, you can export cost and billing details to CSV files. You can also schedule these exports to your storage accounts.
These exported records let you analysis in the finest level of billing, and you can find DBU consumption.

For cost attribution and charge back, use tags, there are different level of tags, workspace tags, cluster tags, pool tags, see how to use them in official doc.

For trial ADB usage (14 days free premium dbu): DBU consumed will not appear in the exported cost data, therefore in customer POC, do not use trial premium workspace, because there's no way to find out how much DBU was consumed. Reverse calculation by using VM costs -> VM up time -> cluster up time -> cluster DBU consumption will not work as it's inaccurate, by experience there can be 20-30% error on DBU consumed. 
