--! license : License(id?)
SELECT 
    id, tier
FROM 
    team_licenses
WHERE
    team_id = :team_id;

--! set_license_tier
UPDATE
    team_licenses
SET 
    tier = :tier
WHERE
    team_id = :team_id;

