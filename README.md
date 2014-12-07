BackUp Mysql và đồng bộ mysql trong OpenStack
======
#### 1. Đặt vấn đề
Là người làm việc trực tiếp với dữ liệu máy tính chắc hẳn ai cũng hiểu mức độ quan trọng của dữ liệu đối với cá nhân,
 tổ chức mình như thế nào. Vậy vấn đề đặt ra là, chúng ta đã làm gì để bảo vệ được dữ liệu đó trước khi có một sự cố 
 ngoài ý muốn xảy ra làm ngưng trệ hoạt động cả một hệ thống. Khi chúng ta chưa phải đối mặt với vấn đề mất đi những 
 dữ liệu cực kỳ quan trọng thì trong chúng ta có rất nhiều người còn thờ ơ với việc sao lưu dự phòng dữ liệu. Họ cho 
 rằng sao lưu dữ liệu chỉ là việc thừa và mất thời gian! Đó thực sự là một suy nghĩ sai lầm. Còn bạn thì sao? Hãy sao 
 lưu dữ liệu để bảo vệ và tiết kiệm công sức cho chính mình đối với sự an toàn của dữ liệu, của công việc. Hãy đề phòng 
 ngay từ bây giờ để đảm bảo công việc của bạn được thuận lợi. 

#### 2. Mô hình áp dụng 
![img](http://i.imgur.com/jva5bSp.png "img")

 - Trong mô hình này, database ban đầu được lưu trên node controller, yêu cầu là phải đồng bộ database sang node db-galera (trong bài
 viết này, tôi sẽ không nói đến vấn đề cài đặt OpenStack, mà mặc nhiên là đã có 1 hệ thống OpenStack ổn định rồi).
 
#### 3. Thực hiện
Để thực hiện được mục đích trên, thì sẽ có 2 hướng giải quyết.

###### a. Gỡ bỏ mysql

Tư tưởng :
Trước khi gỡ bỏ Mysql trên node controller, thực hiện export các database ra trước, nhằm mục đích sau này import trở lại. 
Sau khi thực hiện xong chúng ta bắt đầu việc gỡ mysql ra khỏi controller, sở dĩ phải gỡ ra là vì phiên bản mysql trên node controller
là mysql-server thuần túy, không thực hiện được việc đồng bộ database khi sử dụng galera, mà phải là mysql-server-wsrep. Sau khi
gỡ bỏ hết, ta cài đặt mysql-server-wsrep và galera, cấu hình đồng bộ database với node db-galera, sau đó import database trở lại.

Thực hiện : TRÊN NODE CONTROLLER

B1: Export databases

    mysqldump -u root -pWelcome123 --all-databases > nodedb.sql

B2: Gỡ Mysql : chạy file shell "uninstallmysql" để gỡ

B3: Chạy file shell "2-caidat" để cài đặt mysql-server-wsrep và galera

B4: Chạy file shell "3-cauhinhmysql" để thực hiện cấu hình trong file my.conf

Thực hiện : TRÊN NODE DB_GALERA

B1: Chạy file shell "1-ip" để cấu hình ip và hostname, chú ý cần sửa file "config.cfg" để có ip phù hợp

B2: Chạy file shell "2-caidat" để cài đặt

B3: chạy file shell "3-cauhinhmysql"

Kiểm tra
Sau khi đã thực hiện xong các bước trên, chúng ta login vào mysql kiểm tra cluster giữa 2 node. Sau đó thực hiện
import databases lại trên node controller.

    mysql -u root -pWelcome123$ < nodedb.sql
	
Kiểm tra đồng bộ databases.

###### b. Cài đè mysql

Tư tưởng :
Phiên bản mysql sử dụng trên node controller là mysql-server-5.5 thuần túy, tôi sẽ thực hiện việc cài đè bằng mysql-5.6 là phiên bản tương thích với galera 25.3.5 mà tôi sẽ sử dụng để đồng bộ database. Trước khi thực hiện chúng ta nên
export database ra để sau khi thực hiện xong import lại tránh không bị mất dữ liệu khi cài đè.

Thực hiện : TRÊN NODE DB_GALERA

Thực hiện tương tự như trên

Thực hiện : TRÊN NODE CONTROLLER

B1 : Thực hiện cài đặt các thành phần của mysql5.6

    apt-get install mysql-server-5.6 mysql-client-5.6 mysql-client-core-5.6
	
B2 : Tải gói deb mysql-server-wsrep, galera và giải nén

    wget https://launchpad.net/galera/3.x/25.3.5/+download/galera-25.3.5-amd64.deb
    wget https://launchpad.net/codership-mysql/5.6/5.6.16-25.5/+download/mysql-server-wsrep-5.6.16-25.5-amd64.deb
    apt-get install libssl0.9.8
    dpkg -i galera-25.3.5-amd64.deb
    dpkg --force-all -i mysql-server-wsrep-5.6.16-25.5-amd64.deb

B3 : Tạo và phân quyền cho thư lục log ##

    mkdir -p /var/log/mysql && chown -R mysql. /var/log/mysql

B4 : Khởi động dịch vụ MYSQL ##

    /etc/init.d/mysql start
	
B5 : Đăng nhập và thực hiện cấu hình cơ bản ##

    mysql -u root
    DELETE FROM mysql.user WHERE user='';
    GRANT USAGE ON *.* TO root@'%' IDENTIFIED BY 'Welcome123$';
    GRANT USAGE ON *.* TO root@'localhost' IDENTIFIED BY 'Welcome123$';
    UPDATE mysql.user SET Password=PASSWORD('Welcome123$') WHERE User='root';
	
B6 : Cấu hình cluster

    vi /etc/mysql/conf.d/wsrep.cnf
	
- line 41: wsrep_provider=/usr/lib/galera/libgalera_smm.so

- line 51: wsrep_cluster_address="gcomm://"

- line 30: bind-address=0.0.0.0

- line 58: wsrep_node_address=172.16.69.181 (Bỏ comment và thêm ip cua node controller)
	
B7 : Khởi động lại mysql

    service mysql restart
	
Chú ý:
 Sau khi khởi động lại mysql trên node controller, thì ngay sau đó cũng phải khởi động lại mysql trên node DB_GALERA. Khởi động
xong quay lại node controller sửa file "wsrep.cnf" dòng 51 thêm ip của node DB_GALERA (tương tự trên node DB_GALERA), sau đó khởi động
lại mysql.

B8 : Chạy file shell "cauhinhmysql"

B9 : Sau khi import databases trở lại, ta kiểm tra sự đồng bộ của database.