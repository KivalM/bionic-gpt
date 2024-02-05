-- migrate:up
create table tiers (
    id serial primary key,
    name varchar(255) not null,
    description text not null,
    price integer not null,
    team_limit integer not null,
    created_at timestamp with time zone not null default current_timestamp,
    updated_at timestamp with time zone not null default current_timestamp
);

insert into tiers (name, description, price, team_limit) values ('Free', 'Free tier', 0, 3);
insert into tiers (name, description, price, team_limit) values ('Standard', 'Standard tier', 1000, 0);
insert into tiers (name, description, price, team_limit) values ('Enterprise', 'Enterprise tier', 10000, 0);



-- function and policy for insert into team_users depending on the license tier in the above table
CREATE OR REPLACE FUNCTION can_insert_user(team_id INT) RETURNS BOOLEAN AS $$
DECLARE
    team_limit INTEGER;
    team_count INTEGER;
BEGIN
    SELECT ti.team_limit INTO team_limit FROM tiers ti WHERE id = (SELECT tier FROM team_licenses li WHERE li.team_id = can_insert_user.team_id);
    SELECT count(*) INTO team_count FROM team_users tu WHERE tu.team_id = can_insert_user.team_id;
    -- display the team_limit and team_count for debugging
    RAISE NOTICE 'team_limit: %, team_count: %', team_limit, team_count;
    IF team_limit = 0 THEN
        RETURN TRUE;
    ELSE
        RETURN team_count < team_limit;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE POLICY insert_team_users ON team_users FOR INSERT with check (can_insert_user(team_id));

GRANT SELECT ON tiers TO bionic_application;
-- migrate:down

drop table tiers;
drop function can_insert_user;
drop policy insert_team_users;


