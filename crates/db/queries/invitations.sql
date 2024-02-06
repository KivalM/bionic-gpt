--: Invitation()

--! insert_invitation
INSERT INTO 
    invitations (
        team_id, 
        email, 
        first_name, 
        last_name, 
        invitation_selector, 
        invitation_verifier_hash, 
        roles)
    VALUES(
        :team_id, 
        :email, 
        :first_name, 
        :last_name, 
        :invitation_selector, 
        :invitation_verifier_hash, 
        :roles);

--! get_invitation : Invitation
SELECT
    id, 
    team_id, 
    email, 
    first_name, 
    last_name, 
    invitation_selector, 
    invitation_verifier_hash,
    roles,
    created_at
FROM 
    invitations 
WHERE
    invitation_selector = :invitation_selector;

--! delete_invitation
DELETE FROM
    invitations
WHERE
    email = :email
AND
    team_id = :team_id;

--! get_all : Invitation
SELECT  
    id, 
    email,
    first_name, 
    last_name, 
    invitation_selector, 
    invitation_verifier_hash,
    team_id,
    roles,
    created_at  
FROM 
    invitations 
WHERE team_id = :team_id;

--! get_invitations_by_email : Invitation
SELECT  
    id, 
    email,
    first_name, 
    last_name, 
    invitation_selector, 
    invitation_verifier_hash,
    team_id,
    roles,
    created_at
FROM
    invitations
WHERE email = :email;

--! get_invitations_by_email_with_invite_name_and_team_name : InvitationWithMeta()
SELECT  
    i.id, i.email, i.first_name, i.last_name, i.invitation_selector, i.invitation_verifier_hash, i.roles, i.created_at,
    t.name as team_name,
    u.email as team_owner
FROM
    invitations i
LEFT JOIN teams t ON i.team_id = t.id
LEFT JOIN users u ON t.created_by_user_id = u.id
WHERE i.email = :email;

