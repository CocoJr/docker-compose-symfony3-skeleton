### Installation

1. Create and customise our `.env` files using `.env.dist`
2. Create your own `crontab` in `engine` using `engine/crontab.dist`
3. Clone your symfony 3 project into `volumes/app`
4. Update the `parameters.yml.dist` of the symfony project and use `'%env(ENV_VAR)'` to use full advantages of .env file
5. Launch it with `docker-compose up --build` (use `-d` option to launch in background)
6. Run `docker-compose exec engine bash` to access the PHP container and setup the project

### HTTPS support

For HTTPS support, you need to install nginx in your host machine, and use it like a reverse-proxy. This is an example of server configuration file with http redirect to https and certbot support. You can obtain a certificat with `certbot-auto certonly --webroot --webroot-path /var/www/html -n -d example.com`. Don't forget to install certbot-auto before ...

```
server {
    listen 80;
    server_name example.com;

    location /.well-known {
        alias /var/www/html/.well-known;
    }

    location / {
        return 301 https://example.com$request_uri;
    }
}

server {
    listen 443 ssl;
    server_name example.com;

    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    location / {
        proxy_set_header   X-Real-IP $remote_addr;
        proxy_set_header   Host      $http_host;
        proxy_pass         http://127.0.0.1:1333;
    }
}
```

### Package

 - Nginx for the backend (host: backend)
 - php7-fpm for the engine (host: engine)
 - mysql 5.7 for the database (host: db)
 - redis 3.0 for the server cache (host: redis)
 - RabbitMQ for the queuing messaging (host: rabbit)
