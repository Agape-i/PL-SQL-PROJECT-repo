# Tablespace Configuration Verification
## Coffee Farmers Payment System
### Tablespaces Created
1. **COFFEE_DATA** 
   - Size: 200MB
   - Autoextend: ON (20MB increments)
   - Max Size: UNLIMITED
   - Purpose: Table data storage

2. **COFFEE_INDEX**
   - Size: 100MB  
   - Autoextend: ON (10MB increments)
   - Max Size: UNLIMITED
   - Purpose: Index storage

### Verification Queries Results

```sql
-- Tablespace Status
SELECT tablespace_name, status, contents 
FROM dba_tablespaces 
WHERE tablespace_name LIKE 'COFFEE%';

-- Autoextend Verification
SELECT file_name, tablespace_name, autoextensible, bytes/1024/1024 AS size_mb
FROM dba_data_files 
WHERE tablespace_name IN ('COFFEE_DATA', 'COFFEE_INDEX');
