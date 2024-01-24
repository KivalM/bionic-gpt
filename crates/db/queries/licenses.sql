--! license : License(id?)
SELECT 
    id, tier
FROM 
    licenses
WHERE
    user_id = :user_id;

--! set_license_tier
UPDATE
    licenses
SET 
    tier = :tier
WHERE
    user_id = :user_id;

