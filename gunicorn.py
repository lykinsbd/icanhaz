bind = "0.0.0.0:5000"
chdir = "/app"

workers = 200
worker_class = "sync"
timeout = 300

accesslog = "-"
access_log_format = '%(t)s %(p)s %(h)s %({X-Forwarded-For}i)s %(l)s "%(r)s" %(s)s %(b)s "%(f)s"'

# Enable for SSL
# keyfile = CERT_KEY_FILE
# certfile = CERT_FILE
# ca_certs = CERT_BUNDLE_FILE
# ssl_version = 5
# ciphers = "HIGH:!aNULL:!eNULL:!EXPORT:!DES:!RC4:!3DES:!MD5:!PSK"
