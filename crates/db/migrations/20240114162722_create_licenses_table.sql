have -- migrate:up
create table licenses (
    id integer primary key not null generated always as identity,
    user_id integer not null references users(id),
    tier integer not null default 0,

    expires_at TIMESTAMPTZ not null default current_timestamp,
    created_at TIMESTAMPTZ not null default current_timestamp,
    updated_at TIMESTAMPTZ not null default current_timestamp
);

-- Helper functions for tenancy isolation 
CREATE FUNCTION get_tier() RETURNS INTEGER AS 
$$ 
    SELECT
        tier
    FROM
        licenses
    WHERE
        user_id = current_app_user()
    LIMIT 1
$$ LANGUAGE SQL;

COMMENT ON FUNCTION get_tier IS 
    'The license tier of the user.';

-- policies
CREATE POLICY select_models ON models FOR SELECT USING (tier <= get_tier());

-- create a function to create a license for a user
create or replace function create_license()
returns trigger as $$
begin
    insert into licenses (user_id, tier, expires_at) values (new.id, 0, current_timestamp + interval '1 month');
    return new;
end;

$$ language plpgsql;

-- create a trigger to create a license for a user when they sign up
create or replace trigger create_license
    after insert on users
    for each row
    execute procedure create_license();


GRANT SELECT, UPDATE, INSERT ON licenses TO bionic_application; 

-- Give access to the readonly user
GRANT SELECT ON licenses TO bionic_readonly;


alter table models enable row level security;

-- migrate:down
DROP TABLE licenses;
