-- migrate:up
create table team_licenses (
    id integer primary key not null generated always as identity,
    team_id integer unique not null references teams(id),
    tier integer not null default 1 references tiers(id),

    expires_at TIMESTAMPTZ not null default current_timestamp + interval '1 month',
    created_at TIMESTAMPTZ not null default current_timestamp,
    updated_at TIMESTAMPTZ not null default current_timestamp
);

-- policy for changing the tier of a team based on the user's role in the team
CREATE OR REPLACE FUNCTION is_team_administrator(user_id INT, team_id INT) RETURNS BOOLEAN AS $$
DECLARE
    is_admin BOOLEAN;
BEGIN
    SELECT EXISTS (
        SELECT 1
        FROM team_users tu
        WHERE tu.user_id = is_administrator.user_id
          AND tu.team_id = is_administrator.team_id
          AND 'TeamManager' = ANY(tu.roles)
    ) INTO is_admin;

    RETURN is_admin;
END;
$$ LANGUAGE plpgsql;

CREATE POLICY tier_change_policy
    ON team_licenses
    FOR UPDATE
    USING (is_team_administrator(current_app_user(), team_id));

-- policy for model access based on highest tier of team
CREATE OR REPLACE FUNCTION get_highest_team_tier(user_id INT) RETURNS INTEGER AS $$
DECLARE
    is_admin BOOLEAN;
    highest_tier INTEGER;
BEGIN
    IF current_app_user() IS NULL THEN
        RETURN 0;
    END IF;

    -- if the user is admin set the tier to 100
 
    SELECT system_admin
        FROM users u  
    WHERE u.id = get_highest_team_tier.user_id
        AND u.system_admin = true  
    INTO is_admin;

    IF is_admin THEN
        RETURN 100;
    END IF;


    SELECT COALESCE(MAX(l.tier), 0)
    INTO highest_tier
    FROM team_users tu
    JOIN team_licenses l ON tu.team_id = l.team_id
    WHERE tu.user_id = get_highest_team_tier.user_id;

    RETURN highest_tier;
END;
$$ LANGUAGE plpgsql;

CREATE POLICY select_models ON models FOR SELECT USING (is_app_user_sys_admin() or tier <= get_highest_team_tier(current_app_user()));


-- create a function to create a license for a user
create or replace function create_license()
returns trigger as $$
begin
    insert into team_licenses (team_id, tier, expires_at) values (new.id, 1, current_timestamp + interval '1 month');
    return new;
end;

$$ language plpgsql;

-- create a trigger to create a license for a user when they sign up
create or replace trigger create_license
    after insert on teams
    for each row
    execute procedure create_license();


GRANT SELECT, UPDATE, INSERT ON team_licenses TO bionic_application; 

-- Give access to the readonly user
GRANT SELECT ON team_licenses TO bionic_readonly;


alter table models enable row level security;

-- migrate:down
DROP TABLE team_licenses;
DROP FUNCTION is_team_administrator;
DROP POLICY tier_change_policy ON team_licenses;
DROP FUNCTION get_highest_team_tier;
DROP POLICY select_models ON models;
DROP FUNCTION create_license;
DROP TRIGGER create_license ON teams;

alter table models disable row level security;
