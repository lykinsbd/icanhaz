bind = "0.0.0.0:5000"
chdir = "/app"

workers = 50
worker_class = "sync"
timeout = 300

accesslog = "-"
access_log_format = '%(t)s %(p)s %(h)s %({X-Forwarded-For}i)s %(l)s "%(r)s" %(s)s %(b)s "%(f)s"'

# Enable for SSL (Will need to also install SSL packages/extensions into the container if you choose to do this).
# keyfile = CERT_KEY_FILE
# certfile = CERT_FILE
# ca_certs = CERT_BUNDLE_FILE
# ssl_version = 5
# ciphers = "HIGH:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK"
