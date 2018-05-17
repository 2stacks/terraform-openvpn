version: '3.2'

services:

  ovpn:
    image: "2stacks/docker-ovpn:${ovpn_label}"
    ports:
      - "443:443"
      - "1194:1194/udp"
    volumes:
      - "./configs/ovpn:/etc/openvpn"
    environment:
      - RADIUS_HOST=${radius_host}
      - RADIUS_KEY=${radius_key}
      - DNS_HOST1=${dns_host1}
      - DNS_HOST2=${dns_host2}
      - OVPN_DEBUG=${ovpn_debug}
    cap_add:
      - NET_ADMIN
    restart: always
    networks:
      - backend

  freeradius:
    image: "2stacks/freeradius:${radius_label}"
    ports:
      - "1812:1812/udp"
      - "1813:1813/udp"
    environment:
      - DB_NAME=${mysql_database}
      - DB_HOST=${mysql_host}
      - DB_USER=${mysql_user}
      - DB_PASS=${mysql_passwd}
      - DB_PORT=3306
      - RADIUS_KEY=${radius_key}
      - RAD_CLIENTS=${radius_clients}
      - RAD_DEBUG=${rad_debug}
    depends_on:
      - mysql
    links:
      - mysql
    restart: always
    networks:
      - backend

  mysql:
    image: "mysql:${mysql_label}"
    command: mysqld --server-id=1
    ports:
      - "127.0.0.1:3306:3306"
    volumes:
      - "./configs/mysql/master/data:/var/lib/mysql"
      - "./configs/mysql/master/conf.d:/etc/mysql/conf.d"
      - "./configs/mysql/radius.sql:/docker-entrypoint-initdb.d/radius.sql"
    environment:
      - MYSQL_ROOT_PASSWORD=${mysql_root_passwd}
      - MYSQL_USER=${mysql_user}
      - MYSQL_PASSWORD=${mysql_passwd}
      - MYSQL_DATABASE=${mysql_database}
    restart: always
    networks:
      - backend

networks:
  backend:
    ipam:
      config:
        - subnet: 10.0.0.128/25
