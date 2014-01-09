# Be sure to restart your server when you modify this file.

#Msdn::Application.config.session_store :cookie_store, key: '_msdn_session'
Msdn::Application.config.session_store :active_record_store, key: '_msdn_session'
