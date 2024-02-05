--! get_tier : Tier(id?)
SELECT 
    *
FROM 
    tiers
WHERE
    id = (SELECT tier from  team_licenses where team_id = :team_id);

