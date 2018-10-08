# To Do

## 2FA branch

- [x] changes to login page to request a 2FA code
- [ ] test that the 2FA field is shown, accepts input, and allows users to log in with a valid 2FA code/shows an error without one (if required)
- [ ] expose settings to allow users to enable/disable

	this probably follows on Settings page work going on in Import-Export branch

- [ ] generate QR codes for scanning with Google Authenticator etc.
- [ ] backup codes
* environment setup
- [ ] encryption key is stored in Rails.application.config.twofactor_key

	adding this to config/init/secret_token.rb will work

## Import-export branch

- [ ] JSON export
- [ ] Settings page

   For this branch, this will expose the ability to download the user's data as CSV; over on the 2FA branch it will include enabling/disabling 2FA
