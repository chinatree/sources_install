# vhost: lb.guimi.oa.com
upstream fdfsdfs_g01 {
        server 192.168.2.13:80 weight=1 max_fails=2 fail_timeout=30s;
        server 192.168.2.14:80 weight=1 max_fails=2 fail_timeout=30s;
}
server{
    listen 80;
    server_name lb.guimi.oa.com;
    access_log /usr/local/services/nginx/logs/lb.guimi.oa.com.access.log;
    error_log /usr/local/services/nginx/logs/lb.guimi.oa.com.error.log;
    charset utf-8;
    root /home/test/projects/lb.guimi.oa.com;
    index index.php;

    large_client_header_buffers 4 16k;
    client_max_body_size 300m;
    client_body_buffer_size 128k;
    proxy_connect_timeout 600;
    proxy_read_timeout 600;
    proxy_send_timeout 600;
    proxy_buffer_size 64k;
    proxy_buffers   4 32k;
    proxy_busy_buffers_size 64k;
    proxy_temp_file_write_size 64k;

    location ~ /g0([1-9]) {
        proxy_next_upstream http_502 http_504 error timeout invalid_header;
        proxy_set_header Host fastdfs.oa.yuntree.com;
        proxy_set_header X-Forward-For $remote_addr;
        proxy_pass http://fdfsdfs_g01;
    }

    location ~ (.*)\.php
    {
        include fcgi.conf;
        fastcgi_pass  127.0.0.1:9000;
        fastcgi_index index.php;

        add_header Cache-Control "no-cache, no-store, max-age=0, must-revalidate";
        add_header Pragma no-cache;
    }
}
