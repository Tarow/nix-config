{
  username,
  email,
  dbLocation,
}: ''
  user_perm_uuid="$(uuid)"
  user_uuid="$(uuid)"
  user_name="${username}"
  user_email="${email}"
  podman exec authelia rm -f export.yml
  podman exec authelia authelia storage user identifiers export --file export.yml
  sub=$(podman exec authelia cat export.yml | yq '.identifiers[] | select(.username == "${username}") | .identifier')

  sqlite3 ${dbLocation} <<SQL

  DELETE FROM user_permission
  WHERE uuid IN (
      SELECT user_permission_uuid
      FROM user
      WHERE username = '$user_name'
  );
  DELETE FROM user WHERE username = '$user_name';

  INSERT INTO user_permission (
      uuid, book_create, book_read, book_process, book_download, book_list,
      user_create, user_list, user_read, user_delete, settings_update, book_delete,
      book_update, invite_list, invite_delete, user_update, collection_create
  ) VALUES (
      '$user_perm_uuid', 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
  );
  INSERT INTO user (
      id, user_permission_uuid, username, name, email
  ) VALUES (
      '$user_uuid',
      '$user_perm_uuid',
      '$user_name',
      '$user_name',
      '$user_email'
  );

  DELETE FROM account WHERE user_id = '$user_uuid';
  INSERT INTO account (id, user_id, type, provider, provider_account_id)
  VALUES (
      '$(uuid)',
      '$user_uuid',
      'oidc',
      'authelia',
      '$sub'
  );
  SQL
''
