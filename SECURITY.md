# Security

## Reporting a problem

If you find a security problem in a BuildexLabsAI repository, such as a leaked secret, a
vulnerability, or data exposed that should not be, tell the organization owner
([@eskokoivula](https://github.com/eskokoivula)) directly. Do not open an issue or a pull
request about it, because other people can read those.

## A secret was committed

1. Rotate it first: revoke the key or token and create a new one. Deleting the file does not
   remove the secret from git history.
2. Then remove it from the code and tell the organization owner.
