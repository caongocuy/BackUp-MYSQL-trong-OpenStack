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
 
 - Để thực hiện được mục đích trên, thì sẽ có 2 cách để thực hiện.

###### a. Gỡ bỏ database trên node controller

####### Tư tưởng 