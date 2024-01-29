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
    SELECT t.team_limit, COUNT(tu.id)
    INTO team_limit, team_count
    FROM tiers t
    JOIN team_licenses l ON t.id = l.tier
    JOIN team_users tu ON l.team_id = tu.team_id
    WHERE tu.team_id = can_insert_user.team_id
    GROUP BY t.team_limit;

    RETURN team_count < team_limit OR team_limit = 0;
    
END;
$$ LANGUAGE plpgsql;

CREATE POLICY insert_team_users ON team_users FOR INSERT with check (can_insert_user(team_id));


-- migrate:down

