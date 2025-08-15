# App
Ứng dụng iOS giúp xem và tìm kiếm ảnh từ API Picsum.
Chức năng:
-	Load photo từ API picsum
-	Có hỗ trợ load more.
-	Pull Refresh(Pull list để thực hiện refresh nội dung)
-	Paging(mỗi page có 100 photo), có indicator 'loading...'
-	Cho phép tìm kiếm theo author hoặc id.
# Chức năng Paging/ load more
- Ấn mũi tên chuyển trang
- Vuốt ảnh xuống cuối để load more đến khi đủ 100 ảnh của page
# Mô tả chức năng Tìm kiếm
-	Độ dài nội dung tìm kiếm không vượt qá 15 kí tự.
-	Nội dung tìm kiếm không được nhập kí tự có dấu. Không cho phép nhập kí tự đặc biệt & emoji ngoại trừ !@#$%^&*():.,<>/\[]?.
-	Nếu copy paste phải tiến hành bỏ các kí tự sai validate. Cho phép tìm kiếm bằng swipe typing(có chú thích bên dưới)
# Mô hình
- Clean Architecture
# Design Pattern
- Singleton: NetworkMonitor, ImageLoader
- Observer Pattern: NetworkMonitor
# Chức năng không thực hiện:
- Cho phép tìm kiếm bằng swipe typing
-> Từ IOS 13: Đây là chức năng được setting trong Setting của máy là sẽ được hỗ trợ chứ không can thiệp được bằng code trừ khi custom bàn phím.
  Dự án hỗ trợ từ IOS 12 nên IOS 12 sẽ không sử dụng được chức năng này.

